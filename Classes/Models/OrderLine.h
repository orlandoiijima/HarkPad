//
//  OrderDetail.h
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"
#import "OrderLineProperty.h"
#import "OrderLinePropertyValue.h"

@interface OrderLine : NSObject {
}

typedef enum EntityState {None = 0,New, Modified, Deleted} EntityState;
typedef enum State {Ordered = 0, Preparing = 1} State;

@property int id;
@property (retain) NSDate *createdOn;
@property EntityState entityState;
@property int seat;
@property int quantity;
@property int course;
@property (retain) NSDate *requestedOn;
@property (retain) NSString *note;
@property (retain) Product *product;
@property int sortOrder;
@property State state;
@property (retain) NSMutableArray *propertyValues;

+ (OrderLine *) orderLineFromJsonDictionary: (NSDictionary *) dict;
- (NSDictionary *) initDictionary;
- (NSDecimalNumber *) getAmount;
- (NSString *) getStringValueForProperty: (OrderLineProperty *) property;
- (OrderLinePropertyValue *) getValueForProperty: (OrderLineProperty *) property;
- (void) setStringValueForProperty : (OrderLineProperty *) property value: (NSString *) value;

@end