//
//  WorkInProgress.h
//  HarkPad
//
//  Created by Willem Bison on 20-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Course.h"
#import "Table.h"
#import "Cache.h"
#import "ProductCount.h"

@interface WorkInProgress : NSObject {
    Course *course;
    NSMutableArray *productCount;
}

@property (retain) Course *course;
@property (retain) Table *table;
@property (retain) NSMutableArray *productCount;

@property(nonatomic) int orderId;

+ (WorkInProgress *) workFromJsonDictionary: (NSDictionary *)jsonDictionary;

@end
