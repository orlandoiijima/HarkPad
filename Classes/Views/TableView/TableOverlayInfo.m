//
//  Created by wbison on 10-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <CoreGraphics/CoreGraphics.h>
#import "TableOverlayInfo.h"
#import "NSDate-Utilities.h"


@implementation TableOverlayInfo

@synthesize scrollView;
@dynamic order;

- (id)initWithFrame: (CGRect) frame order: (Order *)order
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectInset(self.bounds, 10, 10)];
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)setOrder:(Order *)anOrder {
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (anOrder == nil) return;
    NSMutableArray *captionValueLabels = [[NSMutableArray alloc] init];
    if(anOrder.reservation != nil) {
        if ([anOrder.reservation.name length] > 0)
            [captionValueLabels addObject:[NSArray arrayWithObjects:anOrder.reservation.name,NSLocalizedString(@"Reservation", nil), nil]];
        if ([anOrder.reservation.notes length] > 0)
            [captionValueLabels addObject: [NSArray arrayWithObjects:anOrder.reservation.name, NSLocalizedString(@"Notes", nil), nil]];
    }
    if (anOrder.createdOn != nil) {
        NSString *val = [anOrder.createdOn dateDiff];
        [captionValueLabels addObject: [NSArray arrayWithObjects:val, NSLocalizedString(@"Started", nil), nil]];
    }
    if (anOrder.currentCourse != nil) {
        NSString *val = anOrder.currentCourse.stringForCourse;
        [captionValueLabels addObject: [NSArray arrayWithObjects:val, NSLocalizedString(@"Current course", nil), nil]];
        if (anOrder.currentCourse.servedOn != nil) {
            NSString *val = [anOrder.currentCourse.servedOn dateDiff];
            [captionValueLabels addObject: [NSArray arrayWithObjects:val, NSLocalizedString(@"Served", nil), nil]];
        }
    }
    if (anOrder.nextCourseToServe != nil) {
        NSString *val = anOrder.nextCourseToServe.stringForCourse;
        [captionValueLabels addObject: [NSArray arrayWithObjects:val, NSLocalizedString(@"Next course", nil), nil]];
        if (anOrder.nextCourseToServe.requestedOn != nil) {
            NSString *val = [anOrder.nextCourseToServe.requestedOn dateDiff];
            [captionValueLabels addObject: [NSArray arrayWithObjects:val, NSLocalizedString(@"Requested", nil), nil]];
        }
    }
    [captionValueLabels addObject: [NSArray arrayWithObjects: [Utils getAmountString:anOrder.totalAmount withCurrency:YES], NSLocalizedString(@"Amount", nil), nil]];
    [self addCaptionValueLabels:captionValueLabels];
}

- (void)addCaptionValueLabels: (NSMutableArray *)captionValueLabels
{
    CGFloat y = 0;
    for(NSArray *strings in captionValueLabels) {
        NSString *caption = [strings objectAtIndex:1];
        NSString *value = [strings objectAtIndex:0];
        UILabel *captionLabel = [[UILabel alloc] init];
        [self.scrollView addSubview:captionLabel];
        captionLabel.font = [UIFont systemFontOfSize:14];
        captionLabel.backgroundColor = [UIColor clearColor];
        captionLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
        captionLabel.textAlignment = UITextAlignmentCenter;
        captionLabel.text = caption;
        CGSize size = [caption sizeWithFont:captionLabel.font forWidth:scrollView.bounds.size.width lineBreakMode:UILineBreakModeWordWrap];
        captionLabel.frame = CGRectMake(0, y, scrollView.bounds.size.width, size.height);
        y += size.height + 4;
        
        UILabel *valueLabel = [[UILabel alloc] init];
        [self.scrollView addSubview:valueLabel];
        valueLabel.font = [UIFont systemFontOfSize:17];
        valueLabel.backgroundColor = [UIColor clearColor];
        valueLabel.textColor = [UIColor blackColor];
        valueLabel.textAlignment = UITextAlignmentCenter;
        valueLabel.text = value;
        size = [value sizeWithFont:valueLabel.font forWidth:scrollView.bounds.size.width lineBreakMode:UILineBreakModeWordWrap];
        valueLabel.frame = CGRectMake(0, y, scrollView.bounds.size.width, size.height);
        y += size.height + 7;
    }
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, y);
}

@end