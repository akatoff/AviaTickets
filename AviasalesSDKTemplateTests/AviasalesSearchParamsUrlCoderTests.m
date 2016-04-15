//
//  AviasalesSearchParamsUrlCoderTests.m
//  AviasalesSDKTemplate
//
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AviasalesSDK/AviasalesSearchParamsUrlCoder.h>
#import <AviasalesSDK/AviasalesSearchParams.h>

@interface AviasalesSearchParamsUrlCoderTests : XCTestCase
@property (strong, nonatomic) id<AviasalesSearchParamsCoder> coder;
@end

@implementation AviasalesSearchParamsUrlCoderTests


- (void)setUp {
    [super setUp];
    self.coder = [[AviasalesSearchParamsUrlCoder alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Encoding

#pragma mark One way

- (void)testOneWayFlightWithOnePassengerCorrectlyEncodedToUrl {
    AviasalesSearchParams *const searchParams = [[AviasalesSearchParams alloc] init];

    searchParams.originIATA = @"LED";
    searchParams.destinationIATA = @"MOW";
    searchParams.departureDate = [self gmtDateFromString: @"12.05.2016"];
    searchParams.adultsNumber = 1;
    searchParams.travelClass = 0;

    NSString *const resultString = [self.coder encodeSearchParams:searchParams];

    XCTAssertEqualObjects(resultString, @"LED1205MOW1Y");
}

- (void)testOneWayFlightWithSevenBusinessPassengerCorrectlyEncodedToUrl {
    AviasalesSearchParams *const searchParams = [[AviasalesSearchParams alloc] init];

    searchParams.originIATA = @"LED";
    searchParams.destinationIATA = @"MOW";
    searchParams.departureDate = [self gmtDateFromString: @"12.05.2016"];
    searchParams.adultsNumber = 7;
    searchParams.travelClass = 1;

    NSString *const resultString = [self.coder encodeSearchParams:searchParams];

    XCTAssertEqualObjects(resultString, @"LED1205MOW7C");
}

- (void)testOneWayFlightWithDifferentPassengerCorrectlyEncodedToUrl {
    AviasalesSearchParams *const searchParams = [[AviasalesSearchParams alloc] init];

    searchParams.originIATA = @"LED";
    searchParams.destinationIATA = @"MOW";
    searchParams.departureDate = [self gmtDateFromString: @"12.05.2016"];
    searchParams.adultsNumber = 8;
    searchParams.childrenNumber = 5;
    searchParams.infantsNumber = 3;
    searchParams.travelClass = 0;

    NSString *const resultString = [self.coder encodeSearchParams:searchParams];

    XCTAssertEqualObjects(resultString, @"LED1205MOW853Y");
}

#pragma mark Two ways

- (void)testTwoWaysFlightWithOnePassengerCorrectlyEncodedToUrl {
    AviasalesSearchParams *const searchParams = [[AviasalesSearchParams alloc] init];

    searchParams.originIATA = @"LED";
    searchParams.destinationIATA = @"MOW";
    searchParams.departureDate = [self gmtDateFromString: @"12.05.2016"];
    searchParams.returnDate = [self gmtDateFromString:@"15.06.2016"];
    searchParams.returnFlight = YES;
    searchParams.adultsNumber = 1;
    searchParams.travelClass = 0;

    NSString *const resultString = [self.coder encodeSearchParams:searchParams];

    XCTAssertEqualObjects(resultString, @"LED1205MOW-MOW1506LED1Y");
}

- (void)testTwoWaysFlightWithSevenBusinessPassengerCorrectlyEncodedToUrl {
    AviasalesSearchParams *const searchParams = [[AviasalesSearchParams alloc] init];

    searchParams.originIATA = @"LED";
    searchParams.destinationIATA = @"MOW";
    searchParams.departureDate = [self gmtDateFromString: @"12.05.2016"];
    searchParams.returnDate = [self gmtDateFromString:@"15.06.2016"];
    searchParams.returnFlight = YES;
    searchParams.adultsNumber = 7;
    searchParams.travelClass = 1;

    NSString *const resultString = [self.coder encodeSearchParams:searchParams];

    XCTAssertEqualObjects(resultString, @"LED1205MOW-MOW1506LED7C");
}

- (void)testTwoWaysFlightWithDifferentPassengerCorrectlyEncodedToUrl {
    AviasalesSearchParams *const searchParams = [[AviasalesSearchParams alloc] init];

    searchParams.originIATA = @"LED";
    searchParams.destinationIATA = @"MOW";
    searchParams.departureDate = [self gmtDateFromString: @"12.05.2016"];
    searchParams.returnDate = [self gmtDateFromString:@"15.06.2016"];
    searchParams.returnFlight = YES;
    searchParams.adultsNumber = 8;
    searchParams.childrenNumber = 5;
    searchParams.infantsNumber = 3;
    searchParams.travelClass = 0;

    NSString *const resultString = [self.coder encodeSearchParams:searchParams];

    XCTAssertEqualObjects(resultString, @"LED1205MOW-MOW1506LED853Y");
}

#pragma mark - Decoding
#pragma mark One way

- (void)testOneWayFlightWithOnePassengerCorrectlyDecodedFromUrl {
    NSString *const inputString = @"LED1205MOW1Y";
    AviasalesSearchParams *const searchParams = [self.coder searchParamsWithString:inputString];

    XCTAssertEqualObjects(searchParams.originIATA, @"LED");
    XCTAssertEqualObjects(searchParams.destinationIATA, @"MOW");
    NSString *const returnDateAsString = [self stringFromGMTDate: searchParams.departureDate];
    XCTAssertTrue([returnDateAsString hasPrefix:@"12.05"]);
    XCTAssertEqual(searchParams.adultsNumber, 1);
    XCTAssertEqual(searchParams.travelClass, 0);

}

- (void)testOneWayFlightWithSevenBusinessPassengerCorrectlyDecodedFromUrl {
    NSString *const inputString = @"LED1205MOW7C";
    AviasalesSearchParams *const searchParams = [self.coder searchParamsWithString:inputString];

    XCTAssertEqualObjects(searchParams.originIATA, @"LED");
    XCTAssertEqualObjects(searchParams.destinationIATA, @"MOW");
    XCTAssertTrue([[self stringFromGMTDate: searchParams.departureDate] hasPrefix:@"12.05"]);
    XCTAssertEqual(searchParams.adultsNumber, 7);
    XCTAssertEqual(searchParams.travelClass, 1);
}

- (void)testOneWayFlightWithDifferentPassengerCorrectlyDecodedFromUrl {
    NSString *const inputString = @"LED1205MOW853Y";
    AviasalesSearchParams *const searchParams = [self.coder searchParamsWithString:inputString];

    XCTAssertEqualObjects(searchParams.originIATA, @"LED");
    XCTAssertEqualObjects(searchParams.destinationIATA, @"MOW");
    XCTAssertTrue([[self stringFromGMTDate: searchParams.departureDate] hasPrefix:@"12.05"]);
    XCTAssertEqual(searchParams.adultsNumber, 8);
    XCTAssertEqual(searchParams.childrenNumber, 5);
    XCTAssertEqual(searchParams.infantsNumber, 3);
    XCTAssertEqual(searchParams.travelClass, 0);
}

#pragma mark Two ways

- (void)testTwoWaysFlightWithOnePassengerCorrectlyDecodedFromUrl {
    NSString *const inputString = @"LED1205MOW-MOW1506LED1Y";
    AviasalesSearchParams *const searchParams = [self.coder searchParamsWithString:inputString];

    XCTAssertEqualObjects(searchParams.originIATA, @"LED");
    XCTAssertEqualObjects(searchParams.destinationIATA, @"MOW");
    XCTAssertTrue([[self stringFromGMTDate: searchParams.departureDate] hasPrefix:@"12.05"]);
    XCTAssertTrue([[self stringFromGMTDate: searchParams.returnDate] hasPrefix:@"15.06"]);
    XCTAssertEqual(searchParams.returnFlight, YES);
    XCTAssertEqual(searchParams.adultsNumber, 1);
    XCTAssertEqual(searchParams.travelClass, 0);

}

- (void)testTwoWaysFlightWithSevenBusinessPassengerCorrectlyDecodedFromUrl {
    NSString *const inputString = @"LED1205MOW-MOW1506LED7C";
    AviasalesSearchParams *const searchParams = [self.coder searchParamsWithString:inputString];

    XCTAssertEqualObjects(searchParams.originIATA, @"LED");
    XCTAssertEqualObjects(searchParams.destinationIATA, @"MOW");
    XCTAssertTrue([[self stringFromGMTDate: searchParams.departureDate] hasPrefix:@"12.05"]);
    XCTAssertTrue([[self stringFromGMTDate: searchParams.returnDate] hasPrefix:@"15.06"]);
    XCTAssertEqual(searchParams.returnFlight, YES);
    XCTAssertEqual(searchParams.adultsNumber, 7);
    XCTAssertEqual(searchParams.travelClass, 1);

}

- (void)testTwoWaysFlightWithDifferentPassengerCorrectlyDecodedFromUrl {
    NSString *const inputString = @"LED1205MOW-MOW1506LED853Y";
    AviasalesSearchParams *const searchParams = [self.coder searchParamsWithString:inputString];

    XCTAssertEqualObjects(searchParams.originIATA, @"LED");
    XCTAssertEqualObjects(searchParams.destinationIATA, @"MOW");
    XCTAssertTrue([[self stringFromGMTDate: searchParams.departureDate] hasPrefix:@"12.05"]);
    XCTAssertTrue([[self stringFromGMTDate: searchParams.returnDate] hasPrefix:@"15.06"]);
    XCTAssertEqual(searchParams.returnFlight, YES);
    XCTAssertEqual(searchParams.adultsNumber, 8);
    XCTAssertEqual(searchParams.childrenNumber, 5);
    XCTAssertEqual(searchParams.infantsNumber, 3);
    XCTAssertEqual(searchParams.travelClass, 0);
}
#pragma mark - Utils
- (NSDate *)gmtDateFromString:(NSString *)string {
    return [self.gmtDateFormatter dateFromString:string];
}

- (NSString *)stringFromGMTDate:(NSDate *)date {
    return [self.gmtDateFormatter stringFromDate:date];
}

- (NSDateFormatter *)gmtDateFormatter {
    NSDateFormatter *const dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";

    NSTimeZone *const gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];

    return dateFormatter;
}
@end
