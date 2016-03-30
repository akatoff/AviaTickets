//
//  AviasalesSearchParamsUrlCoderTests.m
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 30.03.16.
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

#pragma mark - One way

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

#pragma mark - Two ways

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

#pragma mark - Utils
- (NSDate *)gmtDateFromString:(NSString *)string {
    NSDateFormatter *const dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";

    NSTimeZone *const gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    return [dateFormatter dateFromString:string];
}
@end
