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
//    self.layer.borderColor = isSelected ? [[UIColor whiteColor] CGColor] : [[UIColor grayColor] CGColor];
    if (isSelected) {
        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations: ^
        {
            self.transform = CGAffineTransformMakeTranslation(0, 4);
        } completion: nil];
    }
    else {
        [self.layer removeAllAnimations];
        self.transform = CGAffineTransformIdentity;
    }
}

- (void) setIsTransparent: (BOOL)isTransparent {
    self.layer.backgroundColor = isTransparent ? [[UIColor clearColor] CGColor] : [[UIColor underPageBackgroundColor] CGColor];
    self.layer.borderColor = isTransparent ? [[UIColor clearColor] CGColor] : [[UIColor grayColor] CGColor];
}

@end
