//
//  Created by wbison on 26-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import "SeatGridView.h"
#import "Table.h"


@implementation SeatGridView {

}

@synthesize countHorizontal, countVertical, selectedOffset;

+ (SeatGridView *)viewWithFrame: (CGRect) frame countHorizontal: (int) countHorizontal countVertical: (int)countVertical selectedOffset: (int) selectedOffset {
    SeatGridView *view = [[SeatGridView alloc] initWithFrame:frame];
    view.countHorizontal = countHorizontal;
    view.countVertical = countVertical;
    view.selectedOffset = selectedOffset;
    view.backgroundColor = [UIColor clearColor];
    return view;
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
        [self drawStrokedRect:CGRectMake(x + i*dx, y, dx, dy) filled: i == selectedOffset];
        [self drawStrokedRect:CGRectMake(x + i*dx, y + dy *countVertical + dy, dx, dy) filled: 2*countHorizontal + countVertical - i - 1 == selectedOffset];
    }

    x = (self.bounds.size.width - dx*width)/2;
    y = (self.bounds.size.height - dy*height)/2;
    if (countHorizontal > 0)
        y += dy;
    for (int i =0; i < countVertical; i++) {
        [self drawStrokedRect:CGRectMake(x, y + i*dy, dx, dy) filled: countHorizontal + i == selectedOffset];
        [self drawStrokedRect:CGRectMake(x + dx * countHorizontal + dx, y + i*dy, dx, dy) filled: 2*countHorizontal + 2*countVertical - i - 1 == selectedOffset];
    }
}

- (void) drawStrokedRect: (CGRect)rect filled: (BOOL) isFilled
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    path.lineWidth = 1;
    [path stroke];
    UIColor *fillColor = isFilled ? [UIColor blackColor] : [UIColor whiteColor];
    [fillColor setFill];
    [path fill];
}

@end