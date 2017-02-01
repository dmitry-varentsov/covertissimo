//
//  RootViewController.m
//  iRate
//
//  Created by Dmitry Varentsov on 30/01/2017.
//  Copyright © 2017 Dmitry Varentsov. All rights reserved.
//

#import "RootViewController.h"
#import "ModelController.h"
#import "DataViewController.h"

#import "RatesModel.h"
#import "RatesProvider.h"

@interface RootViewController () <UIPageViewControllerDelegate>

@property (strong, nonatomic) ModelController *sourceModelController;
@property (weak, nonatomic) UIPageViewController *sourcePageViewController;
@property (weak, nonatomic) IBOutlet UIView *sourceView;
@property (copy, nonatomic) NSString *sourceCurrency;

@property (strong, nonatomic) ModelController *destinationModelController;
@property (weak, nonatomic) UIPageViewController *destinationPageViewController;
@property (weak, nonatomic) IBOutlet UIView *destinationView;
@property (copy, nonatomic) NSString *destinationCurrency;

@property (strong, nonatomic) RatesModel *model;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *exchange;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rates;

@end

@implementation RootViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.model = [RatesModel new];
	[self setupControls];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(unlockRates)
												 name:kRatesProviderDidUpdateRates
											   object:nil];
	self.rates.enabled = RatesProvider.sharedInstance.isReady;
	@weakify(self);
	self.exchange.enabled = NO;
	[RACObserve(self.model, requested) subscribeNext:^(NSDecimalNumber *_Nullable requested) {
		@strongify(self);
		self.exchange.enabled = requested && [requested compare:[self.model restForCurrency:self.model.from]] <= NSOrderedSame;
	}];}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (UIPageViewController *)buildPageViewController
{
	return [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
}

- (void)embedPageViewController:(UIPageViewController *)pageViewController view:(UIView *)view via:(ModelController *)modelController
{
	pageViewController.delegate = self;
	
	NSUInteger index =  [modelController indexOfCurrency: modelController.source ? self.model.from : self.model.to];
	DataViewController *startingViewController = [modelController viewControllerAtIndex:index storyboard:self.storyboard];
	NSArray *viewControllers = @[startingViewController];
	[pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
	
	pageViewController.dataSource = modelController;
	
	[self addChildViewController:pageViewController];
	[view addSubview:pageViewController.view];
	
	[pageViewController didMoveToParentViewController:self];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)setupControls
{
	UIPageViewController *pageViewController = nil;
	
	pageViewController = self.class.buildPageViewController;
	[self embedPageViewController:pageViewController view:self.sourceView via:self.sourceModelController];
	self.sourcePageViewController = pageViewController;
	
	pageViewController = self.class.buildPageViewController;
	[self embedPageViewController:pageViewController view:self.destinationView via:self.destinationModelController];
	self.destinationPageViewController = pageViewController;
}

#pragma mark - actions

- (IBAction)onCancelClicked:(id)sender
{
	self.model.requested = nil;
}

- (IBAction)onExchangeClicked:(id)sender
{
	if (![self.model exchange]) {
		//alert?
	} else {
		self.model.requested = nil;
	}
}

- (IBAction)onRatesClicked:(id)sender
{
	UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil
																message:nil
														 preferredStyle:UIAlertControllerStyleActionSheet];
	@weakify(ac);
	for (NSString *currency in @[kGBP, kUSD]) {
		NSDecimalNumber *crossRate = [[RatesProvider sharedInstance] crossConvertFrom:currency to:kEUR];
		NSString *title = [NSString stringWithFormat:@"%@1 = %@%@",
						   [self.model currencySymbol:kEUR], [self.model currencySymbol:currency], crossRate.stringValue];
		UIAlertAction *aa = [UIAlertAction actionWithTitle:title
													 style:UIAlertActionStyleDefault
												   handler:nil];
		[ac addAction:aa];
	}
	[ac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
										   style:UIAlertActionStyleCancel
										 handler:^(UIAlertAction * _Nonnull action) {
											 @strongify(ac);
											 [ac dismissViewControllerAnimated:YES completion:nil];
										 }]];
	[self presentViewController:ac animated:YES completion:nil];
}

#pragma mark - model

- (void)unlockRates
{
	self.rates.enabled = YES;
}

- (ModelController *)sourceModelController {
	// Return the model controller object, creating it if necessary.
	// In more complex implementations, the model controller may be passed to the view controller.
	if (!_sourceModelController) {
		_sourceModelController = [ModelController sourceModelController:self.model];
	}
	return _sourceModelController;
}

- (ModelController *)destinationModelController {
	// Return the model controller object, creating it if necessary.
	// In more complex implementations, the model controller may be passed to the view controller.
	if (!_destinationModelController) {
		_destinationModelController = [ModelController destinationModelController:self.model];
		
	}
	return _destinationModelController;
}

#pragma mark - UIPageViewController delegate methods

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
	DataViewController *dataController = pageViewController.viewControllers.firstObject;
	if (pageViewController == self.sourcePageViewController) {
		self.model.from = dataController.currency;
	} else if (pageViewController == self.destinationPageViewController) {
		self.model.to = dataController.currency;
	}
}

@end
