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
    NSArray *countSeatsPerSide;
    District *district;
    int dockedToTableId;
}

@property int id;
@property (retain) NSString *name;
@property CGRect bounds;
@property (retain) NSArray *countSeatsPerSide;
@property (retain) District *district;
@property int dockedToTableId;
@property int maxCountSeatsHorizontal;
@property int maxCountSeatsVertical;
@property int countSeatsTotal;
@property bool isDocked;

+ (Table *) tableFromJsonDictionary: (NSDictionary *)jsonDictionary;
- (bool) isSeatAlignedWith: (Table *)table;
- (TableSide) sideForSeat: (int)seatOffset;

@end