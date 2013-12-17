//
//  ASTFilters.m
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "ASTFilters.h"
#import "ASFilterCellWithView.h"
#import "ASFilterCellWithOneThumbSlider.h"
#import "ASFilterCellWithTwoThumbsSlider.h"
#import "ASFilterHeaderCell.h"
#import "ASFilterCellWithMobileSwitch.h"
#import "ASFilterAirportsSeparatorCell.h"
#import "ASFilterCellWithAirport.h"

#import "AviasalesSDK.h"
#import "AviasalesAirport.h"
#import "AviasalesAirline.h"
#import "AviasalesGate.h"

#import "ASTSearchParams.h"
#import "ASTCommonFunctions.h"

#define CALL_DELAY 0.07
#define PRICE_DEFAULT_WIDTH 9.0f
#define CURRENCY_DEFAULT_X 23.0f
#define SEARCH_FORM_DARK_BG @"dark_background"

#define LOAD_VIEW_FROM_NIB_NAMED(X) [[AVIASALES_BUNDLE loadNibNamed:X owner:self options:nil] objectAtIndex:0]
#define RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0)

@implementation ASFilterCellInfo
@end

@interface ASTFilters ()

@property (assign, nonatomic) BOOL showAlliances;
@property (assign, nonatomic) BOOL showAirlines;
@property (assign, nonatomic) BOOL showAirports;
@property (assign, nonatomic) BOOL showGates;

- (void)resetAction:(id)sender;

@end

@implementation ASTFilters {
    NSUInteger _priorityCount;
    NSMutableArray *_departureAirPorts;
    NSMutableArray *_transferAirPorts;
    NSMutableArray *_destinationAirPorts;
    NSMutableArray *_sections;
    NSNumberFormatter *_formatter;
    UIBarButtonItem *_resetBtn;
    AviasalesFilter *_filter;
    
    BOOL _statistics;
    
    BOOL _transfersStat ;
    BOOL _overnightsStat;
    BOOL _priceStat;
    BOOL _timeInFlightStat;
    BOOL _timeInTransfersStat;
    BOOL _departTimeStat;
    BOOL _returnTimeStat;
    BOOL _airlinesStat;
    BOOL _airportsStat;
    BOOL _allianceStat;
    BOOL _mobileOnlyStat;
    BOOL _resetStat;
    BOOL _agenStat;
}

- (void)dealloc {
    [_filter.response.tickets makeObjectsPerformSelector:@selector(setFilter:) withObject:nil];
    _filter = nil;
    _departureAirPorts = nil;
    _destinationAirPorts = nil;
    _transferAirPorts = nil;
    _sections = nil;
    _tickets = nil;
}

- (void)setFilter:(AviasalesFilter *)filter {
    _filter = filter;
    [self buildTable];
}
#pragma mark - View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:AVIASALES_(@"AVIASALES_FILTERS")];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self setButtons];
    
    [self getAirportsByOrder];
    
    _formatter = [[NSNumberFormatter alloc] init];
    [_formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [_formatter setGroupingSeparator:@" "];
    [_formatter setGroupingSize:3];
    [_formatter setRoundingIncrement:[NSNumber numberWithDouble:1]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self buildTable];
    [_tableView reloadData];
    [self updatePriceLabel];
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _statistics = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _statistics = NO;
}

#pragma mark - Setup View

- (void)setButtons {

//    [UIBackgroundTaskInvalid addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    
    _resetBtn = [[UIBarButtonItem alloc] initWithTitle:AVIASALES_(@"AVIASALES_RESET") style:UIBarButtonItemStylePlain target:self action:@selector(resetAction:)];
    [self.navigationItem setRightBarButtonItem:_resetBtn];
    
    _resetBtn.enabled = _filter.needFiltering;
    
    _priorityCount = 6;
    if ([UIScreen mainScreen].bounds.size.height == 568.0) {
        _priorityCount = 8;
    }
}

- (void)setTickets:(NSArray *)tickets {
    _tickets = tickets;
    [self updatePriceLabel];
    _resetBtn.enabled = _filter.needFiltering;
}

- (void)getAirportsByOrder {
    
    _departureAirPorts = [[NSMutableArray alloc] init];
    _transferAirPorts = [[NSMutableArray alloc] init];
    _destinationAirPorts = [[NSMutableArray alloc] init];
    
    NSString *departureAirport = [ASTSearchParams sharedInstance].origin.city;
    NSString *destinationAirport = [ASTSearchParams sharedInstance].destination.city;
    
    NSArray *filterAirports = _filter.response.filtersBoundary.airports.copy;
    
    filterAirports = [filterAirports sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"averageRate" ascending:NO]]];
    
    for (AviasalesAirport *airport in filterAirports){
        if (departureAirport && [airport.city rangeOfString:departureAirport].location != NSNotFound) {
            [_departureAirPorts addObject:airport];
        } else if (destinationAirport && [airport.city rangeOfString:destinationAirport].location != NSNotFound) {
            [_destinationAirPorts addObject:airport];
        } else {
            [_transferAirPorts addObject:airport];
        }
    }
    
}
- (NSString *)makeHeaderDescription:(NSUInteger)excludedCount allCount:(NSUInteger)allCount {
    NSString *countString = @"";
    if (allCount) {
        countString = [NSString stringWithFormat:@"%d", allCount];
        if (excludedCount) {
            countString = [NSString stringWithFormat:@"%d %@ %@", allCount - excludedCount, @"из", countString];
        }
    }
    return countString;
}

- (void)buildTable {
    if (!_filter || _filter.response.tickets.count == 0) {
        return;
    }
    
    _sections = [[NSMutableArray alloc] init];
    NSMutableArray *transferSection = [[NSMutableArray alloc] init];
    NSArray *transferCellsTitles = @[AVIASALES_(@"AVIASALES_FILTER_NONSTOP"), AVIASALES_(@"AVIASALES_FILTER_ONE_STOP"), AVIASALES_(@"AVIASALES_FILTER_TWO_STOPS"), AVIASALES_(@"AVIASALES_FILTER_NIGHT")];
    for (NSInteger i = ASFilterNoTransferCell; i <= ASFilterOvernightTransferCell; i++) {
        ASFilterCellInfo *transferCellInfo = [[ASFilterCellInfo alloc] init];
        transferCellInfo.title = [transferCellsTitles objectAtIndex:i];
        transferCellInfo.type = i;
        transferCellInfo.CellIdentifier = @"ASFilterCellWithView";
        
        if (transferCellInfo.type == ASFilterNoTransferCell) {
            transferCellInfo.content = _filter.response.filtersBoundary.noTransferTicketWithMinimalPrice;
        }
        if (transferCellInfo.type == ASFilterOneTransferCell) {
            transferCellInfo.content = _filter.response.filtersBoundary.oneTransferTicketWithMinimalPrice;
        }
        if (transferCellInfo.type == ASFilterTwoTransfersCell) {
            transferCellInfo.content = _filter.response.filtersBoundary.twoTransfersTicketWithMinimalPrice;
        }
        
        if (!transferCellInfo.content && transferCellInfo.type != ASFilterOvernightTransferCell) {
            transferCellInfo.disabled = YES;
        }
        if (transferCellInfo.type == ASFilterOvernightTransferCell && !_filter.oneTransferTickets && !_filter.twoTransfersTickets) {
            transferCellInfo.disabled = YES;
        }
        
        [transferSection addObject:transferCellInfo];
        
        if (transferCellInfo.type == ASFilterOvernightTransferCell && !_filter.response.filtersBoundary.haveOvernightTransfers) {
            [transferSection removeObject:transferCellInfo];
        }
        
    }
    if (transferSection.count > 1) {
        [_sections addObject:transferSection];
    }
    
    if (_filter.response.filtersBoundary.minPrice != _filter.response.filtersBoundary.maxPrice) {
        
        ASFilterCellInfo *priceSliderCell = [[ASFilterCellInfo alloc] init];
        priceSliderCell.title = AVIASALES_(@"AVIASALES_FILTER_PRICE");
        priceSliderCell.CellIdentifier = @"ASFilterCellWithOneThumbSlider";
        priceSliderCell.type = ASFilterPriceSliderCell;
        
        [_sections addObject:@[priceSliderCell]];
    }
    
    NSMutableArray *flightAndTransferSection = [[NSMutableArray alloc] init];
    if (_filter.response.filtersBoundary.minFlightDuration != _filter.response.filtersBoundary.maxFlightDuration) {
        
        
        ASFilterCellInfo *fligtTimeSliderCell = [[ASFilterCellInfo alloc] init];
        
        fligtTimeSliderCell.title = AVIASALES_(@"AVIASALES_FILTER_TOTAL_DURATION");
        fligtTimeSliderCell.CellIdentifier = @"ASFilterCellWithOneThumbSlider";
        fligtTimeSliderCell.type = ASFilterFlightTimeSliderCell;
        
        [flightAndTransferSection addObject:fligtTimeSliderCell];
    }
    
    if (_filter.response.filtersBoundary.minStopDuration != _filter.response.filtersBoundary.maxStopDuration) {
        if (_filter.oneTransferTickets || _filter.twoTransfersTickets) {
            
            ASFilterCellInfo *delayTimeSliderCell = [[ASFilterCellInfo alloc] init];
            delayTimeSliderCell.title = AVIASALES_(@"AVIASALES_FILTER_STOPOVER_DURATION");
            delayTimeSliderCell.CellIdentifier = @"ASFilterCellWithTwoThumbsSlider";
            delayTimeSliderCell.type = ASFilterDelayTimeSliderCell;
            [flightAndTransferSection addObject:delayTimeSliderCell];
            
        } else {
            [_filter setCurrentMinStopFlightDuration:_filter.response.filtersBoundary.minStopDuration];
            [_filter setCurrentMaxStopFlightDuration:_filter.response.filtersBoundary.maxStopDuration];
        }
    }
    
    [_sections addObject:flightAndTransferSection];
    
    NSMutableArray *departureAndReturnTimeSection = [[NSMutableArray alloc] init];
    
    if (_filter.response.filtersBoundary.minOutboundDepartureTime != _filter.response.filtersBoundary.maxOutboundDepartureTime) {
        
        ASFilterCellInfo *fligtDepartureTimeSliderCell = [[ASFilterCellInfo alloc] init];
        fligtDepartureTimeSliderCell.title = AVIASALES_(@"AVIASALES_FILTER_DEPARTURE");
        fligtDepartureTimeSliderCell.CellIdentifier = @"ASFilterCellWithTwoThumbsSlider";
        fligtDepartureTimeSliderCell.type = ASFilterOutboundDepartTimeSliderCell;
        
        [departureAndReturnTimeSection addObject:fligtDepartureTimeSliderCell];
    }
    
    
    if (_filter.response.filtersBoundary.minOutboundArrivalTime != _filter.response.filtersBoundary.maxOutboundArrivalTime) {
        
        ASFilterCellInfo *fligtArrivalTimeSliderCell = [[ASFilterCellInfo alloc] init];
        fligtArrivalTimeSliderCell.title = AVIASALES_(@"AVIASALES_FILTER_ARRIVAL");
        fligtArrivalTimeSliderCell.CellIdentifier = @"ASFilterCellWithTwoThumbsSlider";
        fligtArrivalTimeSliderCell.type = ASFilterOutboundArrivalTimeSliderCell;
        
        [departureAndReturnTimeSection addObject:fligtArrivalTimeSliderCell];
    }
    
    
    [_sections addObject:departureAndReturnTimeSection];
    
    NSMutableArray *departureAndReturnArrivalTimeSection = [[NSMutableArray alloc] init];
    
    if ([[_filter.response.tickets objectAtIndex:0] returnDepartureDate] && _filter.response.filtersBoundary.minReturnDepartureTime != _filter.response.filtersBoundary.maxReturnDepartureTime) {
        
        ASFilterCellInfo *fligtReturnTimeSliderCell = [[ASFilterCellInfo alloc] init];
        
        fligtReturnTimeSliderCell.title = AVIASALES_(@"AVIASALES_FILTER_RETURN_DEPARTURE");
        fligtReturnTimeSliderCell.CellIdentifier = @"ASFilterCellWithTwoThumbsSlider";
        fligtReturnTimeSliderCell.type = ASFilterReturnDepartTimeSliderCell;
        
        [departureAndReturnArrivalTimeSection addObject:fligtReturnTimeSliderCell];
    }
    
    
    if ([[_filter.response.tickets objectAtIndex:0] returnDepartureDate] && _filter.response.filtersBoundary.minReturnArrivalTime != _filter.response.filtersBoundary.maxReturnArrivalTime) {
        
        ASFilterCellInfo *fligtReturnTimeSliderCell = [[ASFilterCellInfo alloc] init];
        
        fligtReturnTimeSliderCell.title = AVIASALES_(@"AVIASALES_FILTER_RETURN_ARRIVAL");
        fligtReturnTimeSliderCell.CellIdentifier = @"ASFilterCellWithTwoThumbsSlider";
        fligtReturnTimeSliderCell.type = ASFilterReturnArrivalTimeSliderCell;
        
        [departureAndReturnArrivalTimeSection addObject:fligtReturnTimeSliderCell];
    }
    
    [_sections addObject:departureAndReturnArrivalTimeSection];
    
    
    if (_filter.response.filtersBoundary.airlines.count > 1) {
        
        NSMutableArray *airlinesSection = [[NSMutableArray alloc] init];
        
        ASFilterCellInfo *airlinesHeader = [[ASFilterCellInfo alloc] init];
        airlinesHeader.title = AVIASALES_(@"AVIASALES_FILTER_AIRLINES");
        airlinesHeader.CellIdentifier = @"ASFilterHeaderCell";
        airlinesHeader.type = ASFilterAirlinesHeader;
        airlinesHeader.disabled = _showAirlines;
        airlinesHeader.content = [self makeHeaderDescription:_filter.excludedAirlines.count allCount:_filter.response.filtersBoundary.airlines.count];
        [airlinesSection addObject:airlinesHeader];
        
        if (_showAirlines) {
            
            ASFilterCellInfo *allAirlines = [[ASFilterCellInfo alloc] init];
            allAirlines.title = AVIASALES_(@"AVIASALES_FILTER_ALL_AIRLINES");
            allAirlines.CellIdentifier = @"ASFilterCellWithView";
            allAirlines.type = ASFilterAllAirlinesCell;
            allAirlines.disabled = _filter.excludedAirlines.count;
            [airlinesSection addObject:allAirlines];
            
            void (^addAirlinesCells)(NSArray *) = ^(NSArray * airlines){
                for (AviasalesAirline *airline in airlines.copy) {
                    ASFilterCellInfo *airlineCell = [[ASFilterCellInfo alloc] init];
                    airlineCell.title = airline.name;
                    airlineCell.CellIdentifier = @"ASFilterCellWithView";
                    airlineCell.type = ASFilterAirlineCell;
                    airlineCell.content = airline;
                    [airlinesSection addObject:airlineCell];
                }
            };
            
            
            NSArray *sortedAirlinesByAverageRate = [_filter.response.filtersBoundary.airlines sortedArrayUsingComparator:^NSComparisonResult(AviasalesAirline *a, AviasalesAirline *b) {
                return [a.name caseInsensitiveCompare:b.name];
            }];
            addAirlinesCells(sortedAirlinesByAverageRate);
        }
        
        [_sections addObject:airlinesSection];
    }
    
    if (_filter.response.filtersBoundary.alliances.count > 1) {
        
        NSMutableArray *alliancesSection = [[NSMutableArray alloc] init];
        
        ASFilterCellInfo *alliancesHeader = [[ASFilterCellInfo alloc] init];
        alliancesHeader.title = AVIASALES_(@"AVIASALES_FILTER_ALLIANCES");
        alliancesHeader.CellIdentifier = @"ASFilterHeaderCell";
        alliancesHeader.type = ASFilterAlliancesHeader;
        alliancesHeader.disabled = _showAlliances;
        alliancesHeader.content = [self makeHeaderDescription:_filter.excludedAlliances.count allCount:_filter.response.filtersBoundary.alliances.count];
        
        [alliancesSection addObject:alliancesHeader];
        if (_showAlliances) {
            
            ASFilterCellInfo *allAlliances = [[ASFilterCellInfo alloc] init];
            allAlliances.title = AVIASALES_(@"AVIASALES_FILTER_ALL_ALLIANCES");
            allAlliances.CellIdentifier = @"ASFilterCellWithView";
            allAlliances.type = ASFilterAllAlliancesCell;
            allAlliances.disabled = _filter.excludedAlliances.count;
            [alliancesSection addObject:allAlliances];
            
            [self getAirportsByOrder];
            for (NSString *alliance in _filter.response.filtersBoundary.alliances.copy) {
                
                ASFilterCellInfo *allianceCell = [[ASFilterCellInfo alloc] init];
                allianceCell.title = alliance;
                allianceCell.CellIdentifier = @"ASFilterCellWithView";
                allianceCell.type = ASFilterAllianceCell;
                allianceCell.content = alliance;
                [alliancesSection addObject:allianceCell];
            }
        }
        
        [_sections addObject:alliancesSection];
    }
    
    [self getAirportsByOrder];
    if (_filter.response.filtersBoundary.airports.count && _departureAirPorts.count &&  _transferAirPorts.count &&  _destinationAirPorts.count) {
        NSMutableArray *airportsSection = [[NSMutableArray alloc] init];
        
        ASFilterCellInfo *airportsHeader = [[ASFilterCellInfo alloc] init];
        airportsHeader.title = AVIASALES_(@"AVIASALES_FILTER_AIRPORTS");
        airportsHeader.CellIdentifier = @"ASFilterHeaderCell";
        airportsHeader.type = ASFilterAirportsHeader;
        airportsHeader.disabled = _showAirports;
        airportsHeader.content = [self makeHeaderDescription:_filter.excludedAirports.count allCount:_filter.response.filtersBoundary.airports.count];
        [airportsSection addObject:airportsHeader];
        
        if (_showAirports) {
            
            ASFilterCellInfo *allAirports = [[ASFilterCellInfo alloc] init];
            allAirports.title = AVIASALES_(@"AVIASALES_FILTER_ALL_AIRPORTS");
            allAirports.CellIdentifier = @"ASFilterCellWithView";
            allAirports.type = ASFilterAllAirportsCell;
            allAirports.disabled = _filter.excludedAirports.count;
            [airportsSection addObject:allAirports];
            
            
            NSArray *airportsArrays = @[_departureAirPorts, _transferAirPorts, _destinationAirPorts];
            NSArray *separatorTitles = @[AVIASALES_(@"AVIASALES_FILTER_FROM"), AVIASALES_(@"AVIASALES_FILTER_STOPOVERS"), AVIASALES_(@"AVIASALES_FILTER_TO")];
            
            for (NSArray *airports in airportsArrays) {
                if (airports.count) {
                    ASFilterCellInfo *separatorCell = [[ASFilterCellInfo alloc] init];
                    separatorCell.title = [separatorTitles objectAtIndex:[airportsArrays indexOfObject:airports]];
                    separatorCell.CellIdentifier = @"ASFilterAirportsSeparatorCell";
                    separatorCell.type = ASFilterAirportsSeparator;
                    [airportsSection addObject:separatorCell];
                    for (AviasalesAirport *airport in airports) {
                        ASFilterCellInfo *airportCell = [[ASFilterCellInfo alloc] init];
                        airportCell.title = nil;
                        airportCell.CellIdentifier = @"ASFilterCellWithAirport";
                        airportCell.type = ASFilterCellWithAirportBig;
                        NSString *currentAirport = [NSString stringWithFormat:@"%@, %@", airport.city, airport.country];
                        airportCell.title = currentAirport;
                        airportCell.content = airport;
                        [airportsSection addObject:airportCell];
                    }
                }
            }
        }
        [_sections addObject:airportsSection];
    }
    
    if (_filter.response.filtersBoundary.gates.count > 1) {
        
        NSMutableArray *gatesSection = [[NSMutableArray alloc] init];
        
        ASFilterCellInfo *gatesHeader = [[ASFilterCellInfo alloc] init];
        
        gatesHeader.title = AVIASALES_(@"AVIASALES_FILTER_AGENCIES");
        gatesHeader.CellIdentifier = @"ASFilterHeaderCell";
        gatesHeader.type = ASFilterGatesHeader;
        gatesHeader.disabled = _showGates;
        gatesHeader.content = [self makeHeaderDescription:_filter.excludedGates.count allCount:_filter.response.filtersBoundary.gates.count];
        [gatesSection addObject:gatesHeader];
        
        if (_showGates) {
            
            ASFilterCellInfo *allGates = [[ASFilterCellInfo alloc] init];
            allGates.title = AVIASALES_(@"AVIASALES_FILTER_ALL_AGENCIES");
            allGates.CellIdentifier = @"ASFilterCellWithView";
            allGates.type = ASFilterAllGatesCell;
            allGates.disabled = _filter.excludedGates.count;
            [gatesSection addObject:allGates];
            
            void (^addGateCells)(NSArray *) = ^(NSArray * gates){
                for (AviasalesGate *gate in gates.copy) {
                    ASFilterCellInfo *gateCell = [[ASFilterCellInfo alloc] init];
                    gateCell.title = gate.gateName;
                    gateCell.CellIdentifier = @"ASFilterCellWithView";
                    gateCell.type = ASFilterGateCell;
                    gateCell.content = gate;
                    [gatesSection addObject:gateCell];
                }
            };
            
            NSArray *sortedGatesByName = [_filter.response.filtersBoundary.gates sortedArrayUsingComparator: ^ NSComparisonResult (AviasalesGate *first, AviasalesGate *second) {
                return [[first gateName] caseInsensitiveCompare:[second gateName]];
            }];
            addGateCells(sortedGatesByName);
        }
        
        [_sections addObject:gatesSection];
    }
    
    if (_filter.response.tickets.count > 1 && _filter.response.filtersBoundary.haveMobileWeb) {
        NSMutableArray *mobileSwithSection = [[NSMutableArray alloc] init];
        ASFilterCellInfo *mobileSwithCell = [[ASFilterCellInfo alloc] init];
        mobileSwithCell.CellIdentifier = @"ASFilterCellWithMobileSwitch";
        mobileSwithCell.type = ASFilterCellWithBtn;
        [mobileSwithSection addObject:mobileSwithCell];
        [_sections addObject:mobileSwithSection];
    }
}


- (void)updatePriceLabel {
    
    if (_filter.filteringInProgress && _filter.needFiltering) {
        return;
    }
    
    NSString * countText;
    countText = [self getOffersTextByCount:[_tickets count]];
    
    if (![countText isEqualToString:_offersLabel.text]) {
        _offersLabel.text = [self getOffersTextByCount:[_tickets count]];
    }
    
    if (_tickets.count) {
        
        NSString *priceString = [ASTCommonFunctions formatPrice:[[[_tickets objectAtIndex:0] getBestPrice] value]];
        
        _price.text = [NSString stringWithFormat:@"%@ %@", priceString, [AviasalesSDK sharedInstance].currencySymbol];
        
    } else {
        
        _price.text = nil;

    }
}

- (NSString *)getOffersTextByCount:(NSUInteger)count {
    
    CGRect offersFrame = _offersLabel.frame;
    
    if (count == 0) {
        offersFrame.size.height = 40;
        [_offersLabel setFrame:offersFrame];
        return AVIASALES_(@"AVIASALES_FILTERS_EMPTY");
    } else {
        offersFrame.size.height = 17;
        [_offersLabel setFrame:offersFrame];
        return [NSString stringWithFormat:@"%@: %d",AVIASALES_(@"AVIASALES_FILTER_FOUND") ,count];
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_sections objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_sections count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASFilterCellInfo *cellInfo = (ASFilterCellInfo *)[[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (cellInfo.type >= 4 && cellInfo.type < 11) {
        return 83;
    }
    else if (cellInfo.type == ASFilterAirportsSeparator) {
        return 22;
    }
    else if (cellInfo.type == ASFilterCellWithAirportBig) {
        return 55;
    }
    else if (cellInfo.type >= 11) {
        return 45;
    }
    return 47;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ASFilterCellInfo *info = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[info CellIdentifier]];
    if (!cell) {
        cell = LOAD_VIEW_FROM_NIB_NAMED(info.CellIdentifier);
        if ([cell isKindOfClass:[ASFilterCellWithOneThumbSlider class]]) {
            [[(ASFilterCellWithOneThumbSlider *)cell cellSlider] addTarget:self action:@selector(singleSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        }
        if ([cell isKindOfClass:[ASFilterCellWithTwoThumbsSlider class]]) {
            [[(ASFilterCellWithTwoThumbsSlider *)cell cellSlider] addTarget:self action:@selector(twoThumbsSliderAction:) forControlEvents:UIControlEventValueChanged];
        }
    }
    if (info.type == ASFilterNoTransferCell || info.type == ASFilterOneTransferCell || info.type == ASFilterTwoTransfersCell || info.type == ASFilterOvernightTransferCell) {
        [self setTransferCell:(ASFilterCellWithView *)cell info:info];
    }
    if ([cell isKindOfClass:[ASFilterCellWithOneThumbSlider class]]) {
        [self updateSingleSliderCell:(ASFilterCellWithOneThumbSlider *)cell info:info];
    }
    if ([cell isKindOfClass:[ASFilterCellWithTwoThumbsSlider class]]) {
        [self updateTwoThumbsCell:(ASFilterCellWithTwoThumbsSlider *)cell info:info];
    }
    if ([cell isKindOfClass:[ASFilterHeaderCell class]]) {
        [self updateHeader:(ASFilterHeaderCell *)cell info:info];
    }
    if (info.type == ASFilterAllianceCell || info.type == ASFilterAirlineCell || info.type == ASFilterGateCell) {
        [self updateCellWithView:(ASFilterCellWithView *)cell info:info];
    }
    if (info.type == ASFilterAllAlliancesCell || info.type == ASFilterAllAirlinesCell || info.type == ASFilterAllAirportsCell || info.type == ASFilterAllGatesCell) {
        [self updateAllObjectCellWithView:(ASFilterCellWithView *)cell info:info];
    }
    if ([cell isKindOfClass:[ASFilterAirportsSeparatorCell class]]) {
        [[(ASFilterAirportsSeparatorCell *)cell cellLabel] setText:info.title];
    }
    if ([cell isKindOfClass:[ASFilterCellWithAirport class]]) {
        [self updateAirportCell:(ASFilterCellWithAirport *)cell info:info];
    }
    if (info.type == ASFilterCellWithBtn) {
        [self updateSwitchCell:(ASFilterCellWithMobileSwitch *)cell];
        return cell;
    }
    
//    BOOL nextFooterCell = [tableView numberOfRowsInSection:indexPath.section] == indexPath.row + 2 && [(ASFilterCellInfo *)[[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row + 1] type] == ASFilterAirlineFooterCell;
//    
//    BOOL nextSeparatorCell = [tableView numberOfRowsInSection:indexPath.section] >= indexPath.row + 2 && [(ASFilterCellInfo *)[[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row + 1] type] == ASFilterAirportsSeparator;
    
//    if (info.type == ASFilterAlliancesHeader || info.type == ASFilterAirlinesHeader || (info.type == ASFilterAirlineCell && nextFooterCell) || nextSeparatorCell || info.type == ASFilterAirportsHeader || info.type == ASFilterGatesHeader) {
//        [tableView setBackroundsForCell:cell indexPath:indexPath borderColor:ASC_CLEAR_COLOR];
//    } else {
//        [tableView setBackroundsForCell:cell indexPath:indexPath borderColor:nil];
//    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ASFilterCellInfo *info = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (info.type == ASFilterNoTransferCell || info.type == ASFilterOneTransferCell || info.type == ASFilterTwoTransfersCell || info.type == ASFilterOvernightTransferCell) {
        [self transferCellAction:info];
        [self buildTable];
        [_tableView reloadData];
        if (_statistics) {
            if (info.type == ASFilterOvernightTransferCell) {
                _overnightsStat = YES;
            } else {
                _transfersStat = YES;
            }
        }
    }
    if (info.type == ASFilterAlliancesHeader) {
        [self setShowAlliances:!_showAlliances];
        [self buildTable];
        [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.section, [tableView numberOfSections] - indexPath.section)] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    if (info.type == ASFilterAllianceCell) {
        [_filter.excludedAlliances containsObject:info.content] ? [_filter.excludedAlliances removeObject:info.content] : [_filter.excludedAlliances addObject:info.content];
        [_filter setNeedFiltering:YES];
        [self buildTable];
        [_tableView reloadData];
        if (_statistics) {
            _allianceStat = YES;
        }
        
    }
    if (info.type == ASFilterAirlinesHeader) {
        [self setShowAirlines:!_showAirlines];
        [self buildTable];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    }
    
    if (info.type == ASFilterGatesHeader) {
        [self setShowGates:!_showGates];
        [self buildTable];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        if (_statistics) {
            _agenStat = YES;
        }
    }
    
    if (info.type == ASFilterAirlineCell) {
        [_filter.excludedAirlines containsObject:info.content] ? [_filter.excludedAirlines removeObject:info.content] : [_filter.excludedAirlines addObject:info.content];
        [_filter setNeedFiltering:YES];
        [self buildTable];
        [_tableView reloadData];
        if (_statistics) {
            _airlinesStat = YES;
        }
        
    }
    
    if (info.type == ASFilterGateCell) {
        [_filter.excludedGates containsObject:info.content] ? [_filter.excludedGates removeObject:info.content] : [_filter.excludedGates addObject:info.content];
        [_filter setNeedFiltering:YES];
        [self buildTable];
        [_tableView reloadData];
        
    }
    
    if (info.type == ASFilterAirportsHeader) {
        [self setShowAirports:!_showAirports];
        [self buildTable];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    if (info.type == ASFilterCellWithAirportBig) {
        [_filter.excludedAirports containsObject:info.content] ? [_filter.excludedAirports removeObject:info.content] : [_filter.excludedAirports addObject:info.content];
        
        [_filter setNeedFiltering:YES];
        [self buildTable];
        [_tableView reloadData];
        if (_statistics) {
            _airportsStat = YES;
        }
    }
    
    if (info.type == ASFilterAllAirlinesCell) {
        if (info.disabled) {
            [_filter.excludedAirlines removeAllObjects];
            
        } else {
            for (AviasalesAirline *airline in _filter.response.filtersBoundary.airlines) {
                [_filter.excludedAirlines addObject:airline];
            }
        }
        [_filter setNeedFiltering:YES];
        [self buildTable];
        [_tableView reloadData];
    }
    if (info.type == ASFilterAllAlliancesCell) {
        if (info.disabled) {
            [_filter.excludedAlliances removeAllObjects];
            
        } else {
            for (NSString *alliance in _filter.response.filtersBoundary.alliances) {
                [_filter.excludedAlliances addObject:alliance];
            }
        }
        [_filter setNeedFiltering:YES];
        [self buildTable];
        [_tableView reloadData];
    }
    
    if (info.type == ASFilterAllAirportsCell) {
        if (info.disabled) {
            [_filter.excludedAirports removeAllObjects];
            
        } else {
            NSMutableArray *allAirports = [[NSMutableArray alloc] initWithArray:_departureAirPorts];
            [allAirports addObjectsFromArray:_transferAirPorts];
            [allAirports addObjectsFromArray:_destinationAirPorts];
            for (AviasalesAirport *airport in allAirports) {
                [_filter.excludedAirports addObject:airport];
            }
        }
        [_filter setNeedFiltering:YES];
        [self buildTable];
        [_tableView reloadData];
    }
    if (info.type == ASFilterAllGatesCell) {
        if (info.disabled) {
            [_filter.excludedGates removeAllObjects];
            
        } else {
            for (AviasalesGate *gate in _filter.response.filtersBoundary.gates) {
                [_filter.excludedGates addObject:gate];
            }
        }
        [_filter setNeedFiltering:YES];
        [self buildTable];
        [_tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}

#pragma mark - Header Action

- (void)updateHeader:(ASFilterHeaderCell *)headerCell info:(ASFilterCellInfo *)info {
    [headerCell.cellLabel setText:info.title];
    [headerCell.cellLabel setHighlighted:info.disabled];
    [headerCell.cellImageView  setHighlighted:info.disabled];
    [headerCell.countLabel setText:info.content];
    if (info.type == ASFilterAirlineFooterCell) {
        [headerCell.cellLabel setHighlighted:YES];
    }
}

#pragma mark - Mobile Btn Actions

- (void)updateSwitchCell:(ASFilterCellWithMobileSwitch *)cell {
    [cell.cellButton addTarget:self action:@selector(mobileWebButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.cellButton setSelected:_filter.mobileWebOnly];
    [cell.cellLabel setText:AVIASALES_(@"AVIASALES_FILTER_MOBILE")];
}

- (void)mobileWebButtonAction:(UIButton *)sender {
    _filter.mobileWebOnly = !_filter.mobileWebOnly;
    [self updateSwitchCell:(ASFilterCellWithMobileSwitch *)sender.superview.superview.superview];
    [_filter setNeedFiltering:YES];
    if (_statistics) {
        _mobileOnlyStat = YES;
    }
}

#pragma mark - One Thumb Slider Actions




- (void)updateSingleSliderCell:(ASFilterCellWithOneThumbSlider *)cell info:(ASFilterCellInfo *)info {
    [cell.cellLabel setText:info.title];
    if (info.type == ASFilterPriceSliderCell) {
        [cell updateSingleSliderWithMinVal:_filter.response.filtersBoundary.minPrice maxVal:_filter.response.filtersBoundary.maxPrice  val:_filter.currentMaxPrice];
        [cell applyPriceString:[self getCurrentMaxPriceString]];
    }
    if (info.type == ASFilterFlightTimeSliderCell) {
        [cell updateSingleSliderWithMinVal:_filter.response.filtersBoundary.minFlightDuration maxVal:_filter.response.filtersBoundary.maxFlightDuration val:_filter.currentMaxFlightDuration];
        [cell.cellAttLabel setText:[NSString stringWithFormat:@"%@ %@", AVIASALES_(@"AVIASALES_FILTER_UP_TO"), [ASTFilters formatDuration:_filter.currentMaxFlightDuration]]];
    }
}

- (void)singleSliderValueChanged:(UISlider *)sender {
    
    ASFilterCellWithOneThumbSlider *cell = (ASFilterCellWithOneThumbSlider *)sender.superview.superview.superview;
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    ASFilterCellInfo *info = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (info.type == ASFilterPriceSliderCell) {
        [_filter setCurrentMaxPrice:[[NSNumber numberWithFloat:sender.value] integerValue]];
        [cell applyPriceString:[self getCurrentMaxPriceString]];
        if (_statistics) {
            _priceStat = YES;
        }
    }
    if (info.type == ASFilterFlightTimeSliderCell) {
        
        [_filter setCurrentMaxFlightDuration:[[NSNumber numberWithFloat:sender.value] integerValue]];
        [cell.cellAttLabel setText:[NSString stringWithFormat:@"%@ %@", AVIASALES_(@"AVIASALES_FILTER_UP_TO"), [ASTFilters formatDuration:_filter.currentMaxFlightDuration]]];
        if (_statistics) {
            _timeInFlightStat = YES;
        }
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callFilter) object:nil];
    [self performSelector:@selector(callFilter) withObject:nil afterDelay:CALL_DELAY];
}

- (NSString *)getCurrentMaxPriceString {
    NSString *amountStr = [_formatter stringFromNumber:[_filter currentMaxPriceInUserCurrency]];
    return amountStr;
}

#pragma mark - Two Thumbs Slider Actions

- (void)updateTwoThumbsCell:(ASFilterCellWithTwoThumbsSlider *)cell info:(ASFilterCellInfo *)info {
    
    [cell.cellLabel setText:info.title];
    if (info.type == ASFilterOutboundDepartTimeSliderCell) {
        NSString *text = [NSString stringWithFormat:@"%@ %@ %@ %@", AVIASALES_(@"AVIASALES_FILTER_FROM1"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMinOutboundDepartTime], AVIASALES_(@"AVIASALES_FILTER_UP_TO"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMaxOutboundDepartTime]];
        
        [cell updateTwoThumbsSliderWithMinVal:_filter.response.filtersBoundary.minOutboundDepartureTime
                                       maxVal:_filter.response.filtersBoundary.maxOutboundDepartureTime
                                       uppVal:_filter.currentMaxOutboundDepartTime
                                       lowVal:_filter.currentMinOutboundDepartTime
                                         text:text];
    }
    if (info.type == ASFilterReturnDepartTimeSliderCell) {
        NSString *text = [NSString stringWithFormat:@"%@ %@ %@ %@", AVIASALES_(@"AVIASALES_FILTER_FROM1"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMinReturnDepartTime], AVIASALES_(@"AVIASALES_FILTER_UP_TO"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMaxReturnDepartTime]];
        
        [cell updateTwoThumbsSliderWithMinVal:_filter.response.filtersBoundary.minReturnDepartureTime
                                       maxVal:_filter.response.filtersBoundary.maxReturnDepartureTime
                                       uppVal:_filter.currentMaxReturnDepartTime
                                       lowVal:_filter.currentMinReturnDepartTime
                                         text:text];
    }
    if (info.type == ASFilterOutboundArrivalTimeSliderCell) {
        NSString *text = [NSString stringWithFormat:@"%@ %@ %@ %@", AVIASALES_(@"AVIASALES_FILTER_FROM1"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMinOutboundArrivalTime], AVIASALES_(@"AVIASALES_FILTER_UP_TO"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMaxOutboundArrivalTime]];
        
        [cell updateTwoThumbsSliderWithMinVal:_filter.response.filtersBoundary.minOutboundArrivalTime
                                       maxVal:_filter.response.filtersBoundary.maxOutboundArrivalTime
                                       uppVal:_filter.currentMaxOutboundArrivalTime
                                       lowVal:_filter.currentMinOutboundArrivalTime
                                         text:text];
    }
    if (info.type == ASFilterReturnArrivalTimeSliderCell) {
        NSString *text = [NSString stringWithFormat:@"%@ %@ %@ %@", AVIASALES_(@"AVIASALES_FILTER_FROM1"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMinReturnArrivalTime], AVIASALES_(@"AVIASALES_FILTER_UP_TO"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMaxReturnArrivalTime]];
        
        [cell updateTwoThumbsSliderWithMinVal:_filter.response.filtersBoundary.minReturnArrivalTime
                                       maxVal:_filter.response.filtersBoundary.maxReturnArrivalTime
                                       uppVal:_filter.currentMaxReturnArrivalTime
                                       lowVal:_filter.currentMinReturnArrivalTime
                                         text:text];
    }
    if (info.type ==  ASFilterDelayTimeSliderCell) {
        NSString *text = [NSString stringWithFormat:@"%@ %@ %@ %@", AVIASALES_(@"AVIASALES_FILTER_FROM2"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMinStopFlightDuration], AVIASALES_(@"AVIASALES_FILTER_UP_TO"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMaxStopFlightDuration]];
        
        [cell updateTwoThumbsSliderWithMinVal:_filter.response.filtersBoundary.minStopDuration
                                       maxVal:_filter.response.filtersBoundary.maxStopDuration
                                       uppVal:_filter.currentMaxStopFlightDuration
                                       lowVal:_filter.currentMinStopFlightDuration
                                         text:text];
    }
}

- (void)twoThumbsSliderAction:(NMRangeSlider *)sender {
    ASFilterCellWithTwoThumbsSlider *cell = (ASFilterCellWithTwoThumbsSlider *)sender.superview.superview.superview;
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    ASFilterCellInfo *info = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (info.type == ASFilterOutboundDepartTimeSliderCell) {
        [_filter setCurrentMinOutboundDepartTime:[[NSNumber numberWithFloat:sender.lowerValue] integerValue]];
        [_filter setCurrentMaxOutboundDepartTime:[[NSNumber numberWithFloat:sender.upperValue] integerValue]];
        [cell.cellAccessoryLabel setText:[NSString stringWithFormat:@"%@ %@ %@ %@", AVIASALES_(@"AVIASALES_FILTER_FROM1"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMinOutboundDepartTime], AVIASALES_(@"AVIASALES_FILTER_UP_TO"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMaxOutboundDepartTime]]];
        if (_statistics) {
            _departTimeStat = YES;
        }
    }
    if (info.type == ASFilterReturnDepartTimeSliderCell) {
        [_filter setCurrentMinReturnDepartTime:[[NSNumber numberWithFloat:sender.lowerValue] integerValue]];
        [_filter setCurrentMaxReturnDepartTime:[[NSNumber numberWithFloat:sender.upperValue] integerValue]];
        [cell.cellAccessoryLabel setText:[NSString stringWithFormat:@"%@ %@ %@ %@", AVIASALES_(@"AVIASALES_FILTER_FROM1"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMinReturnDepartTime], AVIASALES_(@"AVIASALES_FILTER_UP_TO"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMaxReturnDepartTime]]];
        if (_statistics) {
            _returnTimeStat = YES;
        }
    }
    if (info.type == ASFilterOutboundArrivalTimeSliderCell) {
        [_filter setCurrentMinOutboundArrivalTime:[[NSNumber numberWithFloat:sender.lowerValue] integerValue]];
        [_filter setCurrentMaxOutboundArrivalTime:[[NSNumber numberWithFloat:sender.upperValue] integerValue]];
        [cell.cellAccessoryLabel setText:[NSString stringWithFormat:@"%@ %@ %@ %@", AVIASALES_(@"AVIASALES_FILTER_FROM1"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMinOutboundArrivalTime], AVIASALES_(@"AVIASALES_FILTER_UP_TO"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMaxOutboundArrivalTime]]];
    }
    if (info.type == ASFilterReturnArrivalTimeSliderCell) {
        [_filter setCurrentMinReturnArrivalTime:[[NSNumber numberWithFloat:sender.lowerValue] integerValue]];
        [_filter setCurrentMaxReturnArrivalTime:[[NSNumber numberWithFloat:sender.upperValue] integerValue]];
        [cell.cellAccessoryLabel setText:[NSString stringWithFormat:@"%@ %@ %@ %@", AVIASALES_(@"AVIASALES_FILTER_FROM1"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMinReturnArrivalTime], AVIASALES_(@"AVIASALES_FILTER_UP_TO"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMaxReturnArrivalTime]]];
    }
    if (info.type == ASFilterDelayTimeSliderCell) {
        [_filter setCurrentMinStopFlightDuration:[[NSNumber numberWithFloat:sender.lowerValue] integerValue]];
        [_filter setCurrentMaxStopFlightDuration:[[NSNumber numberWithFloat:sender.upperValue] integerValue]];
        [cell.cellAccessoryLabel setText:[NSString stringWithFormat:@"%@ %@ %@ %@", AVIASALES_(@"AVIASALES_FILTER_FROM2"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMinStopFlightDuration], AVIASALES_(@"AVIASALES_FILTER_UP_TO"), [ASTFilters formatDurationForFilterWithSliders:_filter.currentMaxStopFlightDuration]]];
        if (_statistics) {
            _timeInTransfersStat = YES;
        }
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callFilter) object:nil];
    [self performSelector:@selector(callFilter) withObject:nil afterDelay:CALL_DELAY];
}

#pragma mark - Alliances, Airlines and Airports
- (void)updateCellWithView:(ASFilterCellWithView *)cell info:(ASFilterCellInfo *)info {
    
    CGRect cellTitileRect = cell.cellTitleLabel.frame;
    cellTitileRect.size.width = 178;
    [cell.cellTitleLabel setFrame:cellTitileRect];
    
    [cell.cellAttLabel setText:nil];

    if (info.type == ASFilterAllianceCell) {
        [cell.cellRatingView setHidden:YES];
        [_filter.excludedAlliances containsObject:info.content] ? [cell.cellImageView setHidden:YES] : [cell.cellImageView setHidden:NO];
    }
    
    if (info.type == ASFilterAirlineCell) {
        [_filter.excludedAirlines containsObject:info.content] ? [cell.cellImageView setHidden:YES] : [cell.cellImageView setHidden:NO];
        
        [cell.cellRatingView setHidden:NO];
        [cell.cellRatingView setRating:[(AviasalesAirline *)info.content averageRate]];
        NSNumber *price = [[_filter.response.filtersBoundary.minimumPricesForAirlines objectForKey:(AviasalesAirline *)[info.content iata]] getBestPrice].value;
        if ([_filter.response.filtersBoundary.minimumPricesForAirlines objectForKey:(AviasalesAirline *)[info.content iata]] && [price longValue] > 0) {
            if ([[_filter.response.filtersBoundary.minimumPricesForAirlines objectForKey:(AviasalesAirline *)[info.content iata]] isKindOfClass:[AviasalesTicket class]]) {
                [cell.cellAttLabel setFrame:CGRectMake(RETINA ? 181 : 184, 17, 95, 21)];
                NSString *firstPart = [_formatter stringFromNumber:[[_filter.response.filtersBoundary.minimumPricesForAirlines objectForKey:(AviasalesAirline *)[info.content iata]] getBestPrice].value];
                NSString *secondPart = [[AviasalesSDK sharedInstance].currencyCode uppercaseString];
                [cell. cellAttLabel setFont:[UIFont systemFontOfSize:RETINA ? 9.0f : 11.0f]];
                [cell.cellAttLabel setText:[NSString stringWithFormat:@"%@ %@", firstPart, secondPart]];
                
            }
        }
    }
    
    if (info.type == ASFilterGateCell) {
        [cell.cellRatingView setHidden:YES];
        [_filter.excludedGates containsObject:info.content] ? [cell.cellImageView setHidden:YES] : [cell.cellImageView setHidden:NO];
    }
    [cell.cellTitleLabel setText:info.title];
    [cell.cellTitleLabel setEnabled:YES];
    
    [cell setUserInteractionEnabled:YES];
}

- (void)updateAllObjectCellWithView:(ASFilterCellWithView *)cell info:(ASFilterCellInfo *)info {
    
    CGRect cellTitileRect = cell.cellTitleLabel.frame;
    cellTitileRect.size.width = 229;
    [cell.cellTitleLabel setFrame:cellTitileRect];
    
    [cell.cellAttLabel setText:nil];
    [cell.cellRatingView setHidden:YES];
    [cell.cellTitleLabel setText:info.title];
    [cell.cellTitleLabel setEnabled:YES];
    [cell setUserInteractionEnabled:YES];
    [cell.cellImageView setHidden:info.disabled];
    
}


- (void)updateAirportCell:(ASFilterCellWithAirport *)cell info:(ASFilterCellInfo *)info {
    [_filter.excludedAirports containsObject:info.content] ? [cell.cellImageView setHidden:YES] : [cell.cellImageView setHidden:NO];
    AviasalesAirport *airport = (AviasalesAirport *)[info content];
//    [cell.cellIataLabel setTextColor:ASC_MEDIUM_THEME_COLOR];
    [cell.cellIataLabel setTextColor:[UIColor brownColor]];
    [cell.cellIataLabel setText:airport.iata];
    [cell.cellNameLabel setText:airport.name];
    [cell.cellRaitingStars setRating:airport.averageRate];
    if ([cell respondsToSelector:@selector(cellTitleLabel)]) {
        [cell.cellTitleLabel setText:info.title];
    }
}


#pragma mark - Transfer Actions

- (void)setTransferCell:(ASFilterCellWithView *)cell info:(ASFilterCellInfo *)info {
    CGRect cellTitileRect = cell.cellTitleLabel.frame;
    cellTitileRect.size.width = 229;
    [cell.cellTitleLabel setFrame:cellTitileRect];
    [cell setUserInteractionEnabled:!info.disabled];
    [cell.cellRatingView setHidden:YES];
    
    [cell.cellTitleLabel setText:info.title];
    [cell.cellTitleLabel setEnabled:!info.disabled];
    
    [cell.cellAttLabel setText:@""];
    
    if (info.type == ASFilterNoTransferCell) {
        [cell.cellImageView setHidden:!_filter.noTransfersTickets];
    }
    if (info.type == ASFilterOneTransferCell) {
        [cell.cellImageView setHidden:!_filter.oneTransferTickets];
    }
    if (info.type == ASFilterTwoTransfersCell) {
        [cell.cellImageView setHidden:!_filter.twoTransfersTickets];
    }
    if (info.type == ASFilterOvernightTransferCell) {
        [cell.cellImageView setHidden:!_filter.overnightTransfer];
    }
    if (info.disabled) {
        [cell.cellImageView setHidden:YES];
    }
    if (info.content) {
        [cell.cellAttLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
        [cell.cellAttLabel setFrame:CGRectMake(181, 13, 95, 21)];
        NSNumber *price = [info.content getBestPrice].value;
        NSString *firstPart = [_formatter stringFromNumber:price];
        [cell applyPriceString:firstPart];
    }
    else {
        [cell.cellAttLabel setText:nil];
    }
    
}

- (void)transferCellAction:(ASFilterCellInfo *)info {
    if (info.type == ASFilterNoTransferCell) {
        [_filter setNoTransfersTickets:!_filter.noTransfersTickets];
    }
    if (info.type == ASFilterOneTransferCell) {
        [_filter setOneTransferTickets:!_filter.oneTransferTickets];
    }
    if (info.type == ASFilterTwoTransfersCell) {
        [_filter setTwoTransfersTickets:!_filter.twoTransfersTickets];
    }
    if (info.type == ASFilterOvernightTransferCell) {
        [_filter setOvernightTransfer:!_filter.overnightTransfer];
    }
    [_filter setNeedFiltering:YES];
}

#pragma mark - Other Actions

- (void)callFilter {
    [_filter setNeedFiltering:YES];
}

- (void)dismiss:(id)sender {
    
    [self.navigationController popViewControllerAnimated:NO];
    
//    [UIView  transitionWithView:self.navigationController.view duration:0.4  options: (UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionCurveEaseInOut)
//                     animations:^(void) {
//                         BOOL oldState = [UIView areAnimationsEnabled];
//                         [UIView setAnimationsEnabled:NO];
//                         [self.navigationController popViewControllerAnimated:YES];
//                         [UIView setAnimationsEnabled:oldState];
//                     }
//                     completion:nil];
}

- (void)resetAction:(id)sender {
    [_resetBtn setEnabled:NO];
    [_filter setNeedFiltering:NO];
    [self updatePriceLabel];
    [self buildTable];
    [_tableView reloadData];
    if (_statistics) {
        _resetStat = YES;
    }
}

#pragma mark - Date Util

+ (NSString*)formatDuration:(int)totalDuration {
    int hours = totalDuration / 60;
    int minutes = totalDuration % 60;
    minutes -= minutes % 5;
    NSString *hoursString = [NSString stringWithFormat:@"%d", hours];
    NSString *minutesString = [NSString stringWithFormat:@"%d", minutes];
    if (hours <= 9) {
        hoursString = [NSString stringWithFormat:@"0%d", hours];
    }
    if (minutes <= 9) {
        minutesString = [NSString stringWithFormat:@"0%d", minutes];
    }
    return [NSString stringWithFormat:AVIASALES_(@"AVIASALES_DURATION_FORMAT_LONG"), hoursString, minutesString];
}

+ (NSString*)formatDurationForFilterWithSliders:(int)totalDuration {
    int hours = totalDuration / 60;
    int minutes = totalDuration % 60;
    minutes -= minutes % 5;
    NSString *hoursString = [NSString stringWithFormat:@"%d", hours];
    NSString *minutesString = [NSString stringWithFormat:@"%d", minutes];
    if (hours <= 9) {
        hoursString = [NSString stringWithFormat:@"0%d", hours];
    }
    if (minutes <= 9) {
        minutesString = [NSString stringWithFormat:@"0%d", minutes];
    }
    return [NSString stringWithFormat:@"%@:%@", hoursString, minutesString];
}

@end
