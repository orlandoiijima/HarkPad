//
//  Table.h
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "District.h";

typedef enum SeatOrientation {row, column} SeatOrientation;

@interface Table : NSObject {
    int id;
    NSString *name;
    CGRect bounds;
    int countSeats;
    SeatOrientation seatOrientation;
    District *district;
}

@property int id;
@property (retain) NSString *name;
@property CGRect bounds;
@property int countSeats;
@property SeatOrientation seatOrientation;
@property (retain) District *district;

+ (Table *) tableFromJsonDictionary: (NSDictionary *)jsonDictionary;
- (Table *) initWithBounds:(CGRect)tableBounds name: (NSString *)tableName countSeats: (int) count;

@end