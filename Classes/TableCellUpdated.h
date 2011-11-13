//
//  Created by wbison on 12-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


@protocol TableCellUpdated <NSObject>
@optional
- (void) updatedCell: (UITableViewCell *)cell;
@end
