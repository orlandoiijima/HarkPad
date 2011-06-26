//
//  GridView.m
//  HarkPad
//
//  Created by Willem Bison on 15-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "GridView.h"

@interface GridView ()
- (void) setContentHeight: (float) height;
- (void) setContentWidth: (float) width;

@end

@implementation GridView

@synthesize leftView, topView, contentView, dataSource = _dataSource, delegate = _delegate, leftHeaderWidth, topHeaderHeight, columnWidth, dragCellLine, dragCellLineCenter,  cellPadding, spaceBetweenCellLines, selectedCellLine, dropMode = _dropMode, dragMode = _dragMode, dragTouchPoint, cellMode = _cellMode;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    [super initWithCoder:aDecoder];
    [self initView];
    return self;
}

- (void) initView
{

    UIScrollView *topHeader = [[[UIScrollView alloc] initWithFrame: CGRectZero] autorelease];
    topHeader.backgroundColor = [UIColor yellowColor];
    topHeader.directionalLockEnabled = YES;
    self.topView = topHeader;        
    [self addSubview:topHeader];
    
    UIScrollView *leftHeader = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
    leftHeader.backgroundColor = [UIColor yellowColor];
    leftHeader.directionalLockEnabled = YES;
    self.leftView = leftHeader;
    [self addSubview:leftHeader];
    
    UIScrollView *view = [[[UIScrollView alloc] initWithFrame: CGRectZero] autorelease];
    view.directionalLockEnabled = YES; 	
    view.backgroundColor = [UIColor redColor];
    view.clipsToBounds = false;
    self.contentView = view;
    [self addSubview:contentView];
    
    self.clipsToBounds = false;
    columnWidth = 100;
    leftHeaderWidth = 100;
    topHeaderHeight = 100;
    
    _dropMode = DropModeInsertCell;
    _dragMode = DragModeCopy;
    _cellMode = CellModeFlow;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    [tapGesture release];           
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    [view addGestureRecognizer:panGesture];
    [panGesture release];   
}

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initView];
        
    }
    return self;
}

- (void)setDelegate:(id<UIScrollViewDelegate,GridViewDelegate>)newDelegate
{
    _delegate = newDelegate;
    topView.delegate = newDelegate;
    leftView.delegate = newDelegate;
}

- (GridViewCellLine *) cellLineAtPoint: (CGPoint)point
{
    UIView *view = [self hitTest:point withEvent:nil];
    if(view == nil) return nil;
    while(view != nil && [view isKindOfClass:[GridViewCellLine class]] == false)
    {
        view = view.superview;
    }
    return (GridViewCellLine *)view;
}		

- (void) selectCellLine: (GridViewCellLine *)cellLine
{
    if(cellLine == selectedCellLine)
        return;

    if(selectedCellLine != nil)
        [self selectCellLine:selectedCellLine select:NO];
        
    if([self.delegate respondsToSelector:@selector(gridView: shouldSelectCellLine:)])
        if([self.delegate gridView:self shouldSelectCellLine: cellLine] == NO)
            return;
    
    selectedCellLine = cellLine;
    if(selectedCellLine != nil)
        [self selectCellLine:selectedCellLine select: YES];

}

- (void) selectCellLine: (GridViewCellLine *)cellLine select: (bool) isSelected
{
    cellLine.isSelected = isSelected;

    if(isSelected) {
        [cellLine.superview bringSubviewToFront: cellLine];
        [UIView animateWithDuration:0.2
                     animations:^{
                         cellLine.frame = CGRectInset(cellLine.frame, -35, -15);
                     }
                         completion:^ (BOOL completed){
                             if([self.delegate respondsToSelector:@selector(gridView: canDeleteCellLine:)] == false || [self.delegate gridView:self canDeleteCellLine: selectedCellLine] == YES)
                                 [selectedCellLine addDeleteButtonWithTarget:self action: @selector(deleteButtonTap)];
                         }
         ];
    }
    else {
        if([self.delegate respondsToSelector:@selector(gridView: canDeleteCellLine:)] == false || [self.delegate gridView:self canDeleteCellLine: selectedCellLine] == YES)
            [selectedCellLine removeDeleteButton];
        [UIView animateWithDuration:0.2
                     animations:^{
                         cellLine.frame = [self frameForPath:cellLine.path]; // CGRectInset(cellLine.frame, 35, 15);
                     }
         ];
    }
    
//    GridViewHeaderCell *rowHeader = [self cellAtColumn:-1 row: cellLine.path.row];
//    rowHeader.isSelected = isSelected;
//    
//    GridViewHeaderCell *columnHeader = [self cellAtColumn:cellLine.path.column row: -1];
//    columnHeader.isSelected = isSelected;
}

- (void) deleteButtonTap
{
    if([self.delegate respondsToSelector:@selector(gridView: didDeleteCellLine:)])
        [self.delegate gridView: self didDeleteCellLine: selectedCellLine];
    [selectedCellLine removeDeleteButton];
    [selectedCellLine removeFromSuperview];
    if(_cellMode == CellModeFixed)
    {
        selectedCellLine = nil;
        return;
    }

    int countColumns = [self.dataSource numberOfColumnsInGridView:self];
    int countRows = [self.dataSource numberOfRowsInGridView:self];

    CellPath *path = [[[CellPath alloc] init] autorelease];

    NSTimeInterval duration = 0.3;
    NSTimeInterval delay = 0;	
    NSTimeInterval delayStep = 0.06;
    for(path.row = selectedCellLine.path.row; path.row < countRows; path.row++) {
        
        for(path.column = 0; path.column < countColumns; path.column++) {

            if(path.row == selectedCellLine.path.row && path.column <= selectedCellLine.path.column)
                continue;
            GridViewCellLine *cellLine = [self findCellLineInView:contentView path:path];
            if(cellLine != nil) {
                if(cellLine.path.column == 0) {
                    cellLine.path.column = countColumns - 1;
                    cellLine.path.row--;
                }
                else {
                    cellLine.path.column--;
                }
                [UIView animateWithDuration: duration
                                      delay:delay
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     cellLine.frame = [self frameForPath: cellLine.path];
                                 }
                                 completion:nil];
            }
            delay += delayStep;
            duration = MAX	(0, duration - 0.01);
        }
    }
}

- (void) selectCell: (GridViewHeaderCell *)cell select: (bool) isSelected
{
    if(cell != nil) {
        cell.isSelected = isSelected;
    }
}

- (void) handleTapGesture: (UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint point = [tapGestureRecognizer locationInView:self];
    GridViewCellLine *tappedCellLine = [self cellLineAtPoint:point];
    [self selectCellLine: tappedCellLine];
}

- (void) handlePanGesture: (UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint point = [panGestureRecognizer locationInView:self];
    switch(panGestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            GridViewCellLine *cellLine = [self cellLineAtPoint:point];
            if([self.delegate respondsToSelector:@selector(gridView:canDragCellLine:)])
                if([self.delegate gridView:self canDragCellLine: cellLine] == false)
                    return;
            dragTouchPoint = point;
            dragCellLine = cellLine;
            dragCellLineCenter = dragCellLine.center;
            if([self.delegate respondsToSelector:@selector(gridView:startsDragWithCellLine:)])
                [self.delegate gridView:self startsDragWithCellLine:dragCellLine];	
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            if(dragCellLine == nil) return;
            
            int xDistance = point.x - dragTouchPoint.x;
            int yDistance = point.y - dragTouchPoint.y;
            dragCellLine.center = CGPointMake( dragCellLine.center.x + xDistance, dragCellLine.center.y + yDistance);
            dragTouchPoint = point;
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            dragCellLine = nil;
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            break;
    }
}


- (void) reloadData
{
    [self selectCellLine:selectedCellLine select:NO];
    int countRows = [_dataSource numberOfRowsInGridView:self];
    int countColumns = [_dataSource numberOfColumnsInGridView:self];
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    float left = 0;
    float heightTotal;
    float top = 0;
    NSMutableArray *rowHeights = [[NSMutableArray alloc] init];

    CellPath *path = [[[CellPath alloc] init] autorelease];
    
    for(; path.row < countRows; path.row++) {

        float rowHeight = 0;
        left = 0;
        
        for(path.column=0; path.column < countColumns; path.column++) {
        
            int countLines = [_dataSource numberOfLinesInGridView: self column:path.column row:path.row];
            
            if(countLines > 0) {
                float cellHeight = 2 * (cellPadding.height);
                float lineTop = top + cellPadding.height;
                float lineLeft = left + cellPadding.width;
                for(path.line = 0; path.line < countLines; path.line++) {
                    if(path.line > 0) {
                        lineTop += spaceBetweenCellLines;
                        cellHeight += spaceBetweenCellLines;
                    }
                    GridViewCellLine *cellLine = [_dataSource gridView:self cellLineForPath:path];
                    float height = [_dataSource gridView:self heightForLineAtPath:path];
                    cellLine.frame = CGRectMake(lineLeft, lineTop, columnWidth - 2 * (cellPadding.width), height);
                    cellHeight += height;
                    if(cellLine != nil)
                        [contentView addSubview:cellLine];
                    lineTop += height;
                }
            
                if(cellHeight > rowHeight)
                    rowHeight = cellHeight;
            
            }
            
            left += columnWidth;
        }
        
        [rowHeights addObject: [NSNumber numberWithFloat: rowHeight]];
        heightTotal += rowHeight;
        top += rowHeight;
    
    }

    left = 0;
    for(int column=0; column < countColumns; column++) {
        GridViewHeaderCell *cell = [[GridViewHeaderCell alloc] initWithFrame:CGRectMake(left, 0, columnWidth, topHeaderHeight)];
        cell.column = column;
        cell.row = -1;
        [topView addSubview:cell];
        left += columnWidth;
    }
    
    top = 0;
    for(int row=0; row < countRows; row++) {
        float rowHeight = [[rowHeights objectAtIndex:row] floatValue];
        GridViewHeaderCell *cell = [[GridViewHeaderCell alloc] initWithFrame:CGRectMake(0, top, leftHeaderWidth, rowHeight)];
        cell.column = -1;
        cell.row = row;
        [leftView addSubview:cell];
        top += rowHeight;
    }
    
    [self setContentHeight: heightTotal];
    [self setContentWidth: countColumns * columnWidth];
    
    [self setNeedsLayout];
}


- (void) setContentHeight: (float) height
{
    self.contentView.frame = CGRectMake( leftHeaderWidth, topHeaderHeight, self.contentView.frame.size.width, height);
    self.leftView.frame = CGRectMake(0, topHeaderHeight, leftHeaderWidth, height);
    self.leftView.contentSize = CGSizeMake(leftHeaderWidth, height * 2);
    self.contentView.contentSize = self.contentView.frame.size;
}

- (void) setContentWidth: (float) width
{
    self.contentView.frame = CGRectMake( leftHeaderWidth, topHeaderHeight, width, self.contentView.frame.size.height);
    self.topView.frame = CGRectMake( leftHeaderWidth, 0, width, self.contentView.frame.size.height);
    self.topView.contentSize = CGSizeMake(width * 2, self.contentView.frame.size.height);
    self.contentView.contentSize = CGSizeMake(500, 500); // self.contentView.frame.size;
}

- (GridViewCellLine *)cellAtColumn: (NSUInteger)column row: (NSUInteger) row
{
    CellPath *path = [[CellPath pathForColumn:column row:row line:0] autorelease];
    if(row == -1)
        return [self findCellLineInView:topView path:path];
    if(column == -1)
        return [self findCellLineInView:leftView path:path];
    return [self findCellLineInView:contentView path:path];
}

- (GridViewCellLine *)findCellLineInView: (UIView *)view path: (CellPath *)path 
{
    for(GridViewCellLine *cellLine in [view subviews]) {
        if( [cellLine isKindOfClass:[GridViewCellLine class]] == false)
            continue;
        if(cellLine.path.column == path.column && cellLine.path.row == path.row && cellLine.path.line == path.line)
            return cellLine;
    }
    return nil;
}

- (CGRect) frameForPath: (CellPath *)path
{
    float lineHeight = [_dataSource gridView:self heightForLineAtPath:path];
    float rowHeight = lineHeight + 2 * (cellPadding.height);
    return CGRectMake( path.column * columnWidth + cellPadding.width, path.row * rowHeight + cellPadding.height, columnWidth - 2 * cellPadding.width, lineHeight);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}

@end
