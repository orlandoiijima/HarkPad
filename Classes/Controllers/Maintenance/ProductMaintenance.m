//
//  Created by wbison on 18-10-11.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "ProductMaintenance.h"
#import "QRootElement.h"
#import "QSection.h"
#import "QEntryElement.h"
#import "QDecimalElement.h"
#import "QBooleanElement.h"
#import "Cache.h"
#import "OrderLineProperty.h"
#import "Utils.h"
#import "MaintenanceSplitViewController.h"
#import "Service.h"

@implementation ProductMaintenance

- (void)fillDetailViewWithObject:(id)object {
    Product *product = (Product *)object;
    NSLog(@"fill %@ %@", product.key, product.name);
    [self putValue:product.name forKey:@"name"];
    [self putValue:product.key forKey:@"key"];
    [self putValue: [NSNumber numberWithFloat: [product.price floatValue]] forKey:@"price"];
//    [self putValue: [NSNumber numberWithBool: product.vat == 1] forKey:@"vat"];
    for (OrderLineProperty*productProperty in [[Cache getInstance] productProperties]) {
        NSString *key = [NSString stringWithFormat:@"prop%d", productProperty.id];
        [self putValue: [NSNumber numberWithBool: [product hasProperty:productProperty.id]] forKey: key];
    }
    [self putValue: [NSNumber numberWithBool: product.isDeleted] forKey:@"isDeleted"];
    [detailsViewController.tableView reloadData];
}

- (void)addItem
{
    int currentSection = 0;
    Product *currentProduct = [self currentItem];
    if (currentProduct != nil)
        currentSection = [self sectionForCategory:currentProduct.category];
    ProductCategory *currentCategory = [self categoryForSection:currentSection];
    if (currentCategory == nil)
        return;

    Product *product = [[Product alloc] init];
    product.entityState = EntityStateNew;
    product.name = NSLocalizedString(@"New", nil);
    product.key = NSLocalizedString(@"New", nil);

    product.category = currentCategory;
    [product.category.products insertObject:product atIndex:0];

    UITableView *tableView = listViewController.tableView;
    [tableView beginUpdates];
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:(NSUInteger) 0 inSection:(NSUInteger) currentSection];
    [insertIndexPaths addObject: insertIndexPath];
    [tableView insertRowsAtIndexPaths: insertIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    [tableView endUpdates];

    [tableView selectRowAtIndexPath:insertIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self fillDetailViewWithObject:product];
}

- (ProductMaintenance *) init
{
    self = [super init];
    if(self) {
        delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (QRootElement *)setupDetailView {
    QRootElement *form = [[QRootElement alloc] init];
    form.grouped = YES;
    QSection *section = [[QSection alloc] init];
    [form addSection: section];
    
    QEntryElement *name = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Name", nil) Value:@"Name" Placeholder:NSLocalizedString(@"Bon, rekening", nil)];
    name.key = @"name";
    [section addElement:name];

    QEntryElement *key = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Code", nil) Value:@"" Placeholder:NSLocalizedString(@"Bestelpanel", nil)];
    key.key = @"key";
    [section addElement:key];

    QDecimalElement *price = [[QDecimalElement alloc] initWithTitle:NSLocalizedString(@"Price", nil) value:0.0];
    price.fractionDigits = 2;
    price.key = @"price";
    [section addElement:price];

	QBooleanElement *vat = [[QBooleanElement alloc] initWithTitle: NSLocalizedString(@"BTW Hoog", nil) BoolValue: true];
    vat.key = @"vat";
    [section addElement:vat];
   
    QSection *propSection = [[QSection alloc] init];
    propSection.title = NSLocalizedString(@"Bijzonderheden", nil);
    for (OrderLineProperty*productProperty in [[Cache getInstance] productProperties]) {
        QBooleanElement *property = [[QBooleanElement alloc] initWithTitle:productProperty.name BoolValue: true];
        property.key = [NSString stringWithFormat:@"prop%d", productProperty.id];
        property.onImage = [UIImage imageNamed:@"imgOn"];
        property.offImage = [UIImage imageNamed:@"imgOff"];
        [propSection addElement:property];
    }
    [form addSection:propSection];

    QSection *deletedSection = [[QSection alloc] init];
    deletedSection.title = NSLocalizedString(@"Verwijderd", nil);
    QBooleanElement *deleted = [[QBooleanElement alloc] initWithTitle: NSLocalizedString(@"Verwijderd", nil) BoolValue: false];
    deleted.key = @"isDeleted";
    [deletedSection addElement:deleted];
    [form addSection:deletedSection];

    return form;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    ProductCategory *category = [self categoryForSection:indexPath.section];
    Product *product = [[category products] objectAtIndex:indexPath.row];
    return product;
}

- (ProductCategory *) categoryForSection: (int)section
{
    NSMutableArray *categories = [[[Cache getInstance] menuCard] categories];
    return [categories objectAtIndex:section];
}

- (int) sectionForCategory: (ProductCategory *)category
{
    NSMutableArray *categories = [[[Cache getInstance] menuCard] categories];
    for(int section=0; section < [categories count]; section++)
//        if ( ((ProductCategory *)[categories objectAtIndex:section]).id == category.id)
//            return section;
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[[Cache getInstance] menuCard] categories] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ProductCategory *category = [self categoryForSection:section];
    return [[category products] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ProductCategory *category = [self categoryForSection:section];
    return category.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    ProductCategory *category = [self categoryForSection:indexPath.section];
    Product *product = [[category products] objectAtIndex:indexPath.row];

    cell.textLabel.text = product.name;
    cell.detailTextLabel.text = product.isDeleted ? @"" : [Utils getAmountString:product.price withCurrency:YES];

    cell.textLabel.alpha = product.isDeleted ? 0.3 : 1;

    cell.textLabel.textColor = product.entityState == EntityStateNew || product.entityState == EntityStateModified ? [UIColor blueColor] : [UIColor blackColor];

    cell.showsReorderControl = product.isDeleted == NO;
    cell.shouldIndentWhileEditing = NO;
    return cell;
}

- (BOOL)tableView: (UITableView *)tableView canMoveRowAtIndexPath: (NSIndexPath *)indexPath {
    Product *product = [self itemAtIndexPath:indexPath];
    return product != nil && product.isDeleted == false;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    Product *product = [self itemAtIndexPath:sourceIndexPath];
    ProductCategory *category = [self categoryForSection:destinationIndexPath.section];
    if (product == nil || category == nil) return;
    [product.category.products removeObject:product];
    [category.products insertObject:product atIndex:destinationIndexPath.row];
    product.category = category;
    if (product.entityState != EntityStateNew)
        product.entityState = EntityStateModified;
}

- (bool)validate {
    Product *product = [self currentItem];
    if (product == nil) return YES;

    NSLog(@"validate %@ %@", product.key, product.name);
    if([self getValueForKey:@"name"] == @"")
        return false;
    if([self getValueForKey:@"key"] == @"")
        return false;
    return true;
}

- (void)endEdit {
    Product *product = [self currentItem];
    if (product == nil) return;

    NSLog(@"endEdit %@ %@", product.key, product.name);

    product.name = [self getValueForKey:@"name"];
    product.key = [self getValueForKey:@"key"];
    product.price = [self getValueForKey:@"price"];
//    product.vat = [[self getValueForKey:@"vat"] intValue];
    for (OrderLineProperty*productProperty in [[Cache getInstance] productProperties]) {
        NSString *key = [NSString stringWithFormat:@"prop%d", productProperty.id];
        bool hasProperty = [[self getValueForKey:key] boolValue];
        if (hasProperty)
            [product addProperty: productProperty];
        else
            [product deleteProperty:productProperty];
    }
    product.isDeleted = [[self getValueForKey:@"isDeleted"] boolValue];

    if ([self isDirty])
        product.entityState = EntityStateModified;
    return;
}

- (NSIndexPath *) indexPathForItem: (id)object {
    int countSections = [self numberOfSectionsInTableView:listViewController.tableView];
    for(int section = 0; section < countSections; section++) {
        ProductCategory *category = [self categoryForSection:section];
        int countRows = [self tableView:listViewController.tableView numberOfRowsInSection: section];
        for(int row=0; row < countRows; row++) {
            if ([category.products objectAtIndex:row] == object)
            {
                return [NSIndexPath indexPathForRow:row inSection:section];
            }
        }
    }
    return nil;
}

- (void)commitChanges
{
    NSMutableArray *categories = [[[Cache getInstance] menuCard] categories];
    for(ProductCategory *category in categories) {
        for(Product *product in category.products)
        {
            switch(product.entityState) {
                case EntityStateModified:
                    [[Service getInstance] updateProduct: product success:^(ServiceResult *serviceResult) {

                    } error:^(ServiceResult *serviceResult) {
                        [serviceResult displayError];
                    }];
                    break;
                case EntityStateNew:
                    [[Service getInstance] createProduct: product success:^(ServiceResult *serviceResult) {

                    }
                    error:^(ServiceResult *serviceResult) {
                        [serviceResult displayError];
                    }];
                    break;
                case EntityStateDeleted:
                    break;
                case EntityStateNone:
                    break;
            }
        }
    }
}

- (void)createFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    Product *product = (Product *)fetcher.userData;
    if(product == nil) return;

    ServiceResult *serviceResult = [ServiceResult resultFromData:data error:error];
    if(serviceResult.id != -1) {
        product.id = serviceResult.id;
        product.entityState = EntityStateNone;
        [self invalidateRowForItem:product];
    }
    else {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:serviceResult.error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [view show];
    }
    return;
}

- (void)updateFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    Product *product = (Product *)fetcher.userData;
    if(product == nil) return;
    product.entityState = EntityStateNone;
    [self invalidateRowForItem:product];
}

@end