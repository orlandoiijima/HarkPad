//
// Created by wbison on 11-10-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import "ProductPanelCell.h"
#import "Product.h"


@implementation ProductPanelCell {

}
@synthesize nameLabel = _nameLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.nameLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.autoresizingMask = (UIViewAutoresizing) -1;
    [self addSubview:self.nameLabel];

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.cornerRadius = 1;
    gradientLayer.frame = self.bounds;
    gradientLayer.borderColor = [[UIColor blackColor] CGColor];
    gradientLayer.borderWidth = 2;
    gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:0.94] CGColor], nil];
    gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.3], [NSNumber numberWithFloat:1.0], nil];
    self.layer.mask = gradientLayer;


    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 2;

//    CAGradientLayer *l = [CAGradientLayer layer];
//    l.frame = self.bounds;
//    l.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
//    l.startPoint = CGPointMake(0.8f, 1.0f);
//    l.endPoint = CGPointMake(1.0f, 1.0f);
//    self.layer.mask = l;

    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.layer.borderColor = selected ? [[UIColor blueColor] CGColor] : [[UIColor blackColor] CGColor];
}

@end