//
//  ProductPropertiesView.m
//  HarkPad
//
//  Created by Willem Bison on 12-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ProductPropertiesView.h"
#import "Utils.h"
#import "Service.h"
#import "ModalAlert.h"
#import "ProductPropertiesTableViewDataSource.h"
#import "MenuItemsTableViewDataSource.h"
#import "MenuItem.h"
#import "MenuPanelView.h"
#import "MenuCollectionViewController.h"
#import "UIImage+Tint.h"

@implementation ProductPropertiesView

@synthesize uiKey, uiName, uiPrice, uiVat, delegate = _delegate;
@synthesize product = _product;
@synthesize popoverController = _popoverController;
@synthesize menuCard = _menuCard;


+ (ProductPropertiesView *)viewWithFrame:(CGRect)frame menuCard:(MenuCard *)menuCard {
    ProductPropertiesView * view = [[ProductPropertiesView alloc] initWithFrame:frame];
    view.menuCard = menuCard;
    view.tableView.backgroundView = nil;
    [view.uiIncludedInQuickMenu setImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateSelected];
    [view.uiIncludedInQuickMenu setImage:[[UIImage imageNamed:@"favorite.png"] imageTintedWithColor:[UIColor grayColor]] forState:UIControlStateNormal];
    [view initVat];
    return view;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        NSArray * nib = [[NSBundle mainBundle]
                     loadNibNamed: @"ProductPropertiesView"
                     owner: self
                     options: nil];

        self = [nib objectAtIndex:0];
        self.frame = frame;
    }
    return self;
}

- (void) initVat {
    [uiVat removeAllSegments];
    int i = 0;
    for (NSDictionary *vat in _menuCard.vatPercentages) {
        NSDecimalNumber *percentage = [vat objectForKey:@"percentage"];
        NSString *label = [NSString stringWithFormat:@"%@ (%@%%)", [vat objectForKey:@"name"], percentage];
        [uiVat insertSegmentWithTitle:label atIndex:i++ animated:YES];
    }
}

- (void)setItem:(id)item {
    _item = item;
    uiKey.text = [item key];
    _itemCaption.text = uiKey.text;
    uiName.text = [item name];
    NSString *price  = [Utils getAmountString: [item price] withCurrency:NO];
    uiPrice.text = [price substringToIndex:[price length] - 3];
    _uiCents.text = [price substringFromIndex:[price length] - 2];
    uiVat.selectedSegmentIndex = [_menuCard vatIndexByPercentage: [item vat]];
    _uiIncludedInQuickMenu.selected  = [_menuCard isFavorite:item];
    if ([item isKindOfClass:[Product class]]) {
        _product = (Product *)item;
        _tableView.allowsSelection = NO;
        _tableCaption.text = NSLocalizedString(@"Options", nil);
        _tableDataSource = [ProductPropertiesTableViewDataSource dataSourceWithProduct:item createCell: ^UITableViewCell *(int row) {return [self createPropertyCellForRow:row];}];
    }
    else {
        _menu = (Menu *)item;
        _tableView.allowsSelection = YES;
        _tableCaption.text = NSLocalizedString(@"Courses", nil);
        _tableDataSource = [MenuItemsTableViewDataSource dataSourceWithMenu:item createCell: ^UITableViewCell *(int row) {return [self createMenuItemCellForRow:row];}];
    }
    _tableView.dataSource = _tableDataSource;
    [_tableView reloadData];
}

- (bool)validate {
    if ([[Utils trim:uiKey.text] length] == 0) {
        [uiKey becomeFirstResponder];
        return NO;
    }
    if ([[Utils trim:uiName.text] length] == 0) {
        [uiName becomeFirstResponder];
        return NO;
    }
    if ([[Utils trim:uiPrice.text] length] == 0) {
        [uiPrice becomeFirstResponder];
        return NO;
    }
    if ([_menuCard isUniqueKey: uiKey.text itemToIgnore: _item] == NO) {
        [uiKey becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (IBAction)toggleQuickMenu {
    if ([_menuCard isFavorite:_item]) {
        [_delegate didInclude:_item inFavorites:NO];
        _uiIncludedInQuickMenu.selected = NO;
    }
    else {
        [_delegate didInclude: _item inFavorites:YES];
        _uiIncludedInQuickMenu.selected = YES;
    }
}

- (IBAction)updateName {
    [_item setValue:[Utils trim:uiName.text] forKey:@"name"];
    [self didUpdate];
}

- (IBAction)updateCode {
    if ([_menuCard isUniqueKey: uiKey.text itemToIgnore: _item] == NO) {
        return;
    }
    [_item setValue:[Utils trim:uiKey.text] forKey:@"key"];
    _itemCaption.text = uiKey.text;
    [self didUpdate];
}

- (IBAction)updateVat {
    [_item setValue: [_menuCard vatPercentageByIndex: uiVat.selectedSegmentIndex] forKey:@"vat"];
    [self didUpdate];
}

- (IBAction)updatePrice {
    NSDecimalNumber *price = (NSDecimalNumber *)[NSDecimalNumber numberWithInt: [uiPrice.text intValue] * 100 + [_uiCents.text intValue]];
    price = [price decimalNumberByDividingBy: [NSDecimalNumber decimalNumberWithString:@"100"]];
    [_item setValue:price forKey:@"price"];
    [self didUpdate];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField != _uiCents && textField != uiPrice) return YES;
    if (textField == uiPrice)
        if ([string isEqualToString:@","] || [string isEqualToString:@"."]) {
            [_uiCents becomeFirstResponder];
            return NO;
        }
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == _uiCents) {
        if ([newString length] >  2)
            return NO;
    }
    NSCharacterSet *digits = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
    NSString *newStringWithoutDigits = [newString stringByTrimmingCharactersInSet: digits];
    if (newStringWithoutDigits.length != 0)
        return NO;
    return YES;
}

- (IBAction)delete {
    if ([ModalAlert confirm:NSLocalizedString(@"Delete item ?", nil)]) {
        [_delegate didDeleteItem: _item];
    }
}

- (void) didUpdate {
    if (self.delegate == nil) return;
    [self.delegate didModifyItem:_item];
}


- (UITableViewCell *) createPropertyCellForRow:(int) row {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, (cell.contentView.bounds.size.height - 21)/2, cell.contentView.frame.size.width, 21)];
    [textField addTarget:self action:@selector(propertyUpdated:) forControlEvents:UIControlEventEditingChanged];
    textField.delegate = self;
    textField.tag = 666;
    [cell.contentView addSubview: textField];

    if (_product != nil && row < [_product.properties count]) {
        textField.text = _product.properties[row];
    }
    else {
        textField.text = @"";
        textField.placeholder = @"Saignant, medium, welldone";
    }
    cell.tag = row;
    return cell;
}

- (UITableViewCell *) createMenuItemCellForRow:(int) row {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.shouldIndentWhileEditing = NO;
    MenuItem *item = [self menuItemAtRow:row];
    if(item != nil) {
        cell.textLabel.text = item.product.key;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.backgroundColor = item.product.category.color;
    }
    else {
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.text = NSLocalizedString(@"New", nil);
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    MenuItem *item = [self menuItemAtRow: indexPath.row];
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    MenuCollectionViewController *controller = [MenuCollectionViewController controllerWithMenuCard:_menuCard menuPanelShow:MenuPanelShowProducts delegate:self];
    controller.selectedItem = item;
    self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    CGRect cellFrame = [self convertRect:[tableView rectForRowAtIndexPath:indexPath] fromView:tableView];
    [self.popover presentPopoverFromRect:cellFrame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)didSelectProduct:(Product *)product {
    [self.popover dismissPopoverAnimated:YES];
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    if (indexPath == nil) return;
    MenuItem *item =  [_menu.items objectAtIndex:indexPath.row];
    if (item == nil) {
        item = [[MenuItem alloc] init];
        item.course = [_menu.items count];
        [_menu.items addObject:item];
        item.product = product;
        [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    else {
        item.product = product;
        [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    }
}

- (MenuItem *)menuItemAtRow:(int)row {
    if(row >= [[_item items] count])
        return nil;
    return [[_item items] objectAtIndex:row];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    int index = [self tableRowByTextField:textField];
    if (index == [_product.properties count]) {
        [_product.properties addObject:@""];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    int index = [self tableRowByTextField:textField];
    if (index >= [_product.properties count])
        return NO;
    if ([textField.text length] == 0) {
        [_product.properties removeObjectAtIndex:index];
        [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]] withRowAnimation:YES];
        return NO;
    }
    else {
        if (index + 1 == [_tableView numberOfRowsInSection:0]) {
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:index + 1 inSection:0]] withRowAnimation:YES];
        }
        return YES;
    }
}

- (int)tableRowByTextField:(UITextField *)textField {
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (indexPath == nil) return -1;
    return indexPath.row;
}

- (void)propertyUpdated:(UITextField *)textField {
    int index = [self tableRowByTextField:textField];
    if (index >= [_product.properties count])
        return;
    _product.properties[index] = textField.text;
}

@end
