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
    view.closeButton.hidden = NO;

    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(tapper:)];
    tapper.delegate = view;
    [view.tableView addGestureRecognizer:tapper];

    return view;
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

//- (CGRect) rectInTableForSeat: (NSUInteger)seat
//{
//    SeatView *seatView = [self seatViewAtOffset:seat];
//    if (seatView == nil) return CGRectZero;
//    CGRect frame = CGRectOffset(seatView.frame, -tableView.frame.origin.x, -tableView.frame.origin.y);
//    CGFloat maxWidth = 100;
//    CGFloat maxHeight = 30;
//    switch(seatView.side) {
//        case TableSideTop:
//            frame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height + 5, frame.size.width, MIN(frame.size.height, maxHeight));
//            if (frame.size.width > maxWidth)
//                frame = CGRectMake(frame.origin.x +  (frame.size.width - maxWidth)/2, frame.origin.y, maxWidth, frame.size.height);
//            break;
//        case TableSideRight:
//            frame = CGRectMake(frame.origin.x - MIN(seatView.frame.size.width, maxWidth) - 7, frame.origin.y, MIN(seatView.frame.size.width, maxWidth), seatView.bounds.size.height);
//            if (frame.size.height > maxHeight)
//                frame = CGRectMake( frame.origin.x, frame.origin.y + (frame.size.height - maxHeight)/2, frame.size.width, maxHeight);
//            break;
//        case TableSideBottom:
//            frame = CGRectMake(frame.origin.x, tableView.frame.size.height - MIN(frame.size.height, maxHeight) - 7, frame.size.width, MIN(frame.size.height, maxHeight));
//            if (frame.size.width > maxWidth)
//                frame = CGRectMake( frame.origin.x + (frame.size.width - maxWidth)/2, frame.origin.y, maxWidth, frame.size.height);
//            break;
//        case TableSideLeft:
//            frame = CGRectMake(frame.origin.x + seatView.frame.size.width + 7, frame.origin.y, frame.size.width, seatView.bounds.size.height);
//            if (frame.size.height > maxHeight)
//                frame = CGRectMake( frame.origin.x, frame.origin.y + (frame.size.height - maxHeight)/2, frame.size.width, maxHeight);
//            break;
//    }
//    return frame;
//}

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
    if (CGRectContainsPoint(CGRectMake(CGRectGetMinX(tableView.frame), CGRectGetMinY(tableView.frame), tableView.frame.size.width, sectionSize.height), point))
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

    if (numberOfSeatsAtSide == 0) {
        switch (tableSide) {
            case TableSideTop:
                tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y - seatToRemove.frame.size.height, tableView.frame.size.width, tableView.frame.size.height + seatToRemove.frame.size.height);
                break;
            case TableSideRight:
                tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width + seatToRemove.frame.size.width, tableView.frame.size.height);
                break;
            case TableSideBottom:
                tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height + seatToRemove.frame.size.height);
                break;
            case TableSideLeft:
                tableView.frame = CGRectMake(tableView.frame.origin.x - seatToRemove.frame.size.width, tableView.frame.origin.y, tableView.frame.size.width + seatToRemove.frame.size.width, tableView.frame.size.height);
                break;
        }
    }
    else {
        [self rearrangeSeatViewsAtSide: tableSide];
    }
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
        [self offsetSeats: +1 startingAt: toSeat - 1];
    else
        [self offsetSeats: +1 startingAt: toSeat];

    seatViewToMove.offset = toSeat - 1;

    [UIView animateWithDuration:1 animations:^{
        if (seatViewToMove.side == toSide) {
            [self rearrangeSeatViewsAtSide:toSide];
        }
        else {
            int numberOfSeats = [[table.countSeatsPerSide objectAtIndex: seatViewToMove.side] intValue];
            [table.countSeatsPerSide replaceObjectAtIndex: seatViewToMove.side withObject:[NSNumber numberWithInt:numberOfSeats - 1]];
            [self rearrangeSeatViewsAtSide: seatViewToMove.side];

            numberOfSeats = [[table.countSeatsPerSide objectAtIndex:toSide] intValue];
            [table.countSeatsPerSide replaceObjectAtIndex:toSide withObject:[NSNumber numberWithInt:numberOfSeats+1]];
            [self rearrangeSeatViewsAtSide:toSide];
        }
    }];
}

-(void) rearrangeSeatViewsAtSide:(TableSide) tableSide {
    int firstSeat = [table firstSeatAtSide:tableSide];
    SeatView *firstSeatView = [self seatViewAtOffset:firstSeat];
    int numberOfSeats = [[table.countSeatsPerSide objectAtIndex:tableSide] intValue];
    float width, height;
    float dx, dy;
    float x, y;
    switch (tableSide) {
        case TableSideTop:
            width = tableView.frame.size.width / numberOfSeats;
            height = firstSeatView.frame.size.height;
            x = CGRectGetMinX(tableView.frame);
            y = CGRectGetMinY(tableView.frame) - firstSeatView.frame.size.height;
            dx = width;
            dy = 0;
            break;
        case TableSideRight:
            height = tableView.frame.size.height / numberOfSeats;
            width = firstSeatView.frame.size.width;
            x = CGRectGetMaxX(tableView.frame);
            y = CGRectGetMinY(tableView.frame);
            dx = 0;
            dy = height;
            break;
        case TableSideBottom:
            width = tableView.frame.size.width / numberOfSeats;
            height = firstSeatView.frame.size.height;
            x = CGRectGetMaxX(tableView.frame) - firstSeatView.frame.size.width;
            y = CGRectGetMaxY(tableView.frame);
            dx = -width;
            dy = 0;
            break;
        case TableSideLeft:
            height = tableView.frame.size.height / numberOfSeats;
            width = firstSeatView.frame.size.width;
            x = CGRectGetMinX(tableView.frame) - firstSeatView.frame.size.width;;
            y = CGRectGetMaxY(tableView.frame) - firstSeatView.frame.size.height;
            dx = 0;
            dy = -height;
            break;
    }
    CGRect seatFrame = CGRectMake(x, y, width, height);
    for (int seat=firstSeat; seat < firstSeat + numberOfSeats; seat++) {
        SeatView *seatView = [self seatViewAtOffset: seat];
        seatView.frame = seatFrame;
        seatFrame = CGRectOffset(seatFrame, dx, dy);
    }
}

@end