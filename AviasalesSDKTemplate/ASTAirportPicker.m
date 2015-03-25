//
//  ASTAirportPicker.m
//  AviasalesSDKTemplate
//
//  Created by Seva Billevich on 23.09.13.
//  Copyright (c) 2013 Go Travel Un Limited. All rights reserved.
//

#import "ASTAirportPicker.h"

#import "ASTAirportPickerCell.h"
#import "ASTAirportPickerSearchingCell.h"
#import "ASTAirportPickerEmptyCell.h"

#define AST_PICKER_DEPARTURE_SECTIONS_NUMBER 2
#define AST_SF_SECTION_DEPARTURE_NEAREST 0
#define AST_SF_SECTION_DEPARTURE_HISTORY 1

#define AST_PICKER_RETURN_SECTIONS_NUMBER 1
#define AST_SF_SECTION_DESTINATION_HISTORY 0

#define AST_AIRPORTS_HISTORY [[AviasalesSDK sharedInstance] airportsSearchHistory]

@interface ASTAirportPicker ()

@end

@implementation ASTAirportPicker

- (id)initPickerWithMode:(ASTAirportPickerMode)pickerMode {
    self = [super initWithNibName:@"ASTAirportPicker" bundle:AVIASALES_BUNDLE];
    if (self) {
        _pickerMode = pickerMode;
        _searchResults = [[NSMutableArray alloc] init];
        _nearestAirports = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![AVIASALES_(@"AVIASALES_PICKER_PLACEHOLDER") isEqualToString:@"AVIASALES_PICKER_PLACEHOLDER"]) {
        self.searchDisplayController.searchBar.placeholder = AVIASALES_(@"AVIASALES_PICKER_PLACEHOLDER");
    }
    if (![AVIASALES_(@"AVIASALES_PICKER_CANCEL") isEqualToString:@"AVIASALES_PICKER_CANCEL"]) {
        [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitle:AVIASALES_(@"AVIASALES_PICKER_CANCEL")];
    }
    _pickerNearestState = ASTAirportPickerNearestStateSearching;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_pickerMode == ASTAirportPickerDeparture) {
        _pickerNearestState = ASTAirportPickerNearestStateSearching;
        [[AviasalesSDK sharedInstance] searchNearestAirportsWithCompletionBlock:^(NSArray *airports, NSError *error) {
            _pickerNearestState = ASTAirportPickerNearestStateIdle;
            [_nearestAirports setArray:airports];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        return 1;
    } else {
        if (self.pickerMode == ASTAirportPickerDeparture) {
            return AST_PICKER_DEPARTURE_SECTIONS_NUMBER;
        } else {
            return AST_PICKER_RETURN_SECTIONS_NUMBER;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        
        NSInteger resultsNumber = [_searchResults count];
        
        if (_pickerState != ASTAirportPickerStateIdle) {
            resultsNumber++;
        }
        
        return resultsNumber;
        
    } else {
        
        if (self.pickerMode == ASTAirportPickerDeparture && section == AST_SF_SECTION_DEPARTURE_NEAREST) {
            if (_pickerNearestState == ASTAirportPickerNearestStateIdle) {
                if ([_nearestAirports count] > 0) {
                    return [_nearestAirports count];
                } else {
                    return 1; //row for displaying "not found"
                }
            } else {
                return 1; //row for displaying searching process
            }
        } else if (section == AST_SF_SECTION_DEPARTURE_HISTORY || section == AST_SF_SECTION_DESTINATION_HISTORY) {
            return [AST_AIRPORTS_HISTORY count];
        }
        
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SearchingCellIdentifier = @"SearchingCell";
    static NSString *CellIdentifier = @"Cell";
    static NSString *EmptyCellIdentifier = @"EmptyCell";
    
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        if (indexPath.row == [_searchResults count]) {
            ASTAirportPickerSearchingCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchingCellIdentifier];
            if (cell == nil) {
                cell = [[AVIASALES_BUNDLE loadNibNamed:@"ASTAirportPickerSearchingCell" owner:self options:nil] objectAtIndex:0];
            }
            return cell;
        } else {
            ASTAirportPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[AVIASALES_BUNDLE loadNibNamed:@"ASTAirportPickerCell" owner:self options:nil] objectAtIndex:0];
            }
            
            AviasalesAirport *airport = [_searchResults objectAtIndex:indexPath.row];
            
            [self applyAirport:airport forCell:cell];
            
            return cell;
        }
    } else {
        if (self.pickerMode == ASTAirportPickerDeparture && indexPath.section == AST_SF_SECTION_DEPARTURE_NEAREST) {
            if (_pickerNearestState == ASTAirportPickerNearestStateIdle) {
                if ([_nearestAirports count] > 0) {
                    ASTAirportPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[AVIASALES_BUNDLE loadNibNamed:@"ASTAirportPickerCell" owner:self options:nil] objectAtIndex:0];
                    }
                    
                    AviasalesAirport *airport = [_nearestAirports objectAtIndex:indexPath.row];
                    
                    [self applyAirport:airport forCell:cell];
                    
                    return cell;
                } else {
                    ASTAirportPickerEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:EmptyCellIdentifier];
                    if (cell == nil) {
                        cell = [[AVIASALES_BUNDLE loadNibNamed:@"ASTAirportPickerEmptyCell" owner:self options:nil] objectAtIndex:0];
                    }
                    
                    cell.centerLabel.text = AVIASALES_(@"AVIASALES_NEARBY_ERROR");
                    
                    return cell;
                }
            } else {
                ASTAirportPickerSearchingCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchingCellIdentifier];
                if (cell == nil) {
                    cell = [[AVIASALES_BUNDLE loadNibNamed:@"ASTAirportPickerSearchingCell" owner:self options:nil] objectAtIndex:0];
                }
                return cell;
            }
        } else if (indexPath.section == AST_SF_SECTION_DEPARTURE_HISTORY || indexPath.section == AST_SF_SECTION_DESTINATION_HISTORY) {
            
            ASTAirportPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[AVIASALES_BUNDLE loadNibNamed:@"ASTAirportPickerCell" owner:self options:nil] objectAtIndex:0];
            }
            
            AviasalesAirport *airport = [AST_AIRPORTS_HISTORY objectAtIndex:indexPath.row];
            
            [self applyAirport:airport forCell:cell];
            
            return cell;
        }
    }

    return nil;
}

- (void)applyAirport:(AviasalesAirport *)airport forCell:(ASTAirportPickerCell *)cell {
    cell.cityLabel.text = airport.name;
    if ([airport.airportName length] == 0) {
        cell.airportLabel.text = AVIASALES_(@"AVIASALES_ANY_AIRPORT");
        [cell.allAirportBadge setHidden:NO];
        [cell.iataLabel setTextColor:[UIColor orangeColor]];
    } else {
        cell.airportLabel.text = airport.airportName;
        [cell.allAirportBadge setHidden:YES];
        [cell.iataLabel setTextColor:[UIColor grayColor]];
    }
    cell.iataLabel.text = airport.iata;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.tableView] && self.pickerMode == ASTAirportPickerDeparture) {
        if (section == AST_SF_SECTION_DEPARTURE_NEAREST) {
            return AVIASALES_(@"AVIASALES_NEARBY");
        } else if (section == AST_SF_SECTION_DEPARTURE_HISTORY && [AST_AIRPORTS_HISTORY count] > 0) {
            return AVIASALES_(@"AVIASALES_SEARCH_HISTORY");
        }
    } else if ([tableView isEqual:self.tableView] && self.pickerMode == ASTAirportPickerDestination && section == AST_SF_SECTION_DESTINATION_HISTORY &&[AST_AIRPORTS_HISTORY count] > 0) {
        return AVIASALES_(@"AVIASALES_SEARCH_HISTORY");
    }
    return @"";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView cellForRowAtIndexPath:indexPath].selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        [self.delegate picker:self didSelectAirport:[_searchResults objectAtIndex:indexPath.row]];
    } else if ([tableView isEqual:self.tableView]) {
        if (self.pickerMode == ASTAirportPickerDeparture && indexPath.section == AST_SF_SECTION_DEPARTURE_NEAREST) {
            [self.delegate picker:self didSelectAirport:[_nearestAirports objectAtIndex:indexPath.row]];
        } else {
            [self.delegate picker:self didSelectAirport:[AST_AIRPORTS_HISTORY objectAtIndex:indexPath.row]];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    void (^localCompletionBlock)(NSArray *, NSError *) = ^(NSArray *airports, NSError *error) {
        
        if (_pickerState == ASTAirportPickerStateSearchingLocal) {
            _pickerState = ASTAirportPickerStateIdle;
        }
        
        if (!error) {
            [_searchResults setArray:airports];
        } else {
            [_searchResults removeAllObjects];
        }
        [self.searchDisplayController.searchResultsTableView reloadData];
    };
    
    if (searchText.length > 2) {
        
        _pickerState = ASTAirportPickerStateSearchingLocalAndWeb;
        
        [[AviasalesSDK sharedInstance] searchAirportsWithString:searchText localCompletion:localCompletionBlock webCompletion:^(NSArray *airports, NSError *error) {
            if (!error) {
                
                _pickerState = ASTAirportPickerStateIdle;
                
                [_searchResults addObjectsFromArray:airports];
                [self.searchDisplayController.searchResultsTableView reloadData];
            }
        }];
    } else {
        
        _pickerState = ASTAirportPickerStateSearchingLocal;
        
        [[AviasalesSDK sharedInstance] searchAirportsWithString:searchText completion:localCompletionBlock];
    }
    
}

@end
