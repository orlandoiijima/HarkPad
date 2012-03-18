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
#import "NewOrderViewController.h"
#import "ZoomedTableViewController.h"

@implementation TableMapViewController

@synthesize buttonRefresh, popoverController, zoomedTableView, tableViewDashboard, zoomOffset, zoomScale, pages;
@dynamic currentDistrictView, currentDistrictOffset, currentDistrict;

- (UIScrollView *)scrollView {
    return (UIScrollView *)self.view;
}

- (void)loadView {
    self.view = [[UIScrollView alloc] init];
    self.view.userInteractionEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.directionalLockEnabled = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self refreshView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.currentDistrictView;
}

- (int) offsetOfDistrict: (District *)district {
    return [[[[Cache getInstance] map] districts] indexOfObject: district];
}

- (void) setCurrentDistrict: (District *) newDistrict {
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:NO];
}

- (District *) currentDistrict
{
    int offset = [self currentDistrictOffset];
    return [[[[Cache getInstance] map] districts] objectAtIndex: offset];
}

- (int) currentDistrictOffset {
    return (int)(self.scrollView.contentOffset.x / self.view.bounds.size.width);
}

- (void) setCurrentDistrictOffset: (int)offset {
    if (offset < 0)
        return;
    CGFloat offsetX = self.view.bounds.size.width * offset;
    if (offsetX > self.scrollView.contentSize.width)
        return;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    District *district = [[[[Cache getInstance] map] districts] objectAtIndex:offset];
    self.title = district.name;
    return;
}

- (UIView *)currentDistrictView {
    int offset = self.currentDistrictOffset;
    return [self.pages objectAtIndex: offset];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.frame = [UIScreen mainScreen].applicationFrame;
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

    [self setupToolbar];

    [NSTimer scheduledTimerWithTimeInterval:10.0f
                                     target:self
                                   selector:@selector(refreshView)
                                   userInfo:nil
                                    repeats:YES];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];

    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinchGesture.delegate = self;
    [self.view addGestureRecognizer:pinchGesture];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (touch.view != self.currentDistrictView)
            return YES;
        return NO;
    }
    if ([touch.view isKindOfClass:[UIButton class]])
        return NO;
    if (touch.view == self.currentDistrictView)
        if (zoomedTableView != nil)
            return YES;
    return NO;
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
    CGPoint point = [pinchGestureRecognizer locationInView: self.currentDistrictView];
    TableView *clickView = [self tableViewAtPoint:point];
    if(clickView == nil)
        return;
    if(clickView.table.isDocked == false)
        return;
    [self undockTable: clickView.table.id];
}

- (void) handlePanGesture: (UIPanGestureRecognizer *)panGestureRecognizer
{
    if (zoomedTableView != nil)
        return;

    switch(panGestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            dragPosition = [panGestureRecognizer locationInView: self.currentDistrictView];
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
            CGPoint point = [panGestureRecognizer locationInView: self.currentDistrictView];
            if ([[dragTableView.orderInfo guests] count] == 0)
                if(dragTableView.table.seatOrientation == row)
                    point.y = dragPosition.y;
                else
                    point.x = dragPosition.x;
            TableView *newTarget = [self tableViewAtPoint: point];
            if (newTarget != targetTableView && newTarget != dragTableView) {
                if (targetTableView != nil)
                    targetTableView.isTableSelected = NO;
                targetTableView = newTarget;
                targetTableView.isTableSelected = YES;
            }

            if ([[dragTableView.orderInfo guests] count] > 0) {
                NSUInteger nextDistrict = self.currentDistrictOffset;
                if (point.x + 50 > self.currentDistrictView.bounds.size.width) {
                    if (self.currentDistrictOffset + 1 < [self.pages count]) {
                        nextDistrict++;
                    }
                }
                if (point.x - 50 < 0) {
                    if (self.currentDistrictOffset > 0) {
                        nextDistrict--;
                    }
                }

                if (nextDistrict != self.currentDistrictOffset) {
                    self.currentDistrictOffset = nextDistrict;
                    [dragTableView removeFromSuperview];
                    [[self.pages objectAtIndex:nextDistrict] addSubview:dragTableView];
                }
            }

            dragTableView.center = CGPointMake(dragTableView.center.x + point.x - dragPosition.x, dragTableView.center.y + point.y - dragPosition.y);
            dragPosition = point;
            break;
        }

        case UIGestureRecognizerStateEnded:
        {
            if(dragTableView == nil) return;
            CGPoint point = [panGestureRecognizer locationInView: self.currentDistrictView];
            if(dragTableView.table.seatOrientation == row)
                point.y = dragPosition.y;
            else
                point.x = dragPosition.x;
            dragTableView.isDragging = NO;
            targetTableView = [self tableViewAtPoint: point];
            if(targetTableView == nil)
            {
                [self revertDrag];
            }
            else
            {
                if ([[dragTableView.orderInfo guests] count] > 0) {
                    [self moveOrderFromTableView: dragTableView toTableView: targetTableView];
                }
                else {
                    [self dockTableView:dragTableView toTableView: targetTableView];
                }
             }
            isRefreshTimerDisabled = NO;
            break;
        }

        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
            break;
    }
}

- (void) revertDrag
{
    District *district = [[[Cache getInstance] map] getDistrict: dragTableView.table.id];
    self.currentDistrictOffset = [self offsetOfDistrict:district];
    [UIView animateWithDuration:0.3 animations:^{
        dragTableView.center = dragTableOriginalCenter;
    }];
}

- (void) moveOrderFromTableView: (TableView *) from toTableView: (TableView *) to;
{
    Service *service = [Service getInstance];
    [service transferOrder: from.orderInfo.id toTable: to.table.id delegate: self callback: @selector(transferOrderCallback:)];
}

- (void) transferOrderCallback: (ServiceResult *) serviceResult
{
    if (serviceResult.isSuccess == false) {
        [ModalAlert error:serviceResult.error];
    }
    [self refreshView];
}

- (NSMutableArray *) dockTableView: (TableView *)dropTableView toTableView: (TableView *)target
{
    NSMutableArray *tables = [[NSMutableArray alloc] init];

    if([dropTableView.table isSeatAlignedWith: target.table] == false)
        return tables;

    TableView *masterTableView, *outerMostTableView;
    if(target.table.seatOrientation == row)
    {
        if(target.table.bounds.origin.x > dropTableView.table.bounds.origin.x)
        {
            masterTableView = dropTableView;
            outerMostTableView = target;
        }
        else
        {
            masterTableView = target;
            outerMostTableView = dropTableView;
        }
    }
    else
    {
        if(target.table.bounds.origin.y > dropTableView.table.bounds.origin.y)
        {
            masterTableView = dropTableView;
            outerMostTableView = target;
        }
        else
        {
            masterTableView = target;
            outerMostTableView = dropTableView;
        }
    }

    Table *masterTable = masterTableView.table;

    NSMutableArray *tableViews = [[NSMutableArray alloc] init];
    CGRect outerBounds = CGRectUnion(masterTable.bounds, outerMostTableView.table.bounds);
    CGRect saveBounds = masterTable.bounds;
    int saveCountSeats = masterTable.countSeats;
    for(TableView *tableView in self.currentDistrictView.subviews) {
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
                [self.currentDistrictView addSubview:tableView];
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
    for(UIView *view in self.currentDistrictView.subviews)
    {
        if(view == dragTableView) continue;
        CGPoint p = [self.currentDistrictView convertPoint:point toView:view];
        if([view pointInside:p withEvent:nil])
        {
            return (TableView*)view;
        }
    }
    return nil;
}

- (IBAction) refreshView
{
    if(isRefreshTimerDisabled) return;
    if(isVisible == false)
        return;
    [self showActivityIndicator];
    if (self.currentDistrict == nil) return;
    [[Service getInstance] getTablesInfoForDistrict: self.currentDistrict.id delegate: self callback:@selector(refreshViewWithInfo:)];
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

- (CGRect)boundingRectForDistrict: (int)district tableInfo: (NSMutableArray *)info
{
    if([info count] == 0) {
        return CGRectZero;
    }
    Map *map = [[Cache getInstance] map];
    CGRect rect = CGRectZero;
    for(TableInfo *tableInfo in info)
    {
        if(tableInfo.table.dockedToTableId != -1)
            continue;
        District *infoDistrict = [map getDistrict:tableInfo.table.id];
        if(infoDistrict == nil) {
            NSLog(@"district not found for table id %d", tableInfo.table.id);
            continue;
        }
        if(district == [self offsetOfDistrict: infoDistrict]) {
            rect = rect.size.width == 0 ? tableInfo.table.bounds : CGRectUnion(rect, tableInfo.table.bounds);
        }
    }
    return rect;
}

- (void) refreshViewWithInfo: (ServiceResult *)serviceResult
{
    [self hideActivityIndicator];

    if (serviceResult.isSuccess == false) {
        [ModalAlert error:serviceResult.error];
        return;
    }

    int countGuests = 0;

    [self.currentDistrictView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    CGRect boundingRect = [self boundingRectForDistrict: self.currentDistrictOffset tableInfo:serviceResult.data];
    scaleX = ((float)self.currentDistrictView.bounds.size.width - 20) / boundingRect.size.width;
    if(scaleX * boundingRect.size.height > self.currentDistrictView.bounds.size.height)
        scaleX = ((float)self.currentDistrictView.bounds.size.height - 20) / boundingRect.size.height;

    for(TableInfo *tableInfo in serviceResult.data)
    {
        if(tableInfo.table.dockedToTableId != -1)
            continue;
        TableView *tableView = [self createTable:tableInfo offset: boundingRect.origin scale: CGPointMake(scaleX, scaleX)];
        [self.currentDistrictView addSubview:tableView];
        if(tableInfo.orderInfo != nil) {
            countGuests += [tableInfo.orderInfo.guests count];
        }
    }

 //   self.title = [NSString stringWithFormat:@"District %@ (%d gasten)", self.currentDistrict.name, countGuests];

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
    TableOverlaySimple *overlaySimple = [[TableOverlaySimple alloc] initWithFrame: tableView.tableView.bounds tableName:table.name countCourses: tableInfo.orderInfo.countCourses currentCourseOffset:tableInfo.orderInfo.currentCourseOffset selectedCourse:-1 currentCourseState: tableInfo.orderInfo.currentCourseState orderState: tableInfo.orderInfo.state delegate:nil];
    tableView.contentTableView = overlaySimple;

    return tableView;
}

- (void)didTapTableView:(TableView *)tableView {

    if (self.zoomedTableView != nil) {
        return;
    }

    isRefreshTimerDisabled = YES;

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

    height = MAX(height, 500);

    tableView.contentTableView.hidden = YES;

    zoomScale = CGPointMake( width / tableView.frame.size.width, height / tableView.frame.size.height);
    zoomOffset = CGPointMake(
            tableView.frame.origin.x * zoomScale.x - (self.view.bounds.size.width - width)/2,
            tableView.frame.origin.y * zoomScale.y - (self.view.bounds.size.height - height)/2);
    [UIView animateWithDuration:0.4 animations:^{
        for(TableView *tableView in self.currentDistrictView.subviews) {
            tableView.frame = CGRectMake( tableView.frame.origin.x * zoomScale.x - zoomOffset.x, tableView.frame.origin.y * zoomScale.y - zoomOffset.y, tableView.frame.size.width * zoomScale.x, tableView.frame.size.height * zoomScale.y);
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

    zoomedTableView.contentTableView.hidden = YES;

    [UIView animateWithDuration:0.4
                     animations:^{
            for(TableView *tableView in self.currentDistrictView.subviews) {
                tableView.frame = CGRectMake(
                        (tableView.frame.origin.x + zoomOffset.x) / zoomScale.x,
                        (tableView.frame.origin.y + zoomOffset.y) / zoomScale.y,
                        tableView.frame.size.width / zoomScale.x,
                        tableView.frame.size.height / zoomScale.y);
            }
        }
        completion: ^(BOOL completed){
            TableOverlaySimple *overlaySimple = [[TableOverlaySimple alloc] initWithFrame: zoomedTableView.tableView.bounds tableName: zoomedTableView.table.name countCourses: zoomedTableView.orderInfo.countCourses currentCourseOffset: zoomedTableView.orderInfo.currentCourseOffset selectedCourse:-1 currentCourseState: zoomedTableView.orderInfo.currentCourseState orderState:zoomedTableView.orderInfo.state delegate:nil];
            zoomedTableView.contentTableView = overlaySimple;
            zoomedTableView.delegate = self;

            zoomedTableView = nil;
            isRefreshTimerDisabled = NO;
        }
    ];

//    [self.scrollView zoomToRect: self.scrollView.bounds animated:YES];
    return;
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
    UIBarButtonItem * refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshView)];

    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:
            refreshButton,
            nil];
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
//    self.zoomedTableView = nil;
}

- (void)gotoOrderViewWithOrder: (Order *)order
{
    if(order == nil)
        return;
    NewOrderViewController *controller = [[NewOrderViewController alloc] init];
    controller.order = order;
    [self.navigationController pushViewController: controller animated:YES];
//    self.zoomedTableView = nil;
}

- (void)didProcessPaymentType:(PaymentType)type forOrder :(Order *)order {
//    isRefreshTimerDisabled = false;
    [self dismissModalViewControllerAnimated:YES];
    [self performSelector:@selector(refreshView) withObject:nil afterDelay:1];
//    self.zoomedTableView = nil;
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
}

@end

