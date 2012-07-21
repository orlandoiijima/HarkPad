//
// Created by wbison on 20-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Run.h"

@interface PrintColumn : NSObject

@property (retain) Run *cell;
@property (retain) NSString *header;

+ (PrintColumn *) columnFromJson:(NSDictionary *)infoJson;

@end