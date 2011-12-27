//
//  Created by wbison on 13-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface ToggleButton : UISegmentedControl

@property BOOL isOn;
@property BOOL ignoreGesture;

+ (ToggleButton *)buttonWithTitle: (NSString *)title frame: (CGRect) frame;
- (void)initButton;
- (void) setImage: (UIImage *)image;


@end