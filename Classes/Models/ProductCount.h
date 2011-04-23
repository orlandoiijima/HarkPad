//
//  ProductCount.h
//  HarkPad
//
//  Created by Willem Bison on 20-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"
#import "Cache.h"

@interface ProductCount : NSObject {
    Product *product;
    int count;
}

@property (retain) Product *product;
@property int count;

+ (ProductCount *) countFromJsonDictionary: (NSDictionary *)jsonDictionary;

@end
