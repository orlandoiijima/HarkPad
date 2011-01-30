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

@interface OrderLine : NSObject {
}

typedef enum EntityState {None = 0,New, Modified, Deleted} EntityState;
typedef enum State {Ordered = 0, Preparing = 1} State;

@property int id;
@property (retain) NSDate *createdOn;
@property EntityState entityState;
@property (retain) Guest *guest;
@property int quantity;
@property (retain) Course *course;
@property (retain) NSString *note;
@property (retain) Product *product;
@property int sortOrder;
@property State state;
@property (retain) NSMutableArray *propertyValues;

+ (OrderLine *) orderLineFromJsonDictionary: (NSDictionary *)jsonDictionary guests: (NSArray *) guests courses: (NSArray *) courses;

- (NSDictionary *) initDictionary;
- (NSDecimalNumber *) getAmount;
- (NSString *) getStringValueForProperty: (OrderLineProperty *) property;
- (OrderLinePropertyValue *) getValueForProperty: (OrderLineProperty *) property;
- (void) setStringValueForProperty : (OrderLineProperty *) property value: (NSString *) value;

- (Course *) getCourseById: (int)courseId courses: (NSArray *) courses;
- (Guest *) getGuestById: (int)guestId guests: (NSArray *) guests;

@end