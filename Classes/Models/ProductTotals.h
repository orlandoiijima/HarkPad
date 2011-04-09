//
//  ProductTotals.h
//  HarkPad
//
//  Created by Willem Bison on 09-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"

@interface ProductTotals : NSObject {
    NSMutableDictionary *totals;
    Product *product;
}

@property (retain) NSMutableDictionary *totals;
@property (retain) Product *product;

+ (ProductTotals *) totalsFromJsonDictionary: (NSDictionary *)jsonDictionary;

@end
