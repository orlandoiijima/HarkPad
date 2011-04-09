//
//  CoureSeat.h
//  HarkPad2
//
//  Created by Willem Bison on 11-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GridCell.h"
#import "OrderLine.h"

typedef enum HitInfoType {nothing = -1, orderLine = 0, orderGridColumnHeader = 1, orderGridRowHeader = 2} HitInfoType ;

@interface OrderGridHitInfo : NSObject {
    GridCell *cell;
    OrderLine *orderLine;
    HitInfoType type;
    CGRect frame;
}

@property (retain) GridCell *cell;
@property (retain) OrderLine *orderLine;
@property HitInfoType type;
@property CGRect frame;

@end
