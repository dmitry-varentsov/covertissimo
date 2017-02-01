//
//  RatesModel.m
//  iRate
//
//  Created by Dmitry Varentsov on 31/01/2017.
//  Copyright © 2017 Dmitry Varentsov. All rights reserved.
//

#import "RatesModel.h"
#import "RatesProvider.h"
#import <ReactiveObjC/RACEXTKeyPathCoding.h>
#import <ReactiveObjC/RACEXTScope.h>
#import "NSObject+RACDeallocating.h"
#import "NSObject+RACDescription.h"
#import "RACSignal+Operations.h"

@interface RatesModel ()

@property (strong, nonatomic) NSMutableDictionary <NSString *, NSDecimalNumber *> *rests;
@property (strong, nonatomic) NSArray<NSString *> *currencyNames;
@property (strong, nonatomic) NSDictionary<NSString *, NSString *> *symbols;
@property (strong, nonatomic) NSArray *subscribers;

@end

@implementation RatesModel

- (instancetype)init
{
	self = [super init];
	
	self.subscribers = [NSArray array];
	
	self.currencyNames = @[kEUR, kGBP, kUSD];
	self.rests = [NSMutableDictionary dictionaryWithObjects:@[
					[NSDecimalNumber numberWithInt:100],
					[NSDecimalNumber numberWithInt:100],
					[NSDecimalNumber numberWithInt:100]] forKeys:self.currencyNames];
	self.from = kEUR;
	self.to = kUSD;
	self.symbols = @{kUSD: @"$", kEUR:@"€", kGBP: @"£"};
	[RatesProvider.sharedInstance scheduleRatesUpdateIfNeeded];
	
	return self;
}

- (NSDecimalNumber *)restForCurrency:(NSString *)currency
{
	return self.rests[currency];
}

- (BOOL)convertFrom:(NSString *)from to:(NSString *)to amount:(NSDecimalNumber *)amount rate:(NSDecimalNumber *)rate
{
	if ([from isEqualToString:to]) {
		return NO;
	}
	NSDecimalNumber *rest = self.rests[from];
	if ([rest compare:amount] >= NSOrderedSame) {
		NSDecimalNumberHandler *rounder = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers
																								 scale:2
																					  raiseOnExactness:NO
																					   raiseOnOverflow:NO
																					  raiseOnUnderflow:NO
																				   raiseOnDivideByZero:YES];
		self.rests[from] = [[rest decimalNumberBySubtracting:amount] decimalNumberByRoundingAccordingToBehavior:rounder];
		self.rests[to] = [[self.rests[to] decimalNumberByAdding:[amount decimalNumberByDividingBy:rate]]
						  decimalNumberByRoundingAccordingToBehavior:rounder];
		[self notifyRACSubscribers:self];
		return YES;
	}
	return NO;
}

- (NSString *)currencySymbol:(NSString *)currency
{
	return self.symbols[currency];
}

- (BOOL)exchange
{
	NSString *from = self.from;
	NSString *to = self.to;
	NSDecimalNumber *requested = self.requested;
	NSDecimalNumber *rate = [RatesProvider.sharedInstance crossConvertFrom:from to:to];
	return [self convertFrom:from to:to amount:requested rate:rate];
}

- (void)notifyRACSubscribers:(id)model
{
	dispatch_async(dispatch_get_main_queue(), ^{
		for (id <RACSubscriber> subscriber in self.subscribers) {
			[subscriber sendNext:model];
		}
	});
}

- (RACSignal *)modelUpdatedSignal
{
	@weakify(self);
	
	return [RACSignal createSignal:^(id <RACSubscriber> subscriber) {
		@strongify(self);

		self.subscribers = [self.subscribers arrayByAddingObject:subscriber];
		[self.rac_deallocDisposable addDisposable:[RACDisposable disposableWithBlock:^{
			[subscriber sendCompleted];
		}]];
		
		return [RACDisposable disposableWithBlock:^{
			@strongify(self);
			NSPredicate *p = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
				return evaluatedObject != subscriber;
			}];
			self.subscribers = [self.subscribers filteredArrayUsingPredicate:p];
		}];
	}];
}

@end
