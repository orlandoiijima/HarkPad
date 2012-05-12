//
//  Created by wbison on 26-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SeatGridView.h"


@implementation SeatGridView

@synthesize countSeats, guests, alignment;

+ (SeatGridView *)viewWithFrame: (CGRect) frame table: (Table *)table guests: (NSMutableArray *)guests {
    SeatGridView *view = [[SeatGridView alloc] initWithFrame:frame];
    view.alignment = UITextAlignmentCenter;
    view.countSeats = table.countSeatsPerSide;
    view.guests = guests;
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void) setGuests: (NSMutableArray *)newGuests {
    guests = newGuests;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {

    rect = CGRectInset(rect, 10, 10);
    UIColor *strokeColor = [UIColor blackColor];
    [strokeColor setStroke];

    int maxCountSeatsHorizontal = MAX([[countSeats objectAtIndex: TableSideTop] intValue], [[countSeats objectAtIndex: TableSideBottom] intValue]);
    int maxCountSeatsVertical = MAX([[countSeats objectAtIndex: TableSideRight] intValue], [[countSeats objectAtIndex: TableSideLeft] intValue]);
    CGFloat width = maxCountSeatsHorizontal;
    CGFloat height = maxCountSeatsVertical;
    if (maxCountSeatsVertical > 0)
        width += 2;
    if (maxCountSeatsHorizontal > 0)
        height += 2;

    CGFloat size = MAX(width, height);
    CGFloat dx = MIN(7, (self.bounds.size.height - 2 * 5) / size);
    CGFloat dy = dx;
    CGFloat x,y;

    switch (alignment) {
        case UITextAlignmentLeft:
            x = 0.5;
        break;

        case UITextAlignmentCenter:
            x = (self.bounds.size.width - dx*width)/2 + 0.5;
        break;

        case UITextAlignmentRight:
            x = self.bounds.size.width - dx*width - 0.5;
        break;
    }
    y = (self.bounds.size.height - dy*height)/2 + 0.5;
    if ([[countSeats objectAtIndex: TableSideLeft] intValue] > 0)
        x += dx;
    int seat = 0;
    for (int i =0; i < [[countSeats objectAtIndex: TableSideTop] intValue]; i++) {
        [self drawStrokedRect:CGRectMake(x + i*dx, y, dx, dy) fillColor: [self fillColorForSeat: seat+i]];
    }
    seat = [[countSeats objectAtIndex:TableSideTop] intValue] + [[countSeats objectAtIndex: TableSideRight] intValue] + [[countSeats objectAtIndex: TableSideBottom] intValue];
    for (int i =0; i < [[countSeats objectAtIndex: TableSideBottom] intValue]; i++) {
        [self drawStrokedRect:CGRectMake(x + i*dx, y + dy *maxCountSeatsVertical + dy, dx, dy) fillColor: [self fillColorForSeat: seat - i - 1]];
    }

    x = (self.bounds.size.width - dx*width)/2 + 0.5;
    y = (self.bounds.size.height - dy*height)/2 + 0.5;
    if ([[countSeats objectAtIndex: TableSideTop] intValue] > 0)
        y += dy;
    seat = [[countSeats objectAtIndex: TableSideTop] intValue];
    for (int i =0; i < [[countSeats objectAtIndex: TableSideRight] intValue]; i++) {
        [self drawStrokedRect:CGRectMake(x + dx * maxCountSeatsHorizontal + dx, y + i*dy, dx, dy) fillColor: [self fillColorForSeat: seat + i]];
    }
    seat = [[countSeats objectAtIndex: TableSideTop] intValue] + [[countSeats objectAtIndex: TableSideRight] intValue] + [[countSeats objectAtIndex: TableSideBottom] intValue] + [[countSeats objectAtIndex: TableSideLeft] intValue];
    for (int i =0; i < [[countSeats objectAtIndex: TableSideLeft] intValue]; i++) {
        [self drawStrokedRect:CGRectMake(x, y + i*dy, dx, dy) fillColor: [self fillColorForSeat: seat - i - 1]];
    }
}

- (UIColor *) fillColorForSeat: (int)seat
{
    for(Guest *guest in guests) {
        if (guest.seat == seat) {
            return (guest.guestType == guestMale ?
                [UIColor colorWithRed:135/255.0 green: 206/255.0 blue: 206/250.0 alpha:1] :
                [UIColor colorWithRed:1 green:182/255.0 blue:193/255.0 alpha:1]);

        }
    }
    return [UIColor whiteColor];
}

- (void) drawStrokedRect: (CGRect)rect fillColor: (UIColor *) fillColor
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    path.lineWidth = 1;
    [path stroke];
    [fillColor setFill];
    [path fill];
}

@end