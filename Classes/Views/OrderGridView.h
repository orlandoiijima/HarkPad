//
//  OrderGridView.h
//  HarkPad2
//
//  Created by Willem Bison on 08-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderGridHitInfo.h"
#import "GridCell.h"
#import "OrderLineDetailViewController.h"
#import "Order.h"

@interface OrderGridView : UIView {
    GridCell *dropTarget;
    GridCell *selectedCell;
//    OrderLine *selectedOrderLine;
//    CGRect selectedOrderLineFrame;
}

@property int tableMarginWidth;
@property int tableMarginHeight;
@property int tableBorderWidth;
@property int tableBorderHeight;
@property int cellBorderWidth;
@property int cellBorderHeight;
@property int cellSpaceWidth;
@property int cellSpaceHeight;
@property int columnWidth;
@property int columnHeaderHeight;
@property int columnFooterHeight;
@property int rowHeaderWidth;
@property int rowFooterWidth;
@property int firstColumn;
@property int firstRow;
@property int lineHeight;
@property int lineSeparatorHeight;
@property int minimumColumnWidth;
@property int countVisibleColumns;

@property (retain) GridCell *dropTarget;
@property (retain) GridCell *selectedCell;
//@property (retain) OrderLine *selectedOrderLine;
//@property CGRect selectedOrderLineFrame;

- (OrderLine *) getSelectedOrderLine;

- (CGRect) getRect: (int) column row: (int) row;
- (int) getRowHeight: (int) seat;
- (void) drawOrderLine: (OrderLine *)orderLine frame: (CGRect) frame selected: (BOOL) selected first:(BOOL)first last:(BOOL)last;
- (void) drawRowHeader: (CGRect) frame row: (int)row;
- (void) drawColumnHeader: (CGRect) frame column: (int) column textColor: (UIColor *) textColor;
- (void) calculateContentSize;
- (void) redraw;
- (OrderGridHitInfo *) getHitInfo : (CGPoint) point;
- (void) targetMoved: (CGPoint) point;
- (void) editOrderLineProperties;
- (void) select: (OrderLine *)line;
- (void) selectCourse: (int)course seat: (int)seat line: (int)line;

@end
