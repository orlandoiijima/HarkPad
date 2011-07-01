//
//  InvoicesDataSource.h
//  HarkPad
//
//  Created by Willem Bison on 20-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InvoicesDataSource : NSObject <UITableViewDataSource>{
    NSMutableArray *invoices;    
}

@property (retain) NSMutableArray *invoices;

+ (InvoicesDataSource *) dataSource;

@end
