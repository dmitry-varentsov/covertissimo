//
//  ModelController.h
//  iRate
//
//  Created by Dmitry Varentsov on 30/01/2017.
//  Copyright © 2017 Dmitry Varentsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataViewController, RatesModel;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

+ (instancetype)sourceModelController:(RatesModel *)model;
+ (instancetype)destinationModelController:(RatesModel *)model;

@property(readonly, weak, nonatomic) RatesModel *model;
@property(readonly, nonatomic) BOOL source;

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;
- (NSUInteger)indexOfCurrency:(NSString *)currency;

@end

