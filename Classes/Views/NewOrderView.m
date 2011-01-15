//
//  NewOrderView.m
//  HarkPad2
//
//  Created by Willem Bison on 24-11-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "NewOrderView.h"
#import "NewOrderVC.h"

@implementation NewOrderView

@synthesize controller;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{   
    [self.controller touchesMoved:touches withEvent:event]; 
}

- (void)dealloc {
    [super dealloc];
}


@end
