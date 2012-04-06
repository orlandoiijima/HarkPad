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

@synthesize table, tableView, delegate = _delegate, orderInfo, tableInnerRect, isTableSelected = _isTableSelected, contentTableView = _contentTableView, isDragging;
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
    if ([table.countSeatsPerSide objectAtIndex:0] > 0)
        verticalUnits++;
    if ([table.countSeatsPerSide objectAtIndex:2] > 0)
        verticalUnits++;
    int horizontalUnits = table.maxCountSeatsHorizontal;
    if ([table.countSeatsPerSide objectAtIndex:1] > 0)
        horizontalUnits++;
    if ([table.countSeatsPerSide objectAtIndex:3] > 0)
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
    if (table.maxCountSeatsVertical > 0)
        tableRect = CGRectInset(tableRect, seatViewSize.width, 0);
    if (table.maxCountSeatsHorizontal > 0)
        tableRect = CGRectInset(tableRect, 0, seatViewSize.width);

    view.tableView = [[TableViewContainer alloc] initWithFrame:tableRect];
    view.tableView.autoresizingMask = (UIViewAutoresizing) -1;
    [view addSubview:view.tableView];

    if (table.maxCountSeatsHorizontal > 0) {
        CGFloat x = tableRect.origin.x;
        CGFloat width = tableRect.size.width / table.maxCountSeatsHorizontal;
        int seat = 0;
        for(int i=0; i < [[table.countSeatsPerSide objectAtIndex:0] intValue]; i++) {
            SeatView *seatView = [SeatView viewWithFrame:CGRectMake(x + i * width, tableRect.origin.y - seatViewSize.height, width, seatViewSize.height) offset:seat+i atSide:TableSideTop];
            [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
            [seatView initByGuest: [tableInfo.orderInfo getGuestBySeat:seatView.offset]];
            [view addSubview:seatView];
        }
        seat = [[table.countSeatsPerSide objectAtIndex:0] intValue] + [[table.countSeatsPerSide objectAtIndex:1] intValue];
        for(int i=0; i < [[table.countSeatsPerSide objectAtIndex:2] intValue]; i++) {
            SeatView *seatView = [SeatView viewWithFrame:CGRectMake(tableRect.origin.x + tableRect.size.width - (i+1)*width, tableRect.origin.y + tableRect.size.height, width, seatViewSize.height) offset:i + seat atSide:TableSideBottom];
            [view addSubview:seatView];
            [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
            [seatView initByGuest: [tableInfo.orderInfo getGuestBySeat: seatView.offset]];
        }
    }

    if (table.maxCountSeatsVertical > 0) {
        CGFloat height = (tableRect.size.height) / table.maxCountSeatsVertical;
        int seat = [[table.countSeatsPerSide objectAtIndex:0] intValue];
        for(int i=0; i < [[table.countSeatsPerSide objectAtIndex:1] intValue]; i++) {
            SeatView *seatView = [SeatView viewWithFrame: CGRectMake(tableRect.origin.x + tableRect.size.width, tableRect.origin.y + i * height, seatViewSize.width, height) offset:i + seat atSide:TableSideRight];
            [view addSubview:seatView];
            [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
            [seatView initByGuest: [tableInfo.orderInfo getGuestBySeat: seatView.offset]];
        }
        seat = [[table.countSeatsPerSide objectAtIndex:0] intValue] + [[table.countSeatsPerSide objectAtIndex:1] intValue] + [[table.countSeatsPerSide objectAtIndex:2] intValue];
        for(int i=0; i < [[table.countSeatsPerSide objectAtIndex:3] intValue]; i++) {
            SeatView *seatView = [SeatView viewWithFrame:CGRectMake(tableRect.origin.x - seatViewSize.width, tableRect.origin.y + tableRect.size.height - (i+1) * height, seatViewSize.width, height) offset:i + seat atSide:TableSideLeft];
            [view addSubview:seatView];
            [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
            [seatView initByGuest: [tableInfo.orderInfo getGuestBySeat: seatView.offset]];
        }
    }

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

- (CGRect) rectInTableForSeat: (NSUInteger)seat
{
    SeatView *seatView = [self seatViewAtOffset:seat];
    if (seatView == nil) return CGRectZero;
    CGRect frame = CGRectOffset(seatView.frame, -tableView.frame.origin.x, -tableView.frame.origin.y);
    CGFloat maxWidth = 100;
    CGFloat maxHeight = 30;
    switch(seatView.side) {
        case TableSideTop:
            frame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height + 5, frame.size.width, MIN(frame.size.height, maxHeight));
            if (frame.size.width > maxWidth)
                frame = CGRectMake(frame.origin.x +  (frame.size.width - maxWidth)/2, frame.origin.y, maxWidth, frame.size.height);
            break;
        case TableSideRight:
            frame = CGRectMake(frame.origin.x - MIN(seatView.frame.size.width, maxWidth) - 7, frame.origin.y, MIN(seatView.frame.size.width, maxWidth), seatView.bounds.size.height);
            if (frame.size.height > maxHeight)
                frame = CGRectMake( frame.origin.x, frame.origin.y + (frame.size.height - maxHeight)/2, frame.size.width, maxHeight);
            break;
        case TableSideBottom:
            frame = CGRectMake(frame.origin.x, tableView.frame.size.height - MIN(frame.size.height, maxHeight) - 7, frame.size.width, MIN(frame.size.height, maxHeight));
            if (frame.size.width > maxWidth)
                frame = CGRectMake( frame.origin.x + (frame.size.width - maxWidth)/2, frame.origin.y, maxWidth, frame.size.height);
            break;
        case TableSideLeft:
            frame = CGRectMake(frame.origin.x + seatView.frame.size.width + 7, frame.origin.y, frame.size.width, seatView.bounds.size.height);
            if (frame.size.height > maxHeight)
                frame = CGRectMake( frame.origin.x, frame.origin.y + (frame.size.height - maxHeight)/2, frame.size.width, maxHeight);
            break;
    }
    return frame;
}

- (CGFloat) requiredVerticalMargin
{
    if(table.maxCountSeatsHorizontal == 0)
        return 0;
    CGRect rect = [self rectInTableForSeat:0];
    return rect.size.height;
}

- (CGFloat) requiredHorizontalMargin
{
    if(table.maxCountSeatsVertical == 0)
        return 0;
    CGRect rect = [self rectInTableForSeat: table.maxCountSeatsHorizontal];
    return rect.size.width;
}

- (CGRect) tableInnerRect
{
    return CGRectInset(tableView.bounds, [self requiredHorizontalMargin], [self requiredVerticalMargin]);
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
    return nil;
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
@end