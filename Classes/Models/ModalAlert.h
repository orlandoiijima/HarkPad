/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface ModalAlert : NSObject
+(NSUInteger) queryWithTitle:(NSString *)title message: (NSString *)message button1: (NSString *)button1 button2: (NSString *)button2;
+ (BOOL) ask: (NSString *) question;
+ (BOOL) confirm:(NSString *) statement;
+ (BOOL) inform:(NSString *) statement;
@end
