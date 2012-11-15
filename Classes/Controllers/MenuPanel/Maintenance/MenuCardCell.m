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
    self.backgroundColor = [UIColor clearColor];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.cornerRadius = 0;
    gradientLayer.frame = self.bounds;
    gradientLayer.borderColor = [[UIColor lightGrayColor] CGColor];
    gradientLayer.borderWidth = 12;
    gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], nil];
    gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.4], [NSNumber numberWithFloat:1.0], nil];
    [self.layer insertSublayer:gradientLayer atIndex:0];
    return self;
}

- (void) setMenuCard:(MenuCard *) menuCard {
    if (menuCard.validFrom == nil) {
        [self setIsDummy:YES];
        _addLabel.text = NSLocalizedString(@"Tap to make new menucard", nil);
    }
    else {
        [self setIsDummy:NO];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        _dateLabel.text = [dateFormatter stringFromDate: menuCard.validFrom];
        int countMenus = 0;
        int countProducts = 0;
        for (ProductCategory *category in menuCard.categories) {
            for (Product *product in category.products) {
                if (product.isMenu)
                    countMenus++;
                else
                    countProducts++;
            }
        }
        _countMenusLabel.text = [NSString stringWithFormat: @"%d", countMenus];
        _countItemsLabel.text = [NSString stringWithFormat:@"%d", countProducts];
    }
}

- (void) setIsDummy:(BOOL)isDummy {
    if (isDummy) {
        _container.hidden = YES;
        _addImage.hidden = NO;
        _addLabel.hidden = NO;
    }
    else {
        _container.hidden = NO;
        _addImage.hidden = YES;
        _addLabel.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CAGradientLayer *layer = [self.layer.sublayers objectAtIndex:0];
    layer.frame = self.bounds;
}
@end