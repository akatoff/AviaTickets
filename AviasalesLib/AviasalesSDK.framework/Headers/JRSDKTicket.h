@protocol JRSDKAirline, JRSDKFlightSegment, JRSDKPrice;

@protocol JRSDKTicket

@property (nonatomic, retain) NSSet <id <JRSDKFlightSegment>> *unorderedFlightSegments;
@property (nonatomic, retain) NSSet <id <JRSDKPrice>> *unorderedPrices;
@property (nonatomic, retain) id <JRSDKAirline> mainAirline;
@property (nonatomic, retain) NSNumber *simpleRating;
@property (nonatomic, retain) NSNumber *totalDuration;
@property (nonatomic, retain) NSNumber *delayDuration;
@property (nonatomic, retain) NSNumber *overnightStopover;

@property (nonatomic, retain) NSString *sign;
@property (nonatomic, retain) NSNumber *fromTrustedGate;

@end
