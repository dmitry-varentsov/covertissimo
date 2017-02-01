//
//  RatesModel.h
//  iRate
//
//  Created by Dmitry Varentsov on 31/01/2017.
//  Copyright © 2017 Dmitry Varentsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface RatesModel : NSObject

@property (readonly, strong, nonatomic) NSArray<NSString *> *currencyNames;
@property (copy, nonatomic) NSString *from;
@property (copy, nonatomic) NSString *to;
@property (copy, nonatomic) NSDecimalNumber *requested;

- (NSDecimalNumber *)restForCurrency:(NSString *)currency;

- (BOOL)convertFrom:(NSString *)from to:(NSString *)to amount:(NSDecimalNumber *)amount rate:(NSDecimalNumber *)rate;

- (NSString *)currencySymbol:(NSString *)currency;
- (BOOL)exchange;

@end

@interface RatesModel(RAC)

- (RACSignal *)modelUpdatedSignal;
- (void)notifySubscribers;

@end
