//
//  ASTTicketScreen.m
//  AviasalesSDKTemplate
//
//  Created by Seva Billevich on 21.10.13.
//  Copyright (c) 2013 Go Travel Un Limited. All rights reserved.
//

#import "ASTTicketScreen.h"
#import <AviasalesSDK/AviasalesSDK.h>

#import "ASTCommonFunctions.h"
#import "ASTSearchParams.h"

#import "ASTFlightCell.h"
#import "ASTStopoverCell.h"

#import "ASTWebBrowserViewController.h"

@interface ASTTicketScreen ()

@end

@implementation ASTTicketScreen

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _waitingView.hidden = YES;
    [self.view addSubview:_waitingView];
    [_waitingLabel setText:AVIASALES_(@"AVIASALES_PLEASE_WAIT")];
    
    [_buyButton setTitle:AVIASALES_(@"AVIASALES_BUY") forState:UIControlStateNormal];
    
    [self applyTicket:_ticket];
	self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillLayoutSubviews {
    [_waitingView setFrame:self.view.bounds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)applyTicket:(AviasalesTicket *)ticket {
    [_passengersInfo setText:[[ASTSearchParams sharedInstance] getPassengersInfoString]];
    
    [_price setText:[NSString stringWithFormat:@"%@ %@", [ASTCommonFunctions formatPrice:ticket.totalPriceInUserCurrency], [[AviasalesSDK sharedInstance] currencySymbol]]];
    
    NSMutableString *gateName = [[NSMutableString alloc] init];
    
    [gateName appendString:[[[_ticket.prices firstObject] gate] gateName]];
    
    if ([ticket.prices count] > 1) {
        [gateName appendString:@" ▾"];
    } else {
        [_mainGate setTintColor:[UIColor darkGrayColor]];
        [_mainGate setUserInteractionEnabled:NO];
    }
    
    [_mainGate setTitle:gateName forState:UIControlStateNormal];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_ticket.returnFlights count] > 0) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [_ticket.outboundFlights count] * 2 - 1;
    } else {
        return [_ticket.returnFlights count] * 2 - 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    
    if (indexPath.row % 2 == 0) {
        cellIdentifier = @"ASTFlightCell";
        ASTFlightCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[AVIASALES_BUNDLE loadNibNamed:@"ASTFlightCell" owner:self options:nil] objectAtIndex:0];
        }
        
        AviasalesFlight *flight;
        
        if (indexPath.section == 0) {
            flight = [_ticket.outboundFlights objectAtIndex:indexPath.row/2];
        } else {
            flight = [_ticket.returnFlights objectAtIndex:indexPath.row/2];
        }
        
        [cell applyFlight:flight];
        
        return cell;
    } else {
        cellIdentifier = @"ASTStopoverCell";
        ASTStopoverCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[AVIASALES_BUNDLE loadNibNamed:@"ASTStopoverCell" owner:self options:nil] objectAtIndex:0];
            cell.stopoverLabel.text = AVIASALES_(@"AVIASALES_STOPOVER");
        }
        
        AviasalesFlight *flight;
        
        if (indexPath.section == 0) {
            flight = [_ticket.outboundFlights objectAtIndex:((indexPath.row+1)/2)];
        } else {
            flight = [_ticket.returnFlights objectAtIndex:((indexPath.row+1)/2)];
        }
        
        [cell applyFlight:flight];
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0) {
        return 170;
    } else {
        return 55;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - Actions

- (void)showOtherAgencies:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:AVIASALES_(@"AVIASALES_FILTER_AGENCIES") delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (AviasalesPrice *price in _ticket.prices) {
        [sheet addButtonWithTitle:[NSString stringWithFormat:@"%@ — %@ %@", price.gate.gateName, [ASTCommonFunctions formatPrice:price.value], [[AviasalesSDK sharedInstance] currencySymbol]]];
    }
    
    
    
    [sheet addButtonWithTitle:AVIASALES_(@"AVIASALES_CANCEL")];
    
    sheet.cancelButtonIndex = [_ticket.prices count];
    
    [sheet showInView:self.view];
    
}

- (void)buyBest:(id)sender {
    [self redirectToPurchaseWithPrice:[_ticket.prices firstObject]];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([_ticket.prices count] <= buttonIndex) {
        return;
    }
    
    AviasalesPrice *selectedPrice = [_ticket.prices objectAtIndex:buttonIndex];
    
    [self redirectToPurchaseWithPrice:selectedPrice];
    
}

#pragma mark - Private methods

- (void)redirectToPurchaseWithPrice:(AviasalesPrice *)price {
    
    _waitingView.hidden = NO;
    [self.view bringSubviewToFront:_waitingView];
    
    [price getRedirectRequest:^(NSURLRequest *request, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSString *errorText = AVIASALES_(@"AVIASALES_ALERT_UNKNOWN_ERROR_TEXT");
                if ([error isKindOfClass:[NSError class]] && [[error localizedDescription] length] > 0) {
                    errorText = [error localizedDescription];
                }
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:AVIASALES_(@"AVIASALES_ALERT_ERROR_TITLE") message:errorText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                ASTWebBrowserViewController *webBrowser = [[ASTWebBrowserViewController alloc] initWithRequest:request];
                
                UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:AVIASALES_(@"AVIASALES_CANCEL") style:UIBarButtonItemStylePlain target:nil action:nil];
                
                self.navigationItem.backBarButtonItem = backButton;
                
                webBrowser.title = price.gate.gateName;
                
                [self.navigationController pushViewController:webBrowser animated:YES];
            }
            [_waitingView setHidden:YES];
        });
    }];
}

@end
