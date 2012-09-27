//
// Created by wbison on 27-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>


@interface ReportMailer : NSObject <MFMailComposeViewControllerDelegate>
@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong) NSData *data;
@property(nonatomic, strong) UIViewController *viewController;

@property(nonatomic, strong) NSDate *fromDate;

@property(nonatomic, strong) NSDate *toDate;

+ (ReportMailer *)mailerWithData: (NSData *)data name:(NSString *)name fromDate:(NSDate *)from toDate:(NSDate *)to viewController:(UIViewController *)viewController;
- (void)send;


@end