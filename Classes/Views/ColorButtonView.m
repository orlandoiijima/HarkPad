//
// Created by wbison on 21-10-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ColorButtonView.h"
#import "UIColor-Expanded.h"

@implementation ColorButtonView {
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];
    self.layer.cornerRadius = 7;
    return self;
}

- (void)tap {
    ColorViewController *controller = [[ColorViewController alloc] init];
    controller.delegate = self;
    _popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    [_popover presentPopoverFromRect: self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)colorPopoverControllerDidSelectColor:(NSString *)hexColor {
    UIColor *color = [UIColor colorWithHexString:hexColor];
    self.backgroundColor = color;
    [_popover dismissPopoverAnimated:YES];
    [_delegate colorPopoverControllerDidSelectColor: hexColor];
}

@end