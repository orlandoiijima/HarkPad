//
//  CollapseTableViewHeader.m
//  HarkPad
//
//  Created by Willem Bison on 02/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "CollapseTableViewHeader.h"
#import "Utils.h"
#import "UIImage+Tint.h"
#import "OrderDataSourceSection.h"
#import "OrderDataSource.h"
#import "SeatGridView.h"

@implementation CollapseTableViewHeader

@synthesize section = _section, delegate = _delegate, tableView = _tableView, imageView, isExpanded, seatGridView, isSelected, label, expandButton;

- (id)initWithFrame:(CGRect)frame section: (NSUInteger) section delegate: (id<OrderDelegate>) delegate tableView: (UITableView *) tableView guests: (NSMutableArray *)guests isExpanded: (BOOL)expanded isSelected: (BOOL)selected
{
    self = [super initWithFrame: frame];
    if (self) {
        _section = section;
        _delegate = delegate;
        _tableView = tableView;

        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
        tapper.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tapper];

        self.backgroundColor = [UIColor blackColor];
        [self addTarget:self action:@selector(headerClick:event:) forControlEvents:UIControlEventTouchDown];

        expandButton = [UIButton buttonWithType:UIButtonTypeCustom];

        UIImage *image = [UIImage imageNamed: @"circle-east.png"];
        [expandButton setImage:image forState:UIControlStateNormal];
        [expandButton setImage:image forState:UIControlStateHighlighted];
        [expandButton addTarget:self action:@selector(expandClick) forControlEvents:UIControlEventTouchDown];
        expandButton.frame = CGRectMake(0, 0, 35, frame.size.height);
        if (expanded)
            [self setExpandedImage:YES animate:NO];

        label = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, frame.size.width/2, frame.size.height)];
        label.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];

        OrderDataSource *dataSource = (OrderDataSource *) tableView.dataSource;
        OrderDataSourceSection *sectionInfo = [dataSource groupForSection: section];
        UILabel *labelAction = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/3, 0, frame.size.width - frame.size.width/3 - 20, frame.size.height)];
        labelAction.textAlignment = UITextAlignmentRight;
        labelAction.text = sectionInfo.subTitle;
        labelAction.textColor = [UIColor lightGrayColor];
        labelAction.font = [UIFont systemFontOfSize:12];
        labelAction.backgroundColor = [UIColor clearColor];

        seatGridView = [SeatGridView viewWithFrame:CGRectMake(frame.size.width - 59, 0, 36, frame.size.height) table:dataSource.order.table guests: guests];
        if ([labelAction.text length] > 0)
            seatGridView.hidden = YES;

        [self addSubview: expandButton];
        [self addSubview:label];
        [self addSubview:labelAction];
        [self addSubview:seatGridView];

        CALayer *layer = [CALayer layer];
        layer.cornerRadius = 6;
        layer.frame = self.bounds; // CGRectInset(self.bounds, 2, 2);
        layer.borderColor = [[UIColor clearColor] CGColor];
        layer.borderWidth = 3;
        layer.backgroundColor = [[UIColor clearColor] CGColor];
        [self.layer insertSublayer:layer atIndex:0];

        isExpanded = expanded;
        self.isSelected = selected;
    }
    return self;
}

- (void)setFrame:(CGRect)aFrame {
    [super setFrame:aFrame];
    CALayer *layer = [self.layer.sublayers objectAtIndex:0];
    int countRows = [_tableView numberOfRowsInSection:self.section];
    if (countRows == INT32_MAX)
        return;
    float sectionHeight = self.frame.size.height;
    if (countRows > 0) {
        sectionHeight += 10;
        for (int row = 0; row < countRows; row++) {
            sectionHeight += [_tableView.delegate tableView:_tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow: row inSection: self.section]];
        }
    }
    layer.frame = CGRectMake(0, 0, self.frame.size.width, sectionHeight);
}

- (void) doubleTap
{
    isExpanded = YES;
    imageView.image = [[UIImage imageNamed:@"expanded.png"] imageTintedWithColor: [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1]];
    if ([self.delegate respondsToSelector:@selector(didExpandSection: collapseAllOthers:)])
        [self.delegate didExpandSection: _section collapseAllOthers:YES];
}

- (void) headerClick: (id) sender event:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(didSelectSection:)])
        [self.delegate didSelectSection: _section];
}

- (void) expandClick
{
    self.isExpanded = !self.isExpanded;
}

- (void) setIsSelected: (BOOL) newIsSelected
{
    isSelected = newIsSelected;
    CALayer *layer = [self.layer.sublayers objectAtIndex:0];
    if (newIsSelected) {
        layer.borderColor = [[UIColor whiteColor] CGColor];
        layer.backgroundColor = [[UIColor clearColor] CGColor];
    }
    else {
        layer.borderColor = [[UIColor clearColor] CGColor];
        layer.backgroundColor = [[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.1] CGColor];
    }
}

- (void) setIsExpanded: (BOOL) newIsExpanded
{
    isExpanded = newIsExpanded;
//    [expandButton setImage:[UIImage imageNamed: isExpanded ? @"circle-south.png" : @"circle-east.png"] forState:UIControlStateNormal];
    [self setExpandedImage:newIsExpanded animate:YES];
    if (newIsExpanded == NO)
    {
        if ([self.delegate respondsToSelector:@selector(didCollapseSection:)])
            [self.delegate didCollapseSection: _section];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(didExpandSection: collapseAllOthers:)])
            [self.delegate didExpandSection: _section collapseAllOthers:NO];
    }
}

- (void) setExpandedImage: (BOOL)expand animate:(BOOL)animate{
    if (animate)
        [UIView animateWithDuration:0.2 animations:^{
            [expandButton.imageView layer].transform = expand ?
               CATransform3DMakeRotation(M_PI_2, 0.0f, 0.0f, 1.0f) :
               CATransform3DMakeRotation(0, 0.0f, 0.0f, 1.0f);
        }];
    else {
        [expandButton.imageView layer].transform = expand ?
           CATransform3DMakeRotation(M_PI_2, 0.0f, 0.0f, 1.0f) :
           CATransform3DMakeRotation(0, 0.0f, 0.0f, 1.0f);

    }
}

@end
