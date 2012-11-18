//
//  LocalLogViewController+.m
//  HarkPad
//
//  Created by Willem Bison on 11/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocalLogViewController.h"
#import "Logger.h"
#import "LogItem.h"

@interface LocalLogViewController ()

@end

@implementation LocalLogViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Log";
}

- (void)viewDidAppear:(BOOL)animated {
    int count = [[Logger lines] count];
    if (count == 0) return;
    NSMutableArray *newItems = [[NSMutableArray alloc] init];
    for (int j = _lastCount; j < count; j++) {
        [newItems addObject:[NSIndexPath indexPathForItem:j inSection:0]];
    }
    [self.tableView insertRowsAtIndexPaths:newItems withRowAnimation:UITableViewRowAnimationLeft];
 //   [self.tableView reloadData];
    _lastCount = count;
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:count-1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    _lastCount = [[Logger lines] count];
    return _lastCount;
}

- (LogItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [[Logger lines] count])
        return nil;
    return [[Logger lines] objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cedll";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    LogItem *logItem = [self itemAtIndexPath:indexPath];
    if (logItem) {
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.text = logItem.message;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    LogItem *logItem = [self itemAtIndexPath:indexPath];
    if (!logItem) return;
    switch (logItem.level) {
        case LogLevelInfo:
            cell.backgroundColor = [UIColor whiteColor];
            break;
        case LogLevelWarning:
            cell.backgroundColor = [UIColor yellowColor];
            break;
        case LogLevelError:
            cell.backgroundColor = [UIColor redColor];
            break;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 20;
}

@end
