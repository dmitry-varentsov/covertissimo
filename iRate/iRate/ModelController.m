//
//  ModelController.m
//  iRate
//
//  Created by Dmitry Varentsov on 30/01/2017.
//  Copyright © 2017 Dmitry Varentsov. All rights reserved.
//

#import "ModelController.h"
#import "DataViewController.h"
#import "RatesModel.h"
#import "RatesProvider.h"

@interface ModelController ()

@property(nonatomic) BOOL source;
@property(weak, nonatomic) RatesModel *model;

@end

@implementation ModelController

+ (instancetype)sourceModelController:(RatesModel *)model;
{
	ModelController *instance = [self new];
	[instance setSource:YES];
	[instance setModel:model];
	return instance;
}

+ (instancetype)destinationModelController:(RatesModel *)model
{
	ModelController *instance = [self new];
	[instance setModel:model];
	return instance;
}

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
	// Return the data view controller for the given index.
	if (([self.model.currencyNames count] == 0) || (index >= [self.model.currencyNames count])) {
	    return nil;
	}

	// Create a new view controller and pass suitable data.
	DataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
	
	dataViewController.model = self.model;
	dataViewController.currency = self.model.currencyNames[index];
	dataViewController.source = self.source;
	
	return dataViewController;
}


- (NSUInteger)indexOfViewController:(DataViewController *)viewController {
	// Return the index of the given data view controller.
	// For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
	return [self indexOfCurrency:viewController.currency];
}

- (NSUInteger)indexOfCurrency:(NSString *)currency
{
	return [self.model.currencyNames indexOfObject:currency];
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        index = self.model.currencyNames.count;
    }
    
    --index;
	return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    ++index;
    if (index == [self.model.currencyNames count]) {
        index = 0;
    }
	return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
