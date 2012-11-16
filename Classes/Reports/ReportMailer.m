//
// Created by wbison on 27-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MessageUI/MessageUI.h>
#import "ReportMailer.h"
#import "NSDate-Utilities.h"
#import "AppVault.h"


@implementation ReportMailer {

}
@synthesize name = _name;
@synthesize data = _data;
@synthesize viewController = _viewController;
@synthesize fromDate = _fromDate;
@synthesize toDate = _toDate;


+ (ReportMailer *)mailerWithData: (NSData *)data name:(NSString *)name fromDate:(NSDate *)from toDate:(NSDate *)to viewController:(UIViewController *)viewController {
    ReportMailer *mailer = [[ReportMailer alloc] init];
    mailer.data = data;
    mailer.name = name;
    mailer.fromDate = from;
    mailer.toDate = to;
    mailer.viewController = viewController;
    return mailer;
}

- (void) send {
    NSString *from = [_fromDate inJson];
    NSString *to = [_toDate inJson];
    NSString *range = [from isEqualToString:to] ? from : [NSString stringWithFormat:@"%@ - %@", from, to];
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", _name, range];
    NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [arrayPaths objectAtIndex:0];
    NSString *fileName = [fullName stringByAppendingString:@".csv"];
    NSString *path = [docDir stringByAppendingFormat:@"/%@", fileName];
    [_data writeToFile:path atomically:YES];

    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;

    [controller setSubject: fullName];
    [controller addAttachmentData:_data mimeType:@"text/csv" fileName: fileName];
    [self.viewController presentViewController:controller animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end