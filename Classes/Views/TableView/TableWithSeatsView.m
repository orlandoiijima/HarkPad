//
//  Created by wbison on 27-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "TableWithSeatsView.h"
#import "GuestPropertiesViewController.h"
#import "TableInfo.h"
#import "TableViewContainer.h"

@implementation TableWithSeatsView {

}

@synthesize table, tableView, delegate = _delegate, orderInfo, isTableSelected = _isTableSelected, contentTableView = _contentTableView, isDragging, spareSeatView;
@dynamic selectedGuests, isCloseButtonVisible;
@synthesize closeButton;

+ (TableWithSeatsView *) viewWithFrame: (CGRect)frame tableInfo: (TableInfo *)tableInfo showSeatNumbers: (BOOL) showSeatNumbers
{
    TableWithSeatsView *view = [[TableWithSeatsView alloc] init];
    view.autoresizingMask = (UIViewAutoresizing)-1;
    view.frame = frame;
    view.clipsToBounds = NO;
    view.table = tableInfo.table;
    view.orderInfo = tableInfo.orderInfo;
    Table *table = view.table;
    int verticalUnits = table.maxCountSeatsVertical;
    if ([table.countSeatsPerSide objectAtIndex: TableSideTop] > 0)
        verticalUnits++;
    if ([table.countSeatsPerSide objectAtIndex: TableSideBottom] > 0)
        verticalUnits++;
    int horizontalUnits = table.maxCountSeatsHorizontal;
    if ([table.countSeatsPerSide objectAtIndex: TableSideRight] > 0)
        horizontalUnits++;
    if ([table.countSeatsPerSide objectAtIndex: TableSideLeft] > 0)
        horizontalUnits++;
    CGFloat minimumSize = frame.size.width / horizontalUnits < frame.size.height / verticalUnits ? frame.size.width / horizontalUnits : frame.size.height / verticalUnits;
    if (minimumSize > 50)
        minimumSize = 50;
    if (table.maxCountSeatsVertical)
        minimumSize = MIN(frame.size.width/4, minimumSize);
    if (table.maxCountSeatsHorizontal)
        minimumSize = MIN(frame.size.height/4, minimumSize);
    CGSize seatViewSize = CGSizeMake(minimumSize, minimumSize);

    CGRect tableRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
    if ([[table.countSeatsPerSide objectAtIndex: TableSideTop] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x, seatViewSize.height, tableRect.size.width, tableRect.size.height - seatViewSize.height);
    if ([[table.countSeatsPerSide objectAtIndex: TableSideBottom] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x, tableRect.origin.y, tableRect.size.width, tableRect.size.height - seatViewSize.height);

    if ([[table.countSeatsPerSide objectAtIndex: TableSideRight] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x, tableRect.origin.y, tableRect.size.width - seatViewSize.width, tableRect.size.height);
    if ([[table.countSeatsPerSide objectAtIndex: TableSideLeft] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x + seatViewSize.width, tableRect.origin.y, tableRect.size.width - seatViewSize.width, tableRect.size.height);

    view.tableView = [[TableViewContainer alloc] initWithFrame:tableRect];
    view.tableView.autoresizingMask = (UIViewAutoresizing) -1;
    [view addSubview:view.tableView];

    if (table.maxCountSeatsHorizontal > 0) {
        CGFloat x = tableRect.origin.x;
        CGFloat width = tableRect.size.width / [[table.countSeatsPerSide objectAtIndex:TableSideTop] intValue];
        int seat = 0;
        for(int i=0; i < [[table.countSeatsPerSide objectAtIndex: TableSideTop] intValue]; i++) {
            SeatView *seatView = [SeatView viewWithFrame:CGRectMake(x + i * width, tableRect.origin.y - seatViewSize.height, width, seatViewSize.height) offset:seat+i atSide:TableSideTop];
            [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchUpInside];
            [seatView initByGuest: [tableInfo.orderInfo getGuestBySeat:seatView.offset]];
            [view addSubview:seatView];
        }
        seat = [[table.countSeatsPerSide objectAtIndex: TableSideTop] intValue] + [[table.countSeatsPerSide objectAtIndex: TableSideRight] intValue];
        width = tableRect.size.width / [[table.countSeatsPerSide objectAtIndex: TableSideBottom] intValue];
        for(int i=0; i < [[table.countSeatsPerSide objectAtIndex: TableSideBottom] intValue]; i++) {
            SeatView *seatView = [SeatView viewWithFrame:CGRectMake(tableRect.origin.x + tableRect.size.width - (i+1)*width, tableRect.origin.y + tableRect.size.height, width, seatViewSize.height) offset:i + seat atSide:TableSideBottom];
            [view addSubview:seatView];
            [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
            [seatView initByGuest: [tableInfo.orderInfo getGuestBySeat: seatView.offset]];
        }
    }

    if (table.maxCountSeatsVertical > 0) {
        CGFloat height = (tableRect.size.height) / [[table.countSeatsPerSide objectAtIndex: TableSideRight] intValue];
        int seat = [[table.countSeatsPerSide objectAtIndex:TableSideTop] intValue];
        for(int i=0; i < [[table.countSeatsPerSide objectAtIndex:TableSideRight] intValue]; i++) {
            SeatView *seatView = [SeatView viewWithFrame: CGRectMake(tableRect.origin.x + tableRect.size.width, tableRect.origin.y + i * height, seatViewSize.width, height) offset:i + seat atSide:TableSideRight];
            [view addSubview:seatView];
            [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
            [seatView initByGuest: [tableInfo.orderInfo getGuestBySeat: seatView.offset]];
        }
        height = (tableRect.size.height) / [[table.countSeatsPerSide objectAtIndex:TableSideLeft] intValue];
        seat = [[table.countSeatsPerSide objectAtIndex:TableSideTop] intValue] + [[table.countSeatsPerSide objectAtIndex:TableSideRight] intValue] + [[table.countSeatsPerSide objectAtIndex:TableSideBottom] intValue];
        for(int i=0; i < [[table.countSeatsPerSide objectAtIndex: TableSideLeft] intValue]; i++) {
            SeatView *seatView = [SeatView viewWithFrame:CGRectMake(tableRect.origin.x - seatViewSize.width, tableRect.origin.y + tableRect.size.height - (i+1) * height, seatViewSize.width, height) offset:i + seat atSide:TableSideLeft];
            [view addSubview:seatView];
            [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
            [seatView initByGuest: [tableInfo.orderInfo getGuestBySeat: seatView.offset]];
        }
    }

    view.spareSeatView = [SeatView viewWithFrame:CGRectMake(0, 0, seatViewSize.width, seatViewSize.height) offset:-1 atSide:TableSideBottom];
    view.spareSeatView.hidden = YES;
    [view addSubview: view.spareSeatView];

    view.closeButton = [[UIButton alloc] init];
    [view addSubview: view.closeButton];
    [view.closeButton addTarget:view action:@selector(tapCloseButton) forControlEvents:UIControlEventTouchUpInside];
    [view.closeButton setImage:[UIImage imageNamed:@"closebox.png"] forState:UIControlStateNormal];
    view.closeButton.hidden = YES;

    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(tapper:)];
    tapper.delegate = view;
    [view.tableView addGestureRecognizer:tapper];

    return view;
}

- (void)layoutSubviews {
    int verticalUnits = table.maxCountSeatsVertical;
    if ([table.countSeatsPerSide objectAtIndex: TableSideTop] > 0)
        verticalUnits++;
    if ([table.countSeatsPerSide objectAtIndex: TableSideBottom] > 0)
        verticalUnits++;
    int horizontalUnits = table.maxCountSeatsHorizontal;
    if ([table.countSeatsPerSide objectAtIndex: TableSideRight] > 0)
        horizontalUnits++;
    if ([table.countSeatsPerSide objectAtIndex: TableSideLeft] > 0)
        horizontalUnits++;
    CGFloat minimumSize = self.frame.size.width / horizontalUnits < self.frame.size.height / verticalUnits ? self.frame.size.width / horizontalUnits : self.frame.size.height / verticalUnits;
//    if (minimumSize > 50)
//        minimumSize = 50;
    if (table.maxCountSeatsVertical)
        minimumSize = MIN(self.frame.size.width/4, minimumSize);
    if (table.maxCountSeatsHorizontal)
        minimumSize = MIN(self.frame.size.height/4, minimumSize);
    CGSize seatViewSize = CGSizeMake(minimumSize, minimumSize);

    CGRect tableRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if ([[table.countSeatsPerSide objectAtIndex: TableSideTop] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x, seatViewSize.height, tableRect.size.width, tableRect.size.height - seatViewSize.height);
    if ([[table.countSeatsPerSide objectAtIndex: TableSideBottom] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x, tableRect.origin.y, tableRect.size.width, tableRect.size.height - seatViewSize.height);

    if ([[table.countSeatsPerSide objectAtIndex: TableSideRight] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x, tableRect.origin.y, tableRect.size.width - seatViewSize.width, tableRect.size.height);
    if ([[table.countSeatsPerSide objectAtIndex: TableSideLeft] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x + seatViewSize.width, tableRect.origin.y, tableRect.size.width - seatViewSize.width, tableRect.size.height);

    tableView.frame = tableRect;

    if (table.maxCountSeatsHorizontal > 0) {
        CGFloat x = tableRect.origin.x;
        CGFloat width = tableRect.size.width / [[table.countSeatsPerSide objectAtIndex:TableSideTop] intValue];
        int seat = 0;
        for(int i=0; i < [[table.countSeatsPerSide objectAtIndex: TableSideTop] intValue]; i++) {
            SeatView *seatView = [self seatViewAtOffset:seat+i];
            seatView.frame = CGRectMake(x + i * width, tableRect.origin.y - seatViewSize.height, width, seatViewSize.height);
        }
        seat = [[table.countSeatsPerSide objectAtIndex: TableSideTop] intValue] + [[table.countSeatsPerSide objectAtIndex: TableSideRight] intValue];
        width = tableRect.size.width / [[table.countSeatsPerSide objectAtIndex: TableSideBottom] intValue];
        for(int i=0; i < [[table.countSeatsPerSide objectAtIndex: TableSideBottom] intValue]; i++) {
            SeatView *seatView = [self seatViewAtOffset:seat+i];
            seatView.frame = CGRectMake(tableRect.origin.x + tableRect.size.width - (i+1)*width, tableRect.origin.y + tableRect.size.height, width, seatViewSize.height);
        }
    }

    if (table.maxCountSeatsVertical > 0) {
        CGFloat height = (tableRect.size.height) / [[table.countSeatsPerSide objectAtIndex: TableSideRight] intValue];
        int seat = [[table.countSeatsPerSide objectAtIndex:TableSideTop] intValue];
        for(int i=0; i < [[table.countSeatsPerSide objectAtIndex:TableSideRight] intValue]; i++) {
            SeatView *seatView = [self seatViewAtOffset:seat+i];
            seatView.frame = CGRectMake(tableRect.origin.x + tableRect.size.width, tableRect.origin.y + i * height, seatViewSize.width, height);
        }
        height = (tableRect.size.height) / [[table.countSeatsPerSide objectAtIndex:TableSideLeft] intValue];
        seat = [[table.countSeatsPerSide objectAtIndex:TableSideTop] intValue] + [[table.countSeatsPerSide objectAtIndex:TableSideRight] intValue] + [[table.countSeatsPerSide objectAtIndex:TableSideBottom] intValue];
        for(int i=0; i < [[table.countSeatsPerSide objectAtIndex: TableSideLeft] intValue]; i++) {
            SeatView *seatView = [self seatViewAtOffset:seat+i];
            seatView.frame = CGRectMake(tableRect.origin.x - seatViewSize.width, tableRect.origin.y + tableRect.size.height - (i+1) * height, seatViewSize.width, height);
        }
    }

    closeButton.frame = CGRectMake(tableView.frame.origin.x + tableView.frame.size.width + 15 - 30, tableView.frame.origin.y - 15, 30, 29);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[SeatView class]]) {
            if (CGRectContainsPoint(view.frame, point))
                return YES;
        }
    }
    return [super pointInside:point withEvent:event];
}

- (void) setIsCloseButtonVisible: (BOOL)vis {
    closeButton.frame = CGRectMake(tableView.frame.origin.x + tableView.frame.size.width + 15 - 30, tableView.frame.origin.y - 15, 30, 29);
    closeButton.hidden = !vis;
}

- (void)tapCloseButton {
    if([self.delegate respondsToSelector:@selector(didTapCloseButton)])
        [self.delegate didTapCloseButton];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if([self.delegate respondsToSelector:@selector(didTapTableView:)])
        return YES;
    if([self.delegate respondsToSelector:@selector(didSelectTableView:)])
        return YES;
    return NO;
}

- (void) tapper: (UITapGestureRecognizer *)gestureRecognizer
{
    if([self.delegate respondsToSelector:@selector(didTapTableView:)])
        [self.delegate didTapTableView:self];

    BOOL canSelect = YES;
    if([self.delegate respondsToSelector:@selector(canSelectTableView:)])
        if ([self.delegate canSelectTableView:self] == false)
            canSelect = NO;
    if (canSelect) {
        self.isTableSelected = YES;
        if([self.delegate respondsToSelector:@selector(didSelectTableView:)])
            [self.delegate didSelectTableView:self];
    }
}

- (void)setIsTableSelected: (BOOL)selected
{
    _isTableSelected = selected;
    tableView.isSelected = selected;
    if (selected)
        self.selectedGuests = nil;
}

- (void) setIsDragging: (BOOL)dragging {

    isDragging = dragging;
    if ([[orderInfo guests] count] > 0) {
        tableView.isTransparent = isDragging;
    }
}

- (void)tapSeat: (id)sender {
    SeatView *seatView = (SeatView *)sender;
    if([self.delegate respondsToSelector:@selector(didTapSeat:)])
        [self.delegate didTapSeat: seatView.offset];

    BOOL canSelect = YES;
    if([self.delegate respondsToSelector:@selector(canSelectSeat:)])
        if ([self.delegate canSelectSeat: seatView.offset] == false)
            canSelect = NO;
    if (canSelect) {
        [self selectSeat:seatView.offset];
        self.isTableSelected = NO;
        if([self.delegate respondsToSelector:@selector(didSelectSeat:)])
            [self.delegate didSelectSeat: seatView.offset];
    }
}

- (void)editOrder: (Order *)o {
    if (_delegate == nil) return;
    if([self.delegate respondsToSelector:@selector(editOrder:)])
        [self.delegate editOrder:o];
}

- (void)makeBillForOrder: (Order *)o {
    if (_delegate == nil) return;
    if([self.delegate respondsToSelector:@selector(makeBillForOrder:)])
        [self.delegate makeBillForOrder:o];
}

- (void)getPaymentForOrder: (Order *)o {
    if (_delegate == nil) return;
    if([self.delegate respondsToSelector:@selector(getPaymentForOrder:)])
        [self.delegate getPaymentForOrder:o];
}

- (SeatView *)seatViewAtOffset: (NSUInteger)offset
{
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[SeatView class]]) {
            SeatView *seatView = (SeatView *) view;
            if (seatView.offset == offset)
                return seatView;
        }
    }
    NSLog(@"seat %d not found", offset);
    return nil;
}

- (SeatView *)seatViewAtPoint: (CGPoint) point exclude:(SeatView *)seatViewToExclude
{
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[SeatView class]] && view != spareSeatView && view != seatViewToExclude) {
            if (CGRectContainsPoint(view.frame, point))
                return view;
        }
    }
    return nil;
}

- (TableSide) tableSideSeatSectionAtPoint: (CGPoint) point {
    CGSize sectionSize = CGSizeMake(tableView.frame.size.width / 4, tableView.frame.size.height / 4);
    if (CGRectContainsPoint(CGRectMake(CGRectGetMinX(tableView.frame), CGRectGetMinY(tableView.frame) - sectionSize.height, tableView.frame.size.width, sectionSize.height), point))
        return TableSideTop;
    if (CGRectContainsPoint(CGRectMake(CGRectGetMaxX(tableView.frame), CGRectGetMinY(tableView.frame), sectionSize.width, tableView.frame.size.height), point))
        return TableSideRight;
    if (CGRectContainsPoint(CGRectMake(CGRectGetMinX(tableView.frame), CGRectGetMaxY(tableView.frame), tableView.frame.size.width, sectionSize.height), point))
        return TableSideBottom;
    if (CGRectContainsPoint(CGRectMake(CGRectGetMinX(tableView.frame) - sectionSize.width, CGRectGetMinY(tableView.frame), sectionSize.width, tableView.frame.size.height), point))
        return TableSideLeft;
    return NSNotFound;
}

- (void) selectSeat: (int) offset
{
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[SeatView class]]) {
            SeatView *seatView = (SeatView *) view;
            seatView.isSelected = seatView.offset == offset;
        }
    }
}

- (void) setOverlayText: (NSString *) text forSeat: (int)offset
{
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[SeatView class]]) {
            SeatView *seatView = (SeatView *) view;
            if (seatView.offset == offset)
                seatView.overlayText = text;
        }
    }
}

- (NSMutableArray *) selectedGuests
{
    NSMutableArray *seats = [[NSMutableArray alloc] init];
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[SeatView class]]) {
            SeatView *seatView = (SeatView *) view;
            if (seatView.isSelected) {
                Guest *guest = [orderInfo getGuestBySeat:seatView.offset];
                if (guest != nil)
                    [seats addObject:guest];
            }
        }
    }
    return seats;
}

- (void)setSelectedGuests:(NSMutableArray *)aSelectedGuests {
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[SeatView class]]) {
            SeatView *seatView = (SeatView *) view;
            if (aSelectedGuests == nil)
                seatView.isSelected = NO;
        }
    }
}

- (void)didModifyItem:(id)item {
    Guest *guest = (Guest *)item;
    SeatView *seatView = [self seatViewAtOffset:guest.seat];
    if (seatView != nil) {
        [seatView initByGuest:guest];
    }
}

- (void) setContentTableView: (UIView *)contentView {
    [self.tableView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.tableView addSubview: contentView];
    _contentTableView = contentView;
    [self setNeedsDisplay];

//    [UIView transitionFromView:_contentTableView
//                        toView:contentView
//                      duration:1
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    completion:^(BOOL completion)
//                    {
//                        [self.tableView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//                        [self.tableView addSubview: contentView];
//                        _contentTableView = contentView;
//                        [self setNeedsDisplay];
//
//                    }];
}
- (UIView *)contentTableView {
    return _contentTableView;
}

- (void) removeSeat:(int) seat {
    SeatView *seatToRemove = [self seatViewAtOffset:seat];
    if (seatToRemove == nil) return;
    TableSide tableSide = [table sideForSeat:seat];
    int numberOfSeatsAtSide = [[table.countSeatsPerSide objectAtIndex:tableSide] intValue];
    if (numberOfSeatsAtSide == 0) return;

    [self offsetSeats:-1 startingAt:seat+1];

    numberOfSeatsAtSide--;
    [table.countSeatsPerSide replaceObjectAtIndex:tableSide withObject:[NSNumber numberWithInt:numberOfSeatsAtSide]];

    seatToRemove.offset = -1;

    [self layoutSubviews];
}

- (void) offsetSeats:(int) delta startingAt:(int)startSeat {
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[SeatView class]]) {
            SeatView *seatView = (SeatView *) view;
            if (seatView.offset >= startSeat)
                seatView.offset += delta;
        }
    }
    for(Guest *guest in orderInfo.guests) {
        if (guest.seat >= startSeat) {
            guest.seat += delta;
        }
    }

}

- (void) moveSeat: (int) seatToMove toSeat:(int) toSeat atSide:(TableSide)toSide {
    SeatView *seatViewToMove = [self seatViewAtOffset:seatToMove];
    if (seatViewToMove == nil) return;

    [self offsetSeats: -1 startingAt: seatToMove+1];
    if (seatToMove < toSeat)
        toSeat--;
    [self offsetSeats: +1 startingAt: toSeat];
    seatViewToMove.offset = toSeat;

    if (seatViewToMove.side != toSide) {
        int numberOfSeatsOldSide = [[table.countSeatsPerSide objectAtIndex: seatViewToMove.side] intValue] - 1;
        [table.countSeatsPerSide replaceObjectAtIndex: seatViewToMove.side withObject:[NSNumber numberWithInt:numberOfSeatsOldSide]];

        int numberOfSeatsNewSide = [[table.countSeatsPerSide objectAtIndex:toSide] intValue] + 1;
        [table.countSeatsPerSide replaceObjectAtIndex:toSide withObject:[NSNumber numberWithInt: numberOfSeatsNewSide]];

        seatViewToMove.side = toSide;
    }

    [UIView animateWithDuration: 3 animations:^{
        [self layoutSubviews];
    }];
}


@end