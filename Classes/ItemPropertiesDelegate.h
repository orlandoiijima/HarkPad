//
//  Created by wbison on 15-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


@protocol ItemPropertiesDelegate <NSObject>
@required
- (void) didSaveItem: (id)item;
- (void) didCancelItem: (id)item;
- (void) didModifyItem: (id)item;
@end