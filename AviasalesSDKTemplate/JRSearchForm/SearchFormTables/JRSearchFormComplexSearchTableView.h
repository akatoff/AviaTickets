//
//  JRSearchFormComplexSearchTable.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 22/01/14.
//
//

#import "JRSearchFormSimpleSearchTableView.h"

@interface JRSearchFormComplexSearchTableView : JRSearchFormSimpleSearchTableView

@property (weak, nonatomic) JRSearchFormSimpleSearchTableView *travelClassAndPassengers;
@property (weak, nonatomic) NSLayoutConstraint *travelClassAndPassengersConstraint;
@property (weak, nonatomic) id<JRSearchFormItemDelegate> itemDelegate;
@end
