//
//  RatesRawDataProvider.h
//  iRate
//
//  Created by Dmitry Varentsov on 31/01/2017.
//  Copyright © 2017 Dmitry Varentsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RatesRawDataProvider : NSObject

+ (instancetype)sharedInstance;
- (void)requestRatesRawDataWithCompletion:(void(^)(NSXMLParser *))completion;

@end
