//
//  Created by wbison on 13-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ToggleButton.h"

@implementation ToggleButton 

@synthesize isOn;

- (void) setImage: (UIImage *)image
{
}

+ (ToggleButton *)buttonWithTitle: (NSString *)title frame: (CGRect) frame    {
    ToggleButton *sw = [[ToggleButton alloc] init];
    sw.frame = frame;
    [sw setTitle:title forState:UIControlStateNormal];
    [sw addTarget:sw action:@selector(tap) forControlEvents:UIControlEventTouchDown];
    return sw;
}

- (void) tap
{
    isOn = !isOn;
    if (isOn)
        self.backgroundColor = [UIColor blueColor];
    else
        self.backgroundColor = [UIColor clearColor];

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end