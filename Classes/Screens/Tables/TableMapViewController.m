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
#import "ToolbarTitleView.h"

@implementation TableMapViewController

@synthesize buttonRefresh, zoomedTableView, zoomOffset, zoomScale, pages, scrollView, pageControl, switchedDistrictWhileDragging;
@dynamic currentDistrictView, currentDistrictOffset, currentDistrict, caption;
@synthesize zoomedTableController = _zoomedTableController;


- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [self setCurrentDistrictOffset:page];
    [self refreshView];
}

- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].applicationFrame;
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    [self.view addSubview:self.pageControl];
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.pageControl.backgroundColor = [UIColor blackColor];
    [self.pageControl addTarget:self action:@selector(pagerAction) forControlEvents:UIControlEventValueChanged];

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.pageControl.frame.size.height)];
    [self.view addSubview:self.scrollView];
    self.scrollView.autoresizingMask = (UIViewAutoresizing)-1;


    NSMutableArray *const districts = [[[Cache getInstance] map] districts];

    self.view.userInteractionEnabled = YES;
    self.pageControl.numberOfPages = [districts count];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.pages = [[NSMutableArray alloc] init];

    CGRect pageRect = self.scrollView.bounds;
    for (District *district in districts) {
        UIView *districtView = [[UIView alloc] initWithFrame:pageRect];
        [pages addObject:districtView];
        [self.scrollView addSubview: districtView];
        districtView.autoresizingMask = (UIViewAutoresizing)-1;
        districtView.backgroundColor = [UIColor clearColor];
        pageRect = CGRectOffset(pageRect, pageRect.size.width, 0);
    }
    self.scrollView.contentSize = CGSizeMake([pages count] * pageRect.size.width, pageRect.size.height);

    [self setupToolbar];

    isVisible = YES;
    [self setupAllDistricts];
    self.currentDistrictOffset = 0;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.scrollView addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    [self.scrollView addGestureRecognizer:panGesture];

    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinchGesture.delegate = self;
    [self.scrollView addGestureRecognizer:pinchGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.scrollView.contentSize = CGSizeMake([pages count] * self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);

    if (zoomedTableView != nil)
        [self unzoom];
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

- (void)pagerAction
{
    [self setCurrentDistrictOffset:pageControl.currentPage];
}

- (void) handleTapGesture: (UITapGestureRecognizer *) tapGestureRecognizer
{
    if (self.zoomedTableView != nil)
        [self unzoom];
}

- (void)didTapCloseButton {
    [self unzoom];
}

- (void) handlePinchGesture: (UIPinchGestureRecognizer *) pinchGestureRecognizer
{
    if(pinchGestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    if(pinchGestureRecognizer.scale < 1)
        return;
    CGPoint point = [pinchGestureRecognizer locationInView: self.currentDistrictView];
    TableWithSeatsView *clickView = [self tableViewAtPoint:point];
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
                if(dragTableView.table.maxCountSeatsHorizontal > 0)
                    point.y = dragPosition.y;
                else
                    point.x = dragPosition.x;
            TableWithSeatsView *newTarget = [self tableViewAtPoint: point];
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

                NSTimeInterval intervalSinceLastSwitch = - [switchedDistrictWhileDragging timeIntervalSinceNow];
                if (switchedDistrictWhileDragging == nil || intervalSinceLastSwitch > 1) {
                    if (nextDistrict != self.currentDistrictOffset) {
                        self.currentDistrictOffset = nextDistrict;
                        [dragTableView removeFromSuperview];
                        [[self.pages objectAtIndex:nextDistrict] addSubview:dragTableView];
                        switchedDistrictWhileDragging = [NSDate date];
                    }
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
            if(dragTableView.table.maxCountSeatsHorizontal > 0)
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

- (void) moveOrderFromTableView: (TableWithSeatsView *) from toTableView: (TableWithSeatsView *) to;
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

- (void) dockTableView: (TableWithSeatsView *)dropTableView toTableView: (TableWithSeatsView *)target
{
    if([dropTableView.table isSeatAlignedWith: target.table] == false)
        return;

    TableWithSeatsView *masterTableView, *outerMostTableView;
    if(target.table.maxCountSeatsHorizontal > 0)
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
    NSArray *saveCountSeats = [NSArray arrayWithArray: masterTable.countSeatsPerSide];
    NSMutableArray *countSeats = [NSMutableArray arrayWithArray:masterTable.countSeatsPerSide];
    for(TableWithSeatsView *tableView in self.currentDistrictView.subviews) {
        Table* table = tableView.table;
        if(masterTable.id != table.id) {
            if([masterTable isSeatAlignedWith:table]) {
                if(CGRectContainsRect(outerBounds, table.bounds)) {
                    [tableViews addObject:tableView];
                    if(table.maxCountSeatsHorizontal > 0)
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
                    for (int side = 0; side < 4; side++) {
                        int count = [[countSeats objectAtIndex:side] intValue] + [[table.countSeatsPerSide objectAtIndex:side] intValue];
                        [countSeats replaceObjectAtIndex:side withObject:[NSNumber numberWithInt:count]];
                    }
                    masterTable.countSeatsPerSide = [NSArray arrayWithArray:countSeats];
                    [tableView removeFromSuperview];
                }
            }
        }
    }

    if([tableViews count] > 0)
    {
        NSString *message;
        if([tableViews count] == 1)
            message = [NSString stringWithFormat:@"Tafel %@", ((TableWithSeatsView *)[tableViews objectAtIndex:0]).table.name];
        else if([tableViews count] == 2)
            message = [NSString stringWithFormat:@"Tafels %@ en %@", ((TableWithSeatsView *)[tableViews objectAtIndex:0]).table.name, ((TableWithSeatsView *)[tableViews objectAtIndex:1]).table.name];
        else {
            message = [NSString stringWithFormat:@"Tafels %@", ((TableWithSeatsView *)[tableViews objectAtIndex:0]).table.name];
            NSUInteger i = 1;
            for(; i < [tableViews count] - 1; i++) {
                TableWithSeatsView *tableButton = [tableViews objectAtIndex:i];
                message = [NSString stringWithFormat:@"%@, %@", message, tableButton.table.name];
            }
            message = [NSString stringWithFormat:@"%@ en %@", message, ((TableWithSeatsView *)[tableViews objectAtIndex:i]).table.name];
        }
        message = [NSString stringWithFormat:@"%@ aanschuiven bij %@ ?", message, masterTable.name];

        isRefreshTimerDisabled = YES;

        masterTableView.hidden = YES;

        TableInfo *tableInfo = [[TableInfo alloc] init];
        tableInfo.table = masterTable;
        TableWithSeatsView *newTableView = [self createTable:tableInfo offset:mapOffset scale:CGPointMake(mapScaleX, mapScaleX)];
        [self.currentDistrictView addSubview:newTableView];

        bool continueDock = [ModalAlert confirm:message];
        if(continueDock == NO)
        {
            [newTableView removeFromSuperview];

            for(TableWithSeatsView *tableView in tableViews) {
                tableView.isTableSelected = NO;
                [self.currentDistrictView addSubview:tableView];
            }
            dragTableView.center = dragTableOriginalCenter;

            masterTable.bounds = saveBounds;
            masterTable.countSeatsPerSide = saveCountSeats;
            masterTableView.hidden = NO;
            [masterTableView setNeedsDisplay];
        }
        else
        {
            NSMutableArray *tables = [[NSMutableArray alloc] init];
            [tables addObject: masterTable];
            for(TableWithSeatsView *tableView in tableViews) {
                Table* table = tableView.table;
                [tables addObject:table];
            }

            [masterTableView removeFromSuperview];
            [[Service getInstance] dockTables:tables];
        }
        isRefreshTimerDisabled = NO;
    }
    return;
}

- (TableWithSeatsView *) tableViewAtPoint: (CGPoint) point
{
    for(UIView *view in self.currentDistrictView.subviews)
    {
        if(view == dragTableView) continue;
        CGPoint p = [self.currentDistrictView convertPoint:point toView:view];
        if([view pointInside:p withEvent:nil])
        {
            return (TableWithSeatsView *)view;
        }
    }
    return nil;
}

- (void) refreshView
{
    if(isRefreshTimerDisabled) return;
    if(isVisible == false)
        return;
    if (self.currentDistrict == nil) return;
    [MBProgressHUD showProgressAddedTo:self.view withText:@""];
    [[Service getInstance] getTablesInfoForDistrict: self.currentDistrict.id delegate: self callback:@selector(refreshViewWithInfo:)];
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    if (serviceResult.isSuccess == false) {
        [ModalAlert error:serviceResult.error];
        return;
    }

    [self refreshDistrict:self.currentDistrictOffset withData:serviceResult];
}

- (void) refreshAllViewWithInfo: (ServiceResult *)serviceResult
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    if (serviceResult.isSuccess == false) {
        [ModalAlert error:serviceResult.error];
        return;
    }

    for (int districtOffset = 0; districtOffset < [self.pages count]; districtOffset++) {
        [self refreshDistrict: districtOffset withData:serviceResult];
    }

    [NSTimer scheduledTimerWithTimeInterval:20.0f
                                     target:self
                                   selector:@selector(refreshView)
                                   userInfo:nil
                                    repeats:YES];

}

- (void) refreshDistrict: (int) districtOffset withData: (ServiceResult *)serviceResult
{
    UIView *districtView = [self viewForDistrictOffset:districtOffset];
    if(districtView == nil)
        return;
    District *district = [self districtAtOffset:districtOffset];
    if (district == nil)
        return;
    [districtView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    CGRect boundingRect = [self boundingRectForDistrict: districtOffset tableInfo:serviceResult.data];
    mapScaleX = ((float)districtView.bounds.size.width - 20) / boundingRect.size.width;
    if(mapScaleX * boundingRect.size.height > districtView.bounds.size.height)
        mapScaleX = ((float)districtView.bounds.size.height - 20) / boundingRect.size.height;
    mapOffset = boundingRect.origin;
    for(TableInfo *tableInfo in serviceResult.data)
    {
        if(tableInfo.table.dockedToTableId != -1)
            continue;
        if (tableInfo.table.district.id == district.id) {
            TableWithSeatsView *tableView = [self createTable:tableInfo offset: mapOffset scale: CGPointMake(mapScaleX, mapScaleX)];
            [districtView addSubview:tableView];
        }
    }
}

- (void) setupAllDistricts
{
    [MBProgressHUD showProgressAddedTo:self.view withText:@""];
    [[Service getInstance] getTablesInfoForDistrict: -1 delegate: self callback:@selector(refreshAllViewWithInfo:)];
}


- (TableWithSeatsView *) createTable: (TableInfo *)tableInfo offset: (CGPoint) offset scale: (CGPoint)scale
{
    Table *table = tableInfo.table;
    CGRect frame = CGRectMake(
                            (table.bounds.origin.x - offset.x) * scale.x,
                            (table.bounds.origin.y - offset.y) * scale.x,
                            table.bounds.size.width * scale.x,
                            table.bounds.size.height * scale.x);
    TableWithSeatsView *tableView = [TableWithSeatsView viewWithFrame:frame tableInfo: tableInfo showSeatNumbers:NO];
    tableView.delegate = self;
    TableOverlaySimple *overlaySimple = [[TableOverlaySimple alloc] initWithFrame: tableView.tableView.bounds tableName:table.name countCourses: tableInfo.orderInfo.countCourses currentCourseOffset:tableInfo.orderInfo.currentCourseOffset selectedCourse:-1 currentCourseState: tableInfo.orderInfo.currentCourseState orderState: tableInfo.orderInfo.state delegate:nil];
    tableView.contentTableView = overlaySimple;

    return tableView;
}

- (void)didTapTableView:(TableWithSeatsView *)tableView {
    [self zoomToTable:tableView];
}

- (void) zoomToTable:(TableWithSeatsView *)tableView {

    if (self.zoomedTableView != nil) {
        return;
    }

    self.caption = [NSString stringWithFormat: @"%@ %@", NSLocalizedString(@"Table", nil), tableView.table.name];

    isRefreshTimerDisabled = YES;

    self.zoomedTableView = tableView;

    CGFloat width, height;
    width = self.scrollView.bounds.size.width;
    height = (tableView.frame.size.height * self.scrollView.bounds.size.width) / tableView.frame.size.width;
    if (height > self.scrollView.bounds.size.height) {
        height = self.scrollView.bounds.size.height;
        width = (tableView.frame.size.width * height) / tableView.frame.size.height;
    }
    width *= 0.8;
    height *= 0.8;

    height = MAX(height, 500);

    zoomScale = CGPointMake( width / tableView.frame.size.width, height / tableView.frame.size.height);
    zoomOffset = CGPointMake(
            tableView.frame.origin.x * zoomScale.x - (self.scrollView.bounds.size.width - width)/2,
            tableView.frame.origin.y * zoomScale.y - (self.scrollView.bounds.size.height - height)/2);
    self.zoomedTableController = [ZoomedTableViewController controllerWithTableView:zoomedTableView delegate:self];
    [UIView animateWithDuration: 0.3 animations:^{
        NSLog(@"start ani");
            for(TableWithSeatsView *tableView in self.currentDistrictView.subviews) {
                tableView.frame = CGRectMake( tableView.frame.origin.x * zoomScale.x - zoomOffset.x, tableView.frame.origin.y * zoomScale.y - zoomOffset.y, tableView.frame.size.width * zoomScale.x, tableView.frame.size.height * zoomScale.y);
            }
        }
        completion: ^(BOOL completed) {
            zoomedTableView.isCloseButtonVisible = YES;
        }
    ];
}

- (void)unzoom
{
    if (zoomedTableView == nil) return;

    zoomedTableView.isCloseButtonVisible = NO;
    zoomedTableView.selectedGuests = nil;
    zoomedTableView.contentTableView.hidden = YES;

    self.caption = [NSString stringWithFormat: @"%@ %@", NSLocalizedString(@"District", nil), [self.currentDistrict name]];

    TableOverlaySimple *overlaySimple = [[TableOverlaySimple alloc] initWithFrame: zoomedTableView.tableView.bounds tableName: zoomedTableView.table.name countCourses: zoomedTableView.orderInfo.countCourses currentCourseOffset: zoomedTableView.orderInfo.currentCourseOffset selectedCourse:-1 currentCourseState: zoomedTableView.orderInfo.currentCourseState orderState:zoomedTableView.orderInfo.state delegate:nil];
    zoomedTableView.contentTableView = overlaySimple;
    zoomedTableView.delegate = self;

    [UIView animateWithDuration:0.4 animations:^{
            for(TableWithSeatsView *tableView in self.currentDistrictView.subviews) {
                tableView.frame = CGRectMake(
                        (tableView.frame.origin.x + zoomOffset.x) / zoomScale.x,
                        (tableView.frame.origin.y + zoomOffset.y) / zoomScale.y,
                        tableView.frame.size.width / zoomScale.x,
                        tableView.frame.size.height / zoomScale.y);
            }
        }
        completion: ^(BOOL completed){
            zoomedTableView = nil;
            isRefreshTimerDisabled = NO;
        }
    ];
    return;
}

- (BOOL)canSelectSeat:(int)seatOffset {
    if (self.zoomedTableView != nil)
        return YES;
    else
        return NO;
}

- (BOOL)canSelectTableView:(TableWithSeatsView *)tableView {
    return NO;
}

- (void) setupToolbar {
    UIBarButtonItem * refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshView)];

    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:
            refreshButton,
            nil];
    self.navigationItem.titleView = [[ToolbarTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-100, 44)];
}

- (void) setCaption: (NSString *)aCaption {
    ((UILabel *)self.navigationItem.titleView).text = aCaption;
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
}

- (void)gotoOrderViewWithOrder: (Order *)order
{
    if(order == nil)
        return;
    NewOrderViewController *controller = [[NewOrderViewController alloc] init];
    controller.order = order;
    [self.navigationController pushViewController: controller animated:YES];
}

- (void)didProcessPaymentType:(PaymentType)type forOrder :(Order *)order {
    [self dismissModalViewControllerAnimated:YES];
    [self performSelector:@selector(refreshView) withObject:nil afterDelay:1];
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
 //   scrollView.contentSize = CGSizeMake(scrollView.contentSize.height, scrollView.contentSize.width);
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    scrollView.contentSize = CGSizeMake(scrollView.contentSize.height, scrollView.contentSize.width);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (isVisible)
        return;
    isVisible = true;
    [self refreshView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    isVisible = false;
}


- (int) offsetOfDistrict: (District *)district {
    return [[[[Cache getInstance] map] districts] indexOfObject: district];
}

- (District *)districtAtOffset: (int)offset {
    NSMutableArray *districts = [[[Cache getInstance] map] districts];
    if (districts == nil || offset >= [districts count])
        return nil;
    return [[[[Cache getInstance] map] districts] objectAtIndex: offset];
}

- (void) setCurrentDistrict: (District *) newDistrict {
    self.currentDistrictOffset = [self offsetOfDistrict:newDistrict];
}

- (District *) currentDistrict
{
    return [self districtAtOffset: [self currentDistrictOffset]];
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
    self.pageControl.currentPage = offset;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    self.caption = [NSString stringWithFormat: @"%@ %@", NSLocalizedString(@"District", nil), [[self districtAtOffset:offset] name]];
    return;
}

- (UIView *)currentDistrictView {
    return [self viewForDistrictOffset: self.currentDistrictOffset];
}

- (UIView *)viewForDistrictOffset: (int)offset {
    if(offset >= [self.pages count])
        return nil;
    return [self.pages objectAtIndex: offset];
}

@end

