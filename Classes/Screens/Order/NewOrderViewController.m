//
//  NewOrderViewController.m
//  HarkPad
//
//  Created by Willem Bison on 02/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "NewOrderViewController.h"
#import "MenuItem.h"
#import "Service.h"
#import "CrystalButton.h"

@implementation NewOrderViewController

@synthesize productPanelView = _productPanelView, orderView = _orderView, tableView = _tableView, order = _order, dataSource, tableOverlayHud = _tableOverlayHud;
@dynamic selectedCourse, selectedCourseOffset, selectedGuest, selectedSeat;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#define MARGIN 25

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([_order.courses count] == 0 || [_order.lastCourse.lines count] > 0) {
        [_order addCourse];
    }

    self.dataSource = [OrderDataSource dataSourceForOrder:_order grouping:byCourse totalizeProducts:NO showFreeProducts:YES showProductProperties:YES isEditable:YES showPrice:NO showEmptySections:YES fontSize: 0];
    self.dataSource.showSeat = YES;
    self.dataSource.collapsableHeaders = YES;
    self.dataSource.delegate = self;

    CGFloat orderViewWidth = 300;
    CGFloat buttonSize = 100;

    TableInfo *tableInfo = [[TableInfo alloc] init];
    tableInfo.table = _order.table;
    tableInfo.orderInfo = [OrderInfo infoWithOrder:_order];

    _tableView = [TableView viewWithFrame:CGRectMake(
            MARGIN,
            MARGIN,
            self.view.bounds.size.width - 3* MARGIN - orderViewWidth,
            (self.view.bounds.size.height - 3* MARGIN) / 4) tableInfo: tableInfo showSeatNumbers: NO];
    [self.view addSubview:_tableView];
//    _tableOverlaySimple = [[TableOverlaySimple alloc] initWithFrame:_tableView.tableView.bounds tableName: tableInfo.table.name countCourses: [_order.courses count] currentCourseOffset: _order.currentCourse == nil ? -1:_order.currentCourse.offset selectedCourse:-1 currentCourseState: _order.currentCourse == nil ? CourseStateNothing : _order.currentCourse.state delegate:self];
    _tableOverlayHud = [[TableOverlayHud alloc] initWithFrame:_tableView.tableView.bounds];
    _tableView.contentTableView = _tableOverlayHud;
    _tableView.delegate = self;
    _tableView.autoresizingMask = 0;

    _productPanelView = [[MenuTreeView alloc] initWithFrame:CGRectMake(
            MARGIN,
            MARGIN + _tableView.frame.origin.y + _tableView.frame.size.height,
            self.view.bounds.size.width - 3* MARGIN - orderViewWidth,
            self.view.bounds.size.height - MARGIN - (MARGIN + _tableView.frame.origin.y + _tableView.frame.size.height))];
    _productPanelView.countColumns = 4;
    _productPanelView.leftHeaderWidth = 0;
    _productPanelView.topHeaderHeight = 0;
    [self.view addSubview:_productPanelView];
    _productPanelView.menuDelegate = self;

    _orderView = [[UITableView alloc] initWithFrame:CGRectMake(
            _tableView.frame.origin.x + _tableView.frame.size.width + MARGIN,
            MARGIN,
            orderViewWidth,
            self.view.bounds.size.height - 3* MARGIN - buttonSize - 80) style:UITableViewStyleGrouped];
    [self.view addSubview:_orderView];
    _orderView.backgroundView = nil;
    _orderView.dataSource = self.dataSource;
    _orderView.delegate = self.dataSource;

    CrystalButton *saveButton = [[CrystalButton alloc] initWithFrame: CGRectMake(_orderView.frame.origin.x + (_orderView.frame.size.width - buttonSize)/2, _orderView.frame.origin.y + _orderView.frame.size.height + MARGIN, buttonSize, buttonSize)];
    [saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchDown];

    [self.view addSubview:saveButton];

    [self setupToolbar];

    self.selectedCourseOffset = 0;
    self.selectedSeat = 0;
}

- (void) setupToolbar {
    UIBarButtonItem * editButton = [[UIBarButtonItem alloc] initWithTitle: @"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(toggleEditMode:)];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
            editButton,
            nil];
}

- (void)toggleEditMode: (id)sender {
    UIBarButtonItem *buttonItem = (UIBarButtonItem *)sender;
    if (_orderView.editing) {
        buttonItem.title = NSLocalizedString(@"Edit", nil);
        buttonItem.style = UIBarButtonItemStylePlain;
    }
    else {
        buttonItem.title = NSLocalizedString(@"Done", nil);
        buttonItem.style = UIBarButtonItemStyleDone;
    }
    [_orderView setEditing:_orderView.editing == NO animated:YES];
}

- (void) save {
    [[Service getInstance] updateOrder:_order delegate:self callback:@selector(updateOrderCallback:)];

    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)canSelectTableView:(TableView *)tableView {
    return YES;
}

- (void) updateOrderCallback: (ServiceResult *)serviceResult
{
    if(serviceResult.isSuccess == false) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:serviceResult.error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [view show];
        return;
    }
}

- (void)menuTreeView:(MenuTreeView *)menuTreeView didTapProduct:(Product *)product {
    for(Guest *guest in [_tableView selectedGuests]) {
        OrderLine *line = [_order addLineWithProductId:product.id seat:guest.seat course: self.selectedCourseOffset];
        [self.dataSource tableView:self.orderView addLine:line];
    }
    if (_tableView.isTableSelected) {
        OrderLine *line = [_order addLineWithProductId:product.id seat: -1 course: self.selectedCourseOffset];
        [self.dataSource tableView:self.orderView addLine:line];
    }

    Course *nextCourse = nil;
    if (self.selectedCourse != nil) {
        nextCourse = self.selectedCourse.nextCourse;
        if (nextCourse == nil) {
            nextCourse = [_order addCourse];
            [self.dataSource tableView:self.orderView addSection: nextCourse.offset + 1];
        }
    }

    if (self.selectedGuest != nil) {
        if (self.selectedGuest.isLast) {
            if(nextCourse != nil) {
                //
                self.selectedCourse = nextCourse;
                self.selectedGuest = _order.firstGuest;
            }
        }
        else {
            Guest *nextGuest =  self.selectedGuest.nextGuest;
            if (nextGuest != nil)
                self.selectedGuest = nextGuest;
        }
    }
}

- (void)menuTreeView:(MenuTreeView *)menuTreeView didTapMenu:(Menu *)menu {
    for(Guest *guest in [_tableView selectedGuests]) {
        for(MenuItem *menuItem in menu.items) {
            OrderLine *line = [_order addLineWithProductId: menuItem.product.id seat:guest.seat course: menuItem.course];
            [self.dataSource tableView:self.orderView addLine:line];
        }
    }
    [self selectNextGuest];
}

- (BOOL)canSelectCourse:(NSUInteger)courseOffset {
    return YES;
}

- (void)didSelectCourse:(NSUInteger)courseOffset {
    Course *course = [_order getCourseByOffset:courseOffset];
    if (course == nil) return;
    [self selectOrderLineForGuest: self.selectedGuest course:course];
}

- (void)didSelectSeat:(int)seatOffset {
    Guest *guest = [_order getGuestBySeat:seatOffset];
    if (guest == nil) return;
    [self selectOrderLineForGuest: guest course: self.selectedCourse];
    [self.tableOverlayHud showForGuest:[self selectedGuest]];
}

- (void)didSelectTableView:(TableView *)tableView {
    [self.tableOverlayHud showForOrder: self.order];
}

- (void)didSelectSection:(NSUInteger)section {
    self.selectedCourseOffset = [self courseOffsetFromSection:section];
}

- (int) selectedCourseOffset
{
    for (int section = 0; section < [_orderView numberOfSections]; section++) {
        OrderDataSourceSection *sectionInfo = [dataSource groupForSection:section];
        if (sectionInfo.isSelected) {
            return [self courseOffsetFromSection:section];
        }
    }
    return -1;
}

- (int) courseOffsetFromSection: (int) section {
    return section - 1;
}

- (void) setSelectedCourseOffset: (int)courseOffset
{
    Course *course = [_order getCourseByOffset:courseOffset];
    NSNumber *key = [dataSource keyForCourse: course];
    int sectionToSelect = [dataSource sectionForKey:key];
    for (int section = 0; section < [_orderView numberOfSections]; section++) {
        OrderDataSourceSection *sectionInfo = [dataSource groupForSection:section];
        sectionInfo.isSelected = section == sectionToSelect;
        CollapseTableViewHeader *headerView = [self headerViewForSection:section];
        if (headerView != nil)
            headerView.isSelected = sectionInfo.isSelected;
    }
}

- (Course *) selectedCourse
{
    if (self.selectedCourseOffset >= [_order.courses count] || self.selectedCourseOffset < 0) return nil;
    return [_order.courses objectAtIndex: self.selectedCourseOffset];
}

- (void)setSelectedCourse:(Course *)aSelectedCourse {
    self.selectedCourseOffset = aSelectedCourse == nil ? -1 : aSelectedCourse.offset;
}

- (Guest *) selectedGuest
{
    NSMutableArray *selectedGuests = [_tableView selectedGuests];
    if (selectedGuests == nil) return nil;
    if ([selectedGuests count] == 0) return nil;
    return [selectedGuests objectAtIndex:0];
}

- (void)setSelectedGuest:(Guest *)aSelectedGuest {
    self.selectedSeat = aSelectedGuest == nil ? -1 : aSelectedGuest.seat;
}

- (void)setSelectedSeat: (int)seat
{
    [_tableView selectSeat:seat];
    [self.tableOverlayHud showForGuest:[self selectedGuest]];
}

- (int) selectedSeat
{
    Guest *guest = self.selectedGuest;
    return guest == nil ? -1 : guest.seat;
}

- (void) selectNextGuest {
    if(self.selectedGuest == nil) return;
    if (self.selectedGuest.nextGuest == nil) return;
    self.selectedSeat = self.selectedGuest.nextGuest.seat;
}

- (void) selectNextCourse {
    if(self.selectedCourse == nil) return;
    if (self.selectedCourse.nextCourse == nil) return;
    self.selectedCourse = self.selectedCourse.nextCourse;
}

- (void)didSelectOrderLine:(OrderLine *)line {
    if (line == nil) return;

    if (line.course != nil)
        self.selectedCourseOffset = line.course.offset;
    else
        self.selectedCourseOffset = -1;

    if (line.guest != nil) {
        [_tableView selectSeat:line.guest.seat];
        _tableView.isTableSelected = NO;
    }
    else {
        [_tableView selectSeat:-1];
        _tableView.isTableSelected = YES;
    }
}

- (void) selectOrderLineForGuest: (Guest *)guest course: (Course *)course
{
    NSNumber *key = [dataSource keyForCourse:course];
    int section = [dataSource sectionForKey:key];
    [dataSource tableView:_orderView expandSection:section collapseAllOthers:NO];
    for (int row = 0; row < [_orderView numberOfRowsInSection:section]; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
         OrderLine *line = [dataSource orderLineAtIndexPath:indexPath];
        if (line.guest.seat == guest.seat) {
            [_orderView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            break;
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (CollapseTableViewHeader *) headerViewForSection:(NSInteger)section {
    for(UIView *view in _orderView.subviews) {
        if ([view isKindOfClass:[CollapseTableViewHeader class]]) {
            CollapseTableViewHeader *viewHeader = (CollapseTableViewHeader *) view;
            if (viewHeader.section == section)
                return viewHeader;
        }
    }
    return nil;
}

- (void) didCollapseSection: (NSUInteger)section
{
    [dataSource tableView:_orderView collapseSection:section];
}

- (void) didExpandSection: (NSUInteger)sectionToExpand collapseAllOthers:(BOOL)collapseOthers
{
    [dataSource tableView:_orderView expandSection:sectionToExpand collapseAllOthers:collapseOthers];
}

- (BOOL)canEditOrderLine:(OrderLine *)line {
    if (line == nil)
        return NO;
    if (line.course == nil)
        return YES;
    if (line.course.requestedOn != nil || line.course.servedOn != nil)
        return NO;
    return YES;
}

@end