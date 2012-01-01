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
- (void)addItem;
- (id) itemAtIndexPath: (NSIndexPath *)indexPath;
- (NSIndexPath *) indexPathForItem: (id)object;
- (void)endEdit;
- (bool)validate;
- (void)commitChanges;
@optional
@end

@interface MaintenanceSplitViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MaintenanceViewDelegate>
{
    MaintenanceDetailsViewController *detailsViewController;
    MaintenanceListViewController *listViewController;
    id<MaintenanceViewDelegate> __unsafe_unretained  delegate;
    id<UITableViewDataSource> __unsafe_unretained  dataSource;
    id currentItem;
}

@property (retain) MaintenanceDetailsViewController *detailsViewController;
@property (retain) MaintenanceListViewController *listViewController;
@property (nonatomic, assign) id<MaintenanceViewDelegate> delegate;
@property (nonatomic, assign) id<UITableViewDataSource> dataSource;
@property (retain, nonatomic) id currentItem;

- (void)putValue: (id)value forKey: (NSString *)key;
- (id)getValueForKey: (NSString *)key;
- (bool)isDirty;
- (id)currentItem;
- (void)invalidateRowForItem: (id)object;
@end