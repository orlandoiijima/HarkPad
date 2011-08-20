//
//  GridView.h
//  HarkPad
//
//  Created by Willem Bison on 15-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridViewCellLine.h"
#import "GridViewHeaderCell.h"
#import "CellPath.h"

typedef enum
{
    DragModeCopy,
    DragModeMove
} DragMode;

typedef enum
{
    DropModeInsertCell,
    DropModeAddLine
} DropMode;

typedef enum
{
    CellModeFixed,
    CellModeFlow
} CellMode;

@class GridView;

@protocol GridViewDataSource <NSObject>

@required

- (NSUInteger) numberOfRowsInGridView: (GridView *) gridView;
- (NSUInteger) numberOfColumnsInGridView: (GridView *) gridView;
- (NSUInteger) numberOfLinesInGridView: (GridView *) gridView column: (NSUInteger)column row:(NSUInteger)row;
- (GridViewCellLine *)gridView:(GridView *)gridView cellLineForPath: (CellPath *)path;
- (CGFloat)gridView:(GridView *)gridView heightForLineAtPath:(CellPath *)path;

@end

@protocol GridViewDelegate <NSObject>

@optional
- (void) gridView: (GridView *) gridView startsDragWithCellLine: (GridViewCellLine *)cellLine;
- (void) gridView: (GridView *) gridView movesDragWithCellLine: (GridViewCellLine *)cellLine;
- (void) gridView: (GridView *) gridView endsDragWithCellLine: (GridViewCellLine *)cellLine;
- (bool) gridView: (GridView *) gridView canDeleteCellLine: (GridViewCellLine *)cellLine;
- (bool) gridView: (GridView *) gridView shouldSelectCellLine: (GridViewCellLine *)cellLine;
- (void) gridView: (GridView *) gridView didDeleteCellLine: (GridViewCellLine *)cellLine;
- (bool) gridView: (GridView *) gridView canDragCellLine: (GridViewCellLine *)cellLine;
- (void) gridView: (GridView *) gridView didDeselectCellLine: (GridViewCellLine *)cellLine;
- (UIView *)gridView:(GridView *)gridView viewForSelectedCellLine: (GridViewCellLine *)cellLine;
@end

@interface GridView : UIView <UIGestureRecognizerDelegate> {
	id<GridViewDataSource> __unsafe_unretained _dataSource;
    id<UIScrollViewDelegate,GridViewDelegate> __unsafe_unretained _delegate;
}

@property (retain) UIScrollView *topView;
@property (retain) UIScrollView *leftView;
@property (retain) UIScrollView *contentView;

@property (nonatomic, assign) id<GridViewDataSource> dataSource;
@property (nonatomic, assign) id<UIScrollViewDelegate, GridViewDelegate> delegate;

@property float leftHeaderWidth;
@property float topHeaderHeight;
@property float spaceBetweenCellLines;
@property CGSize cellPadding;
@property float columnWidth;
@property CGPoint dragCellLineCenter;
@property CGPoint dragTouchPoint;
@property (retain) GridViewCellLine *dragCellLine;
@property (retain) GridViewCellLine *selectedCellLine;
@property DropMode dropMode;
@property DragMode dragMode;
@property CellMode cellMode;

- (void) reloadData;
- (void) initView;
//- (GridViewHeaderCell *)findCellInView: (UIView *)view column: (NSUInteger)column row: (NSUInteger) row;
- (GridViewHeaderCell *)cellAtColumn: (NSUInteger)column row: (NSUInteger) row;
- (void) selectCellLine: (GridViewCellLine *)cellLine select: (bool) isSelected;
- (CGRect) frameForPath: (CellPath *)path;
- (GridViewCellLine *)findCellLineInView: (UIView *)view path: (CellPath *)path;
	
@end
