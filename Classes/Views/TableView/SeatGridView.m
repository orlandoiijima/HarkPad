//
//  Created by wbison on 26-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import "SeatGridView.h"
#import "Table.h"
#import "Guest.h"


@implementation SeatGridView

@synthesize countHorizontal, countVertical, guests;

+ (SeatGridView *)viewWithFrame: (CGRect) frame table: (Table *)table guests: (NSMutableArray *)guests {
    SeatGridView *view = [[SeatGridView alloc] initWithFrame:frame];
    view.countHorizontal = table.seatsHorizontal;
    view.countVertical = table.seatsVertical;
    view.guests = guests;
//    if (guest == nil) {
//        view.seatOffset = -1;
//        view.fillColor = [UIColor blackColor];
//    }
//    else {
//        view.seatOffset = guest.seat;
//        view.fillColor = (guest.isMale ? [UIColor  colorWithRed:135/255.0 green: 206/255.0 blue: 206/250.0 alpha:1] :
//                [UIColor colorWithRed:1 green:182/255.0 blue:193/255.0 alpha:1]);
//    }
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

    CGFloat width = countHorizontal;
    if (countVertical > 0)
        width += 2;
    CGFloat height = countVertical;
    if (countHorizontal > 0)
        height += 2;

    CGFloat size = MAX(width, height);
    CGFloat dx = MIN(7, (self.bounds.size.height - 2 * 5) / size);
    CGFloat dy = dx;
    CGFloat x,y;

    x = (self.bounds.size.width - dx*width)/2;
    y = (self.bounds.size.height - dy*height)/2;
    if (countVertical > 0)
        x += dx;
    for (int i =0; i < countHorizontal; i++) {
        [self drawStrokedRect:CGRectMake(x + i*dx, y, dx, dy) fillColor: [self fillColorForSeat:i]];
        [self drawStrokedRect:CGRectMake(x + i*dx, y + dy *countVertical + dy, dx, dy) fillColor: [self fillColorForSeat:2*countHorizontal + countVertical - i - 1]];
    }

    x = (self.bounds.size.width - dx*width)/2;
    y = (self.bounds.size.height - dy*height)/2;
    if (countHorizontal > 0)
        y += dy;
    for (int i =0; i < countVertical; i++) {
        [self drawStrokedRect:CGRectMake(x, y + i*dy, dx, dy) fillColor: [self fillColorForSeat:countHorizontal + i]];
        [self drawStrokedRect:CGRectMake(x + dx * countHorizontal + dx, y + i*dy, dx, dy) fillColor: [self fillColorForSeat:2*countHorizontal + 2*countVertical - i - 1]];
    }
}

- (UIColor *) fillColorForSeat: (int)seat
{
    for(Guest *guest in guests) {
        if (guest.seat == seat) {
            return (guest.isMale ?
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