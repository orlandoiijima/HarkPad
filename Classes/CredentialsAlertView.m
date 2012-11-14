//
// Created by wbison on 11-08-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CredentialsAlertView.h"


@implementation CredentialsAlertView {

@private

    void (^_afterDone)(Credentials *);

}
@synthesize afterDone = _afterDone;
@synthesize pincode = _pincode;


+ (CredentialsAlertView *) viewWithPincode:(NSString *)pin afterDone:(void (^)(Credentials *))afterDone {
    CredentialsAlertView *alertView = [[CredentialsAlertView alloc] init];
    alertView.pincode = pin;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Administrator"
                                                           message:@"Enter your email and password"
                                                          delegate:alertView
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"Done", nil];
    alertView.afterDone = afterDone;    
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    UITextField *nameField = [alert textFieldAtIndex:0];
    nameField.keyboardType = UIKeyboardTypeEmailAddress;
    nameField.placeholder = @"Email";
    [alert show];
    return alertView;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *email = [[alertView textFieldAtIndex:0] text];
        NSString *password = [[alertView textFieldAtIndex:1] text];
        _afterDone([Credentials credentialsWithEmail:email password:password pinCode:_pincode]);
    }
}

@end