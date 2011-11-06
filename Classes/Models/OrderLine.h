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
#import "Guest.h"
#import "Course.h"
#import "EntityState.h"

typedef enum State {Ordered = 0, Preparing = 1} State;

@class Order;

@interface OrderLine : NSObject {
    int id;
    NSDate *createdOn;
    EntityState entityState;
    Guest *guest;
    int quantity;
    Course *course;
    NSString *note;
    Product *product;
    int sortOrder;
    State state;
    NSMutableArray *propertyValues;
}

@property int id;
@property (retain) NSDate *createdOn;
@property (nonatomic) EntityState entityState;
@property (retain) Guest *guest;
@property int quantity;
@property (retain) Course *course;
@property (retain) NSString *note;
@property (retain) Product *product;
@property int sortOrder;
@property State state;
@property (retain) NSMutableArray *propertyValues;

+ (OrderLine *) orderLineFromJsonDictionary: (NSDictionary *)jsonDictionary order: (Order *)order;

- (NSDictionary *)toDictionary;
- (NSString *) getStringValueForProperty: (OrderLineProperty *) property;
- (OrderLinePropertyValue *) getValueForProperty: (OrderLineProperty *) property;
- (void) setStringValueForProperty : (OrderLineProperty *) property value: (NSString *) value;

- (Course *) getCourseByOffset: (int)offset courses: (NSArray *) courses;
- (Guest *) getGuestBySeat: (int)seat guests: (NSArray *) guests;

@end