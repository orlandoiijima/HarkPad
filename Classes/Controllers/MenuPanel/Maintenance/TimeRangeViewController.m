//
//  TimeRangeViewController.m
//  HarkPad
//
//  Created by Willem Bison on 11/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimeRangeViewController.h"
#import "NMRangeSlider.h"
#import "TimeRangeDelegate.h"

@interface TimeRangeViewController ()

@end

@implementation TimeRangeViewController

+ (TimeRangeViewController *)controllerWithLowerValue:(float)lowerValue upperValue:(float)upperValue delegate:(id<TimeRangeDelegate>)delegate {
    TimeRangeViewController *controller = [[TimeRangeViewController alloc] init];
    controller.delegate = delegate;
    controller.lowerValue = lowerValue;
    controller.upperValue = upperValue;
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.contentSizeForViewInPopover = CGSizeMake(300, 80);

    _slider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(30, 40, 240, 40)];
    [self.view addSubview: _slider];
    _slider.minimumValue = 8;
    _slider.maximumValue = 22;
    _slider.stepValue = 0.5;
    _slider.minimumRange = 0.5;

    _minimumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    [self.view addSubview:_minimumLabel];
    _minimumLabel.textColor = [UIColor whiteColor];
    _minimumLabel.backgroundColor = [UIColor clearColor];
    _minimumLabel.textAlignment = NSTextAlignmentRight;

    _maximumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    [self.view addSubview:_maximumLabel];
    _maximumLabel.textColor = [UIColor whiteColor];
    _maximumLabel.backgroundColor = [UIColor clearColor];
    _maximumLabel.textAlignment = NSTextAlignmentLeft;

    [_slider addTarget:self action:@selector(updateSliderLabels) forControlEvents:UIControlEventAllTouchEvents];

    if (_lowerValue == 0)
        _lowerValue = _slider.minimumValue;
    if (_upperValue == 0)
        _upperValue = _slider.maximumValue;
    [_slider setLowerValue: _lowerValue upperValue:_upperValue animated:YES];
    [self updateSliderLabels];
}

- (void) updateSliderLabels
{
    // You get get the center point of the slider handles and use this to arrange other subviews

    CGPoint lowerCenter;
    lowerCenter.x = (_slider.lowerCenter.x + _slider.frame.origin.x);
    lowerCenter.y = (_slider.center.y - 40.0f);
    _minimumLabel.center = CGPointMake(lowerCenter.x - _minimumLabel.bounds.size.width/2 + _slider.trackImage.size.width/2, lowerCenter.y);
    _minimumLabel.text = [self labelForValue: _slider.lowerValue];

    CGPoint upperCenter;
    upperCenter.x = (_slider.upperCenter.x + _slider.frame.origin.x);
    upperCenter.y = (_slider.center.y - 40.0f);
    _maximumLabel.center = CGPointMake(upperCenter.x + _minimumLabel.bounds.size.width/2 - _slider.trackImage.size.width/2, upperCenter.y);
    _maximumLabel.text = [self labelForValue: _slider.upperValue];
}

- (NSString *) labelForValue: (float)val {
    int value = (int)(val * 2);
    return [NSString stringWithFormat:@"%d:%@", value / 2, value & 1 ? @"30" : @"00"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneTimeRange {
    float lower = _slider.lowerValue == _slider.minimumValue ? 0: _slider.lowerValue;
    float upper = _slider.upperValue == _slider.maximumValue ? 0: _slider.upperValue;
    [self.delegate didSetLower:lower upper:upper];
}

@end
