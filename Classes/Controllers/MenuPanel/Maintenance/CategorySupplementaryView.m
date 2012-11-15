//
//  CategorySupplementaryView.m
//  HarkPad
//
//  Created by Willem Bison on 10/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColorViewController.h"
#import "CategorySupplementaryView.h"
#import "ProductCategory.h"
#import "MenuDelegate.h"
#import "ColorButtonView.h"
#import "UIColor-Expanded.h"
#import "UIImage+Tint.h"
#import "TimeRangeViewController.h"
#import "NMRangeSlider.h"

@implementation CategorySupplementaryView


- (void) setupForCategory:(ProductCategory *) category isEditing:(bool)isEditing delegate:(id<MenuDelegate>)delegate {
    _category = category;
    _delegate = delegate;
    _name.text = category.name;
    _colorButton.backgroundColor = category.color;

    _colorButton.delegate = self;
    if (_category.type == CategoryTypeStandard && isEditing) {
        _colorButton.enabled = YES;
        _colorButton.hidden = NO;
        _name.enabled = YES;
        _foodButton.enabled = YES;
        _foodButton.hidden = NO;
        [_foodButton setImage:[[UIImage imageNamed:@"fork-and-knife.png"] imageTintedWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_foodButton setImage:[[UIImage imageNamed:@"wine-glass.png"] imageTintedWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
        _foodButton.selected = _category.isFood == false;

        _timeButton.enabled = YES;
        _timeButton.hidden = NO;
        [_timeButton setImage:[[UIImage imageNamed:@"UITabBarHistoryTemplate.png"] imageTintedWithColor:[UIColor grayColor]] forState:UIControlStateNormal];
        [_timeButton setImage:[[UIImage imageNamed:@"UITabBarHistoryTemplate.png"] imageTintedWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
        _timeButton.selected = [_category isOrderableAllDay] == NO;

    }
    else {
        _colorButton.enabled = NO;
        _colorButton.hidden = YES;
        _foodButton.enabled = NO;
        _foodButton.hidden = YES;
        _name.enabled = NO;
    }
}

- (IBAction) textChange: (UITextField *)textField {
    if (_category.type == CategoryTypeStandard)
        _category.name = _name.text;
}

- (void)colorPopoverControllerDidSelectColor:(NSString *)hexColor {
    _category.color = [UIColor colorWithHexString:hexColor];
    if([_delegate respondsToSelector:@selector(didSelectColor:forCategory:)])
        [_delegate didSelectColor:_category.color  forCategory:_category];
}

- (IBAction)toggleFood {
    _category.isFood = !_category.isFood;
    _foodButton.selected = !_foodButton.selected;
    if([_delegate respondsToSelector:@selector(didToggleFoodForCategory:)])
        [_delegate didToggleFoodForCategory:_category];
}

- (IBAction) getTimeRange {
    TimeRangeViewController *controller = [TimeRangeViewController controllerWithLowerValue:_category.orderableFromHour upperValue:_category.orderableToHour delegate:self];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:controller action:@selector(doneTimeRange)];
    navigationController.navigationBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeTimeRange)];
    _popover = [[UIPopoverController alloc] initWithContentViewController: navigationController];
    [_popover presentPopoverFromRect:_timeButton.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)closeTimeRange {
    [_popover dismissPopoverAnimated:YES];
}

- (void)didSetLower:(float)lower upper:(float)upper {
    _category.orderableFromHour = lower;
    _category.orderableToHour = upper;
    [_popover dismissPopoverAnimated:YES];
    _timeButton.selected = [_category isOrderableAllDay] == NO;
}

@end
