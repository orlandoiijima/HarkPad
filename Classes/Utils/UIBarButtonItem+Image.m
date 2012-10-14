//
// Created by wbison on 14-10-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIBarButtonItem+Image.h"


@implementation UIBarButtonItem (Image)

+ (UIBarButtonItem *) buttonWithImage:(UIImage *)image target:(id)target action:(SEL) action {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchDown];
    [button setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView: button];
    return barButton;
}

@end