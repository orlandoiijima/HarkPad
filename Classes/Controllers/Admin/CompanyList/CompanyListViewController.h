//
// Created by wbison on 10-11-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface CompanyListViewController : UIViewController <UICollectionViewDataSource>


@property (retain) IBOutlet UICollectionView *companyView;

@property(nonatomic, strong) NSMutableArray *companies;
@end