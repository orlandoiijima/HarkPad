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
@synthesize imageSize = _imageSize;

+ (TableActionButton *) buttonWithFrame: (CGRect) frame imageName: (NSString *)imageName  imageSize:(CGSize)imageSize caption:(NSString *)caption description: (NSString *) description delegate:(id<NSObject>) delegate action: (SEL)action {
    TableActionButton *button = [[TableActionButton alloc] initWithFrame:frame];
    button.imageSize = imageSize;
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
    button.labelDescription.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    button.labelDescription.font = [UIFont fontWithName:@"Helvetica-Oblique" size:14];
    button.labelDescription.backgroundColor = [UIColor clearColor];
    button.labelDescription.numberOfLines = 0;
    button.labelDescription.lineBreakMode = UILineBreakModeWordWrap;
    button.labelDescription.textAlignment = UITextAlignmentLeft;
    [button addSubview: button.labelDescription];

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

- (void)layoutSubviews {
    CGRect frame = CGRectInset(self.bounds, 10, 10);
    if (frame.size.width > frame.size.height) {
        self.imageCommand.frame = CGRectMake(frame.origin.x, frame.origin.y, self.imageSize.width, self.imageSize.height);
        frame = CGRectMake(frame.origin.x + self.imageSize.width + 10, frame.origin.y, frame.size.width - self.imageSize.width - 10, frame.size.height);
        CGFloat y = frame.origin.y;
        if ([self.labelCommand.text length] > 0) {
            self.labelCommand.textAlignment = UITextAlignmentLeft;
            self.labelCommand.frame = CGRectMake(frame.origin.x, y, frame.size.width, 20);
            y += 30;
        }
        self.labelDescription.frame = CGRectMake(frame.origin.x, y, frame.size.width, 0);
        self.labelDescription.textAlignment = UITextAlignmentLeft;

    }
    else {
        self.imageCommand.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, self.imageSize.height);
        CGFloat y = self.imageSize.height + 10;
        if ([self.labelCommand.text length] > 0) {
            self.labelCommand.frame = CGRectMake(frame.origin.x, y, frame.size.width, 20);
            self.labelCommand.textAlignment = UITextAlignmentCenter;
            y += 30;
        }
        self.labelDescription.textAlignment = UITextAlignmentCenter;
        self.labelDescription.frame = CGRectMake(frame.origin.x, y, frame.size.width, 0);
    }
    [self setCommandDescription:self.labelDescription.text];

    CAGradientLayer *layer = [self.layer.sublayers objectAtIndex:0];
    layer.frame = self.bounds;
}

- (void)setEnabled:(BOOL)anEnabled {
    [super setEnabled:anEnabled];
    self.imageCommand.alpha = anEnabled ? 1 : 0.3;
    self.labelCommand.alpha = anEnabled ? 1 : 0.3;
    self.labelDescription.alpha = anEnabled ? 1 : 0.3;
}

- (void) setCommandDescription:(NSString *)text {
    self.labelDescription.text = text;
    CGSize size = [self.labelDescription.text sizeWithFont:self.labelDescription.font constrainedToSize:CGSizeMake(self.labelDescription.frame.size.width, self.frame.size.height - self.labelDescription.frame.origin.y - 10) lineBreakMode:UILineBreakModeWordWrap];
    self.labelDescription.frame = CGRectMake(self.labelDescription.frame.origin.x, self.labelDescription.frame.origin.y, self.labelDescription.frame.size.width, size.height);
}

@end