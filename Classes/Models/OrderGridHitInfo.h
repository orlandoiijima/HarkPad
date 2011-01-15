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

@interface OrderGridHitInfo : NSObject {

}

@property (retain) GridCell *cell;
@property (retain) OrderLine *orderLine;
@property int type;
@property CGRect frame;

@end
