//
//  JRSearchFormDateCell.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 21/01/14.
//
//

#import "JRC.h"
#import "DateUtil.h"
#import "JRSearchFormDateCell.h"
#import "UIView+FadeAnimation.h"

#define JRSearchFormDateCellFontSize 18
#define kJRSearchFormTravelClassCellAnimationDuration 0.1

@interface JRSearchFormDateCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *buttonTitle;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end


@implementation JRSearchFormDateCell


- (void)awakeFromNib
{
	[super awakeFromNib];
    
	[_buttonTitle setText:NSLS(@"JR_SEARCH_FORM_DATE_CELL_RETURN_BUTTON_TITLE")];
    [_button setAccessibilityLabelWithNSLSKey:@"JR_SEARCH_FORM_DATE_CELL_RETURN_BUTTON_TITLE"];
}

- (void)updateCell
{
	[self setupIconImage];
	[self updateDateLabel];
}

- (BOOL)isReturnItem
{
    return self.item.type == JRSearchFormTableViewReturnDateItem;
}

- (void)setupIconImage
{
	UIImage *image = [UIImage imageNamed:@"JRSearchFormDirectDateIcon"];
    [_iconImageView setImage:[UIImage imageWithCGImage:image.CGImage
                                                 scale:image.scale
                                           orientation:[self isReturnItem] ? UIImageOrientationUpMirrored : UIImageOrientationUp]];
}

- (void)updateDateLabel
{
	_button.hidden = _buttonTitle.hidden = self.item.type == JRSearchFormTableViewDirectDateItem;
    
	NSDate *date = nil;
	NSMutableAttributedString *dateAttributedString  = nil;
    
	if (self.item.type == JRSearchFormTableViewDirectDateItem) {
		date = [[self.searchInfo.travelSegments firstObject] departureDate];
	} else if (self.item.type == JRSearchFormTableViewReturnDateItem) {
		if (self.searchInfo.travelSegments.count >= 2) {
			date = [(self.searchInfo.travelSegments)[1] departureDate];
		}
	}
    
	if (date) {
		[_button setSelected:YES];
        static NSDateFormatter *dateFormatter;
        if (dateFormatter == nil) {
            dateFormatter = [NSDateFormatter applicationUIDateFormatter];
        }
		[dateFormatter setDateFormat:@"EEE"];
		NSString *weekday = [dateFormatter stringFromDate:date];
		weekday = [NSString stringWithFormat:@", %@", weekday];

        NSString *dateString;
        if (Aviasales()) {
            dateString = iPhone() ? [DateUtil dayMonthYearStringFromDate:date] : [DateUtil dayFullMonthYearStringFromDate:date];
        } else {
            dateString = iPhone() ? [DateUtil dayMonthYearWeekdayStringFromDate:date] : [DateUtil fullDayMonthYearWeekdayStringFromDate:date];
        }

		UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:JRSearchFormDateCellFontSize];
		UIFont *regularFont = [UIFont fontWithName:@"HelveticaNeue" size:JRSearchFormDateCellFontSize];
		dateAttributedString = [[NSMutableAttributedString alloc] initWithString:dateString attributes: @{ NSFontAttributeName : boldFont}];
        if (Aviasales()) {
            [dateAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", weekday] attributes: @{ NSFontAttributeName : regularFont}]];
            NSArray *dmy = [DateUtil dayMonthYearComponentsFromDate:date];
            NSString *year = dmy[2];
            [dateAttributedString addAttribute:NSFontAttributeName value:regularFont range:[dateAttributedString.string rangeOfString:year]];
        }
        [dateAttributedString addAttribute:NSForegroundColorAttributeName value:[JRC SF_DATES_TEXT_COLOR] range:NSMakeRange(0, dateAttributedString.length)];
        
        [_dateLabel setAccessibilityLabel:[DateUtil stringForSpeakDayMonthYearDayOfWeek:date]];
	} else {
		[_button setSelected:NO];
	}
    
	[_dateLabel setAttributedText:dateAttributedString];
    
	[self updatePlaceholderLabel];
}

- (void)updatePlaceholderLabel
{
	NSString *placeholderString = nil;
    
	if (_dateLabel.text.length == 0) {
		if (self.item.type == JRSearchFormTableViewDirectDateItem) {
			placeholderString = NSLS(@"JR_SEARCH_FORM_DATE_CELL_EMPTY_DIRECT");
		} else if (self.item.type == JRSearchFormTableViewReturnDateItem) {
			placeholderString = NSLS(@"JR_SEARCH_FORM_DATE_CELL_EMPTY_RETURN");
		}
	}
	[_placeholderLabel setText:[placeholderString uppercaseString]];
}

- (IBAction)returnDateButtonAction:(UIButton *)sender
{
	NSUInteger objectAtIndex = 1;
    
	JRTravelSegment *travelSegment = self.searchInfo.travelSegments.count > objectAtIndex ?
    (self.searchInfo.travelSegments)[objectAtIndex] : nil;
    
	if (travelSegment.departureDate) {
		[self.item.itemDelegate saveReturnFlightTravelSegment];
	} else {
		[self.item.itemDelegate restoreReturnFlightTravelSegment];
	}
}

- (void)action
{
	JRTravelSegment *travelSegment = nil;
	if (self.item.type == JRSearchFormTableViewDirectDateItem) {
		travelSegment = [self.searchInfo.travelSegments firstObject];
	} else if (self.item.type == JRSearchFormTableViewReturnDateItem) {
		if (self.searchInfo.travelSegments.count >= 2) {
			travelSegment = (self.searchInfo.travelSegments)[1];
		}
	}
	[self.item.itemDelegate selectDepartureDateForTravelSegment:travelSegment itemType:self.item.type];
}

#pragma mark accessibility container

- (BOOL)isAccessibilityElement
{
    return NO;
}

- (NSInteger)accessibilityElementCount
{
    if ([self isReturnItem]) {
        return 2;
    }
    return 1;
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
    if (index == 0) {
        if (_placeholderLabel.text) {
            return _placeholderLabel;
        } else {
            return _dateLabel;
        }
    } else if (index == 1) {
        return _button;
    }
    return nil;
}

@end
