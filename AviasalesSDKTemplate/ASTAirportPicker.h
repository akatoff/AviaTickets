//
//  ASTAirportPicker.h
//  AviasalesSDKTemplate
//
//  Created by Seva Billevich on 23.09.13.
//  Copyright (c) 2013 Go Travel Un Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AviasalesSDK/AviasalesSDK.h>

typedef NS_ENUM(NSUInteger, ASTAirportPickerMode) {
    ASTAirportPickerDeparture,
    ASTAirportPickerDestination
};

typedef NS_ENUM(NSUInteger, ASTAirportPickerState) {
    ASTAirportPickerStateIdle,
    ASTAirportPickerStateSearchingLocal,
    ASTAirportPickerStateSearchingLocalAndWeb
};

typedef NS_ENUM(NSUInteger, ASTAirportPickerNearestState) {
    ASTAirportPickerNearestStateIdle,
    ASTAirportPickerNearestStateSearching
};

@class ASTAirportPicker;

@protocol ASTAirportPickerDelegate <NSObject>
- (void)picker:(ASTAirportPicker *)picker didSelectAirport:(AviasalesAirport *)airport;
@end

@interface ASTAirportPicker : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate> {
    NSMutableArray *_searchResults;
    ASTAirportPickerState _pickerState;
    NSMutableArray *_nearestAirports;
    ASTAirportPickerNearestState _pickerNearestState;
}

- (id)initPickerWithMode:(ASTAirportPickerMode)pickerMode;

@property (nonatomic, readonly) ASTAirportPickerMode pickerMode;
@property (nonatomic, weak) id<ASTAirportPickerDelegate> delegate;

@end
