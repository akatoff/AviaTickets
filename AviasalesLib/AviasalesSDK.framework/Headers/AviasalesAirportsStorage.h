#import <Foundation/Foundation.h>

@protocol JRSDKAirport;

#define kAviasalesAirportsStorageNewAirportsParsedNotificationName @"kAviasalesAirportsStorageNewAirportsParsedNotificationName"


@interface AviasalesAirportsStorage : NSObject

+ (AviasalesAirportsStorage *)sharedInstance;
@property (strong, nonatomic) NSArray *topAirports;

+ (id <JRSDKAirport>)getAirportByIATA:(NSString *)iata;
+ (NSArray *)topAirports;
+ (NSString *)mainIATAByIATA:(NSString *)iata;

+ (NSDictionary *)topAirportsDictionary;
+ (NSDictionary *)allAirportsDictionary;

@end