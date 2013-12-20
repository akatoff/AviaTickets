//
//  ASTSearchForm.m
//  AviasalesSDKTemplate
//
//  Created by Seva Billevich on 17.09.13.
//  Copyright (c) 2013 Go Travel Un Limited. All rights reserved.
//

#import "ASTSearchForm.h"

#import "ASTSearchFormDateCell.h"
#import "ASTSearchFormOptionsCell.h"

#import "ASTResults.h"

#import "ASTSearchParams.h"

#define AST_SF_TITLE AVIASALES_(@"AVIASALES_FORM_TITLE")
#define AST_SF_CLOSE_BUTTON_TEXT AVIASALES_(@"AVIASALES_CLOSE_BUTTON")
#define AST_SF_SEARCH_BUTTON_TEXT AVIASALES_(@"AVIASALES_SEARCH_BUTTON")
#define AST_SF_HEADER_HEIGHT 4.0f

#define AST_SF_SECTIONS_NUMBER 3
#define AST_SF_SECTION_CITIES 0
#define AST_SF_SECTION_DATES 1
#define AST_SF_SECTION_OPTIONS 2

#define AST_SF_CITIES_ROWS 2
#define AST_SF_ROW_FROM 0
#define AST_SF_ROW_TO 1

#define AST_SF_DATES_ROWS 2 + 1 * (_datePickerState != ASTDatePickerHidden)
#define AST_SF_ROW_DEPARTURE_DATE 0
#define AST_SF_ROW_DEPARTURE_PICKER 1
#define AST_SF_ROW_RETURN_DATE (1 + 1 * (_datePickerState == ASTDatePickerDeparture))
#define AST_SF_ROW_RETURN_PICKER 2

#define AST_SF_INDEX_PATH_DEPARTURE_AIRPORT [NSIndexPath indexPathForRow:AST_SF_ROW_FROM inSection:AST_SF_SECTION_CITIES]
#define AST_SF_INDEX_PATH_DESTINATION_AIRPORT [NSIndexPath indexPathForRow:AST_SF_ROW_TO inSection:AST_SF_SECTION_CITIES]

#define AST_SF_INDEX_PATH_DEPARTURE_DATE [NSIndexPath indexPathForRow:AST_SF_ROW_DEPARTURE_DATE inSection:AST_SF_SECTION_DATES]
#define AST_SF_INDEX_PATH_DEPARTURE_PICKER [NSIndexPath indexPathForRow:AST_SF_ROW_DEPARTURE_PICKER inSection:AST_SF_SECTION_DATES]
#define AST_SF_INDEX_PATH_RETURN_DATE [NSIndexPath indexPathForRow:AST_SF_ROW_RETURN_DATE inSection:AST_SF_SECTION_DATES]
#define AST_SF_INDEX_PATH_RETURN_PICKER [NSIndexPath indexPathForRow:AST_SF_ROW_RETURN_PICKER inSection:AST_SF_SECTION_DATES]

#define AST_SF_INDEX_PATH_OPTIONS [NSIndexPath indexPathForRow:0 inSection:AST_SF_SECTION_OPTIONS]

#define AST_SF_DATEPICKER_TAG 1

#define AST_SF_MAX_SEATS_NUMBER 9

typedef NS_ENUM(NSUInteger, ASTDatePickerState) {
    ASTDatePickerHidden,
    ASTDatePickerDeparture,
    ASTDatePickerReturn
};

@interface ASTSearchForm () {
    UITableView *_tableView;
    UIDatePicker *_datePicker;
    ASTDatePickerState _datePickerState;
    NSDateFormatter *_dateFormatter;
    
    UITableViewCell *_visiblePickerCell;
    
    ASTSearchParams *_searchParams;
}

@property (nonatomic, assign) BOOL launchedModally;

- (void)updateNearestAirport;
- (void)updateAirportAtIndexPath:(NSIndexPath *)indexPath withIATA:(NSString *)IATA;
@end

BOOL isCompatible() {
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending) {
        NSLog(@"Aviasales SDK Search Form needs iOS7 and higher to work correctly.");
        return NO;
    }
    return YES;
}

@implementation ASTSearchForm

+ (void)launchFromViewController:(UIViewController *)viewController withOriginIATA:(NSString *)originIATA destinationIATA:(NSString *)destinationIATA departureDate:(NSString *)departureDate returnDate:(NSString *)returnDate {
    
    if (!isCompatible) {
        return;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d-MM-yyyy"];
    
    NSDate *initialDepartureDate = [formatter dateFromString:departureDate];
    NSDate *initialReturnDate = [formatter dateFromString:returnDate];
    
    ASTSearchForm *searchForm = [[ASTSearchForm alloc] initWithNibName:@"ASTSearchForm" bundle:AVIASALES_BUNDLE];
    searchForm.launchedModally = YES;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchForm];
    [viewController presentViewController:nav animated:YES completion:^{
        [searchForm updateOrigin:originIATA];
        [searchForm updateDestination:destinationIATA];
        [searchForm updateDepartureDate:initialDepartureDate];
        [searchForm updateReturnDate:initialReturnDate];
    }];
}

+ (void)setMarker:(NSString *)marker andAPIToken:(NSString *)APIToken {
    [[AviasalesSDK sharedInstance] setMarker:marker];
    [[AviasalesSDK sharedInstance] setAPIToken:APIToken];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _searchParams = [ASTSearchParams sharedInstance];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollEnabled = NO;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_tableView];
    
    _datePickerState = ASTDatePickerHidden;
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"d MMMM ‘yy"];
    
    self.navigationItem.title = AST_SF_TITLE;
    
    if (self.launchedModally) {
        UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:AST_SF_CLOSE_BUTTON_TEXT style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
        self.navigationItem.leftBarButtonItem = closeBtn;
    }
    
    UIBarButtonItem *searchBtn = [[UIBarButtonItem alloc] initWithTitle:AST_SF_SEARCH_BUTTON_TEXT style:UIBarButtonItemStylePlain target:self action:@selector(showSearchResults)];
    self.navigationItem.rightBarButtonItem = searchBtn;
    
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    
    if (_searchParams.originIATA) {
        [self updateOrigin:_searchParams.originIATA];
    } else {
        [self updateNearestAirport];
    }
    
    if (_searchParams.destinationIATA) {
        [self updateDestination:_searchParams.destinationIATA];
    }
    
    _departureDate = _searchParams.departureDate;
    _returnDate = _searchParams.returnDate;
    if (_returnDate) {
        _returnFlight = YES;
    }
    
    int adultsNumber = [_searchParams.adultsNumber intValue];
    
    _adultsNumber = adultsNumber > 0 ? adultsNumber : 1;
    _childrenNumber = [_searchParams.childrenNumber intValue];
    _infantsNumber = [_searchParams.infantsNumber intValue];
    _travelClass = [_searchParams.travelClass intValue];
    
    UIButton *switcher = [UIButton buttonWithType:UIButtonTypeCustom];
    [switcher setFrame:CGRectMake(10.0f, 32.0f, 23.0f, 23.0f)];
    [switcher setImage:[UIImage imageWithContentsOfFile:[AVIASALES_BUNDLE pathForResource:@"switch_airports" ofType:@"png"]] forState:UIControlStateNormal];
    [switcher addTarget:self action:@selector(switchAirports) forControlEvents:UIControlEventTouchUpInside];
    [_tableView addSubview:switcher];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_datePickerState != ASTDatePickerHidden) {
        _datePickerState = ASTDatePickerHidden;
        [_tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return AST_SF_SECTIONS_NUMBER;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == AST_SF_SECTION_CITIES) {
        return AST_SF_CITIES_ROWS;
    } else if (section == AST_SF_SECTION_DATES) {
        return AST_SF_DATES_ROWS;
    } else if (section == AST_SF_SECTION_OPTIONS) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    UITableViewCell *cell;
    
    if ((_datePickerState == ASTDatePickerDeparture && [indexPath isEqual:AST_SF_INDEX_PATH_DEPARTURE_PICKER]) ||
        (_datePickerState == ASTDatePickerReturn && [indexPath isEqual:AST_SF_INDEX_PATH_RETURN_PICKER])) {
        cellIdentifier = @"datePickerCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            UIDatePicker *datePicker = [[UIDatePicker alloc] init];
            datePicker.datePickerMode = UIDatePickerModeDate;
            [cell addSubview:datePicker];
            [datePicker setTag:AST_SF_DATEPICKER_TAG];
            [datePicker setMinimumDate:[NSDate date]];
            [datePicker setMaximumDate:[NSDate dateWithTimeIntervalSinceNow:365*24*60*60]];
            [datePicker addTarget:self action:@selector(datePickerDidChangeDate:) forControlEvents:UIControlEventValueChanged];
        }
        
        if (indexPath.row == AST_SF_ROW_DEPARTURE_PICKER) {
            if (_departureDate) {
                [(UIDatePicker *)[cell viewWithTag:AST_SF_DATEPICKER_TAG] setDate:_departureDate animated:NO];
            }
        } else {
            UIDatePicker *picker = (UIDatePicker *)[cell viewWithTag:AST_SF_DATEPICKER_TAG];
            if (_returnDate) {
                [picker setDate:_returnDate animated:NO];
            }
            if (_departureDate) {
                [picker setMinimumDate:_departureDate];
            }
        }
        return cell;
        
    } else if ([indexPath isEqual:AST_SF_INDEX_PATH_RETURN_DATE] || [indexPath isEqual:AST_SF_INDEX_PATH_DEPARTURE_DATE]) {
        
        cellIdentifier = @"ASTSearchFormDateCell";
        ASTSearchFormDateCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[AVIASALES_BUNDLE loadNibNamed:cellIdentifier owner:self options:nil] firstObject];
            [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0f]];
            [cell.returnButton addTarget:self action:@selector(switchOneWay) forControlEvents:UIControlEventTouchUpInside];
        }
        if (indexPath.section == AST_SF_SECTION_DATES) {
            if (indexPath.row == AST_SF_ROW_DEPARTURE_DATE) {
                cell.textLabel.text = _departureDate ? [_dateFormatter stringFromDate:_departureDate] : AVIASALES_(@"AVIASALES_DEPARTURE_DATE");
                [cell.returnLabel setHidden:YES];
                [cell.returnButton setHidden:YES];
            } else if (indexPath.row == AST_SF_ROW_RETURN_DATE) {
                cell.textLabel.text = (_returnDate && _returnFlight) ? [_dateFormatter stringFromDate:_returnDate] : AVIASALES_(@"AVIASALES_RETURN_DATE");
                [cell.returnLabel setHidden:NO];
                [cell.returnLabel setText:AVIASALES_(@"AVIASALES_RETURN_FLIGHT")];
                [cell.returnButton setHidden:NO];
                [cell.returnButton setSelected:_returnFlight];
            }
        }
        return cell;
        
    } else if ([indexPath isEqual:AST_SF_INDEX_PATH_OPTIONS]) {
        
        cellIdentifier = @"ASTSearchFormOptionsCell";
        ASTSearchFormOptionsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[AVIASALES_BUNDLE loadNibNamed:cellIdentifier owner:self options:nil] firstObject];
        }
        
        cell.stepperAdults.value = _adultsNumber;
        cell.stepperChildren.value = _childrenNumber;
        cell.stepperInfants.value = _infantsNumber;
        
        cell.captionAdults.text = AVIASALES_(@"AVIASALES_PICKER_ADULTS");
        cell.captionChildren.text = AVIASALES_(@"AVIASALES_PICKER_CHILDREN");
        cell.captionInfants.text = AVIASALES_(@"AVIASALES_PICKER_INFANTS");
        
        cell.labelAdults.text = [NSString stringWithFormat:@"%d", _adultsNumber];
        cell.labelChildren.text = [NSString stringWithFormat:@"%d", _childrenNumber];
        cell.labelInfants.text = [NSString stringWithFormat:@"%d", _infantsNumber];
        
        [cell.classSelector setTitle:AVIASALES_(@"AVIASALES_TRAVEL_CLASS_0") forSegmentAtIndex:0];
        [cell.classSelector setTitle:AVIASALES_(@"AVIASALES_TRAVEL_CLASS_1") forSegmentAtIndex:1];
        
        cell.classSelector.selectedSegmentIndex = _travelClass;
        
        return cell;
        
    } else {
        
        cellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0f]];
        }
        
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        
        cell.indentationWidth = 10.0f;
        cell.indentationLevel = 1;
        
        cell.separatorInset = UIEdgeInsetsMake(0, 40.0f, 0, 0);
        
        if (indexPath.section == AST_SF_SECTION_CITIES) {
            if (indexPath.row == AST_SF_ROW_FROM) {
                cell.textLabel.text = _origin ? _origin.name : AVIASALES_(@"AVIASALES_ORIGIN");
            } else if (indexPath.row == AST_SF_ROW_TO) {
                cell.textLabel.text = _destination ? _destination.name : AVIASALES_(@"AVIASALES_DESTINATION");
            }
        }
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == AST_SF_SECTION_CITIES) {
        ASTAirportPicker *picker;
        if (indexPath.row == AST_SF_ROW_FROM) {
            picker = [[ASTAirportPicker alloc] initPickerWithMode:ASTAirportPickerDeparture];
            [picker setTitle:AVIASALES_(@"AVIASALES_ORIGIN")];
        } else if (indexPath.row == AST_SF_ROW_TO) {
            picker = [[ASTAirportPicker alloc] initPickerWithMode:ASTAirportPickerDestination];
            [picker setTitle:AVIASALES_(@"AVIASALES_DESTINATION")];
        }
        picker.delegate = self;
        [self.navigationController pushViewController:picker animated:YES];
    }
    
    if (indexPath.section == AST_SF_SECTION_DATES) {
    
        if ([indexPath isEqual:AST_SF_INDEX_PATH_RETURN_DATE] && !_returnFlight) {
            _returnFlight = !_returnFlight;
            [_tableView reloadRowsAtIndexPaths:@[AST_SF_INDEX_PATH_RETURN_DATE] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        NSInteger relatedState;
        NSInteger anotherState;
        NSIndexPath *relatedPickerIndexPath;
        NSIndexPath *anotherPickerIndexPath;
        if ([indexPath isEqual:AST_SF_INDEX_PATH_DEPARTURE_DATE]) {
            relatedState = ASTDatePickerDeparture;
            anotherState = ASTDatePickerReturn;
            relatedPickerIndexPath = AST_SF_INDEX_PATH_DEPARTURE_PICKER;
            anotherPickerIndexPath = AST_SF_INDEX_PATH_RETURN_PICKER;
        } else if ([indexPath isEqual:AST_SF_INDEX_PATH_RETURN_DATE]) {
            relatedState = ASTDatePickerReturn;
            anotherState = ASTDatePickerDeparture;
            relatedPickerIndexPath = AST_SF_INDEX_PATH_RETURN_PICKER;
            anotherPickerIndexPath = AST_SF_INDEX_PATH_DEPARTURE_PICKER;
        } else {
            return;
        }
        
        if (_datePickerState == relatedState) {
            _datePickerState = ASTDatePickerHidden;
            [_tableView deleteRowsAtIndexPaths:@[relatedPickerIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else if (_datePickerState == anotherState) {
            _datePickerState = ASTDatePickerHidden;
            [_tableView deleteRowsAtIndexPaths:@[anotherPickerIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            _datePickerState = relatedState;
            [_tableView insertRowsAtIndexPaths:@[relatedPickerIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            _visiblePickerCell = [_tableView cellForRowAtIndexPath:relatedPickerIndexPath];
        } else if (_datePickerState == ASTDatePickerHidden) {
            _datePickerState = relatedState;
            [_tableView insertRowsAtIndexPaths:@[relatedPickerIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            _visiblePickerCell = [_tableView cellForRowAtIndexPath:relatedPickerIndexPath];
        }
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (([indexPath isEqual:AST_SF_INDEX_PATH_DEPARTURE_PICKER] && _datePickerState == ASTDatePickerDeparture) ||
        ([indexPath isEqual:AST_SF_INDEX_PATH_RETURN_PICKER] && _datePickerState == ASTDatePickerReturn)) {
        return 216;
    } else if ([indexPath isEqual:AST_SF_INDEX_PATH_OPTIONS]) {
        return 142;
    } else {
        return 44;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == AST_SF_SECTION_CITIES) {
        return 0.1f;
    } else {
        return 7.0f;
    }
}


#pragma mark - Date picker delegate

- (void)datePickerDidChangeDate:(UIDatePicker *)datePicker {
    //to avoid picker set value in not related cell
    if (_visiblePickerCell != [[datePicker superview] superview]) {
        return;
    }
    
    if (_datePickerState == ASTDatePickerDeparture) {
        [self updateDepartureDate:datePicker.date];
    } else {
        [self updateReturnDate:datePicker.date];
    }
    
    [_searchParams save];
}

- (void)switchOneWay {
    _returnFlight = !_returnFlight;

    if (!_returnFlight) {
        _searchParams.returnDate = nil;
    } else {
        _searchParams.returnDate = _returnDate;
    }
    [_searchParams save];
    
    [_tableView reloadRowsAtIndexPaths:@[AST_SF_INDEX_PATH_RETURN_DATE] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (_datePickerState == ASTDatePickerReturn && !_returnFlight) {
        _datePickerState = ASTDatePickerHidden;
        [_tableView deleteRowsAtIndexPaths:@[AST_SF_INDEX_PATH_RETURN_PICKER] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Airport picker delegate

- (void)picker:(ASTAirportPicker *)picker didSelectAirport:(AviasalesAirport *)airport {
    if (picker.pickerMode == ASTAirportPickerDeparture) {
        _origin = airport;
        _searchParams.originIATA = _origin.iata;
        [_tableView reloadRowsAtIndexPaths:@[AST_SF_INDEX_PATH_DEPARTURE_AIRPORT] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (picker.pickerMode == ASTAirportPickerDestination) {
        _destination = airport;
        _searchParams.destinationIATA = _destination.iata;
        [_tableView reloadRowsAtIndexPaths:@[AST_SF_INDEX_PATH_DESTINATION_AIRPORT] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [[AviasalesSDK sharedInstance] updateHistoryWithAirport:airport];
    
    [_searchParams save];
}

#pragma mark - Options changing

- (void)stepperDidChangeValue:(UIStepper *)stepper {
    
    ASTSearchFormOptionsCell *cell = (ASTSearchFormOptionsCell *)[_tableView cellForRowAtIndexPath:AST_SF_INDEX_PATH_OPTIONS];
    
    if (stepper.tag == ASTStepperTypeAdults) {
        _adultsNumber = stepper.value;
        cell.labelAdults.text = [NSString stringWithFormat:@"%d", _adultsNumber];
        [ASTSearchParams sharedInstance].adultsNumber = @(_adultsNumber);
    } else if (stepper.tag == ASTStepperTypeChildren) {
        _childrenNumber = stepper.value;
        cell.labelChildren.text = [NSString stringWithFormat:@"%d", _childrenNumber];
        [ASTSearchParams sharedInstance].childrenNumber = @(_childrenNumber);
    } else if (stepper.tag == ASTStepperTypeInfants) {
        _infantsNumber = stepper.value;
        cell.labelInfants.text = [NSString stringWithFormat:@"%d", _infantsNumber];
        [ASTSearchParams sharedInstance].infantsNumber = @(_infantsNumber);
    }

    cell.stepperAdults.maximumValue = AST_SF_MAX_SEATS_NUMBER - _childrenNumber;
    cell.stepperChildren.maximumValue = AST_SF_MAX_SEATS_NUMBER - _adultsNumber;
    
    //number of infants must be less or equal to total number of adults and children
    cell.stepperInfants.maximumValue = _adultsNumber + _childrenNumber;
    
    if (_infantsNumber > cell.stepperInfants.maximumValue) {
        _infantsNumber = cell.stepperInfants.maximumValue;
        cell.stepperInfants.value = _infantsNumber;
        cell.labelInfants.text = [NSString stringWithFormat:@"%d", _infantsNumber];
        [ASTSearchParams sharedInstance].infantsNumber = @(_infantsNumber);
    }
    
    [[ASTSearchParams sharedInstance] save];

}

- (void)travelClassSelected:(UISegmentedControl *)segmentedControl {
    _travelClass = (int)segmentedControl.selectedSegmentIndex;
    
    _searchParams.travelClass = @(_travelClass);
    [_searchParams save];
}

#pragma mark - Airports

- (void)updateNearestAirport {
    [[AviasalesSDK sharedInstance] searchNearestAirportsWithCompletionBlock:^(NSArray *airports, NSError *error) {
        if (!error) {
            _origin = [airports firstObject];
            _searchParams.originIATA = _origin.iata;
            [_searchParams save];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadRowsAtIndexPaths:@[AST_SF_INDEX_PATH_DEPARTURE_AIRPORT] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        } else {
            _origin = nil;
        }
    }];
}

- (void)updateAirportAtIndexPath:(NSIndexPath *)indexPath withIATA:(NSString *)IATA {
    [[AviasalesSDK sharedInstance] requestAirportByIATA:IATA completion:^(AviasalesAirport *airport, NSError *error) {
        if (!error) {
            if ([indexPath isEqual:AST_SF_INDEX_PATH_DEPARTURE_AIRPORT]) {
                _origin = airport;
            } else if ([indexPath isEqual:AST_SF_INDEX_PATH_DESTINATION_AIRPORT]) {
                _destination = airport;
            } else {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        } else {
            _destination = nil;
        }
    }];
}

#pragma mark - Navigation bar buttons actions

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)showSearchResults {
    
    AviasalesSearchParams *params = [[AviasalesSearchParams alloc] init];
    
    params.originIATA = _searchParams.originIATA;
    params.destinationIATA = _searchParams.destinationIATA;
    params.departureDate = _searchParams.departureDate;
    params.returnDate = _searchParams.returnDate;
    params.returnFlight = _returnFlight;
    
    params.adultsNumber = [_searchParams.adultsNumber integerValue];
    params.childrenNumber = [_searchParams.childrenNumber integerValue];
    params.infantsNumber = [_searchParams.infantsNumber integerValue];
    params.travelClass = [_searchParams.travelClass integerValue];
    
    NSError *error = [params validate];
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:AVIASALES_(@"AVIASALES_ALERT_ERROR_TITLE") message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    __block ASTResults *resultsVC = [[ASTResults alloc] initWithNibName:@"ASTResults" bundle:AVIASALES_BUNDLE];
    
    [[AviasalesSDK sharedInstance] setDurationFormat:AVIASALES_(@"AVIASALES_DURATION_FORMAT")];
    
    [[AviasalesSDK sharedInstance] searchTicketsWithParams:params completion:^(AviasalesSearchResponse *response, NSError *error) {
        if (error) {
            [self performSelector:@selector(cancelSearchWithError:) withObject:error afterDelay:1.0f];
        } else {
            [resultsVC setResponse:response];
        }
    }];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:AVIASALES_(@"AVIASALES_BACK") style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.backBarButtonItem = backButton;
    
    [self.navigationController pushViewController:resultsVC animated:YES];
    
    [ASTSearchParams sharedInstance].origin = _origin;
    [ASTSearchParams sharedInstance].destination = _destination;
}

- (void)cancelSearchWithError:(NSError *)error {
    [self.navigationController popViewControllerAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:AVIASALES_(@"AVIASALES_ALERT_ERROR_TITLE") message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Other Actions

- (void)switchAirports {

    AviasalesAirport *previousOrigin = _origin;
    AviasalesAirport *previousDestination = _destination;
    
    _origin = previousDestination;
    _searchParams.originIATA = _origin.iata;
    
    _destination = previousOrigin;
    _searchParams.destinationIATA = _destination.iata;
    
    [_tableView reloadRowsAtIndexPaths:@[AST_SF_INDEX_PATH_DEPARTURE_AIRPORT, AST_SF_INDEX_PATH_DESTINATION_AIRPORT] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [_searchParams save];
}

- (void)updateOrigin:(NSString *)originIATA {
    _searchParams.originIATA = originIATA;
    [_searchParams save];
    [self updateAirportAtIndexPath:AST_SF_INDEX_PATH_DEPARTURE_AIRPORT withIATA:originIATA];
}

- (void)updateDestination:(NSString *)destinationIATA {
    _searchParams.destinationIATA = destinationIATA;
    [_searchParams save];
    [self updateAirportAtIndexPath:AST_SF_INDEX_PATH_DESTINATION_AIRPORT withIATA:destinationIATA];
}

- (void)updateDepartureDate:(NSDate *)departureDate {
    if (departureDate) {
        _searchParams.departureDate = departureDate;
    }
    if ([_searchParams.departureDate timeIntervalSinceNow] < 0) {
        _searchParams.departureDate = [NSDate date];
    }
    
    [_searchParams save];
    
    _departureDate = _searchParams.departureDate;
    
    if ([_departureDate timeIntervalSinceDate:_returnDate] > 0) {
        _returnDate = _departureDate;
        [_tableView reloadRowsAtIndexPaths:@[AST_SF_INDEX_PATH_RETURN_DATE] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [_tableView reloadRowsAtIndexPaths:@[AST_SF_INDEX_PATH_DEPARTURE_DATE] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)updateReturnDate:(NSDate *)returnDate {
    if (returnDate) {
        _searchParams.returnDate = returnDate;
    }
    if ([_searchParams.returnDate timeIntervalSinceDate:_searchParams.departureDate] < 0) {
        _searchParams.returnDate = [NSDate date];
    }
    
    [_searchParams save];
    
    _returnDate = _searchParams.returnDate;
    
    [_tableView reloadRowsAtIndexPaths:@[AST_SF_INDEX_PATH_RETURN_DATE] withRowAnimation:UITableViewRowAnimationNone];
}

@end
