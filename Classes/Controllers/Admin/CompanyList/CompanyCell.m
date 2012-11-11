//
//  CompanyCell.m
//  HarkPad
//
//  Created by Willem Bison on 11/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CompanyCell.h"
#import "Company.h"
#import "Address.h"

@implementation CompanyCell


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
