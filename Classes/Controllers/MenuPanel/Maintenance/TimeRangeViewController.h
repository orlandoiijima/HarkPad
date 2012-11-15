//
//  TimeRangeViewController.h
//  HarkPad
//
//  Created by Willem Bison on 11/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class NMRangeSlider;
@protocol TimeRangeDelegate;

@interface TimeRangeViewController : UIViewController

@property(nonatomic, strong) NMRangeSlider *slider;
@property(nonatomic, strong) UILabel *minimumLabel;
@property(nonatomic, strong) UILabel *maximumLabel;
@property(nonatomic, strong) id<TimeRangeDelegate> delegate;

@property(nonatomic) float lowerValue;
@property(nonatomic) float upperValue;

+ (TimeRangeViewController *)controllerWithLowerValue:(float)lowerValue upperValue:(float)upperValue delegate:(id <TimeRangeDelegate>)delegate;

- (void)doneTimeRange;

@end
