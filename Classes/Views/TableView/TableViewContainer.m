//
//  TableViewContainer.m
//  HarkPad
//
//  Created by Willem Bison on 02/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "TableViewContainer.h"

@implementation TableViewContainer
@dynamic isSelected, isTransparent;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 6;
        self.layer.borderColor = [[UIColor grayColor] CGColor];
        self.layer.borderWidth = 3;
        self.layer.backgroundColor = [[UIColor underPageBackgroundColor] CGColor];
    }
    return self;
}

- (void) setIsSelected: (BOOL) isSelected {
    self.layer.borderColor = isSelected ? [[UIColor whiteColor] CGColor] : [[UIColor grayColor] CGColor];
}

- (void) setIsTransparent: (BOOL)isTransparent {
    self.layer.backgroundColor = isTransparent ? [[UIColor clearColor] CGColor] : [[UIColor underPageBackgroundColor] CGColor];
    self.layer.borderColor = isTransparent ? [[UIColor clearColor] CGColor] : [[UIColor grayColor] CGColor];
}

@end
