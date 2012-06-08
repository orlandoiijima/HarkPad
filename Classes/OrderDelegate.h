//
//  Created by wbison on 12-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//

@class OrderLine;
@class Order;

@protocol OrderDelegate <NSObject>
@optional
- (void) didSelectOrderLine: (OrderLine *)line;
- (BOOL) canEditOrderLine: (OrderLine *)line;
- (void) didMoveOrderLine: (OrderLine *)line toOrderLine: (OrderLine *)toLine toIndexPath: (NSIndexPath *)destinationIndexPath;
- (void) updatedCell: (UITableViewCell *)cell;
- (void) didSelectSection: (NSUInteger)section;
- (void) didExpandSection: (NSUInteger)section collapseAllOthers: (BOOL)collapseOthers;
- (void) didCollapseSection: (NSUInteger)section;
- (void) didUpdateOrder: (Order *)order;
@end
