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
#import "ModalAlert.h"

@implementation ProductPropertiesView

@synthesize uiKey, uiName, uiPrice, uiVat, delegate = _delegate;
@synthesize product = _product;
@synthesize popoverController = _popoverController;
@synthesize menuCard = _menuCard;


+ (ProductPropertiesView *)viewWithFrame:(CGRect)frame menuCard:(MenuCard *)menuCard {
    ProductPropertiesView * view = [[ProductPropertiesView alloc] initWithFrame:frame];
    view.menuCard = menuCard;
    [view initVat];
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

- (void) initVat {
    [uiVat removeAllSegments];
    int i = 0;
    for (NSDictionary *vat in _menuCard.vatPercentages) {
        NSDecimalNumber *percentage = [NSString stringWithFormat:@"%@", [vat objectForKey:@"percentage"]];
        NSString *label = [NSString stringWithFormat:@"%@ (%@%%)", [vat objectForKey:@"name"], percentage];
        [uiVat insertSegmentWithTitle:label atIndex:i++ animated:YES];
    }
}

- (void)setProduct:(Product *)product {
    _product = product;
    uiKey.text = _product.key;
    uiName.text = _product.name;
    uiPrice.text = [NSString stringWithFormat:@"%@", product.price];
    uiVat.selectedSegmentIndex = [_menuCard vatIndexByPercentage:product.vat];
    _uiIncludedInQuickMenu.on = [_menuCard isInQuickMenu:_product];
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

- (IBAction)toggleQuickMenu {
    if ([_menuCard isInQuickMenu:_product]) {
        [_delegate didInclude:_product inFavorites:NO];
    }
    else {
        [_delegate didInclude:_product inFavorites:YES];
    }
}

- (IBAction)updateName {
    _product.name = [Utils trim:uiName.text];
    [self didUpdate];
}

- (IBAction)updateCode {
    _product.key = [Utils trim:uiKey.text];
    [self didUpdate];
}

- (IBAction)updateVat {
    _product.vat = [_menuCard vatPercentageByIndex: uiVat.selectedSegmentIndex];
    [self didUpdate];
}

- (IBAction)updatePrice {
    _product.price = [Utils getAmountFromString:uiPrice.text];
    [self didUpdate];
}

- (IBAction)delete {
    if ([ModalAlert confirm:NSLocalizedString(@"Delete item ?", nil)]) {
        [_delegate didDeleteItem: _product];
    }

}

- (void) didUpdate {
    if (self.delegate == nil) return;
    [self.delegate didModifyItem:_product];
}
@end
