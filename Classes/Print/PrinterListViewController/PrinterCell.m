//
//  PrinterCell.m
//  HarkPad
//
//  Created by Willem Bison on 11/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PrinterCell.h"
#import "PrinterInfo.h"
#import "UIImage+Tint.h"

@implementation PrinterCell


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 2;
    self.layer.borderColor = [[UIColor grayColor] CGColor];
    self.layer.borderWidth = 3;
    return self;
}

- (void) setPrinter:(PrinterInfo *) printerInfo delegate:(id)delegate {
    _name.text = printerInfo.name;
    _ip.text = printerInfo.address;
    _name.delegate = delegate;
    self.isOnline = printerInfo.isOnline;
}

- (void)setIsOnline:(BOOL)isOnline {
    _status.text = isOnline ? @"Online" : @"Offline";
    _statusImage.image = isOnline ? [UIImage imageNamed:@"greendot.png"] : [UIImage imageNamed:@"reddotbig.png"];
    _printerImage.image = isOnline ? [UIImage imageNamed:@"185-printer@2x.png"] : [[UIImage imageNamed:@"185-printer@2x.png"] imageTintedWithColor:[UIColor grayColor]];
}


@end
