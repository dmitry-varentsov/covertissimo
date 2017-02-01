//
//  RatesParser.h
//  iRate
//
//  Created by Dmitry Varentsov on 31/01/2017.
//  Copyright © 2017 Dmitry Varentsov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RatesParserCompletion)(NSDictionary *);

@interface RatesParser : NSObject

- (instancetype)initWithParser:(NSXMLParser *)parser lookingForAttributes:(NSArray <NSString *>*)attributes completion:(RatesParserCompletion)completion;

@end
