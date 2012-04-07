//
//  Created by wbison on 07-04-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "TableActionButton.h"


@implementation TableActionButton {

}
@synthesize imageCommand = _imageCommand;
@synthesize labelCommand = _labelCommand;
@synthesize labelDescription = _labelDescription;


+ (TableActionButton *) buttonWithFrame: (CGRect) frame imageName: (NSString *)imageName  imageSize:(CGSize)imageSize caption:(NSString *)caption description: (NSString *) description delegate:(id<NSObject>) delegate action: (SEL)action {
    TableActionButton *button = [[TableActionButton alloc] initWithFrame:frame];
    button.imageCommand = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    button.imageCommand.contentMode = UIViewContentModeCenter;
    [button addSubview: button.imageCommand];

    button.labelCommand = [[UILabel alloc] init];
    button.labelCommand.text = caption;
    button.labelCommand.backgroundColor = [UIColor clearColor];
    button.labelCommand.textAlignment = UITextAlignmentLeft;
    [button addSubview: button.labelCommand];

    button.labelDescription = [[UILabel alloc] init];
    button.labelDescription.text = description;
    button.labelDescription.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    button.labelDescription.font = [UIFont systemFontOfSize:14];
    button.labelDescription.backgroundColor = [UIColor clearColor];
    button.labelDescription.numberOfLines = 0;
    button.labelDescription.lineBreakMode = UILineBreakModeWordWrap;
    button.labelDescription.textAlignment = UITextAlignmentLeft;
    [button addSubview: button.labelDescription];

    frame = CGRectInset(button.bounds, 10, 10);
    if (frame.size.width > frame.size.height) {
        button.imageCommand.frame = CGRectMake(frame.origin.x, frame.origin.y, imageSize.width, imageSize.height);
        frame = CGRectMake(frame.origin.x + imageSize.width + 10, frame.origin.y, frame.size.width - imageSize.width - 10, frame.size.height);
        CGFloat y = frame.origin.y;
        if ([caption length] > 0) {
            button.labelCommand.frame = CGRectMake(frame.origin.x, y, frame.size.width, 20);
            y += 25;
        }
        button.labelDescription.frame = CGRectMake(frame.origin.x, y, frame.size.width, 0);
    }
    else {
        button.imageCommand.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, imageSize.height);
        CGFloat y = imageSize.height + 10;
        if ([caption length] > 0) {
            button.labelCommand.frame = CGRectMake(frame.origin.x, y, frame.size.width, 20);
            button.labelCommand.textAlignment = UITextAlignmentCenter;
            y += 25;
        }
        button.labelDescription.textAlignment = UITextAlignmentCenter;
        button.labelDescription.frame = CGRectMake(frame.origin.x, y, frame.size.width, 0);
    }
    [button setCommandDescription:description];

    [button addTarget:delegate action:action forControlEvents:UIControlEventTouchUpInside];

    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = button.bounds;
    layer.backgroundColor = [[UIColor colorWithWhite:0.9 alpha:1] CGColor];
    layer.borderColor = [[UIColor grayColor] CGColor];
    layer.borderWidth = 1;
    layer.cornerRadius = 5;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOffset = CGSizeMake(5, 5);
    layer.shadowOpacity = 0.4;
    layer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], nil];
    layer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.1], [NSNumber numberWithFloat:1.0], nil];

    [button.layer insertSublayer: layer atIndex:0];

    return button;
}

- (void)setEnabled:(BOOL)anEnabled {
    [super setEnabled:anEnabled];
    self.imageCommand.alpha = anEnabled ? 1 : 0.4;
    self.labelCommand.alpha = anEnabled ? 1 : 0.4;
    self.labelDescription.alpha = anEnabled ? 1 : 0.4;
}

- (void) setCommandDescription:(NSString *)text {
    self.labelDescription.text = text;
    CGSize size = [self.labelDescription.text sizeWithFont:self.labelDescription.font constrainedToSize:CGSizeMake(self.frame.size.width, 500) lineBreakMode:UILineBreakModeWordWrap];
    self.labelDescription.frame = CGRectMake(self.labelDescription.frame.origin.x, self.labelDescription.frame.origin.y, self.labelDescription.frame.size.width, size.height);
}

@end