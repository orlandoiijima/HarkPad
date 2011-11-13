//
//  Created by wbison on 13-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ToggleButton.h"

@implementation ToggleButton 

@synthesize isOn, ignoreGesture;

+ (ToggleButton *)buttonWithTitle: (NSString *)title frame: (CGRect) frame    {
    ToggleButton *sw = [[ToggleButton alloc] init];
    sw.frame = frame;
    [sw insertSegmentWithTitle:title atIndex:0 animated:NO];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:sw action:@selector(handleTapGesture:)];
    tapGesture.delegate = sw;
    [sw addGestureRecognizer:tapGesture];
    [sw addTarget:sw action:@selector(action:) forControlEvents:UIControlEventTouchDown];
    return sw;
}

- (void) action: (id)event {
    NSLog(@"action");
    ignoreGesture = YES;
    isOn = YES;
}

- (void) handleTapGesture: (UITapGestureRecognizer *)tapGestureRecognizer
{
    if (ignoreGesture) {
        ignoreGesture = NO;
        NSLog(@"ignore");
        return;
    }
    isOn = !isOn;
    self.selectedSegmentIndex = isOn ? 0:-1;
    if (isOn == false) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    NSLog(@"toggle");
}

@end