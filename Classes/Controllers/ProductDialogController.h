//
//  ProductsDialogController.h
//  HarkPad
//
//  Created by Willem Bison on 19-08-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "QuickDialogController.h"
#import "Product.h"

@interface ProductDialogController : QuickDialogController

- (ProductDialogController *) initWithProduct: (Product *) product;

@end
