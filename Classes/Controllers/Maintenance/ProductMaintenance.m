//
//  Created by wbison on 18-10-11.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "ProductMaintenance.h"
#import "Product.h"
#import "QRootElement.h"
#import "QSection.h"
#import "QEntryElement.h"
#import "QDecimalElement.h"
#import "QBooleanElement.h"
#import "Cache.h"
#import "QRadioElement.h"
#import "OrderLineProperty.h"
#import "Utils.h"

@implementation ProductMaintenance


- (void) viewDidLoad
{
}

- (void)fillDetailViewWithObject:(id)object {
    Product *product = (Product *)object;
}

- (QRootElement *)setupDetailView {
    QRootElement *form = [[QRootElement alloc] init];
    form.grouped = YES;
    QSection *section = [[QSection alloc] init];
    [form addSection: section];

    QEntryElement *key = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Code", nil) Value:@"" Placeholder:NSLocalizedString(@"Bestelpanel", nil)];
    key.key = @"Code";
    [section addElement:key];

    QEntryElement *name = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Naam", nil) Value:@"" Placeholder:NSLocalizedString(@"Bon, rekening", nil)];
    name.key = @"login";
    [section addElement:name];

    QDecimalElement *price = [[QDecimalElement alloc] initWithTitle:NSLocalizedString(@"Prijs", nil) value:0.0];
    price.fractionDigits = 2;
    price.key = @"price";
    [section addElement:price];

	QBooleanElement *bool1 = [[QBooleanElement alloc] initWithTitle: NSLocalizedString(@"BTW Hoog", nil) BoolValue:true];
    [section addElement:bool1];

    NSMutableArray *categories = [[NSMutableArray alloc] init];
    int i = 0, selected = 0;
    for (ProductCategory *category in [[[Cache getInstance] menuCard] categories]) {
        [categories addObject:category.name];
        i++;
    }
    QRadioElement *category = [[QRadioElement alloc] initWithItems: categories selected:selected title: NSLocalizedString(@"Group", nil)];
	category.key = NSLocalizedString(@"Group", nil);
    [section addElement:category];

    QSection *propSection = [[QSection alloc] init];
    propSection.title = NSLocalizedString(@"Properties", nil);
    for (OrderLineProperty*productProperty in [[Cache getInstance] productProperties]) {
        QBooleanElement *property = [[QBooleanElement alloc] initWithTitle:productProperty.name BoolValue: true];
        property.onImage = [UIImage imageNamed:@"imgOn"];
        property.offImage = [UIImage imageNamed:@"imgOff"];
        [propSection addElement:property];
    }
    [form addSection:propSection];

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
    cell.detailTextLabel.text = [Utils getAmountString:product.price withCurrency:YES];

    return cell;
}

@end