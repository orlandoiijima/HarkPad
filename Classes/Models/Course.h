//
//  Course.h
//  HarkPad
//
//  Created by Willem Bison on 28-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Course : NSObject {
@private
    
}

+ (Course *) courseFromJsonDictionary: (NSDictionary *)jsonDictionary;

@property int id;
@property int offset;
@property (retain) NSDate *requestedOn;
@property (retain) NSMutableArray *lines;

@end
