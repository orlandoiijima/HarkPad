//
//  Created by wbison on 16-10-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "MaintenanceSplitViewController.h"
#import "QRootElement.h"


@implementation MaintenanceSplitViewController

@synthesize delegate, detailsViewController, listViewController;

- (MaintenanceSplitViewController *) initWithDatasource: (id)dataSource
{
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //To change the template use AppCode | Preferences | File Templates.
    id item = [delegate itemAtIndexPath:indexPath];
    if (item != nil)
            [delegate fillDetailViewWithObject:item];
}

@end