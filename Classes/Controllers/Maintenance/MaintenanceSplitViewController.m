//
//  Created by wbison on 16-10-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "MaintenanceSplitViewController.h"
#import "QRootElement.h"
#import "QSection.h"

@implementation MaintenanceSplitViewController

@synthesize dataSource, delegate, detailsViewController, listViewController, currentItem;

- (void)viewDidLoad
{
    UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [self.view addSubview:bar];

    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:delegate action:@selector(addItem)];
    add.style = UIBarButtonItemStyleBordered;
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:delegate action:@selector(save)];
    save.style = UIBarButtonItemStyleBordered;

    [bar setItems:[NSArray arrayWithObjects:add, save, nil] animated:YES];
    
    listViewController = [[MaintenanceListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    listViewController.view.frame = CGRectMake(self.view.frame.origin.x, 44, self.view.frame.size.width/2, self.view.frame.size.height);
    listViewController.tableView.dataSource = self;
    listViewController.tableView.delegate = self;

    listViewController.tableView.editing = YES;
    listViewController.tableView.allowsSelectionDuringEditing = YES;
    [self.view addSubview: listViewController.view];
    detailsViewController = [[MaintenanceDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.view addSubview: detailsViewController.view];
    detailsViewController.view.frame = CGRectMake(
            self.view.frame.origin.x + listViewController.view.frame.size.width,
            44,
            self.view.frame.size.width - listViewController.view.frame.size.width,
            self.view.frame.size.height);
    detailsViewController.view.hidden = YES;
    if(delegate == nil)
        delegate = self;
    detailsViewController.root = [delegate setupDetailView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    detailsViewController.view.hidden = NO;
    self.currentItem = [delegate itemAtIndexPath:indexPath];
    [delegate fillDetailViewWithObject:self.currentItem];
}

- (id)currentItem {
    return nil;
    //To change the template use AppCode | Preferences | File Templates.

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
    //To change the template use AppCode | Preferences | File Templates.

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
    //To change the template use AppCode | Preferences | File Templates.

}

- (NSIndexPath *)tableView: (UITableView *)tableView willSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    if ([delegate validate] == false)
        return nil;
    return indexPath;
}

- (NSIndexPath *)tableView: (UITableView *)tableView willDeselectRowAtIndexPath: (NSIndexPath *)indexPath {
    if ([delegate validate] == false)
        return nil;
    [self.delegate endEdit];
    [listViewController.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
    return indexPath;
}

- (BOOL)tableView: (UITableView *)tableView canMoveRowAtIndexPath: (NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView: (UITableView *)tableView editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)commitChanges {
    //To change the template use AppCode | Preferences | File Templates.

}

- (void)fillDetailViewWithObject:(id)object {
    //To change the template use AppCode | Preferences | File Templates.

}

- (QRootElement *)setupDetailView {
    return nil;
    //To change the template use AppCode | Preferences | File Templates.

}

- (void)addItem {
    //To change the template use AppCode | Preferences | File Templates.

}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
    //To change the template use AppCode | Preferences | File Templates.

}

- (NSIndexPath *)indexPathForItem:(id)object {
    return nil;
    //To change the template use AppCode | Preferences | File Templates.

}

- (void)endEdit {
    //To change the template use AppCode | Preferences | File Templates.

}

- (bool)validate {
    return 0;
    //To change the template use AppCode | Preferences | File Templates.

}

- (void)invalidateRowForItem: (id)object
{
    NSIndexPath *indexPath = [delegate indexPathForItem:object];
    if (indexPath == nil) return;
    [listViewController.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
}

- (void)putValue: (id)value forKey: (NSString *)key
{
    for (QSection *s in detailsViewController.root.sections){
        for (QElement *el in s.elements) {
            if([el.key isEqualToString:key])
                [el putValue:value];
        }
    }
}

- (id)getValueForKey: (NSString *)key
{
    for (QSection *s in detailsViewController.root.sections){
        for (QElement *el in s.elements) {
            if([el.key isEqualToString:key])
                return [el getValue];
        }
    }
    return nil;
}

- (void) save
{
    [delegate endEdit];
    [delegate commitChanges];
}

- (bool)isDirty
{
    for (QSection *s in detailsViewController.root.sections){
        for (QElement *el in s.elements) {
            if (el.isDirty)
                return true;
        }
    }
    return false;
}

@end