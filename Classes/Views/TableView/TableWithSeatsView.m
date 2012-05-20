//
//  Created by wbison on 27-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TableWithSeatsView.h"

@implementation TableWithSeatsView {

}

@synthesize table, tableView, delegate = _delegate, orderInfo, isTableSelected = _isTableSelected, contentTableView = _contentTableView, isDragging, spareSeatView;
@dynamic selectedGuests, isCloseButtonVisible, isSpareSeatViewVisible, seatViewSize;
@synthesize closeButton;

+ (TableWithSeatsView *) viewWithFrame: (CGRect)frame tableInfo: (TableInfo *)tableInfo
{
    TableWithSeatsView *view = [[TableWithSeatsView alloc] init];
    view.autoresizingMask = (UIViewAutoresizing)-1;
    view.frame = frame;
    view.clipsToBounds = NO;
    view.table = tableInfo.table;
    view.orderInfo = tableInfo.orderInfo;
    Table *table = view.table;
    CGRect tableRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
    if ([[table.countSeatsPerSide objectAtIndex: TableSideTop] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x, view.seatViewSize.height, tableRect.size.width, tableRect.size.height - view.seatViewSize.height);
    if ([[table.countSeatsPerSide objectAtIndex: TableSideBottom] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x, tableRect.origin.y, tableRect.size.width, tableRect.size.height - view.seatViewSize.height);

    if ([[table.countSeatsPerSide objectAtIndex: TableSideRight] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x, tableRect.origin.y, tableRect.size.width - view.seatViewSize.width, tableRect.size.height);
    if ([[table.countSeatsPerSide objectAtIndex: TableSideLeft] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x + view.seatViewSize.width, tableRect.origin.y, tableRect.size.width - view.seatViewSize.width, tableRect.size.height);

    view.tableView = [[TableViewContainer alloc] initWithFrame:tableRect];
    view.tableView.autoresizingMask = (UIViewAutoresizing) -1;
    [view addSubview:view.tableView];

    int seat = 0;
    for (TableSide side = 0; side <= TableSideLeft; side++) {
        for(int i=0; i < [[table.countSeatsPerSide objectAtIndex: side] intValue]; i++) {
            [view addNewSeatViewAtOffset:seat atSide:side withGuest:[tableInfo.orderInfo getGuestBySeat: seat]];
            seat++;
        }
    }

    view.spareSeatView = [SeatView viewWithFrame:CGRectMake(0, 0, view.seatViewSize.width, view.seatViewSize.height) offset:-1 atSide:TableSideBottom];
    view.spareSeatView.hidden = YES;
    view.spareSeatView.overlayText = @"+";
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

- (SeatView *) addNewSeatViewAtOffset:(int) seat atSide:(TableSide)side withGuest:(Guest *)guest {
    SeatView *seatView = [SeatView viewWithFrame:CGRectZero offset:seat atSide:side];
    [seatView addTarget: self action:@selector(tapSeat:) forControlEvents:UIControlEventTouchUpInside];
    [seatView initByGuest: guest];
    [self addSubview:seatView];
    return seatView;
}

- (CGSize) seatViewSize
{
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
    if (table.maxCountSeatsVertical)
        minimumSize = MIN(self.frame.size.width/4, minimumSize);
    if (table.maxCountSeatsHorizontal)
        minimumSize = MIN(self.frame.size.height/4, minimumSize);
    return CGSizeMake(minimumSize, minimumSize);
}

- (void)layoutSubviews {
    CGRect tableRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if ([[table.countSeatsPerSide objectAtIndex: TableSideTop] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x, self.seatViewSize.height, tableRect.size.width, tableRect.size.height - self.seatViewSize.height);
    if ([[table.countSeatsPerSide objectAtIndex: TableSideBottom] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x, tableRect.origin.y, tableRect.size.width, tableRect.size.height - self.seatViewSize.height);

    if ([[table.countSeatsPerSide objectAtIndex: TableSideRight] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x, tableRect.origin.y, tableRect.size.width - self.seatViewSize.width, tableRect.size.height);
    if ([[table.countSeatsPerSide objectAtIndex: TableSideLeft] intValue] > 0)
        tableRect = CGRectMake(tableRect.origin.x + self.seatViewSize.width, tableRect.origin.y, tableRect.size.width - self.seatViewSize.width, tableRect.size.height);

    tableView.frame = tableRect;

    int seat = 0;
    float dx, dy;
    CGRect seatFrame;
    for (TableSide side = 0; side <= TableSideLeft; side++) {
        int countSeats = [[table.countSeatsPerSide objectAtIndex: side] intValue];
        if (countSeats > 0) {
            switch (side) {
                case TableSideTop:
                    dx = tableRect.size.width / countSeats;
                    dy = 0;
                    seatFrame = CGRectMake(CGRectGetMinX(tableRect), CGRectGetMinY(tableRect) - self.seatViewSize.height, dx, self.seatViewSize.height);
                    break;
                case TableSideRight:
                    dx = 0;
                    dy = tableRect.size.height / countSeats;
                    seatFrame = CGRectMake(CGRectGetMaxX(tableRect), CGRectGetMinY(tableRect), self.seatViewSize.width, dy);
                    break;
                case TableSideBottom:
                    dx = - tableRect.size.width / countSeats;
                    dy = 0;
                    seatFrame = CGRectMake(CGRectGetMaxX(tableRect) + dx, CGRectGetMaxY(tableRect), -dx, self.seatViewSize.height);
                    break;
                case TableSideLeft:
                    dx = 0;
                    dy =  - tableRect.size.height / countSeats;
                    seatFrame = CGRectMake(CGRectGetMinX(tableRect) - self.seatViewSize.width, CGRectGetMaxY(tableRect) + dy, self.seatViewSize.width, -dy);
                    break;
            }
            for(int i=0; i < [[table.countSeatsPerSide objectAtIndex: side] intValue]; i++) {
                SeatView *seatView = [self seatViewAtOffset:seat];
                seatView.frame = seatFrame;
                seat++;
                seatFrame = CGRectOffset(seatFrame, dx, dy);
            }
        }
    }

    closeButton.frame = CGRectMake(tableView.frame.origin.x + tableView.frame.size.width + 15 - 30, tableView.frame.origin.y - 15, 30, 29);
    spareSeatView.frame = CGRectMake(- self.frame.origin.x, - self.frame.origin.y, self.seatViewSize.width, self.seatViewSize.height);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[SeatView class]] || view == closeButton) {
            if (CGRectContainsPoint(view.frame, point))
                return YES;
        }
    }
    return [super pointInside:point withEvent:event];
}

- (void) setIsCloseButtonVisible: (BOOL)vis {
    closeButton.hidden = !vis;
}

- (void) setIsSpareSeatViewVisible: (BOOL)vis {
    spareSeatView.hidden = !vis;
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

//- (void)editOrder: (Order *)o {
//    if (_delegate == nil) return;
//    if([self.delegate respondsToSelector:@selector(editOrder:)])
//        [self.delegate editOrder:o];
//}
//
//- (void)makeBillForOrder: (Order *)o {
//    if (_delegate == nil) return;
//    if([self.delegate respondsToSelector:@selector(makeBillForOrder:)])
//        [self.delegate makeBillForOrder:o];
//}
//
//- (void)getPaymentForOrder: (Order *)o {
//    if (_delegate == nil) return;
//    if([self.delegate respondsToSelector:@selector(getPaymentForOrder:)])
//        [self.delegate getPaymentForOrder:o];
//}

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

-(int) seatAtPoint:(CGPoint) point {
    CGRect tableRect = tableView.frame;

    int seat = 0;
    float dx, dy;
    CGRect seatFrame;
    for (TableSide side = 0; side <= TableSideLeft; side++) {
        int countSeats = [[table.countSeatsPerSide objectAtIndex: side] intValue];
        if (countSeats > 0) {
            switch (side) {
                case TableSideTop:
                    dx = tableRect.size.width / countSeats;
                    dy = 0;
                    seatFrame = CGRectMake(CGRectGetMinX(tableRect), CGRectGetMinY(tableRect) - self.seatViewSize.height, dx, self.seatViewSize.height);
                    break;
                case TableSideRight:
                    dx = 0;
                    dy = tableRect.size.height / countSeats;
                    seatFrame = CGRectMake(CGRectGetMaxX(tableRect), CGRectGetMinY(tableRect), self.seatViewSize.width, dy);
                    break;
                case TableSideBottom:
                    dx = - tableRect.size.width / countSeats;
                    dy = 0;
                    seatFrame = CGRectMake(CGRectGetMaxX(tableRect) + dx, CGRectGetMaxY(tableRect), -dx, self.seatViewSize.height);
                    break;
                case TableSideLeft:
                    dx = 0;
                    dy =  - tableRect.size.height / countSeats;
                    seatFrame = CGRectMake(CGRectGetMinX(tableRect) - self.seatViewSize.width, CGRectGetMaxY(tableRect) + dy, self.seatViewSize.width, -dy);
                    break;
            }
            for(int i=0; i < [[table.countSeatsPerSide objectAtIndex: side] intValue]; i++) {
                if(CGRectContainsPoint(seatFrame, point))
                    return seat;
                seat++;
                seatFrame = CGRectOffset(seatFrame, dx, dy);
            }
        }
    }
    return NSNotFound;
}

-(CGRect) frameForSeat:(int) seatToFind {
    CGRect tableRect = tableView.frame;

    int seat = 0;
    float dx, dy;
    CGRect seatFrame;
    for (TableSide side = 0; side <= TableSideLeft; side++) {
        int countSeats = [[table.countSeatsPerSide objectAtIndex: side] intValue];
        if (countSeats > 0) {
            switch (side) {
                case TableSideTop:
                    dx = tableRect.size.width / countSeats;
                    dy = 0;
                    seatFrame = CGRectMake(CGRectGetMinX(tableRect), CGRectGetMinY(tableRect) - self.seatViewSize.height, dx, self.seatViewSize.height);
                    break;
                case TableSideRight:
                    dx = 0;
                    dy = tableRect.size.height / countSeats;
                    seatFrame = CGRectMake(CGRectGetMaxX(tableRect), CGRectGetMinY(tableRect), self.seatViewSize.width, dy);
                    break;
                case TableSideBottom:
                    dx = - tableRect.size.width / countSeats;
                    dy = 0;
                    seatFrame = CGRectMake(CGRectGetMaxX(tableRect) + dx, CGRectGetMaxY(tableRect), -dx, self.seatViewSize.height);
                    break;
                case TableSideLeft:
                    dx = 0;
                    dy =  - tableRect.size.height / countSeats;
                    seatFrame = CGRectMake(CGRectGetMinX(tableRect) - self.seatViewSize.width, CGRectGetMaxY(tableRect) + dy, self.seatViewSize.width, -dy);
                    break;
            }
            for(int i=0; i < [[table.countSeatsPerSide objectAtIndex: side] intValue]; i++) {
                if(seatToFind == seat)
                    return seatFrame;
                seat++;
                seatFrame = CGRectOffset(seatFrame, dx, dy);
            }
        }
    }
    return CGRectNull;
}


- (TableSide) tableSideSeatSectionAtPoint: (CGPoint) point {
    if (CGRectContainsPoint(CGRectMake(CGRectGetMinX(tableView.frame), CGRectGetMinY(tableView.frame) - self.seatViewSize.height, tableView.frame.size.width, self.seatViewSize.height), point))
        return TableSideTop;
    if (CGRectContainsPoint(CGRectMake(CGRectGetMaxX(tableView.frame), CGRectGetMinY(tableView.frame), self.seatViewSize.width, tableView.frame.size.height), point))
        return TableSideRight;
    if (CGRectContainsPoint(CGRectMake(CGRectGetMinX(tableView.frame), CGRectGetMaxY(tableView.frame), tableView.frame.size.width, self.seatViewSize.height), point))
        return TableSideBottom;
    if (CGRectContainsPoint(CGRectMake(CGRectGetMinX(tableView.frame) - self.seatViewSize.width, CGRectGetMinY(tableView.frame), self.seatViewSize.width, tableView.frame.size.height), point))
        return TableSideLeft;
    return NSNotFound;
}
- (void) selectSeat: (int) offset
{
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[SeatView class]] && view != spareSeatView) {
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

    [seatToRemove removeFromSuperview];

    [UIView animateWithDuration: 0.3 animations:^{
        [self layoutSubviews];
    }];
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
    Guest *guestToMove = [orderInfo getGuestBySeat:seatToMove];
    if (guestToMove == nil) return;
    SeatView *seatViewToMove = [self seatViewAtOffset:seatToMove];
    if (seatViewToMove == nil) return;

    [self offsetSeats: -1 startingAt: seatToMove+1];
    if (seatToMove < toSeat)
        toSeat--;
    [self offsetSeats: +1 startingAt: toSeat];
    seatViewToMove.offset = toSeat;
    guestToMove.seat = toSeat;

    if (seatViewToMove.side != toSide) {
        int numberOfSeatsOldSide = [[table.countSeatsPerSide objectAtIndex: seatViewToMove.side] intValue] - 1;
        [table.countSeatsPerSide replaceObjectAtIndex: seatViewToMove.side withObject:[NSNumber numberWithInt:numberOfSeatsOldSide]];

        int numberOfSeatsNewSide = [[table.countSeatsPerSide objectAtIndex:toSide] intValue] + 1;
        [table.countSeatsPerSide replaceObjectAtIndex:toSide withObject:[NSNumber numberWithInt: numberOfSeatsNewSide]];

        seatViewToMove.side = toSide;
    }

    [UIView animateWithDuration: 0.3 animations:^{
        [self layoutSubviews];
    }];
}

- (void) insertSeatBeforeSeat: (int) toSeat atSide:(TableSide)toSide {
    CGRect newSeatFrame = spareSeatView.frame;
    spareSeatView.frame = CGRectMake(- self.frame.origin.x, - self.frame.origin.y, self.seatViewSize.width, self.seatViewSize.height);

    [self offsetSeats: +1 startingAt: toSeat];

    int numberOfSeatsNewSide = [[table.countSeatsPerSide objectAtIndex:toSide] intValue] + 1;
    [table.countSeatsPerSide replaceObjectAtIndex:toSide withObject:[NSNumber numberWithInt: numberOfSeatsNewSide]];

    Guest *newGuest = [orderInfo addGuest];
    newGuest.seat = toSeat;
    SeatView *seatView = [self addNewSeatViewAtOffset:toSeat atSide:toSide withGuest: newGuest];
    seatView.frame = newSeatFrame;

    [UIView animateWithDuration: 0.3 animations:^{
        [self layoutSubviews];
    }];
}

@end