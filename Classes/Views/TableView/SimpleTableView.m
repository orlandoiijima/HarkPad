//
//  Created by wbison on 27-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "SimpleTableView.h"


@implementation SimpleTableView {

}

@synthesize contentView = _contentView, toolBar = _toolBar;

+ (SimpleTableView *)viewWithFrame: (CGRect)frame content: aContentView
{
    SimpleTableView *view = [[SimpleTableView alloc] initWithFrame:frame];

    view.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, view.bounds.size.height - 44, view.bounds.size.width, 44)];
    view.toolBar.barStyle = UIBarStyleBlack;
    [view addSubview: view.toolBar];

    view.toolBar.items = [NSArray arrayWithObjects:
        [[UIBarButtonItem alloc] initWithTitle:@"Acties" style:UIBarButtonItemStyleBordered target:self action:nil],
        [[UIBarButtonItem alloc] initWithTitle:@"Bestellingen" style:UIBarButtonItemStyleBordered target:self action:nil],
        [[UIBarButtonItem alloc] initWithTitle:@"Gast" style:UIBarButtonItemStyleDone target:self action:nil],
        [[UIBarButtonItem alloc] initWithTitle:@"Reserveringen" style:UIBarButtonItemStyleBordered target:self action:nil],
        [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStyleBordered target:self action:nil],
        nil];
    view.contentView = aContentView;

    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.cornerRadius = 6;
    layer.frame = CGRectInset(view.bounds, 0, 0);
    layer.borderColor = [[UIColor grayColor] CGColor];
    layer.borderWidth = 3;
    layer.backgroundColor = [[UIColor clearColor] CGColor];
    layer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], nil];
    layer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.7], [NSNumber numberWithFloat:1.0], nil];
    [view.layer insertSublayer:layer atIndex:0];

    return view;
}

- (void)setContentView:(UIView *)aContentView {
    if (_contentView != nil)
        [_contentView removeFromSuperview];
    _contentView = aContentView;
    aContentView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 44);
    self.bounds;
    [self addSubview:aContentView];
}

@end