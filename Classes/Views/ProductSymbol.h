//
//  ProductSymbol.h
//  HarkPad
//
//  Created by Willem Bison on 23-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface ProductSymbol : UIView {
@private
    
}

@property (retain) Product *product;
@property int seat;

+ (ProductSymbol *) symbolWithFrame: (CGRect) frame product: (Product *)product seat: (int) seat;

@end
