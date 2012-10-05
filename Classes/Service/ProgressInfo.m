//
// Created by wbison on 30-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ProgressInfo.h"
#import "MBProgressHUD.h"


@implementation ProgressInfo {

}
@synthesize parentView = _parentView;
@synthesize text = _text;
@synthesize indicatorView = _indicatorView;
@synthesize label = _label;


+ (ProgressInfo *) progressWithHudText: (NSString *) text parentView:(UIView *)parentView {
    ProgressInfo *info = [[ProgressInfo alloc] init];
    info.text = text;
    info.parentView = parentView;
    return info;
}

+ (ProgressInfo *) progressWithActivityText: (NSString *) text label:(UILabel *)label activityIndicatorView:(UIActivityIndicatorView *)indicatorView {
    ProgressInfo *info = [[ProgressInfo alloc] init];
    info.text = text;
    info.label = label;
    info.indicatorView = indicatorView;
    return info;
}

- (void)start {
    if (_indicatorView != nil) {
        [_indicatorView startAnimating];
        if(_text != nil && _label != nil)
            _label.text = _text;
    }
    else {
        [MBProgressHUD showProgressAddedTo: _parentView withText:NSLocalizedString(_text, nil)];
    }
}

- (void)stop {
    if (_indicatorView != nil) {
        [_indicatorView stopAnimating];
        if(_label != nil)
            _label.text = @"";
    }
    else {
        if (_parentView != nil)
            [MBProgressHUD hideHUDForView: _parentView animated:YES];
    }
}

@end