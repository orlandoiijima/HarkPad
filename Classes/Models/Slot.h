//
//  Slot.h
//  HarkPad
//
//  Created by Willem Bison on 20-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Slot : NSObject {
    int id;
    NSDate *startedOn;
    NSDate *completedOn;
    NSMutableArray *slotTables	;
}

@property int id;
@property (retain) NSDate *startedOn;
@property (retain) NSDate *completedOn;
@property (retain) NSMutableArray *slotTables;

+ (Slot *) slotFromJsonDictionary: (NSDictionary *)jsonDictionary;

@end
