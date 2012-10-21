//
// Created by wbison on 21-10-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ColorViewController.h"


@interface ColorButtonView : UIButton <ColorViewControllerDelegate>
@property(nonatomic, strong) UIPopoverController *popover;
@property(nonatomic, strong) id<ColorViewControllerDelegate> delegate;
@end