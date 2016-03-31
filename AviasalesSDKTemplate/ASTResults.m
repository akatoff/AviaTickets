//
//  ASTResults.m
//  AviasalesSDKTemplate
//
//  Created by Seva Billevich on 28.10.13.
//  Copyright (c) 2013 Go Travel Un Limited. All rights reserved.
//

#import "ASTResults.h"

#import "ASTResultsTicketCell.h"

#import "ASTTicketScreen.h"

#import "ASTSearchParams.h"

#import "ASTFilters.h"
#import <AviasalesSDK/AviasalesFilter.h>

#define AST_SEARCH_TIME 40.0f
#define AST_PROGRESS_UPDATE_INTERVAL 0.1f

#define AST_RS_HEADER_HEIGHT 4.0f

@interface ASTResults () {
    NSTimer *_progressTimer;
    NSArray *_currencies;
    ASTFilters *_filtersVC;
    AviasalesFilter *_filter;
    NSArray *_tickets;
}

- (void)updateCurrencyButton;
- (NSArray *)filteredTickets;
- (NSArray *)tickets;

@end

@implementation ASTResults

/**
 Nib name for ticket cell in results. Depends on oneway or return ticket.
 */
static NSString *NibName = nil;
static NSIndexPath *selectedIndexPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSString *pathToCurrenciesFile = [AVIASALES_BUNDLE pathForResource:@"currencies" ofType:@"json"];
        if (pathToCurrenciesFile) {
            NSData *currenciesData = [NSData dataWithContentsOfFile:pathToCurrenciesFile options:kNilOptions error:nil];
            NSMutableArray *currencies = [[NSMutableArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:currenciesData options:kNilOptions error:NULL]];
            BOOL __block shouldAddDefaultCurrency = YES;
            NSString *upperCaseCurrencyCode = [[[AviasalesSDK sharedInstance] currencyCode] uppercaseString];
            [currencies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj[@"code"] isEqual:upperCaseCurrencyCode]) {
                    shouldAddDefaultCurrency = NO;
                    *stop = YES;
                }
            }];
            if (shouldAddDefaultCurrency) {
                [currencies addObject:@{
                                        @"code":
                                            [[AviasalesSDK sharedInstance] currencyCode],
                                        @"name":
                                            upperCaseCurrencyCode}];
                [[NSJSONSerialization dataWithJSONObject:currencies options:NSJSONWritingPrettyPrinted error:nil] writeToFile:pathToCurrenciesFile atomically:YES];
            }
            _currencies = currencies;
        }
        
        NibName = [ASTSearchParams sharedInstance].returnDate ? @"ASTResultsTicketCell" : @"ASTResultsTicketCellOneWay";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_progressLabel setText:AVIASALES_(@"AVIASALES_SEARCHING_PROGRESS")];
    [_filters setTitle:AVIASALES_(@"AVIASALES_FILTERS")];
    [_emptyLabel setText:AVIASALES_(@"AVIASALES_FILTERS_EMPTY")];
    
    [self.view bringSubviewToFront:_waitingView];
    [_progressView setProgress:0];
    
    _progressTimer = [NSTimer timerWithTimeInterval:AST_PROGRESS_UPDATE_INTERVAL target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_progressTimer forMode:NSRunLoopCommonModes];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ — %@", [ASTSearchParams sharedInstance].originIATA, [ASTSearchParams sharedInstance].destinationIATA];
    
    [self updateCurrencyButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateProgress {
    _progressView.progress += AST_PROGRESS_UPDATE_INTERVAL / AST_SEARCH_TIME;
    if (_progressView.progress >= 1) {
        [_progressTimer invalidate];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    
    if (_filter.needFiltering && [self.filteredTickets count] == 0) {
        [_emptyView setHidden:NO];
    } else {
        [_emptyView setHidden:YES];
    }
}

- (void)dealloc {
    [_progressTimer invalidate];
}

- (void)setResponse:(AviasalesSearchResponse *)response {
    _response = response;
    [self.tableView reloadData];
    
    [_progressView setProgress:1 animated:YES];
    
    [UIView animateWithDuration:0.5f animations:^{
        [_waitingView setAlpha:0];
    }];
    
    _filter = [[AviasalesFilter alloc] init];
    [_filter setResponse:_response];
    [_filter setDelegate:self];
    
    NSString *xibName = @"ASTFilters";
    if (AVIASALES_VC_GRANDPA_IS_TABBAR) {
        xibName = @"ASTFiltersTabBar";
    }
    
    _filtersVC = [[ASTFilters alloc] initWithNibName:xibName bundle:AVIASALES_BUNDLE];
    [_filtersVC setFilter:_filter];
    [_filtersVC setTickets:[self filteredTickets]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self tickets] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ASTResultsTicketCell";
    ASTResultsTicketCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[AVIASALES_BUNDLE loadNibNamed:NibName owner:self options:nil] objectAtIndex:0];
    }
    
    [cell applyTicket:[[self tickets] objectAtIndex:indexPath.section]];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedIndexPath = indexPath;
    
    ASTTicketScreen *ticketVC = [[ASTTicketScreen alloc] initWithNibName:@"ASTTicketScreen" bundle:AVIASALES_BUNDLE];
    
    ticketVC.ticket = [[self tickets] objectAtIndex:indexPath.section];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:AVIASALES_(@"AVIASALES_BACK") style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.backBarButtonItem = backButton;
    
    ticketVC.title = AVIASALES_(@"AVIASALES_TICKET");
    
    [self.navigationController pushViewController:ticketVC animated:YES];
}

#pragma mark - Actions

- (void)showCurrenciesList:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:AVIASALES_(@"AVIASALES_CURRENCY") delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (NSDictionary *currency in _currencies) {
        [sheet addButtonWithTitle:[NSString stringWithFormat:@"%@", [currency objectForKey:@"name"]]];
    }
    
    [sheet addButtonWithTitle:AVIASALES_(@"AVIASALES_CANCEL")];
    
    sheet.cancelButtonIndex = [_currencies count];
    
    [sheet showInView:self.view];
    
}

- (void)showFilters:(id)sender {
    
    [self.navigationController pushViewController:_filtersVC animated:NO];
    
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([_currencies count] <= buttonIndex) {
        return;
    }
    
    NSString *code = [[_currencies objectAtIndex:buttonIndex] objectForKey:@"code"];
    
    [[AviasalesSDK sharedInstance] updateCurrencyCode:code];
    
    [self.tableView reloadData];
    
    [self updateCurrencyButton];
    
}

#pragma mark - Private methods

- (void)updateCurrencyButton {
    
    [_currencyButton setTitle:[NSString stringWithFormat:@"%@: %@", AVIASALES_(@"AVIASALES_CURRENCY"), [[[AviasalesSDK sharedInstance] currencyCode] uppercaseString]]];
    
}

- (NSArray *)filteredTickets {
    NSArray *tickets = _filter.needFiltering && !_filter.filteringInProgress ? _filter.filteredTickets :_response.tickets ;
//    if (tickets.count) {
//        [_placeholderView setHidden:YES];
//    } else {
//        [_placeholderView setHidden:showBest];
//    }
//    _tableView.scrollEnabled = _placeholderView.hidden;
    
    return tickets;
}

- (NSArray*) tickets {
    if (_tickets) {
        return _tickets;
    }
    
    return _tickets = [self filteredTickets];
}

#pragma mark - AviasalesFilter delegate

- (void)filteringProccessFinished {
    _tickets = nil;
    [_tableView reloadData];
    [_filtersVC setTickets:[self filteredTickets]];
}

- (void)needReloadFilter {
    [_filtersVC buildTable];
    [_filtersVC.tableView reloadData];
}

@end
