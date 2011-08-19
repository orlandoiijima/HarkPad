//
//  Created by wbison on 18-08-11.
//
//  To change this template use File | Settings | File Templates.
//


@protocol PopupHost <NSObject>

@required

- (void) closePopup;
- (void) cancelPopup;

@end