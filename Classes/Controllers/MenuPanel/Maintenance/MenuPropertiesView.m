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
#import "MenuCollectionViewController.h"
#import "OrderLineCell.h"


@implementation MenuPropertiesView

- (void) setMenu:(Menu *) menu {
    _menu = menu;
    _keyField.text = menu.key;
    _nameField.text = menu.name;
    _priceField.text = [NSString stringWithFormat:@"%@", menu.price];
    _includedInQuickMenu.selected  = [_menuCard isInQuickMenu: menu];
    [_productTable reloadData];
}

+ (MenuPropertiesView *)viewWithFrame:(CGRect)frame menuCard:(MenuCard *)menuCard {
    MenuPropertiesView *view = [[MenuPropertiesView alloc] initWithFrame:frame];
    view.menuCard = menuCard;
    [view.includedInQuickMenu setImage:[UIImage imageNamed:@"BlueStar.png"] forState:UIControlStateSelected];
    view.productTable.backgroundView = nil;
    return view;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        NSArray * nib = [[NSBundle mainBundle]
                     loadNibNamed: @"MenuPropertiesView"
                     owner: self
                     options: nil];

        self = [nib objectAtIndex:0];
        self.frame = frame;
    }
    return self;
}

//- (void)resizeTableView {
//    _productTable.frame = CGRectMake(
//            _productTable.frame.origin.x,
//            _productTable.frame.origin.y,
//            _productTable.frame.size.width,
//            ([_menu.items count]+1) * 44 + 20);
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_menu.items count] + 1;
}

- (MenuItem *)menuItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row >= [_menu.items count])
        return nil;
    return [_menu.items objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];

    MenuItem *item = [self menuItemAtIndexPath:indexPath];
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
    MenuItem *item = [self menuItemAtIndexPath:indexPath];
    [_productTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    MenuCollectionViewController *controller = [MenuCollectionViewController controllerWithMenuCard:_menuCard menuPanelShow:MenuPanelShowProducts delegate:self];
    controller.selectedItem = item;
    self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    CGRect cellFrame = [self convertRect:[tableView rectForRowAtIndexPath:indexPath] fromView:tableView];
    [self.popover presentPopoverFromRect:cellFrame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)didSelectProduct:(Product *)product {
    NSIndexPath *indexPath = [_productTable indexPathForSelectedRow];
    if (indexPath == nil) return;
    MenuItem *item =  [_menu.items objectAtIndex:indexPath.row];
    if (item == nil) {
        item = [[MenuItem alloc] init];
        item.course = [_menu.items count];
        [_menu.items addObject:item];
        item.product = product;
        [_productTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    else {
        item.product = product;
        [_productTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];

    }
    [self.popover dismissPopoverAnimated:YES];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    MenuItem *itemToMove = [self menuItemAtIndexPath:sourceIndexPath];
    if (itemToMove == nil) return;

    [_menu.items removeObjectAtIndex:sourceIndexPath.row];
    [_menu.items insertObject:itemToMove atIndex:destinationIndexPath.row];
}

- (IBAction)updateName {
    _menu.name = [Utils trim: _nameField.text];
    [self didUpdate];
}

- (IBAction)updateCode {
    _menu.key = [Utils trim: _keyField.text];
    [self didUpdate];
}

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
    if ([_menuCard isInQuickMenu:_menu]) {
        _includedInQuickMenu.selected = NO;
        [_delegate didInclude:_menu inFavorites:NO];
    }
    else {
        _includedInQuickMenu.selected = YES;
        [_delegate didInclude:_menu inFavorites:YES];
    }
}

@end