//
//  Table.h
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "District.h"

typedef enum SeatOrientation {row, column} SeatOrientation;

typedef enum TableSide {
    TableSideTop, TableSideRight, TableSideBottom, TableSideLeft
} TableSide;

@interface Table : NSObject {
    int id;
    NSString *name;
    CGRect bounds;
    NSUInteger countSeats;
    NSUInteger seatsHorizontal;
    NSUInteger seatsVertical;
    SeatOrientation seatOrientation;
    District *district;
    int dockedToTableId;
}

@property int id;
@property (retain) NSString *name;
@property CGRect bounds;
@property NSUInteger countSeats;
@property SeatOrientation seatOrientation;
@property (retain) District *district;
@property int dockedToTableId;
@property bool isDocked;
@property NSUInteger seatsHorizontal;
@property NSUInteger seatsVertical;

+ (Table *) tableFromJsonDictionary: (NSDictionary *)jsonDictionary;
- (bool) isSeatAlignedWith: (Table *)table;
- (TableSide) sideForSeat: (int)seatOffset;

@end