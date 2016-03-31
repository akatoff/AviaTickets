//
//  ASTTicketScreen.h
//  AviasalesSDKTemplate
//
//  Created by Seva Billevich on 21.10.13.
//  Copyright (c) 2013 Go Travel Un Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AviasalesTicket;

@interface ASTTicketScreen : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

- (IBAction)buyBest:(id)sender;
- (IBAction)showOtherAgencies:(id)sender;

@property (nonatomic, strong) AviasalesTicket *ticket;

@property (nonatomic, weak) IBOutlet UILabel *passengersInfo;
@property (nonatomic, weak) IBOutlet UIButton *mainGate;
@property (nonatomic, weak) IBOutlet UILabel *price;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UIView *waitingView;
@property (nonatomic, weak) IBOutlet UILabel *waitingLabel;

@property (nonatomic, weak) IBOutlet UIButton *buyButton;

@end
