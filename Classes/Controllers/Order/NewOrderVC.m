//
//  NewOrderVC.m
//  HarkPad2
//
//  Created by Willem Bison on 19-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "NewOrderVC.h"
#import "Service.h"
#import "Cache.h"
#import "Menu.h"
#import "MenuItem.h"
#import "DragNode.h"
#import "NewOrderView.h"
#import "OrderGridView.h"
#import "OrderLineDetailViewController.h"
#import "ModalAlert.h"

@implementation NewOrderVC

@synthesize splitter, menuViewController, productPanelView, orderGridView, tableLabel;
@synthesize order, orderLineGridArray, dragType, orientation, dragStart;
@synthesize saveButton, existingButton, orientationSegment, filterSegment, panelSegment;
@synthesize currentNode, rootNode, dragNode, dragOffset, showType, showExisting;


- (void)viewDidLoad {
    [super viewDidLoad];

//    order = [[Service getInstance] getOrder:1];
    ((NewOrderView *)self.view).controller = self;
    
    orientation = CourseColumns;
    showType = FoodAndDrink;
    showExisting = YES;
    
    productPanelView = [[ProductPanelView alloc] init];
    
    CGRect frame = CGRectMake(0, 0, 10, 10);
    orderGridView = [[OrderGridView alloc] initWithFrame:frame];
//    orderGridView.order = order;

    [splitter initWithView: productPanelView secondView: orderGridView controller: self position:300 width: 30];
    [orderGridView redraw];
}

- (void) setOrder: (Order *) newOrder
{
    if(order != newOrder)
    {
        [order release];
        order = [newOrder retain];            
        orderGridView.order = order;
        [self createOrderLineGridArray];
        tableLabel.text = [[order.tables objectAtIndex:0] name];
    }
}

- (void) gotoMenuCard
{
    rootNode = [[Cache getInstance] tree];
    int countSegments = 0;
    for(TreeNode *node in rootNode.nodes)
    {
        if(node.menu == nil && node.product == nil)
        {
            if(productPanelView.menuCardSegment.selectedSegmentIndex == countSegments)
            {
                productPanelView.parentNode = node;
                productPanelView.rootNode = node;    
                [productPanelView setNeedsDisplay];
            }
            countSegments++;
        }
    }
}

- (void) panelButtonClick: (TreeNode *) node
{
    if(node.product != nil) {
        if(orderGridView.dropTarget != nil)
        {
            int seat = orientation == SeatColumns ? orderGridView.dropTarget.column : orderGridView.dropTarget.row;
            int course = orientation == CourseColumns ? orderGridView.dropTarget.column : orderGridView.dropTarget.row;
            
            [order addLineWithProductId:node.product.id seat: seat course: course];
            [orderGridView redraw];
        }
    }
    else {
        productPanelView.parentNode = node;
        [productPanelView setNeedsDisplay];
    }  
}

- (void) droppedDragNodeAtPoint: (CGPoint)point 
{
    if(dragNode == nil) return;
//    [dragNode release];
    OrderGridHitInfo *hitInfo = [orderGridView getHitInfo: [self.view convertPoint:point toView:orderGridView]];
    if(hitInfo.type == -1)
    {
        if(dragNode.orderLine != nil)
        {
            NSUInteger answer = [ModalAlert confirm: @"Wil je de regel verwijderen ?"];
            if(answer == 1)
                dragNode.orderLine.entityState = Deleted;
        }
    }
    else
    {
        int seat = orientation == SeatColumns ? hitInfo.cell.column : hitInfo.cell.row;
        int course = orientation == CourseColumns ? hitInfo.cell.column : hitInfo.cell.row;
        if(dragNode.treeNode != nil)
        {
            if(dragNode.treeNode.menu != nil)
            {
                Menu* menu = dragNode.treeNode.menu;
                for(MenuItem *menuItem in menu.items)
                {
                    [order addLineWithProductId:menuItem.product.id seat:seat course: menuItem.course];
                }
            }
            else
            {
                Product *product = dragNode.treeNode.product;
                [order addLineWithProductId: product.id seat: seat course: course];
            }
        }
        else
        {
            dragNode.orderLine.entityState = Modified;
            dragNode.orderLine.course = course;
            dragNode.orderLine.seat = seat;
        }
        [self createOrderLineGridArray];
    }
    [dragNode removeFromSuperview];
    dragNode = nil;
    orderGridView.dropTarget = nil;
    [orderGridView redraw];
}


- (void) createOrderLineGridArray
{
    int countColumns = [order getLastCourse] + 2;
    int countRows = [order getLastSeat] + 2;
    orderLineGridArray = [[NSMutableArray alloc] init];
    for(int i=0; i < countRows; i++)
    {
        NSMutableArray *courseCounts = [[NSMutableArray alloc] init];
        for(int c = 0; c < countColumns; c++)
        {
            NSMutableArray *courseSeatLines = [[NSMutableArray alloc] init];
            [courseCounts insertObject:courseSeatLines atIndex:c];
        }
        [orderLineGridArray insertObject:courseCounts atIndex:i];
    }
    
    for(OrderLine *line in order.lines)
    {
        int course = line.course;
        int seat = line.seat;
        NSMutableArray *courses = [orderLineGridArray objectAtIndex:seat];
        NSMutableArray *courseSeatLines = [courses objectAtIndex:course];
        [courseSeatLines addObject:line];
    }
}

- (NSMutableArray *) orderLinesWithCourse: (int) course seat: (int)seat
{
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    for(OrderLine *line in [[orderLineGridArray objectAtIndex: seat] objectAtIndex: course])
        if([self matchesFilter:line])
            [lines addObject:line];
    return lines;
}

- (NSMutableArray *) orderLinesWithColumn: (int) column row: (int) row
{
    int seat = orientation == SeatColumns ? column : row;
    int course = orientation == CourseColumns ? column : row;
    
    return [self orderLinesWithCourse:course seat:seat];
}


- (NSString *) getSeatString: (int) seat
{
    return [NSString stringWithFormat:@"Stoel %d", seat+1]; 
}

- (NSString *) getSeatChar: (int) seat
{
    return [NSString stringWithFormat:@"%d", seat+1]; 
}
- (NSString *) getCourseString: (int) course
{
    NSArray *chars = [NSArray arrayWithObjects:@"A", @"B",@"C",@"D",@"E",@"F",nil];
    return [NSString stringWithFormat:@"Gang %@", [chars objectAtIndex: course]]; 
}

- (NSString *) getCourseChar: (int) course
{
    NSArray *chars = [NSArray arrayWithObjects:@"A", @"B",@"C",@"D",@"E",@"F",nil];
    return [NSString stringWithFormat:@"%@", [chars objectAtIndex: course]]; 
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [orderGridView redraw];    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    dragStart = [[touches anyObject] locationInView:self.view];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    
    if(dragNode == nil)
    {
        CGRect rect;
        if([self isPoint: point inView:productPanelView])
        {
            TreeNode *node = [productPanelView treeNodeByPoint: [self.view convertPoint:point toView:productPanelView] frame:&rect];
            rect = [productPanelView convertRect:rect toView:self.view];
            dragNode = [DragNode nodeWithNode: node frame:rect];
            dragType = dragProduct;
        }
        else
        {
            OrderGridHitInfo *hitInfo = [orderGridView getHitInfo: [self.view convertPoint:point toView:orderGridView]];
            if(hitInfo.type == -1) return;
            if(hitInfo.type == 0)
            {
                rect = [orderGridView convertRect:hitInfo.frame toView:self.view];
                dragNode = [DragNode nodeWithOrderLine:hitInfo.orderLine frame:rect];
                dragType = dragOrderLine;
            }
            if(hitInfo.type == 1)
                dragType = dragOrderGridColumnHeader;
            if(hitInfo.type == 2)
                dragType = dragOrderGridRowHeader;
        }
        dragOffset = CGPointMake(point.x - rect.origin.x, point.y - rect.origin.y);
        [self.view addSubview:dragNode];    
    }   
    dragNode.frame = CGRectMake(point.x - dragOffset.x, point.y - dragOffset.y, dragNode.frame.size.width, dragNode.frame.size.height);

    if([self isPoint: point inView:orderGridView])
        [orderGridView targetMoved: [self.view convertPoint:point toView:orderGridView]];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{   
    UITouch *touch = [touches anyObject];    
    CGPoint point = [touch locationInView:self.view];
    if(dragNode == nil)
    {
        if([self isPoint: point inView: orderGridView])
        {
            OrderGridHitInfo *hitInfo = [orderGridView getHitInfo: [self.view convertPoint:point toView:orderGridView]];
            if(hitInfo.cell == nil) return;
            switch(hitInfo.type)
            {
                case 0:
                    if(hitInfo.orderLine != nil)
                        [orderGridView select: hitInfo.orderLine];
                    else
                    {
                        int seat = orientation == SeatColumns ? hitInfo.cell.column : hitInfo.cell.row;
                        int course = orientation == CourseColumns ? hitInfo.cell.column : hitInfo.cell.row;
                        
                        [orderGridView selectCourse: course seat: seat line: hitInfo.cell.line];
                    }
                    if(touch.tapCount == 2)
                    {
                        [orderGridView editOrderLineProperties];
                    }
                    break;
                case 1:
                    if(dragType == dragOrderGridColumnHeader)
                    {
                        if(point.x < dragStart.x)
                            [self gridScrollLeft];
                        if(point.x > dragStart.x)
                            [self gridScrollRight];
                        return;
                    }
                    if(orientation == SeatColumns)
                        [self showActionSheetForSeat: hitInfo.cell.column];
                    else
                        [self showActionSheetForCourse: hitInfo.cell.column];
                    break;
                case 2:
                    if(dragType == dragOrderGridRowHeader)
                    {
                        if(point.y < dragStart.y)
                            [self gridScrollUp];
                        if(point.y > dragStart.y)
                            [self gridScrollDown];
                        return;
                    }
                    if(orientation == SeatColumns)
                        [self showActionSheetForCourse: hitInfo.cell.row];
                    else
                        [self showActionSheetForSeat: hitInfo.cell.row];
                    break;
            }
        }
        else
            if([self isPoint: point inView: productPanelView])
        {
            CGRect rect;
            TreeNode *node = [productPanelView treeNodeByPoint: [self.view convertPoint:point toView:productPanelView] frame:&rect];
            if(node == nil)
            {
                return;
            }
            [self panelButtonClick:node];
        }
    }
    else
    {
        [self droppedDragNodeAtPoint: point];
    }
}

- (BOOL) isPoint: (CGPoint) point inView: (UIView *) view
{
    CGPoint convertedPoint = [self.view convertPoint:point toView:view];
    return [view pointInside:convertedPoint withEvent:nil];
}

- (BOOL) matchesFilter: (OrderLine *)orderLine
{
    if(orderLine == nil)
        return NO;
    if(orderLine.entityState == Deleted) return false;
    if(showExisting == false && orderLine.entityState != New) return false;
    if(showType == FoodAndDrink) return true;
    if(showType == Food && orderLine.product.category.isFood) return true;
    if(showType == Drink && orderLine.product.category.isFood == false) return true;
    return false;
}

- (void) showActionSheetForSeat: (int) seat
{
    NSString *title = [self getSeatString:seat];
    NSString *insertBefore = [NSString stringWithFormat:@"Invoegen voor %@", title];
    NSString *insertAfter = [NSString stringWithFormat:@"Invoegen na %@", title];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: insertBefore, insertAfter, @"Verwijderen", nil];
    sheet.tag = 2 + (seat << 8);
    [sheet showInView:self.view];
}

- (void) showActionSheetForCourse: (int) course
{
    NSString *title = [self getCourseString:course];
    NSString *insertBefore = [NSString stringWithFormat:@"Invoegen voor %@", title];
    NSString *insertAfter = [NSString stringWithFormat:@"Invoegen na %@", title];
    NSString *getCourse = [NSString stringWithFormat:@"%@ opvragen", title];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: insertBefore, insertAfter, @"Verwijderen", getCourse, nil];
    sheet.tag = 1 + (course << 8);
    [sheet showInView:self.view];
}

- (void) actionSheet: (UIActionSheet *) actionSheet clickedButtonAtIndex: (int)buttonIndex
{
    int type = (int)actionSheet.tag & 0xff;
    int parameter = (int)actionSheet.tag >> 8;
    switch(type)
    {
        case 1:
        {
            int course = parameter;
            switch(buttonIndex)
            {
                case 0:
                    [self moveCourses: course delta: 1];
                    break;
                case 1:
                    [self moveCourses: course+1 delta: 1];
                    break;
                case 2:
                    [self startCourse: course forOrder: order.id];
                    break;
            }
            break;
        }
    }
}

- (void) moveCourses: (int)firstCourseToMove delta: (int) delta
{
    for(OrderLine *line in order.lines)
    {
        if(line.course >= firstCourseToMove)
        {
            line.course += delta;
            if(line.entityState == None)
                line.entityState = Modified;
        }
    }
    [self createOrderLineGridArray];
    [orderGridView redraw];
}

- (void) moveSeats: (int)firstSeatToMove delta: (int) delta
{
    for(OrderLine *line in order.lines)
    {
        if(line.seat >= firstSeatToMove)
        {
            line.seat += delta;
            if(line.entityState == None)
                line.entityState = Modified;
        }
    }
    [self createOrderLineGridArray];
    [orderGridView redraw];
}

- (void) startCourse: (int) course forOrder: (int) orderId
{
    [[Service getInstance] startCourse:course forOrder:orderId];     
}

- (void) gridScrollRight
{
    if(orderGridView.firstColumn != 0)
    {
        orderGridView.firstColumn--;
        [orderGridView redraw];
    }
}

- (void) gridScrollLeft
{
    if(YES)
    {
        orderGridView.firstColumn++;
        [orderGridView redraw];
    }
}

- (void) gridScrollUp
{
    if(orderGridView.firstRow != 0)
    {
        orderGridView.firstRow--;
        [orderGridView redraw];
    }
}

- (void) gridScrollDown
{
    if(YES)
    {
        orderGridView.firstRow++;
        [orderGridView redraw];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
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

- (void) save
{
    [[Service getInstance] updateOrder:order]; 
}

- (void) existingAction
{
    showExisting = !showExisting;
    [orderGridView redraw];
}

- (void) orientationAction
{
    orientation = orientation == SeatColumns ? CourseColumns : SeatColumns;
    [orderGridView redraw];
}

- (void) filterAction
{
    switch(filterSegment.selectedSegmentIndex)
    {
        case 0:
            showType = Drink;
            break;
        case 1:
            showType = Food;
            break;
        case 2:
            showType = FoodAndDrink;
            break;
    }
    [orderGridView redraw];
}

- (void) panelAction
{
    switch(panelSegment.selectedSegmentIndex)
    {
        case 0:
            [splitter collapseFirst];
            break;
        case 1:
            [splitter expandFirst];
            break;
    }
}

@end
