//
//  MenuCardCell.m
//  HarkPad
//
//  Created by Willem Bison on 10/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MenuCardCell.h"

@implementation MenuCardCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.clipsToBounds = YES;
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.cornerRadius = 6;
    gradientLayer.frame = self.bounds;
    gradientLayer.borderColor = [[UIColor lightGrayColor] CGColor];
    gradientLayer.borderWidth = 2;
    gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], nil];
    gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.4], [NSNumber numberWithFloat:1.0], nil];
    [self.layer insertSublayer:gradientLayer atIndex:0];
    return self;
}

- (void) setMenuCard:(MenuCard *) menuCard {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    _dateLabel.text = [dateFormatter stringFromDate: menuCard.validFrom];
    _countMenusLabel.text = [NSString stringWithFormat: @"%d", [menuCard.menus count]];
    int count = 0;
    for (ProductCategory *category in menuCard.categories) {
        count += [category.products count];
    }
    _countItemsLabel.text = [NSString stringWithFormat:@"%d", count];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CAGradientLayer *layer = [self.layer.sublayers objectAtIndex:0];
    layer.frame = self.bounds;
}
@end