//
//  OrderGridView.m
//  HarkPad2
//
//  Created by Willem Bison on 08-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "OrderGridView.h"
#import "NewOrderVC.h"
#import "NewOrderView.h"
#import "Course.h"
#import "Utils.h"

@implementation OrderGridView

@synthesize cellSpaceWidth, cellBorderWidth, cellSpaceHeight, cellBorderHeight, tableMarginWidth, tableMarginHeight, tableBorderWidth, tableBorderHeight, columnWidth, firstRow, firstColumn, rowHeaderWidth, rowFooterWidth, columnHeaderHeight, columnFooterHeight, lineHeight, lineSeparatorHeight, minimumColumnWidth, countVisibleColumns, dropTarget, selectedCell;
/*
 
|tableMarginWidth|tableBorderWidth|rowHeaderWidth|cellSpaceWidth| cellBorderWidth | cellcontent | cellBorderWidth | cellSpaceWidth | cellBorderWidth | cellcontent | cellBorderWidth | cellSpaceWidth | tableBorderWidth | tableMarginWidth
*/
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        lineHeight = 40;
        columnHeaderHeight = 22;
        rowHeaderWidth = 30;
        cellSpaceWidth = 8;
        cellSpaceHeight = 8;
        lineSeparatorHeight = 1;
        minimumColumnWidth = 80;
        firstColumn = 0;
        dropTarget = nil;
        selectedCell = nil;
	    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [[UIColor blackColor] set];
    UIRectFill(rect);
    NewOrderVC *topController = [(NewOrderView*)[[self superview] superview] controller];
    Order *order = [topController order];
    int countRows = topController.orientation == CourseColumns ? order.lastSeat + 2 : order.lastCourse.offset + 2;
    for(int column = firstColumn; column < firstColumn + countVisibleColumns; column++)
    {
        for(int row = firstRow; row < countRows; row++)
        {
            int seat = topController.orientation == SeatColumns ? column : row;
            int course = topController.orientation == CourseColumns ? column : row;
            
            CGRect frame = [self getRect: column row:row];
            
            frame = CGRectInset(frame, cellBorderWidth, cellBorderHeight);
            if(column == firstColumn)
            {
                if([order isCourseAlreadyRequested:course] && topController.orientation == SeatColumns)
                {
                    CGRect frame = [self getRect: column row:row];
                    frame.size.width = self.bounds.size.width;
                    frame.origin.x = 0;
                    frame = CGRectInset(frame, -cellSpaceWidth, -cellSpaceHeight);
                    [[UIColor colorWithWhite:0.1 alpha:1] set];
                    UIRectFill(frame);
                }
                CGRect rowHeaderFrame = CGRectMake(tableMarginWidth + tableBorderWidth, frame.origin.y, rowHeaderWidth, frame.size.height - cellSpaceHeight);
                [self drawRowHeader: rowHeaderFrame row: row];
            }
            if(row == firstRow)
            {
                UIColor *headerColor = [UIColor whiteColor];
                if([order isCourseAlreadyRequested:course] && topController.orientation == CourseColumns)
                {
                    CGRect frame = [self getRect: column row:row];
                    frame.size.height = self.bounds.size.height;
                    frame = CGRectInset(frame, -cellSpaceWidth, -cellSpaceHeight);
                    [[UIColor colorWithWhite:0.1 alpha:1] set];
                    UIRectFill(frame);
                    headerColor = [UIColor grayColor];
                }
                CGRect columnHeaderFrame = CGRectMake(frame.origin.x, tableMarginHeight + tableBorderHeight, frame.size.width, columnHeaderHeight);
                [self drawColumnHeader: columnHeaderFrame column: column textColor: headerColor];
            }
            int lineOffset = 0;
            NSMutableArray *cellOrderLines = [topController orderLinesWithCourse: course seat: seat];
            for(OrderLine *line in cellOrderLines)
            {
                if([topController matchesFilter:line])
                {
                    BOOL selected = (selectedCell != nil && selectedCell.column == column && selectedCell.row == row && selectedCell.line == lineOffset);
                    [self drawOrderLine: line frame:frame selected: selected first: lineOffset == 0 last: lineOffset + 1 == cellOrderLines.count];
                    frame = CGRectOffset(frame, 0, lineHeight + lineSeparatorHeight);
                    lineOffset++;
                }
            }
        }
    }
}

- (void) drawRoundedRect:(CGContextRef)c rect:(CGRect)rect radiusTop:(int)radiusTop  radiusBottom:(int)radiusBottom color:(UIColor *)color
{
    int x_left = rect.origin.x;
    int x_right = rect.origin.x + rect.size.width;
    
    int y_top = rect.origin.y;
    int y_bottom = rect.origin.y + rect.size.height;
    
    /* Begin! */
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, x_left, y_top + radiusTop);
    
    /* First corner */
    CGContextAddArcToPoint(c, x_left, y_top, x_left + radiusTop, y_top, radiusTop);
    CGContextAddLineToPoint(c, x_right - radiusTop, y_top);
    
    /* Second corner */
    CGContextAddArcToPoint(c, x_right, y_top, x_right, y_top + radiusTop, radiusTop);
    CGContextAddLineToPoint(c, x_right, y_bottom - radiusBottom);
    
    /* Third corner */
    CGContextAddArcToPoint(c, x_right, y_bottom, x_right - radiusBottom, y_bottom, radiusBottom);
    CGContextAddLineToPoint(c, x_left + radiusBottom, y_bottom);
    
    /* Fourth corner */
    CGContextAddArcToPoint(c, x_left, y_bottom, x_left, y_bottom - radiusBottom, radiusBottom);
    CGContextAddLineToPoint(c, x_left, y_top + radiusBottom);
    
    /* Done */
    CGContextClosePath(c);
    
    CGContextSetFillColorWithColor(c, color.CGColor);
    
    CGContextFillPath(c);
}


- (void) redraw
{
    [self calculateContentSize];
    [self setNeedsDisplay];
}

- (void) calculateContentSize
{
    NewOrderVC *topController = [(NewOrderView*)[[self superview] superview] controller];
    
    int countCourses = topController.order.lastCourse.offset + 2;
    int countSeats = topController.order.lastSeat + 2;

    int countColumns = topController.orientation == SeatColumns ? countSeats : countCourses;
    int countRows = topController.orientation == CourseColumns ? countSeats : countCourses;
    
    countVisibleColumns = (self.bounds.size.width - 2 * (tableMarginWidth + tableBorderWidth) - rowHeaderWidth - rowFooterWidth) / minimumColumnWidth;
    if(countColumns - firstColumn < countVisibleColumns)
        countVisibleColumns = countColumns - firstColumn;
    if(countVisibleColumns == 0)
        countVisibleColumns = 1;
    columnWidth = (self.bounds.size.width - 2 * (tableMarginWidth + tableBorderWidth) - rowHeaderWidth - rowFooterWidth) / (countVisibleColumns);
    int height = 2 * (tableMarginHeight + tableBorderHeight) + columnHeaderHeight + columnFooterHeight;
    for(int row = 0; row < countRows; row++)
    {
        height += [self getRowHeight:row];
    }
//    self.contentSize = CGSizeMake(width, height);
}

- (void) drawRowHeader: (CGRect) frame row: (int)row
{
    NewOrderVC *topController = [(NewOrderView*)[[self superview] superview] controller];
    if((dropTarget != nil && dropTarget.row == row) || (selectedCell != nil && selectedCell.row == row))
        [[UIColor blueColor] set];
    else
        [[UIColor blackColor] set];
    UIRectFill(frame);
    [[UIColor whiteColor] set];
    UIFont *font = [UIFont systemFontOfSize:17];
    NSString *label = topController.orientation == SeatColumns ? [Utils getCourseChar:row]: [Utils getSeatChar: row];
    CGSize size = [label sizeWithFont:font forWidth:frame.size.width lineBreakMode:UILineBreakModeClip];
    CGPoint point = CGPointMake(frame.origin.x + (frame.size.width - size.width)/2, frame.origin.y + (frame.size.height - size.height)/2);
    [label drawAtPoint:point withFont:font];
    return;
}

- (void) drawColumnHeader: (CGRect) frame column: (int) column textColor: (UIColor *) textColor
{
    NewOrderVC *topController = [(NewOrderView*)[[self superview] superview] controller];
    
    if((dropTarget != nil && dropTarget.column == column) || (selectedCell != nil && selectedCell.column == column))
        [[UIColor blueColor] set];
    else
        [[UIColor blackColor] set];
    UIRectFill(frame);
    [textColor set];
    UIFont *font = [UIFont systemFontOfSize:17];
    NSString *label = topController.orientation == SeatColumns ? [Utils getSeatString:column]: [Utils getCourseString: column];
    CGSize size = [label sizeWithFont:font forWidth:frame.size.width lineBreakMode:UILineBreakModeClip];
    CGPoint point = CGPointMake(frame.origin.x + (frame.size.width - size.width)/2, frame.origin.y + (frame.size.height - size.height)/2);
    [label drawAtPoint:point withFont:font];
    return;
}

- (void) drawOrderLine: (OrderLine *)orderLine frame: (CGRect) frame selected: (BOOL) selected first:(BOOL)first last:(BOOL)last
{
    frame.size.height = lineHeight;
    CGContextRef c = UIGraphicsGetCurrentContext();
    UIColor *bgrColor;
    UIColor *textColor;
    if(selected)
    {
        bgrColor = [UIColor blueColor];
        textColor = [UIColor whiteColor];
    }
    else
    {
        bgrColor = orderLine.product.category.color;
        if(bgrColor == [UIColor blackColor])
            bgrColor = [UIColor greenColor];
        textColor = [UIColor blackColor];
    }
        
    [self drawRoundedRect:c rect:frame radiusTop:first ? 8:0 radiusBottom:last ? 8:0 color:bgrColor];
    [textColor set];
    UIFont *font = orderLine.entityState == EntityStateNew ? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:17];
    CGSize size = [orderLine.product.key sizeWithFont:font forWidth:frame.size.width lineBreakMode:UILineBreakModeClip];
    CGPoint point = CGPointMake(frame.origin.x + (frame.size.width - size.width)/2, frame.origin.y + (frame.size.height - size.height)/2);
    if((orderLine.propertyValues!= nil && orderLine.propertyValues.count > 0) || orderLine.note.length > 0)
        point.y -= 7;
    [orderLine.product.key drawAtPoint:point withFont:font];
    
    UIFont *smallFont = [UIFont systemFontOfSize:9];
    bgrColor = [UIColor whiteColor];
    int x = frame.origin.x + 5; 
    int y = point.y + size.height;
    for(OrderLinePropertyValue *propertyValue in orderLine.propertyValues)
    {
        NSString *props = [propertyValue.displayValue uppercaseString];
        CGSize smallSize = [props sizeWithFont:smallFont forWidth: (frame.origin.x + frame.size.width - x) lineBreakMode:UILineBreakModeClip];
        CGRect rect = CGRectMake(x, y, smallSize.width + 3, smallSize.height + 1);
        [bgrColor set];
        UIRectFill(rect);
        [[UIColor grayColor] set];
        UIRectFrame(rect);
        [[UIColor blackColor] set];
        rect = CGRectOffset(rect, 2, 1);
        [props drawInRect:rect withFont:smallFont];
        x += rect.size.width - 1;
    }
    
    if(orderLine.note.length > 0)
    {
        CGSize smallSize = [orderLine.note sizeWithFont:smallFont forWidth: (frame.origin.x + frame.size.width - x) lineBreakMode:UILineBreakModeClip];
        CGRect rect = CGRectMake(x, y, smallSize.width + 3, smallSize.height + 1);
        [bgrColor set];
        UIRectFill(rect);
        [[UIColor grayColor] set];
        UIRectFrame(rect);
        [[UIColor blackColor] set];
        rect = CGRectOffset(rect, 2, 1);
        [orderLine.note drawInRect:rect withFont:smallFont];
    }
    return;
}


- (OrderGridHitInfo *) getHitInfo : (CGPoint) point;
{
    NewOrderVC *topController = [(NewOrderView*)[[self superview] superview] controller];
    OrderGridHitInfo *hitInfo = [[OrderGridHitInfo alloc] init];
    int countRows = topController.order.lastSeat + 2;
    for(hitInfo.cell.column = -1; hitInfo.cell.column < firstColumn + countVisibleColumns; hitInfo.cell.column++)
    {
        CGRect frame = [self getRect: hitInfo.cell.column row:0];
        frame.origin.y = 0;
        frame.size.height = 32000;
        if(CGRectContainsPoint(frame, point))
        {
            for(hitInfo.cell.row = -1; hitInfo.cell.row < countRows; hitInfo.cell.row++)
            {
                CGRect frame = [self getRect: hitInfo.cell.column row:hitInfo.cell.row];
                if(CGRectContainsPoint(frame, point))
                {
                    if(hitInfo.cell.column == -1)
                    {
                        hitInfo.type = orderGridRowHeader;
                        return hitInfo;
                    }
                    if(hitInfo.cell.row == -1)
                    {
                        hitInfo.type = orderGridColumnHeader;
                        return hitInfo;
                    }
                    frame = CGRectInset(frame, cellBorderWidth, cellBorderHeight);       
                    frame.size.height = lineHeight + lineSeparatorHeight;
                    int seat = topController.orientation == SeatColumns ? hitInfo.cell.column : hitInfo.cell.row;
                    int course = topController.orientation == CourseColumns ? hitInfo.cell.column : hitInfo.cell.row;
                    for(OrderLine *line in [topController orderLinesWithCourse: course seat: seat])
                    {
                        if(CGRectContainsPoint(frame, point))
                        {
                            hitInfo.orderLine = line;
                            break;
                        }
                        hitInfo.cell.line++;
                        frame = CGRectOffset(frame, 0, lineHeight + lineSeparatorHeight);
                    }
                    hitInfo.frame = frame;
                    hitInfo.type = orderLine;
                    return hitInfo;
                }
                if(hitInfo.cell.row == -1)
                    hitInfo.cell.row = firstRow - 1; 
            }
        }
        
        if(hitInfo.cell.column == -1)
            hitInfo.cell.column = firstColumn - 1; 
    }
    return hitInfo;
}


- (CGRect) getRect: (int) column row: (int) row
{
    int y = tableMarginHeight + tableBorderHeight;
    if(row == -1)
    {
    }
    else
    {
        y += columnHeaderHeight + cellSpaceHeight;
        for(int r = firstRow; r < row; r++)
        {
            y += [self getRowHeight:r];
        }
    }
    if(column == -1)
        return CGRectMake(
                          tableMarginWidth + tableBorderWidth,
                          y,
                          rowHeaderWidth,
                          [self getRowHeight:row]);
    else
        return CGRectMake(
                          tableMarginWidth + tableBorderWidth + rowHeaderWidth + (column - firstColumn) * columnWidth + cellSpaceWidth,
                          y,
                          columnWidth - cellSpaceWidth,
                          [self getRowHeight:row]);
}

- (int) getRowHeight: (int) row
{
    if(row == -1)
        return columnHeaderHeight + cellSpaceHeight;
    NewOrderVC *topController = [(NewOrderView*)[[self superview] superview] controller];
    int maxLines = 1;
    
    int countColumns = topController.orientation == SeatColumns ? topController.order.lastSeat + 2 : topController.order.lastCourse.offset + 2;

    for(int column = firstColumn; column < countColumns; column++)
    {
        int seat = topController.orientation == SeatColumns ? column : row;
        int course = topController.orientation == CourseColumns ? column : row;
        NSMutableArray *lines = [topController orderLinesWithCourse: course seat: seat];    
        if(lines.count > maxLines)
           maxLines = lines.count;
    }
    return cellBorderHeight * 2 + cellSpaceHeight + maxLines * (lineHeight + lineSeparatorHeight) - lineSeparatorHeight;
}

- (void) targetMoved: (CGPoint) point
{
    OrderGridHitInfo *hitInfo = [self getHitInfo:point];

    GridCell *newDropTarget;
    if(hitInfo.type == nothing)
    {
        newDropTarget = nil;
    }
    else
    {
        newDropTarget = [GridCell cellWithColumn:hitInfo.cell.column row:hitInfo.cell.row line: hitInfo.cell.line];
    }
    
    if(newDropTarget != dropTarget)
    {
        if(dropTarget != nil)
        {
//            CGRect rect = [self getRect: dropTarget.column row:dropTarget.row];
//            [self drawRowHeader: rect row: dropTarget.row];
//            [self drawColumnHeader: rect column: dropTarget.column textColor: [UIColor blueColor]];
        }
        self.dropTarget = newDropTarget;
        if(dropTarget != nil)
        {
//            CGRect rect = [self getRect: dropTarget.column row:dropTarget.row];
//            if(dropTarget.row != -1)
//                [self drawRowHeader: rect row: dropTarget.row];
//            if(dropTarget.column != -1)
//                [self drawColumnHeader: rect column: dropTarget.column textColor: [UIColor blueColor]];
        }
        NewOrderVC *topController = [(NewOrderView*)[[self superview] superview] controller];
        int seat = topController.orientation == SeatColumns ? dropTarget.column : dropTarget.row;
        int course = topController.orientation == CourseColumns ? dropTarget.column : dropTarget.row;
        
        [self selectCourse: course seat:seat line:dropTarget.line];
    }
    
    [self redraw];
}

- (void) editOrderLineProperties
{
    NewOrderVC *topController = [(NewOrderView*)[[self superview] superview] controller];

    OrderLine *orderLine = [self getSelectedOrderLine];
    if(orderLine == nil) return;
    OrderLineDetailViewController *detailViewController = [[OrderLineDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    detailViewController.orderLine = orderLine;
    detailViewController.controller = topController;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: detailViewController];
    navController.title = orderLine.product.name;
    
    detailViewController.contentSizeForViewInPopover = CGSizeMake(600, 300);
    
    UIPopoverController *popOver = [[UIPopoverController alloc] initWithContentViewController:navController];
    popOver.delegate = topController;
    CGRect rect = [self getRect:selectedCell.column row:selectedCell.row];
    [popOver presentPopoverFromRect: rect inView: self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    detailViewController.popoverContainer = popOver;
}

- (OrderLine *) getSelectedOrderLine
{
    if(selectedCell == nil) return nil;

    NewOrderVC *topController = [(NewOrderView*)[[self superview] superview] controller];

    int seat = topController.orientation == SeatColumns ? selectedCell.column : selectedCell.row;
    int course = topController.orientation == CourseColumns ? selectedCell.column : selectedCell.row;

    NSMutableArray *orderLines = [topController orderLinesWithCourse: course seat:seat];
    if(orderLines != nil && selectedCell.line < orderLines.count)
        return [orderLines objectAtIndex: selectedCell.line];
    else
        return nil;    
}

- (void) select: (OrderLine *)line
{

    NewOrderVC *topController = [(NewOrderView*)[[self superview] superview] controller];
    NSMutableArray *orderlines = [topController orderLinesWithCourse: line.course.offset seat:line.guest.seat];
    int offset = 0;
    for(OrderLine * cellLine in orderlines)
    {
        if(cellLine == line) break;
        offset++;
    }

    int column = topController.orientation == SeatColumns ? line.guest.seat : line.course.offset;
    int row = topController.orientation == CourseColumns ? line.guest.seat : line.course.offset;
    
    selectedCell = [GridCell cellWithColumn:column row:row line:offset];
    [self redraw];
}

- (void) selectCourse: (int)course seat: (int)seat line: (int)line
{
    NewOrderVC *topController = [(NewOrderView*)[[self superview] superview] controller];

    int column = topController.orientation == SeatColumns ? seat : course;
    int row = topController.orientation == CourseColumns ? seat : course;

    selectedCell = [GridCell cellWithColumn:column row:row line:line];

    [self redraw];
}
 


@end
