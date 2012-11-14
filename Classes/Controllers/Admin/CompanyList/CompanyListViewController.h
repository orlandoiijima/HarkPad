//
// Created by wbison on 10-11-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "SelectItemDelegate.h"
#import "ItemPropertiesDelegate.h"

@interface CompanyListViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, ItemPropertiesDelegate>


@property (retain) IBOutlet UICollectionView *companyView;

@property(nonatomic, strong) NSMutableArray *companies;
@property(nonatomic, strong) id<SelectItemDelegate> delegate;
@end