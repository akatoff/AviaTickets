@protocol JRSDKAirline, JRSDKFlight;

@protocol JRSDKFlightSegment

@property (nonatomic, retain) id <JRSDKAirline> segmentAirline;
@property (nonatomic, retain) NSSet <id <JRSDKFlight>> *unorderedFlights;
@property (nonatomic, retain) NSNumber *totalDuration;
@property (nonatomic, retain) NSNumber *delayDuration;
@property (nonatomic, retain) NSNumber *overnightStopover;
@property (nonatomic, retain) NSNumber *transferToAnotherAirport;

@property (nonatomic, retain) NSNumber *departureDateTimestamp;
@property (nonatomic, retain) NSNumber *arrivalDateTimestamp;

@end