//
//  BacklogViewController.h
//  HarkPad
//
//  Created by Willem Bison on 06-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Backlog.h"

@interface BacklogViewController : UIViewController {
    NSMutableArray *backlog;    
}

@property (retain) NSMutableArray *backlog;
@end
