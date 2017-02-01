//
//  RatesProvider.m
//  iRate
//
//  Created by Dmitry Varentsov on 31/01/2017.
//  Copyright © 2017 Dmitry Varentsov. All rights reserved.
//

#import "RatesProvider.h"

#import "RatesRawDataProvider.h"
#import "RatesParser.h"

NSString *const kEUR = @"EUR";
NSString *const kGBP = @"GBP";
NSString *const kUSD = @"USD";
NSString *const kRatesProviderDidUpdateRates = @"RatesProviderDidUpdateRates";

static const NSTimeInterval kPollingInterval = 30.; //30 seconds

@interface RatesProvider ()

@property (strong, nonatomic) NSDictionary<NSString *, NSString *> *rates;
@property (strong, nonatomic) RatesRawDataProvider *rawDataProvider;
@property (strong, nonatomic) NSTimer *pollingTimer;
@property (nonatomic) BOOL inprogress;

@end

@implementation RatesProvider

+ (instancetype)sharedInstance
{
	static dispatch_once_t onceToken;
	static RatesProvider *staticInstance = nil;
	dispatch_once(&onceToken, ^{
		staticInstance = [self new];
	});
	return staticInstance;
}

- (BOOL)isReady
{
	return self.rates != nil;
}

- (NSDecimalNumber *)crossConvertFrom:(NSString *)from to:(NSString *)to
{
	if ([to isEqualToString:from]) {
		return [NSDecimalNumber one];
	}
	if ([from isEqualToString:kEUR]) {
		return [[NSDecimalNumber one] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:self.rates[to]]];
	}
	if ([to isEqualToString:kEUR]) {
		return self.rates[from] ? [NSDecimalNumber decimalNumberWithString:self.rates[from]] : nil;
	}
	if (!self.rates[from] || self.rates[to]) {
		return nil;
	}
	return [[NSDecimalNumber decimalNumberWithString:self.rates[from]] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:self.rates[to]]];
}

- (void)scheduleRatesUpdateIfNeeded
{
	__weak typeof(self) weakSelf = self;
	if (!self.pollingTimer) {
		self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:kPollingInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
			typeof(weakSelf) strongSelf = weakSelf;
			[strongSelf performRequest];
		}];
	}
	[self performRequest];
}

- (void)performRequest
{
	if (self.inprogress || (self.pollingTimer.isValid && self.isReady)) {
		return;
	}
	self.inprogress = YES;
	__weak typeof(self) weakSelf = self;
	[[RatesRawDataProvider sharedInstance] requestRatesRawDataWithCompletion:^(NSXMLParser *_Nullable parser) {
		if (!parser) {
			typeof(weakSelf) strongSelf = weakSelf;
			strongSelf.inprogress = NO;
			return;
		}
		__block RatesParser *ratesParser = [[RatesParser alloc] initWithParser:parser
														  lookingForAttributes:@[kGBP, kUSD]
																	completion:^(NSDictionary *_Nonnull newRates) {
																		typeof(weakSelf) strongSelf = weakSelf;
																		strongSelf.rates = [newRates copy];
																		[[NSNotificationCenter defaultCenter] postNotificationName:kRatesProviderDidUpdateRates object:strongSelf];
																		strongSelf.inprogress = NO;
																		ratesParser = nil; //release
																	}];
	}];
}

@end
