//
//  UserListViewController.h
//  HarkPad
//
//  Created by Willem Bison on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//



@protocol SelectItemDelegate;

@interface UserListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) UITableView *tableView;
@property (retain) NSMutableArray *users;
@property (retain) id<SelectItemDelegate> delegate;

@end
