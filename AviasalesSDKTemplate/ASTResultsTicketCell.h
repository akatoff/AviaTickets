//
//  ASTResultsTicketCell.h
//  AviasalesSDKTemplate
//
//  Created by Seva Billevich on 18.10.13.
//  Copyright (c) 2013 Go Travel Un Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AviasalesTicket;

@interface ASTResultsTicketCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *price;

@property (nonatomic, weak) IBOutlet UILabel *airline;
@property (nonatomic, weak) IBOutlet UIImageView *logo;

@property (nonatomic, weak) IBOutlet UILabel *outboundDepartureDate;
@property (nonatomic, weak) IBOutlet UILabel *returnDepartureDate;

@property (nonatomic, weak) IBOutlet UILabel *outboundDepartureTime;
@property (nonatomic, weak) IBOutlet UILabel *returnDepartureTime;

@property (nonatomic, weak) IBOutlet UILabel *outboundDepartureIATA;
@property (nonatomic, weak) IBOutlet UILabel *returnDepartureIATA;

@property (nonatomic, weak) IBOutlet UILabel *outboundArrivalTime;
@property (nonatomic, weak) IBOutlet UILabel *returnArrivalTime;

@property (nonatomic, weak) IBOutlet UILabel *outboundArrivalIATA;
@property (nonatomic, weak) IBOutlet UILabel *returnArrivalIATA;

@property (nonatomic, weak) IBOutlet UIView *outboundFlightStopoversView;
@property (nonatomic, weak) IBOutlet UILabel *outboundFlightStopoversNumber;
@property (nonatomic, weak) IBOutlet UIView *returnFlightStopoversView;
@property (nonatomic, weak) IBOutlet UILabel *returnFlightStopoversNumber;

@property (nonatomic, weak) IBOutlet UILabel *outboundFlightDuration;
@property (nonatomic, weak) IBOutlet UILabel *returnFlightDuration;

- (void)applyTicket:(AviasalesTicket *)ticket;

@end
