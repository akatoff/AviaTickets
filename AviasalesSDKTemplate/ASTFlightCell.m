//
//  ASTFlightCell.m
//  AviasalesSDKTemplate
//

#import "ASTFlightCell.h"

#import <AviasalesSDK/AviasalesSDK.h>

#import <SDWebImage/UIImageView+WebCache.h>

#import "ASTCommonFunctions.h"

@implementation ASTFlightCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

static NSNumberFormatter *flightNumberFormatter;
- (void)applyFlight:(AviasalesFlight *)flight {
    
    _route.text = [NSString stringWithFormat:@"%@ - %@", flight.origin.iata, flight.destination.iata];
    
    [self downloadImageForImageView:_logo withURL:flight.airline.logoURL];

    if (!flightNumberFormatter) {
        flightNumberFormatter = [[NSNumberFormatter alloc] init];
        [flightNumberFormatter setGroupingSize:0];
    }
    NSNumber *flightNumber = [flightNumberFormatter numberFromString:flight.number];
    _flightNumber.text = [NSString localizedStringWithFormat:@"%@ %@-%@", AVIASALES_(@"AVIASALES_FLIGHT"), flight.airline.iata, [flightNumberFormatter stringFromNumber:flightNumber]];
    
    _airline.text = flight.airline.name;
    
    _duration.text = flight.formattedDuration;
    
    static NSDateFormatter *dateFormatter = nil;
    static NSDateFormatter *timeFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSTimeZone *GMT = [NSTimeZone timeZoneForSecondsFromGMT:0];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"d MMM, EE"];
        [dateFormatter setTimeZone:GMT];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:AVIASALES__(@"AVIASALES_LANG", [NSLocale currentLocale].localeIdentifier)]];
        
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm"];
        [timeFormatter setTimeZone:GMT];
        [timeFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    
    _departureTime.text = [timeFormatter stringFromDate:flight.departure];
    
    _arrivalTime.text = [timeFormatter stringFromDate:flight.arrival];
    
    _departureDate.text = [dateFormatter stringFromDate:flight.departure];
    
    _arrivalDate.text = [dateFormatter stringFromDate:flight.arrival];
    
    _origin.text = [NSString stringWithFormat:@"%@ %@", flight.origin.city, flight.origin.iata];
    
    _destination.text = [NSString stringWithFormat:@"%@ %@", flight.destination.city, flight.destination.iata];
    
}

static NSMutableDictionary *downloadLogoErrors;

- (void)downloadImageForImageView:(__weak UIImageView *)logo withURL:(NSURL *)URL {
    
    [logo setImage:nil];
    [logo setHighlightedImage:nil];
    [logo setHidden:YES];
    
    [logo sd_setImageWithURL:URL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            NSString *urlWithError = [NSString stringWithFormat:@"%@", URL.relativePath];
            if (error.code == 404 && ![downloadLogoErrors objectForKey:urlWithError]) {
                if (!downloadLogoErrors) {
                    downloadLogoErrors = [[NSMutableDictionary alloc] init];
                }
                [downloadLogoErrors setObject:urlWithError forKey:urlWithError];
            }
        } else {
            [logo setHidden:NO];
        }
    }];
}

@end
