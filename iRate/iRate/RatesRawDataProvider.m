//
//  RatesRawDataProvider.m
//  iRate
//
//  Created by Dmitry Varentsov on 31/01/2017.
//  Copyright © 2017 Dmitry Varentsov. All rights reserved.
//

#import "RatesRawDataProvider.h"
#import <AFNetworking/AFNetworking.h>

static NSString *const kBaseUrl = @"https://www.ecb.europa.eu/stats/eurofxref/";
static NSString *const kRatesXrefPath = @"eurofxref-daily.xml";


@interface RatesRawDataProvider ()
{
	AFHTTPSessionManager *_manager;
}

@property (readonly, strong, nonatomic) AFHTTPSessionManager *manager;

@end

@implementation RatesRawDataProvider

+ (instancetype)sharedInstance
{
	static dispatch_once_t onceToken;
	static RatesRawDataProvider *staticInstance = nil;
	dispatch_once(&onceToken, ^{
		staticInstance = [self new];
	});
	return staticInstance;
}

- (AFHTTPSessionManager *)manager
{
	if (!_manager) {
		_manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
	}
	return _manager;
}

- (void)requestRatesRawDataWithCompletion:(void(^)(NSXMLParser *))completion
{
	AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
	AFHTTPResponseSerializer * responseSerializer = [AFXMLParserResponseSerializer serializer];
	
	NSString *ua = @"Mozilla/5.0 (iPhone; CPU iPhone OS 9_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25";
	[requestSerializer setValue:ua forHTTPHeaderField:@"User-Agent"];

	self.manager.responseSerializer = responseSerializer;
	self.manager.requestSerializer = requestSerializer;
	
	NSDictionary *parameters = nil;
	[self.manager GET:[kRatesXrefPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet letterCharacterSet]]
	  parameters:parameters
		progress:nil
		  success:^(NSURLSessionDataTask * _Nonnull requestTask, NSXMLParser *_Nullable parser) {
			  if (completion) {
				  completion(parser);
			  }
		  }
		  failure:^(NSURLSessionDataTask * _Nonnull requestTask, NSError *_Nonnull error) {
			  NSLog(@"Error: %@", error);
			  if (completion) {
				  completion(nil);
			  }
		  }];
}

@end
