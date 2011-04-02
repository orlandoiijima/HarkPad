//
//  HostController.h
//  HarkPad
//
//  Created by Willem Bison on 02-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol HostController <NSObject>

- (void) closePopup: (bool) cancelled;
@property (retain) UIPopoverController *popover;

@end
