//
//  DataViewController.h
//  iRate
//
//  Created by Dmitry Varentsov on 30/01/2017.
//  Copyright © 2017 Dmitry Varentsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RatesModel;

@interface DataViewController : UIViewController

@property (copy, nonatomic) NSString *currency;
@property (nonatomic, getter=isSource) BOOL source;
@property (weak, nonatomic) RatesModel *model;

@end

