//
//  NewOrderVC.h
//  HarkPad2
//
//  Created by Willem Bison on 19-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
//#import "OrderViewDetailController.h"
#import "ProductPanelView.h"
#import "DragNode.h"
#import "Splitter.h"
#import "OrderGridView.h"

@interface NewOrderVC : UIViewController <UIActionSheetDelegate,UIPopoverControllerDelegate> {
}

typedef enum Orientation {SeatColumns, CourseColumns} Orientation ;
typedef enum DragType {dragProduct, dragOrderLine, dragOrderGridColumnHeader, dragOrderGridRowHeader} DragType ;
typedef enum ShowType {Drink, Food, FoodAndDrink} ShowType ;

@property (retain) IBOutlet Splitter *splitter;
@property (retain) ProductPanelView *productPanelView;
@property (retain) OrderGridView *orderGridView; 
@property (retain) UIViewController *menuViewController;
@property (retain) Order *order;

@property (retain) IBOutlet UILabel *tableLabel;
@property IBOutlet (retain) UIButton *saveButton;
@property (retain) IBOutlet UISegmentedControl *existingButton;
@property (retain) IBOutlet UISegmentedControl *orientationSegment;
@property (retain) IBOutlet UISegmentedControl *filterSegment;
@property (retain) IBOutlet UISegmentedControl *panelSegment;

@property CGPoint dragOffset;
@property CGPoint dragStart;
@property (retain) DragNode *dragNode;

@property (retain) TreeNode *rootNode;
@property (retain) TreeNode *currentNode;

@property (retain) NSMutableArray *orderLineGridArray;

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

- (NSString *) getSeatString: (int) seat;
- (NSString *) getCourseString: (int) course;
- (NSString *) getSeatChar: (int) seat;
- (NSString *) getCourseChar: (int) course;

- (void) moveCourses: (int)firstCourseToMove delta: (int) delta;
- (void) moveSeats: (int)firstSeatToMove delta: (int) delta;

- (void) startCourse: (int) course forOrder: (int) orderId;

- (IBAction) save;
- (IBAction) existingAction;
- (IBAction) orientationAction;
- (IBAction) filterAction;
- (void) panelButtonClick: (TreeNode *) node;
//- (DragNode *) createDragNode: (TreeNode *) treeNode frame:(CGRect) rect;
- (void) createOrderLineGridArray;
- (NSMutableArray *) orderLinesWithCourse: (int) course seat: (int)seat;
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;

- (void) gridScrollRight;
- (void) gridScrollLeft;
- (void) gridScrollUp;
- (void) gridScrollDown;

@end
