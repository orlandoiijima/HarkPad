//
//  TableMapViewController.m
//  HarkPad
//
//  Created by Willem Bison on 03-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "TableMapViewController.h"
#import "Service.h"
#import "Table.h"
#import "TableInfo.h"
#import "TablePopupViewController.h"
#import "NewOrderVC.h"
#import "ReservationsTableViewController.h"
#import "ChefViewController.h"
#import "PaymentViewController.h"
#import "BillViewController.h"

@implementation TableMapViewController

@synthesize map, tableMapView, districtPicker, currentDistrict, isRefreshTimerDisabled, buttonEdit, buttonRefresh, dragPosition, dragTableButton, dragTableOriginalCenter, popoverController, scaleX, isEditing;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    map = [[Cache getInstance] map];
    [self setupDistrictPicker];
    
    [NSTimer scheduledTimerWithTimeInterval:10.0f
                                     target:self
                                   selector:@selector(refreshView)
                                   userInfo:nil
                                    repeats:YES];   
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGesture];
    [panGesture release];   

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [tableMapView addGestureRecognizer:tapGesture];
    [tapGesture release];   

    [self refreshView];		
}

- (void) handleTapGesture: (UITapGestureRecognizer *)tapGestureRecognizer
{
//    if(isEditing) return;
    CGPoint point = [tapGestureRecognizer locationInView:tableMapView];
    TableButton *clickButton = [self tableButtonAtPoint:point];
    if(clickButton != nil)
        [self clickTable:clickButton];
    
}

- (IBAction) editMode:(UIControl*)sender
{
    isEditing = !isEditing;
    buttonEdit.style = isEditing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
}

- (void) handlePanGesture: (UIPanGestureRecognizer *)panGestureRecognizer
{
    switch(panGestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
//            if(isEditing == false)
//                return;
            dragPosition = [panGestureRecognizer locationInView:tableMapView];
            dragTableButton = [self tableButtonAtPoint:dragPosition];
            dragTableOriginalCenter= dragTableButton.center;
            break;
        }
        
        case UIGestureRecognizerStateChanged:
        {
            if(dragTableButton == nil) return;
            [popoverController dismissPopoverAnimated:YES];
            CGPoint point = [panGestureRecognizer locationInView:tableMapView];
            if(dragTableButton.table.seatOrientation == row)
                point.y = dragPosition.y;
            else
                point.x = dragPosition.x;
            dragTableButton.center = CGPointMake(dragTableButton.center.x + point.x - dragPosition.x, dragTableButton.center.y + point.y - dragPosition.y);
            dragPosition = point;
            break;
        }
        
        case UIGestureRecognizerStateEnded:
        {
            if(dragTableButton == nil) return;
            CGPoint point = [panGestureRecognizer locationInView:tableMapView];
            if(dragTableButton.table.seatOrientation == row)
                point.y = dragPosition.y;
            else
                point.x = dragPosition.x;
            TableButton *targetTableButton = [self tableButtonAtPoint: point];
            if(targetTableButton == nil)
            {
                dragTableButton.center = dragTableOriginalCenter;
            }
            else
            {
                NSMutableArray *tables = [self dockTableButton:dragTableButton toTableButton: targetTableButton];
                for(int i=1; i < [tables count]; i++) {
                    TableButton *button = [self findButton:[tables objectAtIndex:i]];
                    [button removeFromSuperview];
                }
            }
            break;
        }
    }
}

- (NSMutableArray *) dockTableButton: (TableButton *)outerMostTableButton toTableButton: (TableButton*) masterTableButton
{
    Table *masterTable = masterTableButton.table;
    if([masterTableButton.table isSeatAlignedWith:outerMostTableButton.table] == false)
        return false;
    NSMutableArray *tables = [[NSMutableArray alloc] init];
    [tables addObject: masterTable];
    CGRect outerBounds = CGRectUnion(masterTable.bounds, outerMostTableButton.table.bounds);
    for(TableButton *tableButton in tableMapView.subviews) {
        Table* table = tableButton.table;
        if(masterTable.id != table.id) {
            if([masterTable isSeatAlignedWith:table]) {
                if(CGRectContainsRect(outerBounds, table.bounds)) {
                    [tables addObject:table];
                    if(table.seatOrientation == row)
                    {
                        if(masterTable.bounds.origin.x > table.bounds.origin.x)
                            masterTable.bounds = CGRectMake(masterTable.bounds.origin.x - table.bounds.size.width,
                                                            masterTable.bounds.origin.y,
                                                            masterTable.bounds.size.width + table.bounds.size.width,
                                                            masterTable.bounds.size.height);
                        else
                            masterTable.bounds = CGRectMake(masterTable.bounds.origin.x,
                                                            masterTable.bounds.origin.y,
                                                            masterTable.bounds.size.width + table.bounds.size.width,
                                                            masterTable.bounds.size.height);
                    }
                    else
                    {
                        if(masterTable.bounds.origin.y > table.bounds.origin.y)
                            masterTable.bounds = CGRectMake(masterTable.bounds.origin.x,
                                                            masterTable.bounds.origin.y - table.bounds.size.height,
                                                            masterTable.bounds.size.width,
                                                            masterTable.bounds.size.height + table.bounds.size.height);
                        else
                            masterTable.bounds = CGRectMake(masterTable.bounds.origin.x,
                                                            masterTable.bounds.origin.y,
                                                            masterTable.bounds.size.width,
                                                            masterTable.bounds.size.height + table.bounds.size.height);
         
                    }
                    masterTable.countSeats += table.countSeats;
                    [tableButton removeFromSuperview];
                }
            }
        }
    }   
    
    if([tables count] > 1)
    {
        [masterTableButton setNeedsDisplay];
        CGRect boundingRect = [currentDistrict getRect]	;
        [masterTableButton rePosition: masterTable offset: boundingRect.origin scaleX: scaleX];
        [[Service getInstance] dockTables:tables];
    }
    return tables;
}

- (TableButton *) findButton: (Table *) table
{
    for(UIView *view in tableMapView.subviews)
    {
        TableButton *button = (TableButton*)view;
        if(button.table.id == table.id)
            return button;
    }
    return nil;
}

- (TableButton *) tableButtonAtPoint: (CGPoint) point
{
    for(UIView *view in tableMapView.subviews)
    {
        if(view == dragTableButton) continue;
        CGPoint p = [tableMapView convertPoint:point toView:view];
        if([view pointInside:p withEvent:UIEventTypeTouches])
        {
            return (TableButton*)view;
        }
    }
    return nil;
}

- (IBAction) refreshView
{
    if(isRefreshTimerDisabled) return;
    
    for(UIView *view in tableMapView.subviews) [view removeFromSuperview];
    [tableMapView setNeedsDisplay];
    if(districtPicker.selectedSegmentIndex >= map.districts.count) return; 
    currentDistrict = [map.districts objectAtIndex:districtPicker.selectedSegmentIndex];
    CGRect boundingRect = [currentDistrict getRect]	;
    scaleX = ((float)tableMapView.bounds.size.width - 20) / boundingRect.size.width;
    if(scaleX * boundingRect.size.height > tableMapView.bounds.size.height)
        scaleX = ((float)tableMapView.bounds.size.height - 20) / boundingRect.size.height;
    float scaleY = scaleX;
    
    NSMutableArray *tables = [[Service getInstance] getTablesInfo];
    
    NSMutableDictionary *districtTables = [[NSMutableDictionary alloc] init];
    for(TableInfo *tableInfo in tables)
    {
        if(tableInfo.table.dockedToTableId != -1)
            continue;
        District *district = [[[Cache getInstance] map] getDistrict:tableInfo.table.id];
        if(district.id == currentDistrict.id) {
            TableButton *button = [TableButton buttonWithTable:tableInfo.table offset:boundingRect.origin scaleX:scaleX scaleY:scaleX];
            button.userInteractionEnabled = false;
            [button addTarget:self action:@selector(clickTable:) forControlEvents:UIControlEventTouchDown];
            button.orderInfo = tableInfo.orderInfo;
            [tableMapView addSubview:button];
        }
        if(tableInfo.orderInfo != nil) {
            NSNumber *count = [districtTables objectForKey:district.name];
            if(count == nil)
                count = [NSNumber numberWithInt:0];
            [districtTables setObject:[NSNumber numberWithInt:[count intValue]+1] forKey:district.name];
        }
    }
    
    int i = 0;
    for(District *district in map.districts)
    {
        NSNumber *count = [districtTables valueForKey:district.name];
        NSString *countString = count == nil ? @"" : [NSString stringWithFormat:@" (%@)", count];
        NSString *title = [NSString stringWithFormat:@"%@%@", district.name, countString];
        [districtPicker setTitle:title forSegmentAtIndex: i];
        i++;
    }

}

- (void) rotateTables
{
    double quarter = M_PI_2;
    for(Table *table in [currentDistrict tables])
    {
        CGAffineTransform rotate = CGAffineTransformMakeRotation(quarter);
        table.bounds = CGRectApplyAffineTransform(table.bounds, rotate);
        table.seatOrientation = table.seatOrientation == row ? column : row;
    }
}

- (void) setupDistrictPicker
{
    [districtPicker removeAllSegments];
    for(District *district in map.districts)
    {
        [districtPicker insertSegmentWithTitle:district.name atIndex:districtPicker.numberOfSegments animated:YES];
    }
    districtPicker.selectedSegmentIndex = 0;
    [districtPicker addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventAllEvents];
}

- (OrderInfo *) orderInfoForTable: (int)tableId inOrders: (NSMutableArray *) orders
{
    for(OrderInfo *order in orders)
    {
        if(order.table.id == tableId)
        {
            return order;
        }
    }
    return nil;
}

- (void) clickTable: (UIControl *) sender
{
    TableButton *tableButton = (TableButton *)sender;
    Order *order = [[Service getInstance] getOpenOrderByTable: tableButton.table.id];
    
    TablePopupViewController *tablePopup = [TablePopupViewController menuForTable: tableButton.table withOrder: order];
    popoverController = [[UIPopoverController alloc] initWithContentViewController:tablePopup];

    popoverController.delegate = self;

    tablePopup.popoverController = popoverController;
    
    [popoverController presentPopoverFromRect:tableButton.frame inView: self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

}

- (void)payOrder: (Order *)order
{
    if(order == nil)
        return;
    PaymentViewController *paymentVC = [[PaymentViewController alloc] init];	
    paymentVC.order = order;
    paymentVC.tableMapViewController = self;
    paymentVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;    
    [self presentModalViewController: paymentVC animated:YES];
}

- (void)gotoOrderViewWithOrder: (Order *)order
{
    if(order == nil)
        return;
    isRefreshTimerDisabled = true;
    NewOrderVC *newOrderVC = [[NewOrderVC alloc] init];
    newOrderVC.order = order;
    newOrderVC.tableMapViewController = self;

    newOrderVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;    
    [self presentModalViewController:newOrderVC animated:YES];
}

- (void) closeOrderView
{
    isRefreshTimerDisabled = false;
    [self dismissModalViewControllerAnimated:YES];
    [self performSelector:@selector(refreshTableButtons) withObject:nil afterDelay:1];
}

- (void) newOrderForTable: (Table *) table
{
    Order *newOrder = [Order orderForTable:table];
    if(newOrder == nil) return;
    [self gotoOrderViewWithOrder:newOrder];
}

- (void) startTable: (Table *)table fromReservation: (Reservation *)reservation
{
    Service *service = [Service getInstance];
    [service startTable:table.id fromReservation: reservation.id];
}

- (void) editOrder: (Order *) order
{
    [self gotoOrderViewWithOrder: order];
}

- (void) startNextCourse: (Order *)order
{
    Course *nextCourse = [order getNextCourse];
    if(nextCourse == nil)
    {
    }
    else
    {
        [[Service getInstance] startCourse: nextCourse.id]; 
    }
}

- (void) makeBills: (Order*)order
{
    if(order == nil)
        return;
    BillViewController *billVC = [[BillViewController alloc] init];	
    billVC.order = order;
    billVC.tableMapViewController = self;
    billVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;    
    [self presentModalViewController: billVC animated:YES];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
