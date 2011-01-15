//
//  Order.h
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderLine.h"
#import "Cache.h"

@interface Order : NSObject {
}

typedef enum OrderGrouping {bySeat, byCourse, byCategory} OrderGrouping ;
typedef enum OrderState {ordering, billed, paid} OrderState ;

+ (Order *) orderForTable: (Table *) table;
+ (Order *) orderFromJsonDictionary: (NSDictionary *)jsonDictionary;
- (NSMutableDictionary *) initDictionary;
- (NSDecimalNumber *) getAmount;
- (BOOL) containsProductId:(int)id;
- (OrderLine *) addLineWithProductId: (int) productId seat: (int) seat course: (int) course;
//- (NSMutableDictionary *) getByCategory:(BOOL)includeExisting;
//- (NSMutableDictionary *) getBySeat:(BOOL)includeExisting;
//- (NSMutableDictionary *) getByCourse:(BOOL)includeExisting;
- (int) getLastCourse;
- (int) getLastSeat;
- (NSDate *) getFirstOrderDate;
- (NSDate *) getLastOrderDate;
- (int) getCurrentCourse;

@property EntityState entityState;
@property (retain) NSMutableArray *lines;
@property (retain) NSDate *createdOn;
@property (retain) NSMutableArray *tables;
@property int id;
@property OrderState state;

@end
