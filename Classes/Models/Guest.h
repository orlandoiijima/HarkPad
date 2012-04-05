//
//  Guest.h
//  HarkPad
//
//  Created by Willem Bison on 28-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityState.h"
#import "DTO.h"

@class Order;

enum {
    DietNone                = 0,
    DietGlutenAllergy       = 1 << 0,
    DietLactoseIntolerance  = 1 << 1,
    DietMilkAllergy         = 1 << 2,
    DietNutAllergy          = 1 << 3,
    DietHalal           = 1 << 4,
    DietKosher          = 1 << 5,
    DietNoMeat          = 1 << 6,
    DietNoFish          = 1 << 7,
    DietLowCalories     = 1 << 8,
    DietLowCarb         = 1 << 9,
    DietLowSugar        = 1 << 10,
    DietLowSalt         = 1 << 11,
    DietLowFat          = 1 << 12,
    DietMontignac       = 1 << 13,
};
typedef NSUInteger Diet;


@interface Guest : DTO {
    int seat;
    BOOL isMale;
    BOOL isEmpty;
    BOOL isHost;
    Diet diet;
    NSMutableArray *lines;
}

+ (Guest *) guestFromJsonDictionary: (NSDictionary *)jsonDictionary order: (Order *)order;
- (NSMutableDictionary *)toDictionary;
+ (NSString *) dietName: (int)offset;
- (NSString *)dietString;
- (NSDecimalNumber *)totalAmount;

@property int seat;
@property (nonatomic) BOOL isMale;
@property BOOL isEmpty;
@property (nonatomic) BOOL isHost;
@property (nonatomic) Diet diet;
@property Order *order;
@property (retain) NSMutableArray *lines;
@property Guest *nextGuest;
@property BOOL isLast;
@end
