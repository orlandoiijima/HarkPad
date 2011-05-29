//
//  CoureSeat.m
//  HarkPad2
//
//  Created by Willem Bison on 11-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "OrderGridHitInfo.h"


@implementation OrderGridHitInfo

@synthesize cell, type, orderLine, frame;

- (id) init
{
    cell = [GridCell cellWithColumn:0 row:0 line:0];
    orderLine = nil;
    type = nothing;
    return self;
}

@end
