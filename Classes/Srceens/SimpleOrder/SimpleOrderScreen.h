//
//  SimpleOrderScreen.h
//  HarkPad
//
//  Created by Willem Bison on 10/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuTreeView.h"


@interface SimpleOrderScreen : UIViewController {

}

@property (retain) IBOutlet MenuTreeView *productView;
@property (retain) IBOutlet UITableView *orderView;
@end
