//
//  RatesParser.m
//  iRate
//
//  Created by Dmitry Varentsov on 31/01/2017.
//  Copyright © 2017 Dmitry Varentsov. All rights reserved.
//

#import "RatesParser.h"

static NSString *const kCurrencyAttribute = @"currency";
static NSString *const kRateAttribute = @"rate";

@interface RatesParser () <NSXMLParserDelegate>

@property (strong, nonatomic) NSArray <NSString *>*attributes;
@property (copy, nonatomic) RatesParserCompletion completion;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSMutableDictionary *result;

@end

@implementation RatesParser

- (instancetype)initWithParser:(NSXMLParser *)parser lookingForAttributes:(NSArray <NSString *>*)attributes completion:(RatesParserCompletion)completion
{
	self = [super init];
	self.parser = parser;
	self.attributes = attributes;
	self.completion = completion;
	
	parser.delegate = self;
	[parser parse];
	return self;
}

- (void)doCompletion
{
	if (self.completion) {
		self.completion(self.result);
		self.completion = nil;
	}
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	self.result = [NSMutableDictionary new];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict
{
	if (![self.attributes containsObject:attributeDict[kCurrencyAttribute]]) {
		return;
	}
	self.result[attributeDict[kCurrencyAttribute]] = attributeDict[kRateAttribute];
	if (self.result.count == self.attributes.count) {
		[parser abortParsing];
		[self doCompletion];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self doCompletion];
}

@end
