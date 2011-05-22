//
//  InvoicesViewController.h
//  HarkPad
//
//  Created by Willem Bison on 20-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface InvoicesViewController : UITableViewController {
    
}

- (void) onUpdateOrder: (Order *)order;

@end
