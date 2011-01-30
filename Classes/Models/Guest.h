//
//  Guest.h
//  HarkPad
//
//  Created by Willem Bison on 28-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Guest : NSObject {
@private
    
}

+ (Guest *) guestFromJsonDictionary: (NSDictionary *)jsonDictionary;

@property int id;
@property int seat;
@property BOOL isMale;
@property (retain) NSMutableArray *lines;

@end
