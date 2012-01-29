//
//  Guest.h
//  HarkPad
//
//  Created by Willem Bison on 28-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityState.h"

enum {
    DietNone                = 0,
    DietGlutenAllergy       = 1 << 0,
    DietLactoseIntolerance  = 1 << 0,
    DietMilkAllergy         = 1 << 0,
    DietNutAllergy          = 1 << 0,
    DietHalal           = 1 << 0,
    DietKosher          = 1 << 0,
    DietNoMeat          = 1 << 0,
    DietNoFish          = 1 << 0,
    DietLowCalories     = 1 << 0,
    DietLowCarb         = 1 << 0,
    DietLowSugar        = 1 << 0,
    DietLowSalt         = 1 << 0,
    DietLowFat          = 1 << 0,
    DietMontignac       = 1 << 0,
};
typedef NSUInteger Diet;


@interface Guest : NSObject {
    int id;
    int seat;
    BOOL isMale;
    BOOL isHost;
    Diet diet;
    EntityState entityState;
    NSMutableArray *lines;
}

+ (Guest *) guestFromJsonDictionary: (NSDictionary *)jsonDictionary;
- (NSMutableDictionary *)toDictionary;

@property int id;
@property int seat;
@property BOOL isMale;
@property BOOL isHost;
@property Diet diet;
@property (retain) NSMutableArray *lines;
@property EntityState entityState;

@end
