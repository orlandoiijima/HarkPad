//
//  MenuPropertiesView.m
//  HarkPad
//
//  Created by Willem Bison on 10/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuPropertiesView.h"
#import "Utils.h"
#import "MenuItem.h"
#import "MenuCard.h"
#import "MenuPanelViewController.h"
#import "ItemPropertiesDelegate.h"
#import "ModalAlert.h"
#import "MenuDelegate.h"


@implementation MenuPropertiesView

- (void) setMenu:(Menu *) menu {
    _menu = menu;
    _keyField.text = menu.key;
    _nameField.text = menu.name;
    _priceField.text = [NSString stringWithFormat:@"%@", menu.price];
    _includedInQuickMenu.on = [_menuCard isInQuickMenu: menu];
    [_productTable reloadData];
}

+ (MenuPropertiesView *)viewWithFrame:(CGRect)frame menuCard:(MenuCard *)menuCard {
    MenuPropertiesView *view = [[MenuPropertiesView alloc] initWithFrame:frame];
    view.menuCard = menuCard;
    return view;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        NSArray * nib = [[NSBundle mainBundle]
                     loadNibNamed: @"MenuPropertiesView"
                     owner: self
                     options: nil];

        self = [nib objectAtIndex:0];
        self.frame = frame;
        [_productTable setEditing:YES animated:YES];
        _productTable.allowsSelectionDuringEditing = YES;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_menu.items count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [Utils getCourseString:section];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    if(indexPath.row < [_menu.items count]) {
        MenuItem *item =  [_menu.items objectAtIndex:indexPath.row];
        cell.textLabel.text = item.product.key;
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    cell.shouldIndentWhileEditing = NO;
    cell.showsReorderControl = NO;
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    MenuItem *item =  [_menu.items objectAtIndex:indexPath.row];
    [_productTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    MenuPanelViewController *controller = [MenuPanelViewController controllerWithMenuCard:_menuCard menuPanelShow:MenuPanelShowProducts delegate:self];
    self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    CGRect cellFrame = [self convertRect:[tableView rectForRowAtIndexPath:indexPath] fromView:tableView];
    [self.popover presentPopoverFromRect:cellFrame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)didTapProduct:(Product *)product {
    NSIndexPath *indexPath = [_productTable indexPathForSelectedRow];
    if (indexPath == nil) return;
    MenuItem *item =  [_menu.items objectAtIndex:indexPath.row];
    item.product = product;
    [_productTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    [self.popover dismissPopoverAnimated:YES];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    MenuItem *itemToMove =  [_menu.items objectAtIndex: sourceIndexPath.row];
    [_menu.items removeObjectAtIndex:sourceIndexPath.row];
    [_menu.items insertObject:itemToMove atIndex:destinationIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (IBAction)updateName {
    _menu.name = [Utils trim: _nameField.text];
    [self didUpdate];
}

- (IBAction)updateCode {
    _menu.key = [Utils trim: _keyField.text];
    [self didUpdate];
}

//- (IBAction)updateVat {
//    _menu.vat = [_menuCard vatPercentageByIndex: .selectedSegmentIndex];
//    [self didUpdate];
//}

- (IBAction)updatePrice {
    _menu.price = [Utils getAmountFromString: _priceField.text];
    [self didUpdate];
}

- (IBAction)delete {
    if ([ModalAlert confirm:NSLocalizedString(@"Delete menu ?", nil)]) {
        [_delegate didDeleteItem:_menu];
    }
}

- (void) didUpdate {
    if (self.delegate == nil) return;
    [self.delegate didModifyItem: _menu];
}

- (IBAction)toggleQuickMenu {
    if ([_menuCard isInQuickMenu:_menu])
        [_menuCard removeFromQuickMenu:_menu];
    else
        [_menuCard addToQuickMenu:_menu];
}

@end