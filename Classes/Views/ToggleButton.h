//
//  Created by wbison on 13-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface ToggleButton : UIButton

@property (nonatomic) BOOL isOn;
@property (retain) UIImageView *imageView;

+ (ToggleButton *)buttonWithTitle: (NSString *)title image: (UIImage *)image frame: (CGRect) frame;
+ (ToggleButton *)buttonWithTitle: (NSString *)title frame: (CGRect) frame;
- (void) tap;


@end