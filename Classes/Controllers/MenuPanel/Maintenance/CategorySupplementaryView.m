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

@implementation CategorySupplementaryView
@synthesize delegate = _delegate;
@synthesize category = _category;


- (void) setupForCategory:(ProductCategory *) category isEditing:(bool)isEditing delegate:(id<MenuDelegate>)delegate {
    _category = category;
    _delegate = delegate;
    _name.text = category.name;
    _colorButton.backgroundColor = category.color;

    _colorButton.delegate = self;
    if (_category.type == CategoryTypeStandard && isEditing) {
        _colorButton.enabled = YES;
        _foodButton.enabled = YES;
        _colorButton.hidden = NO;
        _name.enabled = YES;
        _foodButton.hidden = NO;
        [_foodButton setImage:[[UIImage imageNamed:@"fork-and-knife.png"] imageTintedWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_foodButton setImage:[[UIImage imageNamed:@"wine-glass.png"] imageTintedWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
        _foodButton.selected = _category.isFood == false;
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
    if([_delegate respondsToSelector:@selector(didSelectColor:)])
        [_delegate didSelectColor:_category.color  forCategory:_category];
}

- (IBAction)toggleFood {
    _category.isFood = !_category.isFood;
    _foodButton.selected = !_foodButton.selected;
    if([_delegate respondsToSelector:@selector(didToggleFoodForCategory:)])
        [_delegate didToggleFoodForCategory:_category];
}

@end
