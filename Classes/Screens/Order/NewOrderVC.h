//
//  NewOrderVC.h
//  HarkPad2
//
//  Created by Willem Bison on 19-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
#import "TableMapViewController.h"
#import "ProductPanelView.h"
#import "DragNode.h"
#import "Splitter.h"
#import "OrderGridView.h"

@interface NewOrderVC : UIViewController <UIActionSheetDelegate,UIPopoverControllerDelegate,UIGestureRecognizerDelegate> {
    Order *order;
    DragNode *dragNode;
    CGPoint dragStart;
    TreeNode *rootNode, *currentNode;
    OrderGridView *orderGridView;	
}

typedef enum Orientation {SeatColumns, CourseColumns} Orientation ;
typedef enum DragType {dragProduct, dragOrderLine, dragOrderGridColumnHeader, dragOrderGridRowHeader} DragType ;
typedef enum ShowType {Drink, Food, FoodAndDrink} ShowType ;

@property (retain) IBOutlet Splitter *splitter;
@property (retain) ProductPanelView *productPanelView;
@property (retain) OrderGridView *orderGridView; 
@property (retain) UIViewController *menuViewController;
@property (retain, nonatomic) Order *order;
//@property (retain) TableMapViewController *tableMapViewController;
@property (retain) IBOutlet UIBarButtonItem *tableLabel;
@property (retain) IBOutlet UIButton *saveButton;
@property (retain) IBOutlet UISegmentedControl *existingButton;
@property (retain) IBOutlet UISegmentedControl *orientationSegment;
@property (retain) IBOutlet UISegmentedControl *filterSegment;
@property (retain) IBOutlet UISegmentedControl *panelSegment;

@property CGPoint dragOffset;
@property CGPoint dragStart;
@property (retain) DragNode *dragNode;

@property (retain) TreeNode *rootNode;
@property (retain) TreeNode *currentNode;

@property DragType dragType;
@property Orientation orientation;
@property ShowType showType;
@property BOOL showExisting;

- (BOOL) isPoint: (CGPoint) point inView: (UIView *) view;
- (BOOL) matchesFilter: (OrderLine *)orderLine;

- (void) showActionSheetForSeat: (int) seat;
- (void) showActionSheetForCourse: (int) course;

- (void) droppedDragNodeAtPoint: (CGPoint)point;
- (void) gotoMenuCard;

- (void) moveCourses: (int)firstCourseToMove delta: (int) delta;
- (void) moveSeats: (int)firstSeatToMove delta: (int) delta;

- (void) refreshSelectedCell;

- (void) startCourse: (int) courseId;

- (void) setupToolbar;

- (IBAction) saveAction;
- (IBAction) cancelAction;
- (IBAction) existingAction;
- (IBAction) orientationAction;
- (IBAction) filterAction;
- (void) panelButtonClick: (TreeNode *) node;
//- (DragNode *) createDragNode: (TreeNode *) treeNode frame:(CGRect) rect;
- (NSMutableArray *) orderLinesWithCourse: (int) course seat: (int)seat;
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;

- (void)  moveDragNodeHome;

- (void) gridScrollRight;
- (void) gridScrollLeft;
- (void) gridScrollUp;
- (void) gridScrollDown;

@end
