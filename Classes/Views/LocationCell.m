//
// Created by wbison on 29-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import "LocationCell.h"


@implementation LocationCell {

}
@synthesize nameLabel = _nameLabel;
@synthesize logoImage = _logoImage;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 25)];
    self.logoImage.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.logoImage];

    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, frame.size.height - 20, frame.size.width - 10, 18)];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.nameLabel];

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.cornerRadius = 1;
    gradientLayer.frame = self.bounds;
    gradientLayer.borderColor = [[UIColor blackColor] CGColor];
    gradientLayer.borderWidth = 1;
    gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1] CGColor], nil];
    gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.0], nil];
    [self.layer insertSublayer:gradientLayer atIndex:0];

    return self;
}

- (void)setSelected:(BOOL)selected {
    CAGradientLayer *gradientLayer = [[self.layer sublayers] objectAtIndex:0];
    if (selected) {
        gradientLayer.borderColor =  [[UIColor blueColor] CGColor];
        gradientLayer.borderWidth = 3;
    }
    else{
        gradientLayer.borderColor =  [[UIColor blackColor] CGColor];
        gradientLayer.borderWidth = 1;
    }
}

@end