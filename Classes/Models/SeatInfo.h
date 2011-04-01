//
//  SeatInfo.h
//  HarkPad
//
//  Created by Willem Bison on 29-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"

@interface SeatInfo : NSObject {
    int guestId;
    BOOL isMale;
    Product *food;
    Product *drink;
}

@property BOOL isMale;
@property int guestId;
@property (retain) Product *food;
@property (retain) Product *drink;

+ (SeatInfo *) seatInfoFromJsonDictionary: (NSDictionary *)jsonDictionary;

@end
