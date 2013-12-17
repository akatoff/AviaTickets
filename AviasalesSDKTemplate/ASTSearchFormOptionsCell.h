//
//  ASTSearchFormOptionsCell.h
//  aviasales
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ASTStepperType) {
    ASTStepperTypeAdults = 1,
    ASTStepperTypeChildren,
    ASTStepperTypeInfants
};

@interface ASTSearchFormOptionsCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIStepper* stepperAdults;
@property (nonatomic, weak) IBOutlet UIStepper* stepperChildren;
@property (nonatomic, weak) IBOutlet UIStepper* stepperInfants;

@property (nonatomic, weak) IBOutlet UILabel* labelAdults;
@property (nonatomic, weak) IBOutlet UILabel* labelChildren;
@property (nonatomic, weak) IBOutlet UILabel* labelInfants;

@property (nonatomic, weak) IBOutlet UILabel* captionAdults;
@property (nonatomic, weak) IBOutlet UILabel* captionChildren;
@property (nonatomic, weak) IBOutlet UILabel* captionInfants;

@property (nonatomic, weak) IBOutlet UISegmentedControl* classSelector;

@end
