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


@implementation MenuPropertiesView

- (void) setMenu:(Menu *) menu {
    _menu = menu;
    _keyField.text = menu.key;
    _nameField.text = menu.name;
    _priceField.text = [NSString stringWithFormat:@"%@", menu.price];
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
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_menu.items count] + 1;
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
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    MenuItem *item =  [_menu.items objectAtIndex:indexPath.row];
    [_productTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    MenuPanelViewController *controller = [MenuPanelViewController controllerWithMenuCard:_menuCard delegate:self];
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

@end