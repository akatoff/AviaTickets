//
//  JRSearchFormAirportCell.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRC.h"
#import "JRSearchFormAirportCell.h"
#import "UIImage+JRUIImage.h"

#define kJRSearchFormAirportCellPlaceholderFont [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0]

@interface JRSearchFormAirportCell ()

@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;
@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *airportNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *iataLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;

@end

@implementation JRSearchFormAirportCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_pinImageView setImage:[_pinImageView.image imageTintedWithColor:[JRC SF_CELL_IMAGES_TINT]]];
}


- (void)setupAirportLabelWithIATA:(NSString *)iata item:(JRSearchFormItem *)item
{
    
	NSString *placeholderString = nil;
    
    id <JRSDKAirport> airport = [AviasalesAirportsStorage getAirportByIATA:iata];
    
	NSString *cityString = [airport.city uppercaseString];
	NSString *countryNameString = [airport.country uppercaseString];
    
	NSMutableString *airportCountryString = [[NSMutableString alloc] init];
    
	if (iata) {
        
        // TODO: localize airport.isAny
		NSString *airportNameString = [airport.airportName uppercaseString];
        
		if (airportNameString.length > 0 && airport.city) {
			[airportCountryString appendString:airportNameString];
		} else {
            [airportCountryString appendString:@"…"];
        }
        
		if (countryNameString.length > 0) {
			if (airportCountryString.length > 0) {
				[airportCountryString appendString:@", "];
			}
			[airportCountryString appendString:countryNameString];
		}
        
	} else {
		if (item.type == JRSearchFormTableViewOriginAirportItem) {
			placeholderString = NSLS(@"JR_SEARCH_FORM_AIRPORT_CELL_EMPTY_ORIGIN");
		} else if (item.type == JRSearchFormTableViewDestinationAirportItem) {
			placeholderString = NSLS(@"JR_SEARCH_FORM_AIRPORT_CELL_EMPTY_DESTINATION");
		}
		placeholderString = [placeholderString uppercaseString];
	}
    
	[_placeholderLabel setText:placeholderString];
	[_cityNameLabel setText:cityString];
    
    [_airportNameLabel setText:airportCountryString];
    [_airportNameLabel setHidden:_airportNameLabel.text.length > 0 ? NO : YES];
}


- (void)setupIataLabelForSearchInfo:(JRSearchInfo *)searchInfo item:(JRSearchFormItem *)item
{
	[_iataLabel setTextColor:[JRC SF_AIRPORT_IATA_LABEL_TEXT_COLOR]];
    
	NSString *iataText = nil;
    
	JRTravelSegment *travelSegment = [searchInfo.travelSegments firstObject];
	if (item.type == JRSearchFormTableViewOriginAirportItem) {
		iataText = [travelSegment originIata];
	} else if (item.type == JRSearchFormTableViewDestinationAirportItem) {
		iataText = [travelSegment destinationIata];
	}
	iataText = [iataText uppercaseString];
	[_iataLabel setText:iataText];
    
	[self setupAirportLabelWithIATA:iataText item:item];
}

- (void)updateCell
{
	[self setupIataLabelForSearchInfo:self.searchInfo item:self.item];
}

- (void)action
{
	JRTravelSegment *travelSegment = [self.item.itemDelegate.searchInfo.travelSegments firstObject];
	if (self.item.type == JRSearchFormTableViewOriginAirportItem) {
		[self.item.itemDelegate selectOriginIATAForTravelSegment:travelSegment itemType:self.item.type];
	} else if (self.item.type == JRSearchFormTableViewDestinationAirportItem) {
		[self.item.itemDelegate selectDestinationIATAForTravelSegment:travelSegment itemType:self.item.type];
	}
}

@end
