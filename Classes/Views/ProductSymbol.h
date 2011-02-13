//
//  ProductSymbol.h
//  HarkPad
//
//  Created by Willem Bison on 23-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import <QuartzCore/QuartzCore.h>

@interface ProductSymbol : UIView {
    Product *food;
    Product *drink;
    int seat;
    CAGradientLayer *gradient;
}

@property (retain) Product *food;
@property (retain) Product *drink;
@property int seat;
@property (retain) UILabel *label;
@property (retain) CAGradientLayer *gradient;

+ (ProductSymbol *) symbolWithFrame: (CGRect) frame seat: (int) seat;
- (void) setFood:(Product *)newFood drink: (Product *)newDrink;

@end
