//
//  Created by wbison on 13-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface ToggleButton : UIButton

@property (nonatomic) BOOL isOn;

+ (ToggleButton *)buttonWithTitle: (NSString *)title frame: (CGRect) frame;
- (void) tap;


@end