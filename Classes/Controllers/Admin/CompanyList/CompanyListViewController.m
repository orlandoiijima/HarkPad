//
// Created by wbison on 10-11-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CompanyListViewController.h"
#import "Service.h"
#import "Company.h"
#import "CompanyCell.h"
#import "SelectItemDelegate.h"
#import "EditCompanyViewController.h"

@implementation CompanyListViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Companies", nil);

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    
    UINib *nib = [UINib nibWithNibName:@"CompanyCell" bundle:[NSBundle mainBundle]];
    [_companyView registerNib:nib forCellWithReuseIdentifier:@"clvc"];
}

- (void)done {
    if (_delegate == nil) return;
    NSIndexPath *selectedIndexPath = [[_companyView indexPathsForSelectedItems] objectAtIndex:0];
    [self.delegate didSelectItem: [self companyAtIndexPath:selectedIndexPath]];
}

- (Company *)companyAtIndexPath:(NSIndexPath *)path {
    if (_companies == nil || path.row >= _companies.count)
        return nil;
    return [_companies objectAtIndex:path.row];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"clvc";

    CompanyCell *cell = (CompanyCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.company = [self companyAtIndexPath:indexPath];
    return cell;
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Company *company = [self companyAtIndexPath:indexPath];
    if (company == nil) {
        company = [[Company alloc] init];
        company.name = NSLocalizedString(@"New company", nil);
        [self.navigationController pushViewController:[EditCompanyViewController controllerWithCompany:company delegate:self] animated:YES];
    }
    else {
        [self.delegate didSelectItem:company];
    }

}

- (void)didSaveItem:(id)item {
    [_companies addObject:item];
    [_companyView reloadData];
}

@end