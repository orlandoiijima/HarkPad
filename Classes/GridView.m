//
//  GridView.m
//  HarkPad
//
//  Created by Willem Bison on 15-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "GridView.h"

@interface GridView ()
- (void) setContentHeight: (float) height;
- (void) setContentWidth: (float) width;

@end

@implementation GridView

@synthesize leftView, topView, contentView, dataSource = _dataSource, delegate = _delegate, leftHeaderWidth = _leftHeaderWidth, topHeaderHeight = _topHeaderHeight, columnWidth, dragCellLine, dragCellLineCenter,  cellPadding, spaceBetweenCellLines, selectedCellLine = _selectedCellLine, dropMode = _dropMode, dragMode = _dragMode, dragTouchPoint, cellMode = _cellMode;
@synthesize tapStyle, dragStartPath = _dragStartPath;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self initView];
    return self;
}

- (void) initView
{
    UIScrollView *topHeader = [[UIScrollView alloc] initWithFrame: CGRectZero];
    topHeader.backgroundColor = [UIColor clearColor];
    topHeader.directionalLockEnabled = YES;
    self.topView = topHeader;        
    [self addSubview:topHeader];
    
    UIScrollView *leftHeader = [[UIScrollView alloc] initWithFrame:CGRectZero];
    leftHeader.backgroundColor = [UIColor clearColor];
    leftHeader.directionalLockEnabled = YES;
    self.leftView = leftHeader;
    [self addSubview:leftHeader];
    
    UIScrollView *view = [[UIScrollView alloc] initWithFrame: CGRectZero];
    view.directionalLockEnabled = YES; 	
    view.backgroundColor = [UIColor clearColor];
    view.clipsToBounds = false;
    self.contentView = view;
    [self addSubview:contentView];
    
    self.clipsToBounds = false;
    columnWidth = 100;
    leftHeaderWidth = 100;
    topHeaderHeight = 100;
    
    _dropMode = DropModeInsertCell;
    _dragMode = DragModeNone;
    _cellMode = CellModeFlow;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    [view addGestureRecognizer:panGesture];

    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongGesture:)];
    longGesture.delegate = self;
    [view addGestureRecognizer: longGesture];
}

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initView];
        
    }
    return self;
}

- (void)setLeftHeaderWidth:(float)aLeftHeaderWidth {
    _leftHeaderWidth = aLeftHeaderWidth;
    int countColumns = [_dataSource numberOfColumnsInGridView:self];
    if (countColumns != 0)
        columnWidth = (self.bounds.size.width - 2 * _leftHeaderWidth) / countColumns;
    [self reloadData];
}

- (void)setTopHeaderHeight:(float)aTopHeaderHeight {
    _topHeaderHeight = aTopHeaderHeight;
    [self reloadData];
}

- (void)setDelegate:(id<UIScrollViewDelegate,GridViewDelegate>)newDelegate
{
    _delegate = newDelegate;
    topView.delegate = newDelegate;
    leftView.delegate = newDelegate;
}

- (GridViewCellLine *) cellLineAtPoint: (CGPoint)point
{
    for(GridViewCellLine *cellLine in contentView.subviews) {
        if ([cellLine isKindOfClass:[GridViewCellLine class]])
            if (cellLine != dragCellLine && [cellLine pointInside:[cellLine convertPoint:point fromView:self] withEvent:nil])
                return cellLine;
    }
    return nil;
//    UIView *view = [self hitTest:point withEvent:nil];
//    if(view == nil) return nil;
//    while(view != nil && [view isKindOfClass:[GridViewCellLine class]] == false)
//    {
//        view = view.superview;
//    }
//    return (GridViewCellLine *)view;
}		

- (void) selectCellLine: (GridViewCellLine *)cellLine
{
    if(cellLine == _selectedCellLine)
        return;

    id previousSelection = _selectedCellLine;

    self.selectedCellLine = cellLine;

    if(_selectedCellLine != nil) {
        if([self.delegate respondsToSelector:@selector(gridView: willDisplayCellLine:)])
            [self.delegate gridView:self willDisplayCellLine: previousSelection];
        if([self.delegate respondsToSelector:@selector(gridView: didDeselectCellLine:)])
            [self.delegate gridView:self didDeselectCellLine: previousSelection];
    }

//    if([self.delegate respondsToSelector:@selector(gridView: shouldSelectCellLine:)])
//        if([self.delegate gridView:self shouldSelectCellLine: cellLine] == NO)
//            return;
    
    if(_selectedCellLine != nil) {
//        [self selectCellLine:selectedCellLine select: YES];
        if([self.delegate respondsToSelector:@selector(gridView: willDisplayCellLine:)])
            [self.delegate gridView:self willDisplayCellLine: cellLine];

        if([self.delegate respondsToSelector:@selector(gridView: didSelectCellLine:)])
            [self.delegate gridView:self didSelectCellLine: cellLine];
    }
}

- (void) selectCellLine: (GridViewCellLine *)cellLine select: (bool) isSelected
{
    cellLine.isSelected = isSelected;

    switch(tapStyle)
    {
        case tapNothing:
            break;
        case tapPopout:
            if(isSelected) {
                [self popoutCellLine:cellLine];
            }
            else {
                [self popinCellLine:cellLine];
            }
            break;
        case tapPopoutPopin:
            if(isSelected) {
                [self popoutCellLine:cellLine];
            }
    }
}

- (void) setSelectedCellLine: (GridViewCellLine *)cellLine {
    if (_selectedCellLine != nil)
        _selectedCellLine.isSelected = NO;
    _selectedCellLine = cellLine;    
    if (_selectedCellLine != nil)
        _selectedCellLine.isSelected = YES;
}

- (void) popoutCellLine: (GridViewCellLine *)cellLine
{
    [self.superview bringSubviewToFront: self	];
    [cellLine.superview bringSubviewToFront: cellLine];
    [UIView animateWithDuration:0.2
                 animations:^{
                     cellLine.frame = CGRectInset(cellLine.frame, -35, -15);
                 }
                     completion:^ (BOOL completed){
                         if([self.delegate respondsToSelector:@selector(gridView: canDeleteCellLine:)] == false || [self.delegate gridView:self canDeleteCellLine: _selectedCellLine] == YES)
                             [_selectedCellLine addDeleteButtonWithTarget:self action: @selector(deleteButtonTap)];
                     }
     ];
}

- (void) popinCellLine: (GridViewCellLine *)cellLine
{
    if([self.delegate respondsToSelector:@selector(gridView: canDeleteCellLine:)] == false || [self.delegate gridView:self canDeleteCellLine: _selectedCellLine] == YES)
        [_selectedCellLine removeDeleteButton];
    [UIView animateWithDuration:0.2
                 animations:^{
                     cellLine.frame = [self frameForPath:cellLine.path]; // CGRectInset(cellLine.frame, 35, 15);
                 }
     ];
}

- (void) deleteButtonTap
{
    if([self.delegate respondsToSelector:@selector(gridView: didDeleteCellLine:)])
        [self.delegate gridView: self didDeleteCellLine: _selectedCellLine];
    [_selectedCellLine removeDeleteButton];
    [_selectedCellLine removeFromSuperview];
    if(_cellMode == CellModeFixed)
    {
        _selectedCellLine = nil;
        return;
    }

    [self shiftUpFrom:_selectedCellLine.path to: nil];
}

- (void) shiftUpFrom: (CellPath *)startPath to: (CellPath *)endPath
{
    [self shiftFrom: startPath to: endPath delta: -1];
}

- (void) shiftDownFrom: (CellPath *)startPath  to: (CellPath *)endPath
{
    [self shiftFrom: startPath to: endPath delta: +1];
}

- (void) shiftPath: (CellPath *)path delta: (int)delta
{
    int countColumns = [self.dataSource numberOfColumnsInGridView:self];
    path.column += delta;
    if (path.column == -1) {
        path.column = countColumns - 1;
        path.row--;
    }
    if (path.column == countColumns) {
        path.column = 0;
        path.row++;
    }        
}

- (void) shiftFrom: (CellPath *) startPath to: (CellPath *)endPath delta: (int)delta
{
    if (endPath == nil) {
        int countColumns = [self.dataSource numberOfColumnsInGridView:self];
        int countRows = [self.dataSource numberOfRowsInGridView:self];
        endPath = [CellPath pathForColumn:countColumns-1 row:countRows-1 line:0];
    }
    else
        endPath = [CellPath pathWithPath:endPath];
    CellPath *path = [CellPath pathWithPath: startPath];

    if (delta == 1) {
        //  Start at bottom
        if ([path compare:endPath] == NSOrderedAscending) {
            CellPath *p = path;
            path = endPath;
            endPath = p;
        }
    }
    else {
        //  Start at top
        if ([path compare:endPath] == NSOrderedDescending) {
            CellPath *p = path;
            path = endPath;
            endPath = p;
        }
    }

    NSTimeInterval duration = 0.3;
    NSTimeInterval delay = 0;	
    NSTimeInterval delayStep = 0.06;
    int iterateDelta = -delta;
    while(true) {
        GridViewCellLine *cellLine = [self cellAtColumn:path.column row:path.row];
        if (cellLine != nil) {
            [self shiftPath: cellLine.path delta:delta];
            [UIView animateWithDuration: duration
                                  delay:delay
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 cellLine.frame = [self frameForPath: cellLine.path];
                             }
                             completion:nil];
            delay += delayStep;
            duration = MAX	(0, duration - 0.01);
            
        }

        if ([path isEqualTo: endPath])
            break;
        
        [self shiftPath:path delta:iterateDelta];
    }
}

- (void) selectCell: (GridViewHeaderCell *)cell select: (bool) isSelected
{
    if(cell != nil) {
        cell.isSelected = isSelected;
    }
}

- (void)handleLongGesture: (UILongPressGestureRecognizer *)tapGestureRecognizer
{
    CGPoint point = [tapGestureRecognizer locationInView:self];
    GridViewCellLine *tappedCellLine = [self cellLineAtPoint:point];
    if (tappedCellLine == nil) return;
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if([self.delegate respondsToSelector:@selector(gridView:didEndLongPressCellLine:)])
            [self.delegate gridView:self didEndLongPressCellLine:nil];
    }
    else {
        if([self.delegate respondsToSelector:@selector(gridView:didLongPressCellLine:)])
            [self.delegate gridView:self didLongPressCellLine:tappedCellLine];
    }
}

- (void) handleTapGesture: (UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint point = [tapGestureRecognizer locationInView:self];
    GridViewCellLine *tappedCellLine = [self cellLineAtPoint:point];
    if (tappedCellLine != nil)
        if([self.delegate respondsToSelector:@selector(gridView:didTapCellLine:)])
            [self.delegate gridView:self didTapCellLine:tappedCellLine];
    [self selectCellLine: tappedCellLine];
}

- (void) handlePanGesture: (UIPanGestureRecognizer *)panGestureRecognizer
{
    if (_dragMode == DragModeNone)
        return;
    CGPoint point = [panGestureRecognizer locationInView:self];
    switch(panGestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            GridViewCellLine *cellLine = [self cellLineAtPoint:point];
            if([self.delegate respondsToSelector:@selector(gridView:canDragCellLine:)])
                if([self.delegate gridView:self canDragCellLine: cellLine] == false)
                    return;
            if (_dragMode == DragModeCopy) {
                cellLine = [GridViewCellLine cellLineWithCellLine: cellLine];
                [self addSubview:cellLine];
            }
            _dragStartPath = cellLine.path;
            dragTouchPoint = point;
            dragCellLine = cellLine;
            dragCellLineCenter = dragCellLine.center;
            [dragCellLine.superview bringSubviewToFront:dragCellLine];
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

            GridViewCellLine *cellLine = [self cellLineAtPoint:point];

            if([self.delegate respondsToSelector:@selector(gridView:movesDragWithCellLine: atPoint:)])
                [self.delegate gridView:self movesDragWithCellLine:dragCellLine atPoint: point];

            if(_dropMode == DropModeNone) return;

            if (cellLine != nil && cellLine != dragCellLine)
            {
                [self swapCellLine: dragCellLine withCellLine:cellLine];
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            if(dragCellLine == nil) return;
            if([self.delegate respondsToSelector:@selector(gridView:endsDragWithCellLine: atPoint:)])
                [self.delegate gridView:self endsDragWithCellLine:dragCellLine atPoint: point];

            if(_dropMode != DropModeNone) {
                [self moveCellLine:dragCellLine toPath:dragCellLine.path];
            }
            dragCellLine = nil;
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            break;
    }
}

- (void) swapCellLine: (GridViewCellLine *)from withCellLine: (GridViewCellLine *)to
{
    CellPath *path = [CellPath pathWithPath: to.path];
    int offsetFrom = [self toOffset:from.path];
    int offsetTo = [self toOffset:to.path];
    if (offsetFrom == offsetTo) return;
    if (offsetTo > offsetFrom)
        [self shiftFrom: [self toPath: offsetFrom + 1] to:to.path delta: -1];
    else
        [self shiftFrom: [self toPath: offsetFrom - 1] to:to.path delta: +1];
    from.path = [CellPath pathWithPath:path];
}

- (void)moveCellLine:(GridViewCellLine *)cellLine toPath: (CellPath *)path
{
    [UIView animateWithDuration:0.5 animations:^{
        cellLine.frame = [self frameForPath:path];
    }];
    if ([cellLine.path isEqualTo:path])
        return;
    cellLine.path = [CellPath pathWithPath:path];
    if([self.delegate respondsToSelector:@selector(gridView:didMoveCellLine:)])
        [self.delegate gridView:self didMoveCellLine:dragCellLine];
}

- (void) removeCurrentCellsWithAnimation
{
    for(UIView *view in contentView.subviews) {
        [UIView animateWithDuration:0.3 animations:^{
            view.frame = CGRectMake(view.frame.origin.x + view.frame.size.width/2, view.frame.origin.y + view.frame.size.height/2, 0, 0);
            view.alpha = 0;
        }
        completion: ^ (BOOL completed){
            [view removeFromSuperview];
        }];
    }
}

- (void) addCell: (GridViewCellLine *)cellLine withFrame: (CGRect) frame
{
    cellLine.alpha = 0;
    cellLine.frame = CGRectMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2, 0, 0);
    [contentView addSubview:cellLine];
    [UIView animateWithDuration:0.2 animations:^{
        cellLine.frame = frame;
        cellLine.alpha = 1;
    }];
}

- (void) reloadData
{
//    [self selectCellLine:selectedCellLine select:NO];
    int countRows = [_dataSource numberOfRowsInGridView:self];
    int countColumns = [_dataSource numberOfColumnsInGridView:self];
    [self removeCurrentCellsWithAnimation];
//    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    float left = 0;
    float heightTotal;
    float top = 0;

    float headerHeight = 0;
    if([self.delegate respondsToSelector:@selector(heightForHeader:)])
        headerHeight = [self.delegate heightForHeader:self];

    if([self.delegate respondsToSelector:@selector(viewForHeader:)]) {
        UIView *headerView = [self.delegate viewForHeader:self];
        headerView.frame = CGRectMake(left + cellPadding.width, top + cellPadding.height, 7 * columnWidth, headerHeight);
        [contentView addSubview: headerView];
        top += headerHeight;
    }

    NSMutableArray *rowHeights = [[NSMutableArray alloc] init];

    CellPath *path = [[CellPath alloc] init];
    
    for(; path.row < countRows; path.row++) {

        int rowHeight = 0;
        left = 0;
        
        for(path.column=0; path.column < countColumns; path.column++) {
        
            int countLines = [_dataSource numberOfLinesInGridView: self column:path.column row:path.row];
            
            if(countLines > 0) {
                int cellHeight = 2 * (cellPadding.height);
                int lineTop = top + cellPadding.height;
                int lineLeft = left + cellPadding.width;
                for(path.line = 0; path.line < countLines; path.line++) {
                    if(path.line > 0) {
                        lineTop += spaceBetweenCellLines;
                        cellHeight += spaceBetweenCellLines;
                    }
                    GridViewCellLine *cellLine = [_dataSource gridView:self cellLineForPath:path];
                    if (cellLine == nil)
                        break;
                    cellLine.path = [CellPath pathForColumn:path.column row:path.row line:0];
                    int height = [self.delegate gridView:self heightForLineAtPath:path];
                    CGRect frame = CGRectMake(lineLeft, lineTop, columnWidth - 2 * (cellPadding.width), height);
                    cellHeight += height;
                    if(cellLine != nil) {
                        [self addCell:cellLine withFrame:frame];
                        if([self.delegate respondsToSelector:@selector(gridView: willDisplayCellLine:)])
                            [self.delegate gridView:self willDisplayCellLine: cellLine];
                    }
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
        GridViewHeaderCell *cell = [[GridViewHeaderCell alloc] initWithFrame:CGRectMake(0, top, _leftHeaderWidth, rowHeight)];
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
    self.contentView.frame = CGRectMake( _leftHeaderWidth, _topHeaderHeight, self.contentView.frame.size.width, height);
    self.leftView.frame = CGRectMake(0, _topHeaderHeight, _leftHeaderWidth, height);
    self.leftView.contentSize = CGSizeMake(_leftHeaderWidth, height * 2);
    self.contentView.contentSize = self.contentView.frame.size;
}

- (void) setContentWidth: (float) width
{
    self.contentView.frame = CGRectMake( _leftHeaderWidth, _topHeaderHeight, width, self.contentView.frame.size.height);
    self.topView.frame = CGRectMake( _leftHeaderWidth, 0, width, self.contentView.frame.size.height);
    self.topView.contentSize = CGSizeMake(width * 2, self.contentView.frame.size.height);
    self.contentView.contentSize = CGSizeMake(500, 500); // self.contentView.frame.size;
}

- (GridViewCellLine *)cellAtColumn: (NSUInteger)column row: (NSUInteger) row
{
    CellPath *path = [CellPath pathForColumn:column row:row line:0];
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
    float lineHeight = [self.delegate gridView:self heightForLineAtPath:path];
    float rowHeight = lineHeight + 2 * (cellPadding.height);
    return CGRectMake( path.column * columnWidth + cellPadding.width, path.row * rowHeight + cellPadding.height, columnWidth - 2 * cellPadding.width, lineHeight);
}

- (NSUInteger) toOffset: (CellPath *)path
{
    int countColumns = [self.dataSource numberOfColumnsInGridView:self];
    return (NSUInteger) (path.row * countColumns + path.column);
}

- (CellPath *) toPath: (NSUInteger)offset
{
    int countColumns = [self.dataSource numberOfColumnsInGridView:self];
    return [CellPath pathForColumn: offset % countColumns row: offset / countColumns line:0];
}


@end
