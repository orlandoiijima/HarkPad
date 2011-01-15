//
//  District.h
//  HarkPad
//
//  Created by Willem Bison on 03-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface District : NSObject {

}

@property (retain) NSString *name;
@property (retain) NSMutableArray *tables;


+ (District *) districtFromJsonDictionary: (NSDictionary *)jsonDictionary;
- (CGRect) getRect;

@end
