//
//  GridViewCellLine.h
//  HarkPad
//
//  Created by Willem Bison on 15-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CellPath.h"

@interface GridViewCellLine : UIView {
    UILabel *textLabel;
    UILabel *middleLabel;
    UILabel *bottomLabel;
    CellPath *path;
    BOOL isSelected;
    BOOL isDropTarget;
}

@property (retain) UILabel *textLabel;
@property (retain) UILabel *middleLabel;
@property (retain) UILabel *bottomLabel;
@property (retain) UIButton *deleteButton;
@property (retain) CellPath *path;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isDropTarget;

+ (GridViewCellLine *)cellLineWithCellLine: (GridViewCellLine *)cellLine;

- (id)initWithTitle: (NSString *) title middleLabel: (NSString *)middleLabel bottomLabel: (NSString *)bottomLabel backgroundColor: (UIColor *)backgroundColor path: (CellPath *)path;
- (void) addDeleteButtonWithTarget: (id)target action: (SEL) action;
- (void) removeDeleteButton;

@end
