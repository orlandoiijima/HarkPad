//
//  SlotTable.h
//  HarkPad
//
//  Created by Willem Bison on 23-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Table.h"

@interface SlotTable : NSObject {
    NSMutableArray *lines;
    NSMutableArray *tables;
}

@property (retain) NSMutableArray *lines;
@property (retain) NSMutableArray *tables;

+ (SlotTable *) slotTableFromJsonDictionary: (NSDictionary *)jsonDictionary;

@end
