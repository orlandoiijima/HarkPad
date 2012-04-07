//
//  Created by wbison on 07-04-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface TableActionButton : UIButton
@property(nonatomic, strong) UIImageView *imageCommand;
@property(nonatomic, strong) UILabel *labelCommand;
@property(nonatomic, strong) UILabel *labelDescription;

+ (TableActionButton *) buttonWithFrame: (CGRect) frame imageName: (NSString *)imageName  imageSize: (CGSize) imageSize caption:(NSString *)caption description: (NSString *) description delegate:(id<NSObject>) delegate action: (SEL)action;
- (void) setCommandDescription:(NSString *)text;

@end