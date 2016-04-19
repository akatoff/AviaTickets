//
//  JRSearchFormVC.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 14/01/14.
//
//

#import "ASInitialAirportsManager.h"
#import "ASStatKeeper.h"
#import "DateUtil.h"
#import "JRAirport.h"
#import "JRAirportPickerAirportObject.h"
#import "JRAirportPickerVC.h"
#import "JRAlert.h"
#import "JRAlertManager.h"
#import "JRC.h"
#import "JRDatePickerVC.h"
#import "JRFPPopoverController.h"
#import "JRHintViewController.h"
#import "JRLineViewWithPattern.h"
#import "JRMenuManager.h"
#import "JRPriceCalendarVC.h"
#import "JRSearchedAirportsManager.h"
#import "JRSearchFormComplexSearchTableView.h"
#import "JRSearchFormPassengerPickerVC.h"
#import "JRSearchFormSimpleSearchTableView.h"
#import "JRSearchFormTravelClassPickerVC.h"
#import "JRSearchFormVC.h"
#import "JRSearchInfo.h"
#import "JRSegmentedControl.h"
#import "JRSimplePopoverController.h"
#import "JRUserAirportsManager.h"
#import "JRUserSettings.h"
#import "JRVoiceSearchVC.h"
#import "Reachability.h"
#import "UIImage+ASUIImage.h"
#import "UIView+FadeAnimation.h"
#import "AS-Swift.h"
#import "JRNavigationController.h"
#if JR == 1
#import "JROfferASViewController.h"
#endif

#define kJRSearchFormSegmentLabelFontiPhone                         [UIFont fontWithName:@"HelveticaNeue-Medium" size:18]
#define kJRSearchFormAirportsFraction                               (iPhone() ? 0.39 : 0.35)
#define kJRSearchFormAnimationAnimationInitialSpringVelocity        1
#define kJRSearchFormAnimationStartAlpha                            0.3
#define kJRSearchFormAnimationAnimationUsingSpringWithDamping       0.8
#define kJRSearchFormAnimationDuration                              0.35
#define kJRSearchFormReloadingAnimationDuration                     0.6
#define kJRSearchFormCalendarButtonAnimationDuration                0.5
#define kJRSearchFormCalendarButtonAnimationInitialSpringVelocity   1
#define kJRSearchFormCalendarButtonAnimationUsingSpringWithDamping  0.6
#define kJRSearchFormCalendarButtonWidth                            45
#define kJRSearchFormTableViewAddCellHeight                           36
#define kJRSearchFormTableViewComplexCellHeightIPHONE                 46
#define kJRSearchFormTableViewComplexCellHeightIPAD                   64
#define kJRSearchFormDatesFraction                                  (iPhone() ? 0.31 : 0.3)
#define kJRSearchFormSearchButtonToCalendarButtonMargin             10
#define kJRSearchFormCellFromTableInCellFraction                    0.5
#define kJRSearchFormPassengersPopoverSize                          CGSizeMake(280, 280)

typedef NS_ENUM (NSUInteger, JRSearchFormMode) {
	JRSearchFormModeSimple,
	JRSearchFormModeComplex
};

@interface JRSearchFormVC ()<JRSegmentedControlDelegate, JRSearchFormItemDelegate, FPPopoverControllerDelegate, JRSearchFormPassengerPickerViewDelegate, JRSearchFormTravelClassPickerDelegate, SearchPrefillerDelegate>

@property (assign, nonatomic) JRSearchFormMode searchFormMode;
@property (strong, nonatomic) JRFPPopoverController *popover;
@property (strong, nonatomic) JRSearchInfo *searchInfo;
@property (strong, nonatomic) JRSegmentedControl *segmentedControl;
@property (strong, nonatomic) JRTravelSegment *savedTravelSegment;
@property (strong, nonatomic) NSLayoutConstraint *simpleSearchTableLeadingConstaint;
@property (strong, nonatomic) NSLayoutConstraint *travelClassAndPassengersLeadingTableViewConstraint;
@property (strong, nonatomic) NSLayoutConstraint *travelClassAndPassengersLeadingViewConstraint;
@property (weak, nonatomic) IBOutlet JRSearchFormComplexSearchTableView *complexSearchTable;
@property (weak, nonatomic) IBOutlet JRSearchFormSimpleSearchTableView *simpleSearchTable;
@property (weak, nonatomic) IBOutlet JRSearchFormSimpleSearchTableView *travelClassAndPassengersTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarWidthButtonConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchButtonToCalendarButtonMarginConstraint;
@property (weak, nonatomic) IBOutlet UIButton *calendarButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIImageView *datesCellBackground;
@property (weak, nonatomic) IBOutlet UIView *complexTableFooter;
@property (weak, nonatomic) IBOutlet UIView *passengerPopoverFromView;
@property (weak, nonatomic) IBOutlet UIView *segmentedControlContainer;
@property (weak, nonatomic) IBOutlet UIView *errorMessageFromView;
@property (nonatomic) JRSearchSource searchSource;

@end

@implementation JRSearchFormVC

#pragma mark - ViewController Setup

void * JRComplexTableSizeChangeContext = &JRComplexTableSizeChangeContext;

- (IBAction)startSearchAction:(id)sender
{
    JRFPPopoverController *errorPopover = [self getErrorPopover];
    if (errorPopover) {
        [self showErrorPopover:errorPopover];
        return;
    }
    
	[self clipSearchInfoIfNeeds];
    
	[[JRMenuManager sharedInstance] startNewSearchWithSearchInfo:_searchInfo andSearchSource:_searchSource ? _searchSource : JRSearchSourceSearchForm];
    
    [[ASStatKeeper sharedInstance] logGTMGoal:GTM_GOAL_SEARCH params:[ASStatKeeper GTMDictionaryForSearchInfo:_searchInfo]];
    [[ASStatKeeper sharedInstance] trackSearch];
}


- (JRFPPopoverController *)getErrorPopover {
    JRFPPopoverController *emptyOriginErrorPopover = [[JRAlertManager sharedManager] messagePopoverWithType:JRMessagePopoverTypeSearchFormEmptyOriginError withStringParams:nil andUnderlyingView:self.view];
    
    if (_searchInfo.travelSegments.count == 0) {
        return emptyOriginErrorPopover;
    }
    
    for (JRTravelSegment *travelSegment in _searchInfo.travelSegments) {
        if (_searchFormMode == JRSearchFormModeSimple && [_searchInfo.travelSegments indexOfObject:travelSegment] == 1) {
            return nil;
        }
        if (travelSegment.originIata == nil) {
            return emptyOriginErrorPopover;
        } else if (travelSegment.destinationIata == nil) {
            return [[JRAlertManager sharedManager] messagePopoverWithType:JRMessagePopoverTypeSearchFormEmptyDestinationAirportError withStringParams:nil andUnderlyingView:self.view];
        } else if ([[ASInitialAirportsManager mainIATAByIATA:travelSegment.originIata]
                    isEqualToString:[ASInitialAirportsManager mainIATAByIATA:travelSegment.destinationIata]]) {
            return [[JRAlertManager sharedManager] messagePopoverWithType:JRMessagePopoverTypeSearchFormSameCityError withStringParams:nil andUnderlyingView:self.view];
        } else if (travelSegment.departureDate == nil) {
            return [[JRAlertManager sharedManager] messagePopoverWithType:JRMessagePopoverTypeSearchFormEmptyDepartureAirportError withStringParams:nil andUnderlyingView:self.view];
        }
    }
    return nil;
}

- (void)showErrorPopover:(JRFPPopoverController *)popover
{
    if (!popover) {
        return;
    }
    
    [popover presentPopoverFromView:_errorMessageFromView];
    
    __weak JRFPPopoverController *weakError = popover;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakError dismissPopoverAnimated:YES];
    });
}

- (void)clipSearchInfoIfNeeds
{
	if (_searchFormMode == JRSearchFormModeSimple) {
		[_searchInfo clipSearchInfoForSimpleSearchIfNeeds];
	} else if (_searchFormMode == JRSearchFormModeComplex) {
		[_searchInfo clipSearchInfoForComplexSearchIfNeeds];
	}
	[self reloadSearchFormAnimated:NO];
}

- (void)setupTableViews
{
	JRSearchFormItem *airports = [[JRSearchFormItem alloc] initWithType:JRSearchFormTableViewItemAirportsType itemDelegate:self];
	JRSearchFormItem *dates = [[JRSearchFormItem alloc] initWithType:JRSearchFormTableViewItemDatesType itemDelegate:self];
	[_simpleSearchTable setItems:@[airports, dates]];
	[_simpleSearchTable reloadData];
    
	JRSearchFormItem *travelClassAndPassengers = [[JRSearchFormItem alloc] initWithType:JRSearchFormTableViewItemTravelClassAndPassengersType itemDelegate:self];
	[_travelClassAndPassengersTable setItems:@[travelClassAndPassengers]];
	[_travelClassAndPassengersTable reloadData];
    
	_travelClassAndPassengersLeadingViewConstraint = JRConstraintMake(_travelClassAndPassengersTable, NSLayoutAttributeLeft, NSLayoutRelationEqual, self.view, NSLayoutAttributeLeft, 1, 0);
	_travelClassAndPassengersLeadingTableViewConstraint = JRConstraintMake(_travelClassAndPassengersTable, NSLayoutAttributeLeft, NSLayoutRelationEqual, _simpleSearchTable, NSLayoutAttributeLeft, 1, 0);
	[_travelClassAndPassengersLeadingViewConstraint setPriority:UILayoutPriorityRequired];
	[_travelClassAndPassengersLeadingTableViewConstraint setPriority:UILayoutPriorityDefaultHigh];
	[self.view addConstraint:_travelClassAndPassengersLeadingViewConstraint];
	[self.view addConstraint:_travelClassAndPassengersLeadingTableViewConstraint];
    
	[_complexSearchTable setTravelClassAndPassengers:_travelClassAndPassengersTable];
	[_complexSearchTable setTravelClassAndPassengersConstraint:_travelClassAndPassengersLeadingViewConstraint];
	[_complexSearchTable setItemDelegate:self];
    
	UIImageView *footer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JRBasePatternedGradient"]];
	[footer setTranslatesAutoresizingMaskIntoConstraints:NO];
	[_complexTableFooter addSubview:footer];
	[_complexTableFooter addConstraints:JRConstraintsMakeScaleToFill(footer, _complexTableFooter)];
	[_complexTableFooter setTransform:CGAffineTransformMakeScale(1,-1)];
    
	UIEdgeInsets edgeInsets = UIEdgeInsetsMake(3, 0, 3, 0);
    UIImage *datesBackground = [UIImage imageNamed:@"JRSearchFormDatesBackground"];
    UIImage *backgroundImage = [Aviasales() ? datesBackground : [datesBackground imageTintedWithColor:[JRC SF_DATES_BACKGROUND_TINT]]
	                            resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
	_datesCellBackground.image = backgroundImage;
}

- (void)setupButtons
{
	if (iPhone() && Aviasales()) {
		UIBarButtonItem *voiceSearchItem = [UINavigationItem barItemWithImageName:@"JRSearchFormVoiceBarButtonIcon" target:self action:@selector(showVoiceSearch)];
        voiceSearchItem.accessibilityLabel = NSLS(@"JR_SEARCH_FORM_VOICE_SEARCH_BTN_TITLE_ACC");
		[self.navigationItem setRightBarButtonItem:voiceSearchItem];
	}
	_searchButton.backgroundColor = _calendarButton.backgroundColor = nil;
    
	UIImage *searchBackgroundImage = [UIImage imageNamed:@"JRBaseOrangeButton"];
    
	[_searchButton setBackgroundImage:searchBackgroundImage forState:UIControlStateNormal];
	[_calendarButton setBackgroundImage:searchBackgroundImage forState:UIControlStateNormal];
	[_calendarButton.imageView setContentMode:UIViewContentModeCenter];
	[_calendarButton.imageView setClipsToBounds:NO];
}


- (void)setupSegmentedControl
{
	NSString *simpleTitleString = NSLS(@"JR_SEARCH_FORM_SIMPLE_SEARCH_SEGMENT_TITLE");
	NSString *complexTitleString = NSLS(@"JR_SEARCH_FORM_COMPLEX_SEARCH_SEGMENT_TITLE");
	NSString *voiceTitleString = NSLS(@"JR_SEARCH_FORM_VOICE_SEARCH_SEGMENT_TITLE");
    
    if (iPhone()) {
        simpleTitleString   = simpleTitleString.lowercaseString;
        complexTitleString  = complexTitleString.lowercaseString;
    } else {
        simpleTitleString   = simpleTitleString.uppercaseString;
        complexTitleString  = complexTitleString.uppercaseString;
        voiceTitleString    = voiceTitleString.uppercaseString;
    }
	NSMutableArray *items = [[NSMutableArray alloc] initWithArray:@[simpleTitleString, complexTitleString]];
    
	if (iPad() && Aviasales()) {
		[items addObject:voiceTitleString];
	}
    
	_segmentedControl = [[JRSegmentedControl alloc] initWithItems:items];
	[_segmentedControl setDelegate:self];
	[_segmentedControl setRibbonTintColor:[JRC SF_SEGMENTED_CONTROL_SEGMENT_RIBBON]];
	if (iPhone()) {
		[_segmentedControl setSegmentLabelFont:kJRSearchFormSegmentLabelFontiPhone];
		[_segmentedControl setBackgroundColor:[JRC SF_SEGMENTED_CONTROL_BACKGROUND_COLOR]];
		[_segmentedControl setSegmentTitleTintColor:[JRC SF_SEGMENTED_CONTROL_SEGMENT_TITLE_IPHONE]];
		[_segmentedControl setRibbonTintColor:[JRC SF_SEGMENTED_CONTROL_SEGMENT_RIBBON]];
        
	} else {
		[_segmentedControl setSegmentTitleTintColor:[JRC SF_SEGMENTED_CONTROL_SEGMENT_TITLE_IPAD]];
		[_segmentedControl setSegmentedControlStyle:JRSegmentedControlStyleDarkContent];
	}
    
	[_segmentedControlContainer addSubview:_segmentedControl];
	[_segmentedControlContainer setBackgroundColor:nil];
    
}

- (void)setSearchInfo:(JRSearchInfo *)searchInfoToCopy andSearchSource:(JRSearchSource)searchSource
{
    if (searchInfoToCopy == nil) {
        return;
    }
    JRSearchInfo *searchInfo = [searchInfoToCopy copyWithTravelSegmentsInContext:[NSManagedObjectContext MR_defaultContext]];
    [searchInfo setAdjustSearchInfo:YES];
	_searchInfo = searchInfo;
    while (_searchInfo.travelSegments.count <= 1) {
        JRTravelSegment *travelSegment = [JRTravelSegment MR_createInContext:_searchInfo.managedObjectContext];
        [_searchInfo addTravelSegment:travelSegment];
    }
    _searchSource = searchSource;
	[self reloadSearchFormAnimated:NO];
    [self adjustSearchFormMode];
    [self findOriginIfNeeds];
}

- (void)updateDeparureDatesIfNeeds {
    [_searchInfo cleanUp];
    
}

- (void)adjustSearchFormMode {
    if (_searchInfo.isComplexSearch) {
        [self setSearchFormMode:JRSearchFormModeComplex];
    } else {
        [self setSearchFormMode:JRSearchFormModeSimple];
    }
}

- (void)findOriginIfNeeds
{
    if ([[_searchInfo.travelSegments.firstObject originIata] isKindOfClass:[NSString class]] == NO) {
        [[SearchPrefiller sharedInstance] setDelegate:self];
        [[SearchPrefiller sharedInstance] tryToPrefill];
    } else {
        [[SearchPrefiller sharedInstance] setDelegate:nil];
    }
}

- (void)searchPrefillerCanPrefill:(SearchPrefill *)prefill {
    
    JRTravelSegment *directTravelSegment = _searchInfo.travelSegments.firstObject;
    JRTravelSegment *returnTravelSegment = nil;
    if (_searchInfo.travelSegments.count > 1) {
        returnTravelSegment = [_searchInfo.travelSegments objectAtIndex:1];
    }
    
    JRAirportPickerAirportObject *prefillOriginAirport = [ASInitialAirportsManager getAirportObjectByIATA:prefill.originIATA];
    JRAirportPickerAirportObject *prefillDestinationAirport = [ASInitialAirportsManager getAirportObjectByIATA:prefill.destinationIATA];
    
    if (directTravelSegment.originIata == nil) {
        
        if (directTravelSegment == nil) {
            directTravelSegment = [JRTravelSegment MR_createInContext:_searchInfo.managedObjectContext];
            [_searchInfo addTravelSegment:directTravelSegment];
        }
        
        if (directTravelSegment.originIata == nil) {
            directTravelSegment.originIata = prefill.originIATA;
            if (directTravelSegment.departureDate == nil) {
                directTravelSegment.departureDate = prefill.departureDate;
                if (directTravelSegment.destinationIata == nil &&
                    returnTravelSegment.departureDate == nil) {
                    
                    [directTravelSegment setDestinationIata:prefill.destinationIATA];
                    
                    if (returnTravelSegment == nil) {
                        returnTravelSegment = [JRTravelSegment MR_createInContext:_searchInfo.managedObjectContext];
                        [_searchInfo addTravelSegment:returnTravelSegment];
                    }
                    
                    [returnTravelSegment setOriginIata:prefill.destinationIATA];
                    [returnTravelSegment setDepartureDate:prefill.returnDate];
                    
                }
            }
        }
        
        [self reloadSearchFormAnimated:YES];
        
        [JRSearchedAirportsManager markSearchedAirport:prefillOriginAirport.dbAirport
                                   searchedAirportType:JRSearchedAirportDefaultType];
        
        [JRSearchedAirportsManager markSearchedAirport:prefillDestinationAirport.dbAirport
                                   searchedAirportType:JRSearchedAirportDefaultType];
        
    }
}

- (void)viewDidLoad
{
	[super viewDidLoad];

    [self.view setBackgroundColor:[JRC SF_BACKGROUND_COLOR]];
    
	NSString *titleString = NSLS(@"JR_SEARCH_FORM_TITLE");
	[self setTitle:titleString];
    
    
	[self setupTableViews];
	[self setupButtons];
	[self setupSegmentedControl];
    
	if (_searchInfo) {
        [self adjustSearchFormMode];
	} else {
		JRSearchInfo *searchInfoFromUserSettings = [JRSearchInfo lastUsedSearchInfo];
		JRSearchInfo *searchInfo = searchInfoFromUserSettings ? searchInfoFromUserSettings : [JRSearchInfo MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
		[self setSearchInfo:searchInfo andSearchSource:JRSearchSourceSearchForm];
    }
    
	[_calendarButton addTarget:self action:@selector(priceCalendarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
	[self findOriginIfNeeds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeChange:) name:UIApplicationSignificantTimeChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newAirportsParsed:) name:kASInitialAirportsManagerNewAirportsParsedNotificationName object:nil];
    _calendarButton.accessibilityLabel = NSLS(@"JR_SEARCH_FORM_CALENDAR_BTN_TITLE_ACC");
}

- (void)newAirportsParsed:(NSNotification *)note {
    [self reloadSearchFormAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self reloadSearchFormAnimated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{//fix GTM crash, maybe
        [[ASStatKeeper sharedInstance] logGTMScreen:GTM_SCREEN_SEARCH_FORM];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self offerAviasalesForRussianJetradarUsers];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	if (iPad()) {
		[self detachAccessoryViewControllerAnimated:NO];
	}
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showVoiceSearch {
    JRVoiceSearchVC *voiceVC = [JRVoiceSearchVC new];
    if (iPhone()) {
        [[[JRMenuManager sharedInstance] viewDeckController] setModalVC:voiceVC];
        
    } else {
        [[[JRMenuManager sharedInstance] mainScreenController] setModalVC:voiceVC];
        __weak JRSearchFormVC *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf setSearchFormMode:_searchFormMode animated:NO];
            [UIView addTransitionFadeToView:self.view duration:1];
        });
    }
}

- (void)timeChange:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
       [self reloadSearchForm];
    });
}

- (void)reloadSearchForm {
    if ([NSThread isMainThread]) {
        [self reloadSearchFormAnimated:NO];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadSearchFormAnimated:NO];
        });
    }
}

- (void)reloadSearchFormAnimated:(BOOL)animated
{
    [self updateDeparureDatesIfNeeds];
    
	[_simpleSearchTable reloadData];
	[_travelClassAndPassengersTable reloadData];
	[_complexSearchTable reloadData];
    
	if (animated) {
		NSTimeInterval duration = kJRSearchFormReloadingAnimationDuration;
		[UIView addTransitionFadeToView:_simpleSearchTable
                               duration:duration];
		[UIView addTransitionFadeToView:_travelClassAndPassengersTable
                               duration:duration];
		[UIView addTransitionFadeToView:_complexSearchTable
                               duration:duration];
	}
    
    if (JetRadar()) {
        UIButton *simpleModeButton = _segmentedControl.controlViews.firstObject;
        NSString *simpleModeButtonTitle = NSLS(@"JR_SEARCH_FORM_SIMPLE_SEARCH_ONE_WAY_SEGMENT_TITLE").lowercaseString;
        if ([_searchInfo.returnDateForSimpleSearch isKindOfClass:[NSDate class]]) {
            simpleModeButtonTitle = NSLS(@"JR_SEARCH_FORM_SIMPLE_SEARCH_ROUND_TRIP_SEGMENT_TITLE").lowercaseString;
        }
        if (iPad()) {
            simpleModeButtonTitle = simpleModeButtonTitle.uppercaseString;
        }
        [simpleModeButton setTitle:simpleModeButtonTitle forState:UIControlStateNormal];
    }
}

#pragma mark - Search Form Mode Selecting

- (void)setSearchFormMode:(JRSearchFormMode)searchFormMode
{
	[self setSearchFormMode:searchFormMode animated:NO];
}

- (void)setSearchFormMode:(JRSearchFormMode)searchFormMode animated:(BOOL)animated
{
	_searchFormMode = searchFormMode;
    
	if (_searchFormMode == JRSearchFormModeSimple) {
		[_segmentedControl selectSegmentAtIndex:0 animated:animated];
		[self selectSimpleSearchModeAnimated:animated];
	} else if (_searchFormMode == JRSearchFormModeComplex) {
		[_segmentedControl selectSegmentAtIndex:1 animated:animated];
		[self selectComplexSearchModeAnimated:animated];
	}
    
}

- (void)selectSimpleSearchModeAnimated:(BOOL)animated
{
	[_simpleSearchTable reloadData];
	[_travelClassAndPassengersTable reloadData];
    [self setCalendarButtonHidden:Aviasales() ? NO : YES animated:animated];
	[self addLeadingConstraintToSimpleSearchTable:NO animated:animated];
    
    
	[_datesCellBackground setAlpha:kJRSearchFormAnimationStartAlpha];
	[_simpleSearchTable setAlpha:kJRSearchFormAnimationStartAlpha];
	[UIView animateWithDuration:kJRSearchFormAnimationDuration
                     animations:^{
                         [_datesCellBackground setAlpha:1];
                         [_simpleSearchTable setAlpha:1];
                         [_complexSearchTable setAlpha:kJRSearchFormAnimationStartAlpha];
                     } completion:^(BOOL finished) {
                         [_datesCellBackground setAlpha:1];
                         [_simpleSearchTable setAlpha:1];
                         [_complexSearchTable setAlpha:1];
                     }];
    
    _simpleSearchTable.accessibilityElementsHidden = NO;
    _complexSearchTable.accessibilityElementsHidden = YES;
}

- (void)selectComplexSearchModeAnimated:(BOOL)animated
{
	[_complexSearchTable reloadData];
	[self setCalendarButtonHidden:YES animated:animated];
	[self addLeadingConstraintToSimpleSearchTable:YES animated:animated];
    
	[_complexSearchTable setAlpha:kJRSearchFormAnimationStartAlpha];
	[UIView animateWithDuration:kJRSearchFormAnimationDuration
                     animations:^{
                         [_datesCellBackground setAlpha:kJRSearchFormAnimationStartAlpha];
                         [_simpleSearchTable setAlpha:kJRSearchFormAnimationStartAlpha];
                         [_complexSearchTable setAlpha:1];
                     } completion:^(BOOL finished) {
                         [_datesCellBackground setAlpha:1];
                         [_simpleSearchTable setAlpha:1];
                         [_complexSearchTable setAlpha:1];
                     }];
    
    _complexSearchTable.accessibilityElementsHidden = NO;
    _simpleSearchTable.accessibilityElementsHidden = YES;
}

#pragma mark - Search Form Mode Selecting Animators

- (void)addLeadingConstraintToSimpleSearchTable:(BOOL)addConstraint animated:(BOOL)animated
{
	void (^animations)(void
	                   ) = ^{
		if (!_simpleSearchTableLeadingConstaint) {
			_simpleSearchTableLeadingConstaint = JRConstraintMake(_simpleSearchTable, NSLayoutAttributeRight, NSLayoutRelationEqual, self.view, NSLayoutAttributeLeft, 1, 0);
		}
		BOOL containtConstraint = [self.view.constraints containsObject:_simpleSearchTableLeadingConstaint];
		if (addConstraint && !containtConstraint) {
			[self.view addConstraint:_simpleSearchTableLeadingConstaint];
		} else if (!addConstraint && containtConstraint) {
			[self.view removeConstraint:_simpleSearchTableLeadingConstaint];
		}
		[self.view layoutIfNeeded];
	};
	if (animated) {
		[UIView animateWithDuration:kJRSearchFormAnimationDuration delay:kNilOptions
             usingSpringWithDamping:kJRSearchFormAnimationAnimationUsingSpringWithDamping
              initialSpringVelocity:kJRSearchFormAnimationAnimationInitialSpringVelocity
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionOverrideInheritedOptions
                         animations:animations completion:NULL];
        
	} else {
		animations();
	}
}

- (void)setCalendarButtonHidden:(BOOL)hidden animated:(BOOL)animated
{
    
	void (^animations)(void
	                   ) = ^{
		CGFloat calendarButtonImageAlpha = hidden ? 0 : 1;
		[_calendarButton setAlpha:calendarButtonImageAlpha];
        
		CGFloat calendarWidthButtonConstraintConstant = hidden ? 0 : kJRSearchFormCalendarButtonWidth;
		_calendarWidthButtonConstraint.constant = calendarWidthButtonConstraintConstant;
        
		CGFloat searchButtonToCalendarButtonMarginConstraintConstant = hidden ? 0 : kJRSearchFormSearchButtonToCalendarButtonMargin;
		_searchButtonToCalendarButtonMarginConstraint.constant = searchButtonToCalendarButtonMarginConstraintConstant;
		[self.view layoutIfNeeded];
	};
    
	if (animated) {
        
		[UIView animateWithDuration:kJRSearchFormCalendarButtonAnimationDuration delay:kNilOptions
             usingSpringWithDamping:kJRSearchFormCalendarButtonAnimationUsingSpringWithDamping
              initialSpringVelocity:kJRSearchFormCalendarButtonAnimationInitialSpringVelocity
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionOverrideInheritedOptions
                         animations:animations completion:NULL];
        
	} else {
		animations();
	}
    
    
}
#pragma mark - Actions

- (void)segmentedControl:(JRSegmentedControl *)segmentedControl clickedButtonAtIndex:(NSUInteger)buttonIndex
{
	if (buttonIndex == 0) {
		[self setSearchFormMode:JRSearchFormModeSimple animated:YES];
	} else if (buttonIndex == 1) {
		[self setSearchFormMode:JRSearchFormModeComplex animated:YES];
	} else {
        [self setSearchFormMode:self.searchFormMode animated:NO];
        [self showVoiceSearch];
    }
}

- (void)selectOriginIATAForTravelSegment:(JRTravelSegment *)travelSegment itemType:(JRSearchFormItemType)type
{
    if (!travelSegment) {
        travelSegment = [JRTravelSegment MR_createInContext:_searchInfo.managedObjectContext];
        [_searchInfo addTravelSegment:travelSegment];
    }
    
	JRAirportPickerVC *airportPicker = [[JRAirportPickerVC alloc] initWithMode:JRAirportPickerOriginMode travelSegment:travelSegment];
	if (iPhone()) {
		[self.navigationController pushViewController:airportPicker animated:YES];
	} else if (iPad()) {
		[self attachAccessoryViewController:airportPicker width:[JRScreenSceneController screenSceneControllerTallViewWidth] exclusiveFocus:YES animated:YES];
	}
}


- (void)selectDestinationIATAForTravelSegment:(JRTravelSegment *)travelSegment itemType:(JRSearchFormItemType)type
{
    if (!travelSegment) {
        travelSegment = [JRTravelSegment MR_createInContext:_searchInfo.managedObjectContext];
        [_searchInfo addTravelSegment:travelSegment];
    }
    
	JRAirportPickerVC *airportPicker = [[JRAirportPickerVC alloc] initWithMode:JRAirportPickerDestinationMode travelSegment:travelSegment];
	if (iPhone()) {
		[self.navigationController pushViewController:airportPicker animated:YES];
	} else if (iPad()) {
		[self attachAccessoryViewController:airportPicker width:[JRScreenSceneController screenSceneControllerTallViewWidth] exclusiveFocus:YES animated:YES];
	}
}

- (void)travelClassDidSelect
{
	[self reloadSearchFormAnimated:YES];
}

- (void)showPassengerPicker {
    if (iPad() || _popover) {
        return;
    }
    [self reloadSearchFormAnimated:YES];
    
    JRSearchFormPassengerPickerVC *passengerPickerVC = [[JRSearchFormPassengerPickerVC alloc] init];
    [passengerPickerVC.pickerView setSearchInfo:_searchInfo];
    [passengerPickerVC.pickerView setDelegate:self];
    
	_popover = [[JRFPPopoverController alloc] initWithViewController:passengerPickerVC
                                                                      delegate:self
                                                                underlyingView:nil];
	[_popover setContentSize:kJRSearchFormPassengersPopoverSize];
	[_popover presentPopoverFromView:_passengerPopoverFromView];
}

- (void)classPickerDidSelectTravelClass {
    [self popoverDismiss];
    [self reloadSearchFormAnimated:YES];
}

- (void)showTravelClassPickerFromView:(UIView *)view {
    
    if (_popover) {
        return;
    }
    
    JRSearchFormTravelClassPickerVC *travelClassPickerVC = [[JRSearchFormTravelClassPickerVC alloc] initWithDelegate:self searchInfo:_searchInfo];
    
    _popover = [[JRFPPopoverController alloc] initWithViewController:travelClassPickerVC
                                                                      delegate:self
                                                                underlyingView:self.navigationController.view];
    [_popover setArrowDirection:FPPopoverArrowDirectionDown];
    [_popover setBlurTintColor:[JRC COMMON_BLACK_POPOVER_TINT]];
    [_popover setContentSize:travelClassPickerVC.contentSize];
    [_popover presentPopoverFromView:view];
}

- (void)passengerViewDidChangePassengers {
    [self reloadSearchFormAnimated:NO];
}

- (void)passengerViewExceededTheAllowableNumberOfInfants {
    JRFPPopoverController *popover = [[JRAlertManager sharedManager] messagePopoverWithType:JRMessagePopoverTypeSearchFormExceededTheAllowableNumberOfInfants withStringParams:nil andUnderlyingView:self.view];
    [self showErrorPopover:popover];
}

- (void)passengerViewDismiss {
    [self popoverDismiss];
}

- (void)popoverDismiss {
    
    [_popover dismissPopoverAnimated:YES completion:^{
        _popover = nil;
    }];
}

- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController
{
    _popover = nil;
}


- (void)saveReturnFlightTravelSegment
{
	NSUInteger objectAtIndex = 1;
    
	JRTravelSegment *travelSegment = self.searchInfo.travelSegments.count > objectAtIndex ?
    (self.searchInfo.travelSegments)[objectAtIndex] : nil;
	if (travelSegment) {
		_savedTravelSegment = travelSegment;
		[_searchInfo removeTravelSegmentsStartingFromTravelSegment:_savedTravelSegment];
		[self reloadSearchFormAnimated:NO];
	}
}

- (void)restoreReturnFlightTravelSegment
{
	NSUInteger objectAtIndex = 1;
    
	JRTravelSegment *firstTravelSegment  = _searchInfo.travelSegments.firstObject;
	JRTravelSegment *travelSegment = self.searchInfo.travelSegments.count > objectAtIndex ?
    (self.searchInfo.travelSegments)[objectAtIndex] : nil;
    
	if (firstTravelSegment && _savedTravelSegment) {
		BOOL shouldRestoreDate = [firstTravelSegment.departureDate compare:_savedTravelSegment.departureDate] != NSOrderedDescending;
        
		if (shouldRestoreDate) {
			JRTravelSegment *newTravelSegment = travelSegment;
			if (!newTravelSegment) {
				newTravelSegment = [JRTravelSegment MR_createInContext:_searchInfo.managedObjectContext];
			}
			[newTravelSegment setDepartureDate:_savedTravelSegment.departureDate];
			BOOL shouldRestoreOrigin = [firstTravelSegment.destinationIata isEqualToString:_savedTravelSegment.originIata];
			BOOL shouldRestoreDestination = [firstTravelSegment.originIata isEqualToString:_savedTravelSegment.destinationIata];
            
			if (shouldRestoreOrigin) {
				[newTravelSegment setOriginIata:_savedTravelSegment.originIata];
			}
			if (shouldRestoreDestination) {
				[newTravelSegment setDestinationIata:_savedTravelSegment.destinationIata];
			}
			[_searchInfo addTravelSegment:newTravelSegment];
			[self reloadSearchFormAnimated:NO];
			return;
		}
        
	}
	[self selectDepartureDateForTravelSegment:travelSegment itemType:JRSearchFormTableViewReturnDateItem];
}

- (void)selectDepartureDateForTravelSegment:(JRTravelSegment *)travelSegment itemType:(JRSearchFormItemType)type
{
    if (!travelSegment) {
        travelSegment = [JRTravelSegment MR_createInContext:_searchInfo.managedObjectContext];
        [_searchInfo addTravelSegment:travelSegment];
    }
    
	JRDatePickerMode mode = JRDatePickerModeDefault;
	if (type == JRSearchFormTableViewDirectDateItem) {
		mode = JRDatePickerModeDeparture;
	} else if (type == JRSearchFormTableViewReturnDateItem) {
        while (_searchInfo.travelSegments.count < 2) {
            travelSegment = [JRTravelSegment MR_createInContext:_searchInfo.managedObjectContext];
            [_searchInfo addTravelSegment:travelSegment];
        }
		mode = JRDatePickerModeReturn;
	}
    
	JRDatePickerVC *datePicker = [[JRDatePickerVC alloc] initWithSearchInfo:_searchInfo
                                                              travelSegment:travelSegment
                                                                       mode:mode];
	if (iPhone()) {
		[self.navigationController pushViewController:datePicker animated:YES];
	} else if (iPad()) {
		[self attachAccessoryViewController:datePicker width:[JRScreenSceneController screenSceneControllerTallViewWidth] exclusiveFocus:YES animated:YES];
	}
}

- (void)priceCalendarButtonClick:(UIButton *)button
{
    JRFPPopoverController *errorPopover = [self getErrorPopover];
    if (errorPopover) {
        [self showErrorPopover:errorPopover];
        return;
    }
    
    [self clipSearchInfoIfNeeds];
    
    if (![JRPriceCalendarManager searchInfoIsValidForPriceCalendar:self.searchInfo]) {
        [[JRAlertManager sharedManager] showAlertWithId:JRAlertTypePriceCalendarNoValidSearchInfoMessage withStringParams:nil andDelegate:nil];
        return;
    }
    
    Reachability *reachibility = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reachibility currentReachabilityStatus];
    if (netStatus == NotReachable) {
        [[JRAlertManager sharedManager] showAlertWithId:JRAlertTypeSearchFormConnectionError withStringParams:nil andDelegate:nil];
        return;
    }
    
	JRPriceCalendarVC *priceCalendarVC = [[JRPriceCalendarVC alloc] initWithSearchInfo:self.searchInfo];
    
	if (iPad()) {
        [self.sceneViewController pushScreenSceneWithMainViewController:priceCalendarVC width:[JRScreenSceneController screenSceneControllerWideViewWidth] animated:YES];
	} else {
		[self.navigationController pushViewController:priceCalendarVC animated:YES];
	}
}

- (void)accessoryWillDetach {
    [super accessoryWillDetach];
    [self reloadSearchFormAnimated:YES];
}

#pragma mark - Other

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[_complexSearchTable flashScrollIndicators];
}

- (CGFloat)tableView:(UITableView *)tableView heightForItemWithType:(JRSearchFormItemType)type
{
	if (type == JRSearchFormTableViewItemAirportsType) {
		return tableView.frame.size.height * kJRSearchFormAirportsFraction;
	} else if (type == JRSearchFormTableViewItemDatesType) {
		return tableView.frame.size.height * kJRSearchFormDatesFraction;
	} else if (type == JRSearchFormTableViewItemTravelClassAndPassengersType) {
		return _travelClassAndPassengersTable.frame.size.height;
	} else if (type == JRSearchFormTableViewComplexSegmentItem && iPhone()) {
		return kJRSearchFormTableViewComplexCellHeightIPHONE;
	} else if (type == JRSearchFormTableViewComplexSegmentItem && iPad()) {
		return kJRSearchFormTableViewComplexCellHeightIPAD;
	} else if (type == JRSearchFormTableViewComplexAddSegmentItem) {
		return kJRSearchFormTableViewAddCellHeight;
	} else {
		return tableView.frame.size.height * kJRSearchFormCellFromTableInCellFraction;
	}
	return 44;
}

#pragma mark - Offer Aviasales App for russian JR users

- (void)offerAviasalesForRussianJetradarUsers {
#if JR == 1
    BOOL offerWasShown = [JRSharedUserDefaults() boolForKey:AS_SK_AVIASALES_OFFER_FOR_JR_SHOWN];
    BOOL aviasalesIsAlreadyInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"aviasales://"]];
    BOOL notRussian = ![[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"RU"] && ![[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"ru"];
    if (offerWasShown || aviasalesIsAlreadyInstalled || notRussian) {
        return;
    }
    [JRSharedUserDefaults() setBool:YES forKey:AS_SK_AVIASALES_OFFER_FOR_JR_SHOWN];
    [JRSharedUserDefaults() synchronize];
    JROfferASViewController *offerVC = [JROfferASViewController new];
    if (iPhone()) {
        BottomDrawer *drawer = [[BottomDrawer alloc] initWithViewController:offerVC navigationControllerClass:JRNavigationController.class];
        offerVC.drawer = drawer;
        drawer.showCloseButton = YES;
        drawer.drawerHeight = iPhoneSizeValue(409, 447, 447);
        [drawer show];
    } else {
        offerVC.modalPresentationStyle = UIModalPresentationFormSheet;
        offerVC.preferredContentSize = CGSizeMake(386, 446);
        [self presentViewController:offerVC animated:YES completion:^{}];
    }
#endif
}

@end
