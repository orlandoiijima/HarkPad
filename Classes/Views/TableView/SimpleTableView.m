//
//  Created by wbison on 27-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SimpleTableView.h"


@implementation SimpleTableView {

}

@synthesize contentView = _contentView;

- (void)setContentView:(UIView *)aContentView {
    if (_contentView != nil)
        [_contentView removeFromSuperview];
    _contentView = aContentView;
    aContentView.frame = self.bounds;
    [self addSubview:aContentView];
}

@end