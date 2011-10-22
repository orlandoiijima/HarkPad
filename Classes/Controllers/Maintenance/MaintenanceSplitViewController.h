//
//  Created by wbison on 16-10-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "MaintenanceListViewController.h"
#import "MaintenanceDetailsViewController.h"

@class QRootElement;


@protocol MaintenanceViewDelegate <NSObject>
@required
- (void) fillDetailViewWithObject: (id) object;
- (QRootElement *) setupDetailView;
- (id) itemAtIndexPath: (NSIndexPath *)indexPath;
@optional
@end

@interface MaintenanceSplitViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    MaintenanceDetailsViewController *detailsViewController;
    MaintenanceListViewController *listViewController;
    id<MaintenanceViewDelegate> __unsafe_unretained  delegate;
}

@property (retain) MaintenanceDetailsViewController *detailsViewController;
@property (retain) MaintenanceListViewController *listViewController;
@property (nonatomic, assign) id<MaintenanceViewDelegate> delegate;

@end