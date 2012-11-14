//
//  CompanyCell.m
//  HarkPad
//
//  Created by Willem Bison on 11/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CompanyCell.h"

@implementation CompanyCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 2;
    self.layer.borderColor = [[UIColor grayColor] CGColor];
    self.layer.borderWidth = 3;
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CAGradientLayer *layer = [self.layer.sublayers objectAtIndex:0];
    layer.frame = self.bounds;
}

- (void)setCompany: (Company *) aCompany {
    if (aCompany == nil) {
        _addView.hidden = NO;
        _containerView.hidden = YES;
    }
    else {
        _addView.hidden = YES;
        _containerView.hidden = NO;
        _nameLabel.text = aCompany.name;
        _cityLabel.text = aCompany.address.city;
        _logoView.image = aCompany.logo;
    }
}

@end
