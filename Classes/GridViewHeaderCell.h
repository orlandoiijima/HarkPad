//
//  GridViewCell.h
//  HarkPad
//
//  Created by Willem Bison on 15-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CellPath.h"

@interface GridViewHeaderCell : UIView {
    int row;
    int column;
}

@property int column;
@property int row;
@property (nonatomic) bool isSelected;

- (id)initWithFrame:(CGRect)frame atPath: (CellPath *)path;

@end
