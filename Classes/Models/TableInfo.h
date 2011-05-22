//
//  TableInfo.h
//  HarkPad
//
//  Created by Willem Bison on 27-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Table.h"
#import "OrderInfo.h"


@interface TableInfo : NSObject {
    OrderInfo *orderInfo;
    Table *table;
}

@property (retain) OrderInfo *orderInfo;
@property (retain) Table *table;
@property bool isEmpty;
@end
