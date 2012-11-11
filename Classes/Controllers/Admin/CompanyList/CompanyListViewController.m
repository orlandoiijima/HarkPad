//
// Created by wbison on 10-11-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CompanyListViewController.h"
#import "Service.h"
#import "Company.h"
#import "CompanyCell.h"

@implementation CompanyListViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[Service getInstance] requestResource:@"company"
                                        id:nil action:nil arguments:nil body:nil verb:HttpVerbGet
                                   success:^(ServiceResult *serviceResult) {
                                       self.companies = [[NSMutableArray alloc] init];
                                       for (NSMutableDictionary *dictionary in serviceResult.jsonData) {
                                           Company *company = [[Company alloc] initWithDictionary:dictionary];
                                           [self.companies addObject:company];
                                       }
                                       [_companyView reloadData];
                                   }
                                     error:^(ServiceResult *serviceResult) {
                                         [serviceResult displayError];
                                     }
                              progressInfo:[ProgressInfo progressWithHudText:NSLocalizedString(@"Loading...", nil) parentView:self.view]];
}


- (Company *)companyAtIndexPath:(NSIndexPath *)path {
    if (_companies == nil || path.row >= _companies.count)
        return nil;
    return [_companies objectAtIndex:path.row];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"xjsjw";

    CompanyCell *cell = (CompanyCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.company = [self companyAtIndexPath:indexPath];
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_companies count] + 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


@end