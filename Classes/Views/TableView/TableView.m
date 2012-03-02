//
//  Created by wbison on 27-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "TableView.h"
#import "GuestPropertiesViewController.h"
#import "TableInfo.h"
#import "TableViewContainer.h"

@implementation TableView {

}

@synthesize table, tableView, delegate = _delegate, orderInfo, tableInnerRect, isTableSelected = _isTableSelected, contentTableView = _contentTableView;
@dynamic selectedGuests;

+ (TableView *) viewWithFrame: (CGRect)frame tableInfo: (TableInfo *)tableInfo showSeatNumbers: (BOOL) showSeatNumbers
{
    TableView *view = [[TableView alloc] init];
    view.autoresizingMask = (UIViewAutoresizing)-1;
    view.frame = frame;
    view.clipsToBounds = YES;
    view.table = tableInfo.table;
    view.orderInfo = tableInfo.orderInfo;
    Table *table = view.table;
    CGFloat minimumSize = frame.size.width / (table.seatsHorizontal+2) < frame.size.height / (table.seatsVertical+2) ? frame.size.width / (table.seatsHorizontal+2) : frame.size.height / (table.seatsVertical+2);
    if (minimumSize > 50)
        minimumSize = 50;
    CGSize seatViewSize = CGSizeMake(minimumSize, minimumSize);

    CGRect tableRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
  //  tableRect = CGRectInset(tableRect, 5, 5);
    if (table.seatsVertical > 0)
        tableRect = CGRectInset(tableRect, seatViewSize.width, 0);
    if (table.seatsHorizontal > 0)
        tableRect = CGRectInset(tableRect, 0, seatViewSize.width);

    view.tableView = [[TableViewContainer alloc] initWithFrame:tableRect];
    view.tableView.autoresizingMask = (UIViewAutoresizing) -1;
    [view addSubview:view.tableView];

    CGFloat x = tableRect.origin.x;
    CGFloat width = tableRect.size.width / table.seatsHorizontal;
    for(int i=0; i < table.seatsHorizontal; i++) {
        SeatView *seatView = [SeatView viewWithFrame:CGRectMake(x + i * width, tableRect.origin.y - seatViewSize.height, width, seatViewSize.height) offset:i atSide:TableSideTop showSeatNumber: showSeatNumbers];
        [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
        [seatView initByGuest: [tableInfo.orderInfo getGuestBySeat:seatView.offset]];
        [view addSubview:seatView];

        seatView = [SeatView viewWithFrame:CGRectMake(tableRect.origin.x + tableRect.size.width - (i+1)*width, tableRect.origin.y + tableRect.size.height, width, seatViewSize.height) offset:i + table.seatsHorizontal + table.seatsVertical atSide:TableSideBottom showSeatNumber: showSeatNumbers];
        [view addSubview:seatView];
        [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
        [seatView initByGuest: [tableInfo.orderInfo getGuestBySeat: seatView.offset]];
    }
    
    CGFloat height = (tableRect.size.height) / table.seatsVertical;
    for(int i=0; i < table.seatsVertical; i++) {
        SeatView *seatView = [SeatView viewWithFrame: CGRectMake(tableRect.origin.x + tableRect.size.width, tableRect.origin.y + i * height, seatViewSize.width, height) offset:i + table.seatsHorizontal atSide:TableSideRight showSeatNumber: showSeatNumbers];
        [view addSubview:seatView];
        [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
        [seatView initByGuest: [tableInfo.orderInfo getGuestBySeat: seatView.offset]];

        seatView = [SeatView viewWithFrame:CGRectMake(tableRect.origin.x - seatViewSize.width, tableRect.origin.y + tableRect.size.height - (i+1) * height, seatViewSize.width, height) offset:i + table.seatsHorizontal + table.seatsVertical + table.seatsHorizontal atSide:TableSideLeft showSeatNumber: showSeatNumbers];
        [view addSubview:seatView];
        [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
        [seatView initByGuest: [tableInfo.orderInfo getGuestBySeat: seatView.offset]];
    }

    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(tapper:)];
    tapper.delegate = view;
    [view.tableView addGestureRecognizer:tapper];

    return view;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if([self.delegate respondsToSelector:@selector(didTapTableView:)])
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
    if (canSelect)
        self.isTableSelected = YES;
}

- (void)setIsTableSelected: (BOOL)selected
{
    _isTableSelected = selected;
    CALayer *layer = [tableView.layer.sublayers objectAtIndex:0];
    if (selected) {
        self.selectedGuests = nil;
        layer.borderColor = [[UIColor whiteColor] CGColor];
    }
    else {
        layer.borderColor = [[UIColor grayColor] CGColor];
    }
}

- (CGRect) rectInTableForSeat: (NSUInteger)seat
{
    SeatView *seatView = [self seatViewAtOffset:seat];
    if (seatView == nil) return CGRectZero;
    CGRect frame = CGRectOffset(seatView.frame, -tableView.frame.origin.x, -tableView.frame.origin.y);
    CGFloat maxWidth = 120;
    CGFloat maxHeight = 44;
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
    if(table.seatsHorizontal == 0)
        return 0;
    CGRect rect = [self rectInTableForSeat:0];
    return rect.size.height;
}

- (CGFloat) requiredHorizontalMargin
{
    if(table.seatsVertical == 0)
        return 0;
    CGRect rect = [self rectInTableForSeat: table.seatsHorizontal];
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

- (NSMutableArray *) selectedGuests
{
    NSMutableArray *seats = [[NSMutableArray alloc] init];
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[SeatView class]]) {
            SeatView *seatView = (SeatView *) view;
            if (seatView.isSelected)
                [seats addObject:[orderInfo getGuestBySeat:seatView.offset]];
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
    [UIView transitionFromView:_contentTableView
                        toView:contentView
                      duration:1
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    completion:^(BOOL completion)
                    {
                        [self.tableView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                        [self.tableView addSubview: contentView];
                        _contentTableView = contentView;
                        [self setNeedsDisplay];

                    }];
}

@end