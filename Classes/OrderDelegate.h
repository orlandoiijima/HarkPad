//
//  Created by wbison on 12-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//

@class OrderLine;

@protocol OrderDelegate <NSObject>
@optional
- (void) didSelectOrderLine: (OrderLine *)line;
- (void) updatedCell: (UITableViewCell *)cell;
@end
