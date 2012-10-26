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

@implementation CategorySupplementaryView
@synthesize delegate = _delegate;
@synthesize category = _category;


- (void) setupForCategory:(ProductCategory *) category delegate:(id<MenuDelegate>)delegate {
    _category = category;
    _delegate = delegate;
    _name.text = category.name;
    _colorButton.backgroundColor = category.color;

    _colorButton.delegate = self;
    if (_category.type == CategoryTypeStandard) {
        _colorButton.enabled = YES;
        _colorButton.hidden = NO;
        _name.enabled = YES;
    }
    else {
        _colorButton.enabled = NO;
        _colorButton.hidden = YES;
        _name.enabled = NO;
    }
}

- (IBAction) textChange: (UITextField *)textField {
    if (_category.type == CategoryTypeStandard)
        _category.name = _name.text;
}

- (void)colorPopoverControllerDidSelectColor:(NSString *)hexColor {
    _category.color = [UIColor colorWithHexString:hexColor];
    [_delegate didSelectColor:_category.color  forCategory:_category];
}

@end
