//
//  DataViewController.m
//  iRate
//
//  Created by Dmitry Varentsov on 30/01/2017.
//  Copyright © 2017 Dmitry Varentsov. All rights reserved.
//

#import "DataViewController.h"
#import "RatesProvider.h"
#import "RatesModel.h"
#import <ReactiveObjC/ReactiveObjC.h>

static const NSUInteger kMaxLength = 20;

@interface DataViewController ()

@property (weak, nonatomic) IBOutlet UILabel *currencyName;
@property (weak, nonatomic) IBOutlet UITextField *amount;

@property (weak, nonatomic) IBOutlet UILabel *available;
@property (weak, nonatomic) IBOutlet UILabel *rate;

@property (strong, nonatomic) RACDisposable *modelSubsciption;

@end

@implementation DataViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.rate.hidden = YES;
	[self updateAmountAvailbility];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onRatesProvidedDidUpdateRates)
												 name:kRatesProviderDidUpdateRates object:nil];

	self.currencyName.text = self.currency;

	@weakify(self);
	if (self.source) {
		[[self.self.amount.rac_textSignal map:^id(NSString *text) {
			@strongify(self);
			text = text.length <= kMaxLength ? text : [text substringToIndex:kMaxLength];
			if (![text isEqualToString:self.amount.text]) {
				self.amount.text = text;
			}
			return text.length ? [NSDecimalNumber decimalNumberWithString:text] : nil;
		}] subscribeNext:^(NSDecimalNumber *requested) {
			@strongify(self);
			self.model.requested = requested;
			[self updateRequest];
		}];
		
		[RACObserve(self.model, requested) subscribeNext:^(NSDecimalNumber *_Nullable requested) {
			@strongify(self);
			if (!requested && self.amount.text.length) {
				self.amount.text = @"";
			}
		}];
	} else {
		[RACObserve(self.model, from) subscribeNext:^(NSString *from){
			@strongify(self);
			[self formatRate];
			[self showResultAmount];
		}];
		[RACObserve(self.model, requested) subscribeNext:^(NSDecimalNumber *requested){
			@strongify(self);
			[self showResultAmount];
		}];
	}
	self.modelSubsciption = [self.model.modelUpdatedSignal subscribeNext:^(RatesModel *_Nullable m) {
		@strongify(self);
		[self updateAvailableAmount];
	}];
}

- (void)dealloc
{
	if (self.amount.isFirstResponder) {
		[self.amount resignFirstResponder];
	}
	[self.modelSubsciption dispose], self.modelSubsciption = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)updateAmountAvailbility
{
	self.amount.userInteractionEnabled = RatesProvider.sharedInstance.isReady;
	[self updateAvailableAmount];
}

#pragma mark - rates logics

- (void)onRatesProvidedDidUpdateRates
{
	[self updateAmountAvailbility];
	if (self.amount.userInteractionEnabled && self.isSource) {
		[self.amount becomeFirstResponder];
	}
	[self formatRate];
}

- (void)formatRate
{
	if (self.isSource || !RatesProvider.sharedInstance.isReady) {
		return;
	}
	NSDecimalNumber *rate = [RatesProvider.sharedInstance crossConvertFrom:self.model.from
																		to:self.currency];
	NSString *rateText = [rate stringValue];
	self.rate.text = [NSString stringWithFormat:@"%@1=%@%@",
					  [self.model currencySymbol:self.currency],
					  [self.model currencySymbol:self.model.from],
					  [rateText substringToIndex:MIN(7, rateText.length)]];
	self.rate.hidden = NO;
}

- (void)showResultAmount
{
	
}

- (void)updateRequest
{
	BOOL invalidRequest = [self.model.requested compare:[self.model restForCurrency:self.currency]] > NSOrderedSame;
	self.amount.textColor = invalidRequest ? UIColor.redColor : UIColor.blackColor;
}

- (void)updateAvailableAmount
{
	self.available.text = [NSString stringWithFormat:@"You have %@%@",
						   [self.model currencySymbol:self.currency],
						   [self.model restForCurrency:self.currency]];
}

@end
