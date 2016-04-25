//
//  JRSearchFormComplexSearchTableHeader.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRSearchFormComplexSearchTableHeader.h"

@interface JRSearchFormComplexSearchTableHeader ()
@property (weak, nonatomic) IBOutlet UILabel *originLabel;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation JRSearchFormComplexSearchTableHeader

- (void)awakeFromNib
{
	[super awakeFromNib];
	[_originLabel setText:NSLS(@"JR_SEARCH_FORM_COMPLEX_ORIGIN")];
	[_destinationLabel setText:NSLS(@"JR_SEARCH_FORM_COMPLEX_DESTINATION")];
	[_dateLabel setText:NSLS(@"JR_SEARCH_FORM_COMPLEX_DATE")];
    
    self.accessibilityElementsHidden = YES;
}

@end
