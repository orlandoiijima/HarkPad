//
//  ToBeRequested.h
//  HarkPad
//
//  Created by Willem Bison on 06-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"

@interface Backlog : NSObject {
    NSMutableDictionary *totals;
    Product *product;
}

@property (retain) NSMutableDictionary *totals;
@property (retain) Product *product;

+ (Backlog *) backlogFromJsonDictionary: (NSDictionary *)jsonDictionary;

@end
