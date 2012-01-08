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
    DragModeNone,
    DragModeCopy,
    DragModeMove
} DragMode;

typedef enum
{
    DropModeNone,
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

@end

@protocol GridViewDelegate <NSObject>

@optional
- (void) gridView: (GridView *) gridView startsDragWithCellLine: (GridViewCellLine *)cellLine;
- (void) gridView: (GridView *) gridView movesDragWithCellLine: (GridViewCellLine *)cellLine atPoint: (CGPoint)point;
- (void) gridView: (GridView *) gridView endsDragWithCellLine: (GridViewCellLine *)cellLine atPoint: (CGPoint)point;
- (void) gridView: (GridView *) gridView didMoveCellLine: (GridViewCellLine *)cellLine;
- (bool) gridView: (GridView *) gridView canDeleteCellLine: (GridViewCellLine *)cellLine;
- (void) gridView: (GridView *) gridView didDeleteCellLine: (GridViewCellLine *)cellLine;

- (NSUInteger)gridView:(GridView *)gridView heightForLineAtPath:(CellPath *)path;

//- (bool) gridView: (GridView *) gridView shouldSelectCellLine: (GridViewCellLine *)cellLine;
- (GridViewCellLine *) gridView: (GridView *) gridView willSelectCellLine: (GridViewCellLine *)cellLine;
- (void) gridView: (GridView *) gridView didSelectCellLine: (GridViewCellLine *)cellLine;
- (void) gridView: (GridView *) gridView didTapCellLine: (GridViewCellLine *)cellLine;

- (GridViewCellLine *) gridView: (GridView *) gridView willDeselectCellLine: (GridViewCellLine *)cellLine;
- (void) gridView: (GridView *) gridView didDeselectCellLine: (GridViewCellLine *)cellLine;

- (bool) gridView: (GridView *) gridView canDragCellLine: (GridViewCellLine *)cellLine;
- (void) gridView: (GridView *) gridView didDeselectCellLine: (GridViewCellLine *)cellLine;
- (UIView *)gridView:(GridView *)gridView viewForSelectedCellLine: (GridViewCellLine *)cellLine;
- (UIView *) viewForHeader:(GridView *)gridView;
- (NSUInteger) heightForHeader:(GridView *)gridView;
- (void)gridView:(GridView *)gridView willDisplayCellLine:(GridViewCellLine *)cell;

@end

@interface GridView : UIView <UIGestureRecognizerDelegate> {
	id<GridViewDataSource> __strong _dataSource;
    id<UIScrollViewDelegate,GridViewDelegate> __strong _delegate;
    float leftHeaderWidth;
    float topHeaderHeight;
    DragMode _dragMode;
    DropMode _dropMode;
    NSMutableArray *dragSteps;
}

typedef enum TapStyle {tapNothing, tapPopout, tapPopoutPopin} TapStyle;

@property (retain) UIScrollView *topView;
@property (retain) UIScrollView *leftView;
@property (retain) UIScrollView *contentView;

@property (nonatomic, retain) id<GridViewDataSource> dataSource;
@property (nonatomic, retain) id<UIScrollViewDelegate, GridViewDelegate> delegate;

@property float leftHeaderWidth;
@property float topHeaderHeight;
@property float spaceBetweenCellLines;
@property CGSize cellPadding;
@property int columnWidth;
@property CGPoint dragCellLineCenter;
@property CGPoint dragTouchPoint;
@property (retain) GridViewCellLine *dragCellLine;
@property (retain, nonatomic) GridViewCellLine *selectedCellLine;
@property DropMode dropMode;
@property DragMode dragMode;
@property CellMode cellMode;
@property TapStyle tapStyle;
@property (retain) NSMutableArray *dragSteps;

- (void) reloadData;
- (void) initView;
- (GridViewHeaderCell *)cellAtColumn: (NSUInteger)column row: (NSUInteger) row;
- (void) selectCellLine: (GridViewCellLine *)cellLine select: (bool) isSelected;
- (CGRect) frameForPath: (CellPath *)path;
- (GridViewCellLine *)findCellLineInView: (UIView *)view path: (CellPath *)path;
- (void) popoutCellLine: (GridViewCellLine *)cellLine;
- (void) popinCellLine: (GridViewCellLine *)cellLine;
- (void)moveCellLine:(GridViewCellLine *)cellLine toPath: (CellPath *)path;
- (void) storeDragStep: (CellPath *)path;
- (GridViewCellLine *) cellLineAtPoint: (CGPoint)point;
- (void) shiftCellsUp: (CellPath *)startPath;
- (void) shiftCellsDown: (CellPath *)startPath;
- (void) shiftCells: (CellPath *)startPath delta: (int)delta;
- (void) swapCellLine: (GridViewCellLine *)from withCellLine: (GridViewCellLine *)cellLine;

@end
