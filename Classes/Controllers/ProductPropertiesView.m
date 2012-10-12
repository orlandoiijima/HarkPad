//
//  ProductPropertiesView.m
//  HarkPad
//
//  Created by Willem Bison on 12-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ProductPropertiesView.h"
#import "Utils.h"
#import "Service.h"
#import "ColorViewController.h"
#import "UIColor-Expanded.h"

@implementation ProductPropertiesView

@synthesize uiKey, uiName, uiPrice, uiVat, delegate = _delegate;
@synthesize product = _product;
@synthesize popoverController = _popoverController;


+ (ProductPropertiesView *)viewWithFrame:(CGRect)frame {
    ProductPropertiesView * view = [[ProductPropertiesView alloc] initWithFrame:frame];
    return view;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        NSArray * nib = [[NSBundle mainBundle]
                     loadNibNamed: @"ProductPropertiesView"
                     owner: self
                     options: nil];

        self = [nib objectAtIndex:0];
        self.frame = frame;
    }
    return self;
}

- (void)setProduct:(Product *)product {
    _product = product;
    uiKey.text = _product.key;
    uiName.text = _product.name;
    uiPrice.text = [NSString stringWithFormat:@"%@", product.price];
    uiVat.selectedSegmentIndex =  product.vat == [NSDecimalNumber numberWithInt:6] ? 0:1;
    _uiColorButton.backgroundColor = product.category.color;
    _uiCategory.text = product.category.name;
}

- (bool)validate {
    if ([[Utils trim:uiKey.text] length] == 0) {
        [uiKey becomeFirstResponder];
        return NO;
    }
    if ([[Utils trim:uiName.text] length] == 0) {
        [uiName becomeFirstResponder];
        return NO;
    }
    if ([[Utils trim:uiPrice.text] length] == 0) {
        [uiPrice becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (IBAction)colorAction {
    ColorViewController *controller = [[ColorViewController alloc] init];
    controller.delegate = self;
    _popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    [_popoverController presentPopoverFromRect: _uiColorButton.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)colorPopoverControllerDidSelectColor:(NSString *)hexColor {
    _uiColorButton.backgroundColor = [UIColor colorWithHexString:hexColor];
    _product.category.color = _uiColorButton.backgroundColor;
    [_popoverController dismissPopoverAnimated:YES];
}

- (IBAction)saveAction {
    if ([self validate] == NO) return;

    _product.name = [Utils trim:uiName.text];
    _product.key = [Utils trim:uiKey.text];
    _product.price = [Utils getAmountFromString:uiPrice.text];
    _product.category.name = [Utils trim:_uiCategory.text];
//    product.vat = uiVat.selectedSegmentIndex;
    if([self.delegate respondsToSelector:@selector(didSaveItem:)])
        [self.delegate didSaveItem: _product];
}

- (IBAction)cancelAction {
    if([self.delegate respondsToSelector:@selector(didCancelItem:)])
        [self.delegate didCancelItem: _product];
}


@end
