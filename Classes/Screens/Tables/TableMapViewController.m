	//
//  TableMapViewController.m
//  HarkPad
//
//  Created by Willem Bison on 03-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "TableMapViewController.h"
#import "Service.h"
#import "BillViewController.h"
#import "ModalAlert.h"
#import "TablesViewController.h"
#import "NewOrderViewController.h"
#import "ZoomedTableViewController.h"

@implementation TableMapViewController

@synthesize districtPicker, buttonRefresh, popoverController, zoomedTableView, tableViewDashboard, zoomOffset, zoomScale, pages;
@dynamic currentDistrictView, currentDistrictOffset;

- (UIScrollView *)scrollView {
    return (UIScrollView *)self.view;
}

- (void)loadView {
    self.view = [[UIScrollView alloc] init];
    self.view.userInteractionEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;

    UIView *x = [[UIView alloc] init];
    x.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:x];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.currentDistrictView;
}

- (int) offsetOfDistrict: (District *)district {
    return [[[[Cache getInstance] map] districts] indexOfObject: district];
}

- (void) setCurrentDistrict: (District *) newDistrict {
    int districtOffset = [self offsetOfDistrict: newDistrict];
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
}

- (int) currentDistrictOffset {
    return self.scrollView.contentOffset.x / self.view.bounds.size.width;
}

- (UIView *)currentDistrictView {
    int offset = self.currentDistrictOffset;
    return [self.pages objectAtIndex: offset];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pages = [[NSMutableArray alloc] init];

    CGRect pageRect = self.view.bounds;
    for (District *district in [[[Cache getInstance] map] districts]) {
        UIView *districtView = [[UIView alloc] initWithFrame:pageRect];
        [pages addObject:districtView];
        [self.view addSubview: districtView];
        districtView.backgroundColor = [UIColor blackColor];
        districtView.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        pageRect = CGRectOffset(pageRect, pageRect.size.width, 0);
    }
    self.scrollView.contentSize = CGSizeMake([pages count] * pageRect.size.width, pageRect.size.height);

    self.scrollView.maximumZoomScale = 100;

    [self setupToolbar];

//    [NSTimer scheduledTimerWithTimeInterval:10.0f
//                                     target:self
//                                   selector:@selector(refreshView)
//                                   userInfo:nil
//                                    repeats:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.currentDistrictView addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGesture];

    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [currentDistrictView addGestureRecognizer:pinchGesture];
    
    [self gotoDistrict];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]])
        return NO;
    if (touch.view != self.currentDistrictView)
        return NO;
    return YES;
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

- (void) handleTapGesture: (UITapGestureRecognizer *) tapGestureRecognizer
{
    if (self.zoomedTableView != nil)
        [self unzoom];
}

- (void) handlePinchGesture: (UIPinchGestureRecognizer *) pinchGestureRecognizer
{
    if(pinchGestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    if(pinchGestureRecognizer.scale < 1)
        return;
    CGPoint point = [pinchGestureRecognizer locationInView:currentDistrictView];
    TableView *clickView = [self tableViewAtPoint:point];
    if(clickView == nil)
        return;
    if(clickView.table.isDocked == false)
        return;
    [self undockTable: clickView.table.id];
}

- (void) handlePanGesture: (UIPanGestureRecognizer *)panGestureRecognizer
{
    switch(panGestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            dragPosition = [panGestureRecognizer locationInView:currentDistrictView];
            dragTableView = [self tableViewAtPoint:dragPosition];
            if (dragTableView != nil) {
                    dragTableView.isDragging = YES;
            }
            dragTableOriginalCenter= dragTableView.center;
            isRefreshTimerDisabled = YES;
            break;
        }
        
        case UIGestureRecognizerStateChanged:
        {
            if(dragTableView == nil) return;
            [popoverController dismissPopoverAnimated:YES];
            CGPoint point = [panGestureRecognizer locationInView:currentDistrictView];
            if ([[dragTableView.orderInfo guests] count] == 0)
                if(dragTableView.table.seatOrientation == row)
                    point.y = dragPosition.y;
                else
                    point.x = dragPosition.x;
            dragTableView.center = CGPointMake(dragTableView.center.x + point.x - dragPosition.x, dragTableView.center.y + point.y - dragPosition.y);
            dragPosition = point;
            break;
        }
        
        case UIGestureRecognizerStateEnded:
        {
            isRefreshTimerDisabled = NO;
            if(dragTableView == nil) return;
            CGPoint point = [panGestureRecognizer locationInView:currentDistrictView];
            if(dragTableView.table.seatOrientation == row)
                point.y = dragPosition.y;
            else
                point.x = dragPosition.x;
            dragTableView.isDragging = NO;
            TableView *targetTableView = [self tableViewAtPoint: point];
            if(targetTableView == nil)
            {
                dragTableView.center = dragTableOriginalCenter;
            }
            else
            {
                [self dockTableView:dragTableView toTableView: targetTableView];
             }
            break;
        }
            
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
            break;
    }
}

//- (bool) TransgenderPopup: (TableButton *) button seat: (int)seat
//{
//    SeatInfo *info = [button.orderInfo getSeatInfo:seat];
//    if(info == nil) return false;
//
//    NSString *message = [NSString stringWithFormat:@"Tafel %@, stoel %d", button.table.name, seat + 1];
//    NSUInteger i = [ModalAlert queryWithTitle: [NSString stringWithFormat:@"Gast is %@", (info.isMale ? @"vrouw" : @"man")] message:message button1: @"Ok" button2: @"Terug"];
//    if(i != 0) return false;
//    info.isMale = !info.isMale;
//    NSString *gender = info.isMale ? @"M" : @"F";
//    [[Service getInstance] setGender: gender forGuest: info.guestId];
//    [button setNeedsDisplay];
//    return true;
//}

- (NSMutableArray *) dockTableView: (TableView *)dropTableView toTableView: (TableView *)targetTableView
{
    NSMutableArray *tables = [[NSMutableArray alloc] init];

    if([dropTableView.table isSeatAlignedWith: targetTableView.table] == false)
        return tables;

    TableView *masterTableView, *outerMostTableView;
    if(targetTableView.table.seatOrientation == row)
    {
        if(targetTableView.table.bounds.origin.x > dropTableView.table.bounds.origin.x)
        {
            masterTableView = dropTableView;
            outerMostTableView = targetTableView;
        }
        else
        {
            masterTableView = targetTableView;
            outerMostTableView = dropTableView;
        }
    }
    else
    {
        if(targetTableView.table.bounds.origin.y > dropTableView.table.bounds.origin.y)
        {
            masterTableView = dropTableView;
            outerMostTableView = targetTableView;
        }
        else
        {
            masterTableView = targetTableView;
            outerMostTableView = dropTableView;
        }
    }

    Table *masterTable = masterTableView.table;
    
    NSMutableArray *tableViews = [[NSMutableArray alloc] init];
    CGRect outerBounds = CGRectUnion(masterTable.bounds, outerMostTableView.table.bounds);
    CGRect saveBounds = masterTable.bounds;
    int saveCountSeats = masterTable.countSeats;
    for(TableView *tableView in currentDistrictView.subviews) {
        Table* table = tableView.table;
        if(masterTable.id != table.id) {
            if([masterTable isSeatAlignedWith:table]) {
                if(CGRectContainsRect(outerBounds, table.bounds)) {
                    [tableViews addObject:tableView];
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
                    [tableView removeFromSuperview];
                }
            }
        }
    }   
    
    if([tableViews count] > 0)
    {
        CGRect boundingRect = [currentDistrict getRect]	;
        
        NSString *message;
        if([tableViews count] == 1)
            message = [NSString stringWithFormat:@"Tafel %@", ((TableView*)[tableViews objectAtIndex:0]).table.name];
        else if([tableViews count] == 2)
            message = [NSString stringWithFormat:@"Tafels %@ en %@", ((TableView*)[tableViews objectAtIndex:0]).table.name, ((TableView*)[tableViews objectAtIndex:1]).table.name];
        else {
            message = [NSString stringWithFormat:@"Tafels %@", ((TableView*)[tableViews objectAtIndex:0]).table.name];
            NSUInteger i = 1;
            for(; i < [tableViews count] - 1; i++) {
                TableView *tableButton = [tableViews objectAtIndex:i];
                message = [NSString stringWithFormat:@"%@, %@,", message, tableButton.table.name];
            }
            message = [NSString stringWithFormat:@"%@ en %@", message, ((TableView *)[tableViews objectAtIndex:i]).table.name];
        }
        message = [NSString stringWithFormat:@"%@ aanschuiven bij %@ ?", message, masterTable.name];
        
        isRefreshTimerDisabled = YES;
        
        [masterTableView setNeedsDisplay];
//        [UIView animateWithDuration:1.0  animations:^{
//            [masterTableView setupByTable: masterTable offset: boundingRect.origin scaleX:scaleX];
//        }];
        
        bool continueDock = [ModalAlert confirm:message];
        if(continueDock == NO)
        {
            for(TableView *tableView in tableViews) {
                [currentDistrictView addSubview:tableView];
            }
            dragTableView.center = dragTableOriginalCenter;
            
            masterTable.bounds = saveBounds;
            masterTable.countSeats = saveCountSeats;
//            [UIView animateWithDuration:1.0  animations:^{
//                [masterTableView setupByTable: masterTable offset: boundingRect.origin scaleX:scaleX];
//            }];
            [masterTableView setNeedsDisplay];
        }
        else
        {
            [tables addObject: masterTable];
            for(TableView *tableView in tableViews) {
                Table* table = tableView.table;
                [tables addObject:table];
            }
            
            [masterTableView setNeedsDisplay];
//            [masterTableView rePosition: masterTable offset: boundingRect.origin scaleX: scaleX];
            [[Service getInstance] dockTables:tables];
        }
        isRefreshTimerDisabled = NO;
    }
    return tables;
}

- (TableView *) tableViewAtPoint: (CGPoint) point
{
    for(UIView *view in currentDistrictView.subviews)
    {
        if(view == dragTableView) continue;
        CGPoint p = [currentDistrictView convertPoint:point toView:view];
        if([view pointInside:p withEvent:nil])
        {
            return (TableView*)view;
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

- (void) refreshViewWithInfo: (ServiceResult *)serviceResult
{
    [self hideActivityIndicator];

    if (serviceResult.isSuccess == false) {
        [ModalAlert error:serviceResult.error];
        return;
    }

    for(UIView *view in self.currentDistrictView.subviews) [view removeFromSuperview];
    [self.currentDistrictView setNeedsDisplay];
    CGRect boundingRect = [currentDistrict getRect]	;
    scaleX = ((float)self.currentDistrictView.bounds.size.width - 20) / boundingRect.size.width;
    if(scaleX * boundingRect.size.height > self.currentDistrictView.bounds.size.height)
        scaleX = ((float)self.currentDistrictView.bounds.size.height - 20) / boundingRect.size.height;
   
    Map *map = [[Cache getInstance] map];
    
    NSMutableDictionary *districtTables = [[NSMutableDictionary alloc] init];
    for(TableInfo *tableInfo in serviceResult.data)
    {
        if(tableInfo.table.dockedToTableId != -1)
            continue;
        District *district = [map getDistrict:tableInfo.table.id];
        if(district == nil) {
            NSLog(@"district not found for table id %d", tableInfo.table.id);
            continue;
        }
        if(district.id == currentDistrict.id) {
            TableView *tableView = [self createTable:tableInfo offset: boundingRect.origin scale: CGPointMake(scaleX, scaleX)];
            [self.currentDistrictView addSubview:tableView];
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
}

- (TableView *) createTable: (TableInfo *)tableInfo offset: (CGPoint) offset scale: (CGPoint)scale
{
    Table *table = tableInfo.table;
    CGRect frame = CGRectMake(
                            (table.bounds.origin.x - offset.x) * scale.x,
                            (table.bounds.origin.y - offset.y) * scale.x,
                            table.bounds.size.width * scale.x,
                            table.bounds.size.height * scale.x);
    TableView *tableView = [TableView viewWithFrame:frame tableInfo: tableInfo showSeatNumbers:NO];
    tableView.delegate = self;
    TableOverlaySimple *overlaySimple = [[TableOverlaySimple alloc] initWithFrame: tableView.tableView.bounds tableName:table.name countCourses: tableInfo.orderInfo.countCourses currentCourseOffset:tableInfo.orderInfo.currentCourseOffset selectedCourse:-1 currentCourseState: tableInfo.orderInfo.currentCourseState delegate:nil];
    tableView.contentTableView = overlaySimple;

    return tableView;
}

- (void)didTapTableView:(TableView *)tableView {

    if (self.zoomedTableView != nil) {
        return;
    }

    self.zoomedTableView = tableView;

    CGFloat width, height;
    width = self.view.bounds.size.width;
    height = (tableView.frame.size.height * self.view.bounds.size.width) / tableView.frame.size.width;
    if (height > self.view.bounds.size.height) {
        height = self.view.bounds.size.height;
        width = (tableView.frame.size.width * height) / tableView.frame.size.height;
    }
    width *= 0.8;
    height *= 0.8;

    zoomScale = width / tableView.frame.size.width;
    zoomOffset = CGPointMake(
            tableView.frame.origin.x * zoomScale - (self.view.bounds.size.width - width)/2,
            tableView.frame.origin.y * zoomScale - (self.view.bounds.size.height - height)/2);
    [UIView animateWithDuration:0.4 animations:^{
        for(TableView *tableView in currentDistrictView.subviews) {
            tableView.frame = CGRectMake( tableView.frame.origin.x * zoomScale - zoomOffset.x, tableView.frame.origin.y * zoomScale - zoomOffset.y, tableView.frame.size.width * zoomScale, tableView.frame.size.height * zoomScale);
        }
    }
    completion: ^(BOOL completed) {
        ZoomedTableViewController *controller = [[ZoomedTableViewController alloc] init];
        controller.tableView = zoomedTableView;
        controller.delegate = self;
        tableView.contentTableView = controller.view;
    }
    ];

//    [self.scrollView zoomToRect: CGRectInset(tableView.frame, -50, -50) animated:YES];

}

- (void)unzoom
{
    if (zoomedTableView == nil) return;

    zoomedTableView.selectedGuests = nil;

    TableOverlaySimple *overlaySimple = [[TableOverlaySimple alloc] initWithFrame: zoomedTableView.tableView.bounds tableName: zoomedTableView.table.name countCourses: zoomedTableView.orderInfo.countCourses currentCourseOffset: zoomedTableView.orderInfo.currentCourseOffset selectedCourse:-1 currentCourseState: zoomedTableView.orderInfo.currentCourseState delegate:nil];
    zoomedTableView.contentTableView = overlaySimple;

    zoomedTableView = nil;
    isRefreshTimerDisabled = NO;

    [UIView animateWithDuration:0.4 animations:^{
        for(TableView *tableView in currentDistrictView.subviews) {
            tableView.frame = CGRectMake(
                    (tableView.frame.origin.x + zoomOffset.x) / zoomScale,
                    (tableView.frame.origin.y + zoomOffset.y) / zoomScale,
                    tableView.frame.size.width / zoomScale,
                    tableView.frame.size.height / zoomScale);
        }
    }];

//    [self.scrollView zoomToRect: self.scrollView.bounds animated:YES];
    return;
}

- (void) zoomToTableView:(TableView *)tableView {

    if (self.zoomedTableView != nil) {
        return;
    }

    self.zoomedTableView = tableView;

    CGFloat width, height;
    width = self.view.bounds.size.width;
    height = (tableView.frame.size.height * self.view.bounds.size.width) / tableView.frame.size.width;
    if (height > self.view.bounds.size.height) {
        height = self.view.bounds.size.height;
        width = (tableView.frame.size.width * height) / tableView.frame.size.height;
    }
    width *= 0.8;
    height *= 0.8;

    zoomScale = width / tableView.frame.size.width;
    zoomOffset = CGPointMake(
            tableView.frame.origin.x * zoomScale - (self.view.bounds.size.width - width)/2,
            tableView.frame.origin.y * zoomScale - (self.view.bounds.size.height - height)/2);
    [UIView animateWithDuration:0.4
         animations:^{
            for(TableView *tableView in currentDistrictView.subviews) {
                tableView.frame = CGRectMake( tableView.frame.origin.x * zoomScale - zoomOffset.x, tableView.frame.origin.y * zoomScale - zoomOffset.y, tableView.frame.size.width * zoomScale, tableView.frame.size.height * zoomScale);
            }
         }

         completion: ^(BOOL completed) {
            ZoomedTableViewController *controller = [[ZoomedTableViewController alloc] init];
            controller.tableView = zoomedTableView;
            controller.delegate = self;
            tableView.contentTableView = controller.view;
         }
    ];
}

- (BOOL)canSelectSeat:(int)seatOffset {
    if (self.zoomedTableView != nil)
        return YES;
    else
        return NO;
}

- (BOOL)canSelectTableView:(TableView *)tableView {
    return NO;
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
    for(TableButton *tableButton in currentDistrictView.subviews) {
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
    
- (void)getPaymentForOrder: (Order *)order
{
    [popoverController dismissPopoverAnimated:YES];
    if(order == nil)
        return;

    PaymentViewController *paymentController = [[PaymentViewController alloc] init];
    paymentController.order = order;
    paymentController.delegate = self;
    [self.navigationController pushViewController:paymentController animated:YES];
    self.zoomedTableView = nil;
}

- (void)gotoOrderViewWithOrder: (Order *)order
{
    if(order == nil)
        return;
    NewOrderViewController *controller = [[NewOrderViewController alloc] init];
    controller.order = order;
    [self.navigationController pushViewController: controller animated:YES];
    self.zoomedTableView = nil;
}

- (void)didProcessPaymentType:(PaymentType)type forOrder :(Order *)order {
//    isRefreshTimerDisabled = false;
    [self dismissModalViewControllerAnimated:YES];
    [self performSelector:@selector(refreshView) withObject:nil afterDelay:1];
    self.zoomedTableView = nil;
}


- (void) startTable: (Table *)table fromReservation: (Reservation *)reservation
{
    Service *service = [Service getInstance];
    [service startTable:table.id fromReservation: reservation.id];
    [self refreshView];
}

- (void) editOrder: (Order *) order
{
    [popoverController dismissPopoverAnimated:YES];
    [self gotoOrderViewWithOrder: order];
}

- (void) startNextCourseForOrder: (Order *)order
{
    Course *nextCourse = [order nextCourseToRequest];
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

- (void) makeBillForOrder: (Order*)order
{
    [popoverController dismissPopoverAnimated:YES];
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

//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
//    if (scale == 1) {
//        [self clearZoomedView];
//        return;
//    }
//
//    if (zoomedTableView == nil) return;
//    [self.view setNeedsDisplay];
//    [self setupZoomedView];
//}
//
//- (void) setupZoomedView
//{
//    isRefreshTimerDisabled = YES;
//    zoomedTableView.contentTableView.hidden = YES;
//    CGRect rect = CGRectInset(zoomedTableView.frame, zoomedTableView.tableView.frame.origin.x, zoomedTableView.tableView.frame.origin.y);
//    CGAffineTransform t = CGAffineTransformMakeScale(self.scrollView.zoomScale, self.scrollView.zoomScale);
//    rect = CGRectApplyAffineTransform(rect, t);
//
//    tableViewDashboard = [[TableViewDashboard alloc] initWithFrame:CGRectInset(rect, 10, 10) tableView: zoomedTableView delegate: self];
//    [self.view addSubview: tableViewDashboard];
//}


@end

