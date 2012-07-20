//
//  Map.h
//  HarkPad
//
//  Created by Willem Bison on 03-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "District.h"
#import "Table.h"

@interface Map : NSObject {
    NSMutableArray *districts;    
}

+ (Map *) mapFromJson: (NSMutableDictionary *) jsonArray;
- (Table *) getTable: (int) tableId;
- (District *)getTableDistrict: (NSString *) tableName;
- (Table *) getTableByName: (NSString *) table;

@property (retain) NSMutableArray *districts;

@end
