//
// Created by wbison on 15-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "PrintTable.h"

@interface PrintTemplate : NSObject

@property (retain) NSString *name;
@property (retain) NSMutableArray *preRuns;
@property (retain) PrintTable *table;
@property (retain) NSMutableArray *postRuns;
@property float pointSize;
@property (retain) NSString *fontName;

+ (PrintTemplate *) templateFromJson:(NSDictionary *)infoJson;
+ (PrintTemplate *) defaultTemplate;

@end