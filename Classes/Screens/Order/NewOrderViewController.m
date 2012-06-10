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
#import "ToolbarTitleView.h"
#import "TestFlight.h"

@implementation NewOrderViewController

@synthesize productPanelView = _productPanelView, orderView = _orderView, tableView = _tableView, order = _order, dataSource, tableOverlayHud = _tableOverlayHud;
@dynamic selectedCourse, selectedCourseOffset, selectedGuest, selectedSeat;
@synthesize autoAdvance = _autoAdvance;


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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TestFlight passCheckpoint: [[self class] description]];

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

    ToolbarTitleView *titleView = [[ToolbarTitleView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleView.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Table", nil), _order.table.name];
    self.navigationItem.titleView = titleView;

    UIColor *panelColor = [UIColor colorWithWhite:0.2 alpha:1];

    CGRect rect = CGRectInset(self.view.bounds, 5, 5);
    _tableView = [TableWithSeatsView viewWithFrame:CGRectMake(0, 0, 100, 100) tableInfo: tableInfo];
    [self addPanelWithView:_tableView frame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - orderViewWidth, MAX(300, rect.size.height / 4)) margin:5 padding:10 backgroundColor: panelColor];
    _tableOverlayHud = [[TableOverlayHud alloc] initWithFrame:_tableView.tableView.bounds];
    _tableView.contentTableView = _tableOverlayHud;
    _tableView.delegate = self;
    _tableView.autoresizingMask = (UIViewAutoresizing) -1;

    _productPanelView = [[MenuTreeView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _productPanelView.countColumns = 4;
    _productPanelView.leftHeaderWidth = 0;
    _productPanelView.topHeaderHeight = 0;
    [self addPanelWithView:_productPanelView frame:CGRectMake(rect.origin.x, rect.origin.y + MAX(300, rect.size.height / 4), rect.size.width - orderViewWidth, rect.size.height - MAX(300, rect.size.height / 4)) margin:5 padding:10 backgroundColor:panelColor];
    _productPanelView.leftHeaderWidth = 0;
    _productPanelView.menuDelegate = self;

    _orderView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _orderView.backgroundView = nil;
    _orderView.backgroundColor = panelColor;
    _orderView.dataSource = self.dataSource;
    _orderView.delegate = self.dataSource;
    [_orderView setEditing:YES];
    [self addPanelWithView:_orderView frame:CGRectMake(CGRectGetMaxX(rect) - orderViewWidth, rect.origin.y, orderViewWidth, rect.size.height - buttonSize) margin:5 padding:10 backgroundColor: panelColor];

    CrystalButton *saveButton = [[CrystalButton alloc] initWithFrame: CGRectZero];
    [saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchDown];

    [self addPanelWithView: saveButton frame:CGRectMake(CGRectGetMaxX(rect) - orderViewWidth, rect.origin.y + rect.size.height - buttonSize, orderViewWidth, buttonSize) margin:5 padding:10 backgroundColor:[UIColor clearColor]];

    [self setupToolbar];

}

- (void)viewDidAppear:(BOOL)animated {
    self.selectedCourseOffset = 0;
    Guest *guest = [_order firstGuest];
    if(guest != nil)
        self.selectedSeat = guest.seat;
}

- (void) addPanelWithView:(UIView *)view frame:(CGRect) frame margin:(int) margin padding:(int) padding backgroundColor: (UIColor *)color{
    UIView *panel = [[UIView alloc] initWithFrame:CGRectInset(frame, margin, margin)];
    panel.backgroundColor = color;
    [self.view addSubview:panel];

    [panel addSubview:view];
    view.frame = CGRectInset(panel.bounds, padding, padding);
}

- (void) setupToolbar {
//    UIBarButtonItem * feedbackButton = [[UIBarButtonItem alloc] initWithTitle: @"Feedback" style:UIBarButtonItemStylePlain target:self action:@selector(getFeedback)];
    UIBarButtonItem * groupButton = [[UIBarButtonItem alloc] initWithTitle: @"Group" style:UIBarButtonItemStylePlain target:self action:@selector(totalizeProducts:)];
    UIBarButtonItem * autoAdvanceButton = [[UIBarButtonItem alloc] initWithTitle: @"Advance" style:UIBarButtonItemStylePlain target:self action:@selector(autoAdvance:)];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
    groupButton, autoAdvanceButton, nil];
}

- (void) totalizeProducts:(id)sender
{
    bool totalize = !self.dataSource.totalizeProducts;
    [self.dataSource tableView:_orderView totalizeProducts: totalize];
    [self.dataSource highlightRowsInTableView:_orderView forSeat: self.selectedSeat];
    UIBarButtonItem *buttonItem = (UIBarButtonItem *) sender;
    buttonItem.style = totalize ? UIBarButtonItemStyleDone : UIBarButtonItemStylePlain;
}

- (void) autoAdvance:(id)sender
{
    self.autoAdvance = !self.autoAdvance;
    UIBarButtonItem *buttonItem = (UIBarButtonItem *) sender;
    buttonItem.style = self.autoAdvance ? UIBarButtonItemStyleDone : UIBarButtonItemStylePlain;
}

- (void) getFeedback
{
    [TestFlight openFeedbackView];
}

- (void) save {
    [[Service getInstance] updateOrder:_order delegate:self callback:@selector(updateOrderCallback:)];

    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)canSelectTableView:(TableWithSeatsView *)tableView {
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

- (void)menuTreeView:(MenuTreeView *)menuTreeView didLongPressNode:(TreeNode *)node cellLine:(GridViewCellLine *)cellLine {
    [self.tableOverlayHud showForNode:node];
}

- (void)menuTreeView:(MenuTreeView *)menuTreeView didEndLongPressNode:(TreeNode *)node cellLine:(GridViewCellLine *)cellLine {
    if (self.tableView.isTableSelected) {
        [self.tableOverlayHud showForOrder:_order];
    }
    else {
        [self.tableOverlayHud showForGuest:self.selectedGuest];
    }
}

- (void)addProduct:(Product *)product forSeat:(int)seat course: (int)course {
    OrderLine *line = [_order addLineWithProductId:product.id seat:seat course: course];
    [self.dataSource tableView:self.orderView addLine:line];
    [self.dataSource highlightRowsInTableView:_orderView forSeat:seat];
}

- (void)menuTreeView:(MenuTreeView *)menuTreeView didTapProduct:(Product *)product {
    for(Guest *guest in [_tableView selectedGuests]) {
        [self addProduct:product forSeat: guest.seat course: self.selectedCourseOffset];
    }
    if (_tableView.isTableSelected) {
        [self addProduct:product forSeat: -1 course: self.selectedCourseOffset];
    }

    Course *nextCourse = nil;
    if (self.selectedCourse != nil) {
        nextCourse = self.selectedCourse.nextCourse;
        if (nextCourse == nil) {
            nextCourse = [_order addCourse];
            [self.dataSource tableView:self.orderView addSection: nextCourse.offset + 1];
        }
    }

    [self.tableOverlayHud showForGuest:[self selectedGuest]];
    if (self.autoAdvance) {
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
}

- (void)menuTreeView:(MenuTreeView *)menuTreeView didTapMenu:(Menu *)menu {
    for(Guest *guest in [_tableView selectedGuests]) {
        for(MenuItem *menuItem in menu.items) {
            [self addProduct: menuItem.product forSeat: guest.seat course: menuItem.course];
        }
    }
    [self.tableOverlayHud showForGuest:[self selectedGuest]];
    [self selectNextGuest];
}

- (BOOL)canSelectCourse:(NSUInteger)courseOffset {
    return YES;
}

- (void)didSelectCourse:(NSUInteger)courseOffset {
    Course *course = [_order getCourseByOffset:courseOffset];
    if (course == nil) return;
    [self updateSeatOverlay];
}

- (BOOL)canSelectSeat:(int)seatOffset {
    Guest *guest = [_order getGuestBySeat:seatOffset];
    if (guest == nil || guest.guestType == guestEmpty) return NO;
    return YES;
}

- (void)didSelectSeat:(int)seatOffset {
    Guest *guest = [_order getGuestBySeat:seatOffset];
    if (guest == nil) return;
    [self updateSeatOverlay];
    [self.tableOverlayHud showForGuest:[self selectedGuest]];
    [dataSource highlightRowsInTableView: _orderView forSeat:guest.seat];
}

- (void)didSelectTableView:(TableWithSeatsView *)tableView {
    [self.tableOverlayHud showForOrder: self.order];
    [dataSource highlightRowsInTableView: _orderView forSeat: -1];
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
    NSLog(@"No course selected, returning -1");
    return -1;
}

- (void)didUpdateOrder:(Order *)order {
    [self.tableOverlayHud showForGuest:[self selectedGuest]];
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
    [self updateSeatOverlay];
}

- (void)updateSeatOverlay
{
    NSString *overlay = [self.selectedCourse descriptionShort];
    [_tableView setOverlayText:overlay  forSeat: self.selectedSeat];
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
    [self didSelectSeat:seat];
}

- (int) selectedSeat
{
    Guest *guest = self.selectedGuest;
    return guest == nil ? -1 : guest.seat;
}

- (bool) selectNextGuest {
    if(self.selectedGuest == nil) return NO;
    if (self.selectedGuest.nextGuest == nil) return NO;
    self.selectedSeat = self.selectedGuest.nextGuest.seat;
    return YES;
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
        self.selectedSeat = line.guest.seat;
        _tableView.isTableSelected = NO;
    }
    else {
        self.selectedSeat = -1;
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
    [dataSource highlightRowsInTableView:_orderView forSeat:self.selectedSeat];
}

- (void) didExpandSection: (NSUInteger)sectionToExpand collapseAllOthers:(BOOL)collapseOthers
{
    [dataSource tableView:_orderView expandSection:sectionToExpand collapseAllOthers:collapseOthers];
    [dataSource highlightRowsInTableView:_orderView forSeat:self.selectedSeat];
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
