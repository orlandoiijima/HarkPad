//
//  GridViewCell.m
//  HarkPad
//
//  Created by Willem Bison on 15-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "GridViewHeaderCell.h"
#import "CellPath.h"

@implementation GridViewHeaderCell

@synthesize row, column, isSelected;

- (id)initWithFrame:(CGRect)frame atPath: (CellPath *)path
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.column = path.column;
        self.row = path.row;
        self.layer.cornerRadius = 0.0;
    }
    return self;
}

- (void) setIsSelected:(bool)isSelected
{
//    if(isSelected)
//        self.layer.borderWidth = 3;
//    else
//        self.layer.borderWidth = 0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
