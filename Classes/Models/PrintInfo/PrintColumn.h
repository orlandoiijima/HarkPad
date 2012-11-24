//
// Created by wbison on 20-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Run.h"

@interface PrintColumn : NSObject

@property (retain) NSMutableArray *cellRuns;
@property (retain) NSString *header;
@property (retain) NSString *footer;

+ (PrintColumn *) columnFromJson:(NSDictionary *)infoJson;

@end