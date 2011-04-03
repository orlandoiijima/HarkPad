//
//  LogViewController.h
//  HarkPad
//
//  Created by Willem Bison on 03-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LogViewController : UIViewController {
    UITableView *logTableView;
    NSMutableDictionary *logLines;    
}

@property (retain) IBOutlet UITableView *logTableView;
@property (retain) NSMutableDictionary *logLines;

- (IBAction) refresh;

@end
