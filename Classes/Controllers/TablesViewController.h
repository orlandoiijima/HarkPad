//
//  TablesViewController.h
//  HarkPad
//
//  Created by Willem Bison on 22-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum AllowSelect {selectEmpty, selectFilled} AllowSelect ;

@interface TablesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableDictionary *groupedTables;
    bool selectionMode;
    NSMutableArray *tablesInfo;
    UITableView *tableView;
    UIPopoverController *popoverController;
}

@property bool selectionMode;
@property (retain) NSMutableDictionary *groupedTables;
@property (retain) NSMutableArray *tablesInfo;
@property (retain) IBOutlet UITableView *tableView;
@property (retain) UIPopoverController *popoverController;
@property int orderId;

- (id) initWithTables: (NSMutableArray *)tables;
- (void) createDataSource: (NSMutableArray *)tables;

- (IBAction) done;
- (IBAction) cancel;

@end
