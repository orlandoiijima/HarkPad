//
//  Created by wbison on 13-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface ToggleButton : UIButton

@property BOOL isOn;

+ (ToggleButton *)buttonWithTitle: (NSString *)title frame: (CGRect) frame;
- (void) setImage: (UIImage *)image;
- (void) tap;


@end