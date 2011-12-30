	//
//  TableMapViewController.m
//  HarkPad
//
//  Created by Willem Bison on 03-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "TableMapViewController.h"
#import "Service.h"
#import "TablePopupViewController.h"
#import "NewOrderVC.h"
#import "PaymentViewController.h"
#import "BillViewController.h"
#import "ModalAlert.h"
#import "TablesViewController.h"

@implementation TableMapViewController

@synthesize tableMapView, districtPicker, buttonRefresh, popoverController;


- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupToolbar];

    [NSTimer scheduledTimerWithTimeInterval:10.0f
                                     target:self
                                   selector:@selector(refreshView)
                                   userInfo:nil
                                    repeats:YES];   
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGesture];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [tableMapView addGestureRecognizer:tapGesture];

    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [tableMapView addGestureRecognizer:pinchGesture];
    
    [self gotoDistrict];		
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isVisible = true;
    [self refreshView];	
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    isVisible = false;
}

- (void) handlePinchGesture: (UIPinchGestureRecognizer *) pinchGestureRecognizer
{
    if(pinchGestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    if(pinchGestureRecognizer.scale < 1)
        return;
    CGPoint point = [pinchGestureRecognizer locationInView:tableMapView];
    TableButton *clickButton = [self tableButtonAtPoint:point];
    if(clickButton == nil)
        return;
    if(clickButton.table.isDocked == false)
        return;
    [self undockTable: clickButton.table.id]; 
}

- (void) handleTapGesture: (UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint point = [tapGestureRecognizer locationInView:tableMapView];
    TableButton *clickButton = [self tableButtonAtPoint:point];
    if(clickButton == nil)
        return;
    int seat = [clickButton seatByPoint:[tableMapView convertPoint:point toView:clickButton]];
    if(seat != -1)
    {
        [self TransgenderPopup: clickButton seat: seat];
    }
    else
        [self clickTable:clickButton];
    
}

- (void) handlePanGesture: (UIPanGestureRecognizer *)panGestureRecognizer
{
    switch(panGestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            dragPosition = [panGestureRecognizer locationInView:tableMapView];
            dragTableButton = [self tableButtonAtPoint:dragPosition];
            dragTableOriginalCenter= dragTableButton.center;
            isRefreshTimerDisabled = YES;
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
            isRefreshTimerDisabled = NO;
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
                [self dockTableButton:dragTableButton toTableButton: targetTableButton];
             }
            break;
        }
            
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
            break;
    }
}

- (bool) TransgenderPopup: (TableButton *) button seat: (int)seat
{
    SeatInfo *info = [button.orderInfo getSeatInfo:seat];
    if(info == nil) return false;
    
    NSString *message = [NSString stringWithFormat:@"Tafel %@, stoel %d", button.table.name, seat + 1];
    NSUInteger i = [ModalAlert queryWithTitle: [NSString stringWithFormat:@"Gast is %@", (info.isMale ? @"vrouw" : @"man")] message:message button1: @"Ok" button2: @"Terug"];
    if(i != 0) return false;
    info.isMale = !info.isMale;
    NSString *gender = info.isMale ? @"M" : @"F";
    [[Service getInstance] setGender: gender forGuest: info.guestId];
    [button setNeedsDisplay];
    return true;
}

- (NSMutableArray *) dockTableButton: (TableButton *)dropTableButton toTableButton: (TableButton*) targetTableButton
{
    NSMutableArray *tables = [[NSMutableArray alloc] init];

    if([dropTableButton.table isSeatAlignedWith:targetTableButton.table] == false)
        return tables;

    TableButton *masterTableButton, *outerMostTableButton;
    if(targetTableButton.table.seatOrientation == row)
    {
        if(targetTableButton.table.bounds.origin.x > dropTableButton.table.bounds.origin.x)
        {
            masterTableButton = dropTableButton;
            outerMostTableButton = targetTableButton;
        }
        else
        {
            masterTableButton = targetTableButton;
            outerMostTableButton = dropTableButton;
        }
    }
    else
    {
        if(targetTableButton.table.bounds.origin.y > dropTableButton.table.bounds.origin.y)
        {
            masterTableButton = dropTableButton;
            outerMostTableButton = targetTableButton;
        }
        else
        {
            masterTableButton = targetTableButton;
            outerMostTableButton = dropTableButton;
        }
    }

    Table *masterTable = masterTableButton.table;
    
    NSMutableArray *tableButtons = [[NSMutableArray alloc] init];
    CGRect outerBounds = CGRectUnion(masterTable.bounds, outerMostTableButton.table.bounds);
    CGRect saveBounds = masterTable.bounds;
    int saveCountSeats = masterTable.countSeats;
    for(TableButton *tableButton in tableMapView.subviews) {
        Table* table = tableButton.table;
        if(masterTable.id != table.id) {
            if([masterTable isSeatAlignedWith:table]) {
                if(CGRectContainsRect(outerBounds, table.bounds)) {
                    [tableButtons addObject:tableButton];
                    if(table.seatOrientation == row)
                    {
                        masterTable.bounds = CGRectMake(masterTable.bounds.origin.x,
                                                        masterTable.bounds.origin.y,
                                                        masterTable.bounds.size.width + table.bounds.size.width,
                                                        masterTable.bounds.size.height);
                    }
                    else
                    {
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
    
    if([tableButtons count] > 0)
    {
        CGRect boundingRect = [currentDistrict getRect]	;
        
        NSString *message;
        if([tableButtons count] == 1)
            message = [NSString stringWithFormat:@"Tafel %@", ((TableButton*)[tableButtons objectAtIndex:0]).table.name];
        else if([tableButtons count] == 2)  	
            message = [NSString stringWithFormat:@"Tafels %@ en %@", ((TableButton*)[tableButtons objectAtIndex:0]).table.name, ((TableButton*)[tableButtons objectAtIndex:1]).table.name];
        else {
            message = [NSString stringWithFormat:@"Tafels %@", ((TableButton*)[tableButtons objectAtIndex:0]).table.name];
            NSUInteger i = 1;
            for(; i < [tableButtons count] - 1; i++) {
                TableButton *tableButton = [tableButtons objectAtIndex:i];
                message = [NSString stringWithFormat:@"%@, %@,", message, tableButton.table.name];
            }
            message = [NSString stringWithFormat:@"%@ en %@", message, ((TableButton *)[tableButtons objectAtIndex:i]).table.name];
        }
        message = [NSString stringWithFormat:@"%@ aanschuiven bij %@ ?", message, masterTable.name];
        
        isRefreshTimerDisabled = YES;
        
        [masterTableButton setNeedsDisplay];
        [UIView animateWithDuration:1.0  animations:^{
            [masterTableButton setupByTable: masterTable offset: boundingRect.origin scaleX:scaleX];
        }];
        
        bool continueDock = [ModalAlert confirm:message];
        if(continueDock == NO)
        {
            for(TableButton *tableButton in tableButtons) {
                [tableMapView addSubview:tableButton];
            }
            dragTableButton.center = dragTableOriginalCenter;
            
            masterTable.bounds = saveBounds;
            masterTable.countSeats = saveCountSeats;
            [UIView animateWithDuration:1.0  animations:^{
                [masterTableButton setupByTable: masterTable offset: boundingRect.origin scaleX:scaleX];
            }];
            [masterTableButton setNeedsDisplay];
        }
        else
        {
            [tables addObject: masterTable];
            for(TableButton *tableButton in tableButtons) {
                Table* table = tableButton.table;
                [tables addObject:table];
            }
            
            [masterTableButton setNeedsDisplay];
            [masterTableButton rePosition: masterTable offset: boundingRect.origin scaleX: scaleX];
            [[Service getInstance] dockTables:tables];
        }
        isRefreshTimerDisabled = NO;
    }
    return tables;
}

- (TableButton *) tableButtonAtPoint: (CGPoint) point
{
    for(UIView *view in tableMapView.subviews)
    {
        if(view == dragTableButton) continue;
        CGPoint p = [tableMapView convertPoint:point toView:view];
        if([view pointInside:p withEvent:nil])
        {
            return (TableButton*)view;
        }
    }
    return nil;
}

- (IBAction)gotoDistrict
{
    Map *map = [[Cache getInstance] map];
    if(districtPicker.selectedSegmentIndex >= map.districts.count) return; 
    currentDistrict = [map.districts objectAtIndex:(NSUInteger) districtPicker.selectedSegmentIndex];    
    [self refreshView];
}

- (IBAction) refreshView
{
    if(isRefreshTimerDisabled) return;
    if(isVisible == false)
        return;
    if(currentDistrict == nil) return;
    [self showActivityIndicator];
    [[Service getInstance] getTablesInfoForDistrict:currentDistrict.id delegate: self callback:@selector(refreshViewWithInfo:)];
}

- (void) showActivityIndicator
{
    CGPoint point = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator startAnimating];
    indicator.frame = CGRectMake(point.x, point.y, indicator.frame.size.width, indicator.frame.size.height);
    indicator.tag = 666;
    [self.view addSubview:indicator];
}

- (void)hideActivityIndicator
{
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *) [self.view viewWithTag:666];
    if(indicator != nil)
    {
        [indicator removeFromSuperview];
    }
}

- (void) refreshViewWithInfo: (NSMutableArray *)tablesInfo
{
    for(UIView *view in tableMapView.subviews) [view removeFromSuperview];
    [tableMapView setNeedsDisplay];
    CGRect boundingRect = [currentDistrict getRect]	;
    scaleX = ((float)tableMapView.bounds.size.width - 20) / boundingRect.size.width;
    if(scaleX * boundingRect.size.height > tableMapView.bounds.size.height)
        scaleX = ((float)tableMapView.bounds.size.height - 20) / boundingRect.size.height;
   
    Map *map = [[Cache getInstance] map];
    
    NSMutableDictionary *districtTables = [[NSMutableDictionary alloc] init];
    for(TableInfo *tableInfo in tablesInfo)
    {
        if(tableInfo.table.dockedToTableId != -1)
            continue;
        District *district = [map getDistrict:tableInfo.table.id];
        if(district == nil) {
            NSLog(@"district not found for table id %d", tableInfo.table.id);
            continue;
        }
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
    
    NSUInteger i = 0;
    for(District *district in map.districts)
    {
        NSNumber *count = [districtTables valueForKey:district.name];
        NSString *countString = count == nil ? @"" : [NSString stringWithFormat:@" (%@)", count];
        NSString *title = [NSString stringWithFormat:@"%@%@", district.name, countString];
        [districtPicker setTitle:title forSegmentAtIndex: i];
        i++;
    }
    [self hideActivityIndicator];
}

- (void) setupToolbar {
    districtPicker = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 200, 33)];
    [districtPicker addTarget:self action:@selector(gotoDistrict) forControlEvents:UIControlEventValueChanged];
    districtPicker.segmentedControlStyle = UISegmentedControlStyleBar;
    Map *map = [[Cache getInstance] map];
    for(District *district in map.districts)
    {
        [districtPicker insertSegmentWithTitle:district.name atIndex:districtPicker.numberOfSegments animated:YES];
    }
    districtPicker.selectedSegmentIndex = 0;

    UIBarButtonItem * refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshView)];

    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:
            [[UIBarButtonItem alloc] initWithCustomView: districtPicker],
            refreshButton,
            nil];
    }
    
- (void) clickTable: (UIControl *) sender
{
    TableButton *tableButton = (TableButton *)sender;
    
    TablePopupViewController *tablePopup = [TablePopupViewController menuForTable: tableButton.table];
    popoverController = [[UIPopoverController alloc] initWithContentViewController:tablePopup];

    popoverController.delegate = self;

    tablePopup.popoverController = popoverController;
    
    [popoverController presentPopoverFromRect:tableButton.frame inView: self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void) transferOrder: (int)orderId
{
    TablesViewController *tablesController = [[TablesViewController alloc] init];
    tablesController.selectionMode = selectEmpty;
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:tablesController];
    tablesController.popoverController = popover;
    tablesController.orderId = orderId;
    popover.delegate = self;
    TableButton *tableButton = [self buttonForOrder:orderId];
    [popover presentPopoverFromRect:tableButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (TableButton *) buttonForOrder: (int)orderId
{
    for(TableButton *tableButton in tableMapView.subviews) {
        if(tableButton.orderInfo.id == orderId)
            return tableButton;
    }
    return nil;
}

- (void) transferOrder: (int)orderId toTable: (int)tableId
{
    Service *service = [Service getInstance];
    [service transferOrder: orderId toTable: tableId delegate: self callback: @selector(transferOrderCallback:)];
}

- (void) transferOrderCallback: (ServiceResult *) result
{
    [self refreshView];
}
    
- (void)payOrder: (Order *)order
{
    if(order == nil)
        return;

    PaymentViewController *paymentController = [[PaymentViewController alloc] init];
    paymentController.order = order;
    paymentController.delegate = self;
    [self.navigationController pushViewController:paymentController animated:YES];
}

- (void)gotoOrderViewWithOrder: (Order *)order
{
    if(order == nil)
        return;
    isRefreshTimerDisabled = true;
    NewOrderVC *newOrderVC = [[NewOrderVC alloc] init];
    newOrderVC.order = order;
    [self.navigationController pushViewController: newOrderVC animated:YES];
}

- (void)didProcessPaymentType:(PaymentType)type forOrder :(Order *)order {
    isRefreshTimerDisabled = false;
    [self dismissModalViewControllerAnimated:YES];
    [self performSelector:@selector(refreshView) withObject:nil afterDelay:1];
}

- (void) closeOrderView
{
    isRefreshTimerDisabled = false;
    [self dismissModalViewControllerAnimated:YES];
    [self performSelector:@selector(refreshView) withObject:nil afterDelay:1];
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
    [self refreshView];
}

- (void) editOrder: (Order *) order
{
    [self gotoOrderViewWithOrder: order];
}

- (void) startNextCourse: (Order *)order
{
    Course *nextCourse = [order getNextCourse];
    if(nextCourse != nil)
    {
        [[Service getInstance] startCourse: nextCourse.id delegate:self callback:@selector(startNextCourse:finishedWithData:error:	)];
    }
}

- (void) startNextCourse:(id)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    [MBProgressHUD showSucceededAddedTo:self.view withText: NSLocalizedString(@"Course requested", nil)];
    [self refreshView];
}

- (void) undockTable: (int)tableId
{
    [[Service getInstance] undockTable: tableId];
    [self performSelector:@selector(refreshView) withObject:nil afterDelay:1];
}

- (void) makeBills: (Order*)order
{
    if(order == nil)
        return;
    BillViewController *billVC = [[BillViewController alloc] init];	
    billVC.order = order;
    [self.navigationController pushViewController: billVC animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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




@end
