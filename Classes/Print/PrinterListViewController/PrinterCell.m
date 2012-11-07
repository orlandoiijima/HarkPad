//
//  PrinterCell.m
//  HarkPad
//
//  Created by Willem Bison on 11/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PrinterCell.h"
#import "PrinterInfo.h"

@implementation PrinterCell


- (void) setPrinter:(PrinterInfo *) printerInfo delegate:(id)delegate {
    _name.text = printerInfo.name;
    _ip.text = printerInfo.address;
    _status.text = @"";
    _name.delegate = delegate;
}

@end
