//
//  ASTResultsTicketCell.m
//  AviasalesSDKTemplate
//

#import "ASTResultsTicketCell.h"

#import <AviasalesSDK/AviasalesSDK.h>

#import <SDWebImage/UIImageView+WebCache.h>

#import "ASTCommonFunctions.h"

@implementation ASTResultsTicketCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)applyTicket:(AviasalesTicket *)ticket {
    
    [_price setText:ticket.formattedPrice];
    
    [_airline setText:ticket.mainAirline.iata];
    
    [self downloadImageForImageView:_logo withURL:ticket.mainAirlineLogoURL];
    
    static NSDateFormatter *dateFormatter = nil;
    static NSDateFormatter *timeFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSTimeZone *GMT = [NSTimeZone timeZoneForSecondsFromGMT:0];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"d MMM"];
        [dateFormatter setTimeZone:GMT];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:AVIASALES__(@"AVIASALES_LANG", [NSLocale currentLocale].localeIdentifier)]];
        
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm"];
        [timeFormatter setTimeZone:GMT];
        [timeFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    
    AviasalesFlight *firstOutboundFlight = [ticket.outboundFlights firstObject];
    _outboundDepartureIATA.text = firstOutboundFlight.origin.iata;
    _outboundDepartureDate.text = [dateFormatter stringFromDate:firstOutboundFlight.departure];
    _outboundDepartureTime.text = [timeFormatter stringFromDate:firstOutboundFlight.departure];
    
    AviasalesFlight *lastOutboundFlight = [ticket.outboundFlights lastObject];
    _outboundArrivalIATA.text = lastOutboundFlight.destination.iata;
    _outboundArrivalTime.text = [timeFormatter stringFromDate:lastOutboundFlight.arrival];
    
    AviasalesFlight *firstReturnFlight = [ticket.returnFlights firstObject];
    _returnDepartureIATA.text = firstReturnFlight.origin.iata;
    _returnDepartureDate.text = [dateFormatter stringFromDate:firstReturnFlight.departure];
    _returnDepartureTime.text = [timeFormatter stringFromDate:firstReturnFlight.departure];
    
    AviasalesFlight *lastReturnFlight = [ticket.returnFlights lastObject];
    _returnArrivalIATA.text = lastReturnFlight.destination.iata;
    _returnArrivalTime.text = [timeFormatter stringFromDate:lastReturnFlight.arrival];
    
    NSUInteger outboundFlightsCount = [ticket.outboundFlights count];
    if (outboundFlightsCount > 1) {
        _outboundFlightStopoversView.hidden = NO;
        _outboundFlightStopoversNumber.text = [NSString localizedStringWithFormat:@"%u", (unsigned int)(outboundFlightsCount-1)];
    } else {
        _outboundFlightStopoversView.hidden = YES;
    }
    
    NSUInteger returnFlightsCount = [ticket.returnFlights count];
    if (returnFlightsCount > 1) {
        _returnFlightStopoversView.hidden = NO;
        _returnFlightStopoversNumber.text = [NSString localizedStringWithFormat:@"%u", (unsigned int)(returnFlightsCount-1)];
    } else {
        _returnFlightStopoversView.hidden = YES;
    }
    
    _outboundFlightDuration.text = ticket.formattedOutboundDuration;
    _returnFlightDuration.text = ticket.formattedReturnDuration;
    
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
