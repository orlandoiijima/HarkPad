//
//  Created by wbison on 28-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Guest.h"
#import "ItemPropertiesDelegate.h"
#import "ToggleButton.h"

@interface GuestProperties : UIView

@property (retain) Guest *guest;
@property (retain) id<ItemPropertiesDelegate> delegate;
@property (retain) ToggleButton *viewMale;
@property (retain) ToggleButton *viewFemale;

+ (GuestProperties *)viewWithGuest: (Guest *)guest frame: (CGRect)frame;

@end