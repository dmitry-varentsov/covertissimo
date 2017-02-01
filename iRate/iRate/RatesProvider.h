//
//  RatesProvider.h
//  iRate
//
//  Created by Dmitry Varentsov on 31/01/2017.
//  Copyright © 2017 Dmitry Varentsov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kEUR;
extern NSString *const kGBP;
extern NSString *const kUSD;

extern NSString *const kRatesProviderDidUpdateRates;

@interface RatesProvider : NSObject

+ (instancetype)sharedInstance;
- (BOOL)isReady;
- (void)scheduleRatesUpdateIfNeeded;

- (NSDecimalNumber *)crossConvertFrom:(NSString *)from to:(NSString *)to;

@end
