//
// Created by wbison on 14-10-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@interface UIBarButtonItem (Image)

+ (UIBarButtonItem *)withImage:(UIImage *)image target:(id)target action:(SEL)action;

+ (UIBarButtonItem *)buttonWithImage:(UIImage *)image target:(id)target action:(SEL)action;

@end