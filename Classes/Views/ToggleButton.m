//
//  Created by wbison on 13-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ToggleButton.h"

@implementation ToggleButton 

@synthesize isOn = _isOn;

- (void) initView
{
    UIImage *normalImage = [[UIImage imageNamed:@"UISegmentButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [self setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

    UIImage *hiliteImage = [[UIImage imageNamed:@"UISegmentButtonHighlighted.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [self setBackgroundImage: hiliteImage forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];

    [self addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchDown];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self initView];
    return self;
}

+ (ToggleButton *)buttonWithTitle: (NSString *)title frame: (CGRect) frame    {
    ToggleButton *sw = [[ToggleButton alloc] init];
    sw.frame = frame;
    [sw setTitle:title forState:UIControlStateNormal];
    [sw initView];
    return sw;
}

- (void) tap
{
    self.isOn = !self.isOn;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) setIsOn: (BOOL)on
{
    self.selected = on;
    _isOn = on;
}

@end