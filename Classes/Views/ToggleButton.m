//
//  Created by wbison on 13-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import "ToggleButton.h"

@implementation ToggleButton 

@synthesize isOn = _isOn, imageView;

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

+ (ToggleButton *)buttonWithTitle: (NSString *)title image: (UIImage *)image frame: (CGRect) frame {
    ToggleButton *button = [[ToggleButton alloc] init];
    if (frame.size.width == 0) {
        CGSize size = [title sizeWithFont: [UIFont boldSystemFontOfSize:18]];
        if (image != nil)
            size.width += 18;
        button.frame = CGRectMake(frame.origin.x, frame.origin.y, size.width + 20, size.height+10);
    } 
    else
        button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button initView];

    if (image != nil) {
        button.imageView = [[UIImageView alloc] initWithImage:image];
        button.imageView.frame = CGRectMake(6, (button.bounds.size.height - 16)/2, 16, 16);
        [button addSubview: button.imageView];
        button.titleEdgeInsets = UIEdgeInsetsMake(
                button.titleEdgeInsets.top,
                button.titleEdgeInsets.left + 18,
                button.titleEdgeInsets.bottom,
                button.titleEdgeInsets.right);
    }
    return button;
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    if (self.imageView == nil) return;
//    self.titleLabel.frame = CGRectMake(self.tit, <#(CGFloat)y#>, <#(CGFloat)width#>, <#(CGFloat)height#>), 18, 0);
//    r = CGRectOffset(r, 18, 0);
//    button.titleLabel.frame = r;
//}

+ (ToggleButton *)buttonWithTitle: (NSString *)title frame: (CGRect) frame {
    return [ToggleButton buttonWithTitle:title image:nil frame:frame];
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