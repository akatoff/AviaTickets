//
//  ASTSearchResultsList.h
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 01.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import "ASTTableManager.h"

@class AviasalesTicket;

@protocol ASTSearchResultsListDelegate <NSObject>
- (NSArray<AviasalesTicket *> *)tickets;
- (void)didSelectTicketAtIndex:(NSInteger)index;
@end

@interface ASTSearchResultsList : NSObject <ASTTableManager>
@property (weak, nonatomic) id<ASTSearchResultsListDelegate> delegate;
@property (strong, nonatomic, readonly) NSString *ticketCellNibName;
- (instancetype)initWithCellNibName:(NSString *)cellNibName;
@end
