//
//  ASTSearchForm.h
//  AviasalesSDKTemplate
//
//  Created by Seva Billevich on 17.09.13.
//  Copyright (c) 2013 Go Travel Un Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AviasalesSDK/AviasalesSDK.h>

#import "ASTAirportPicker.h"

@interface ASTSearchForm : UIViewController <ASTAirportPickerDelegate, UITableViewDataSource, UITableViewDelegate>

+ (void)launchFromViewController:(UIViewController *)viewController withOriginIATA:(NSString *)originIATA destinationIATA:(NSString *)destinationIATA departureDate:(NSString *)departureDate returnDate:(NSString *)returnDate;

+ (void)setMarker:(NSString *)marker andAPIToken:(NSString *)APIToken;

@property (nonatomic, strong) AviasalesAirport *origin;
@property (nonatomic, strong) AviasalesAirport *destination;

@property (nonatomic, strong) NSDate *departureDate;
@property (nonatomic, strong) NSDate *returnDate;

@property (nonatomic, assign) int adultsNumber;
@property (nonatomic, assign) int childrenNumber;
@property (nonatomic, assign) int infantsNumber;
@property (nonatomic, assign) int travelClass;

@property (nonatomic, assign) BOOL returnFlight;

- (IBAction)stepperDidChangeValue:(UIStepper *)stepper;
- (IBAction)travelClassSelected:(UISegmentedControl *)segmentedControl;
- (void)switchAirports;

- (void)updateOrigin:(NSString *)originIATA;
- (void)updateDestination:(NSString *)destinationIATA;

- (void)updateDepartureDate:(NSDate *)departureDate;
- (void)updateReturnDate:(NSDate *)returnDate;

@end
