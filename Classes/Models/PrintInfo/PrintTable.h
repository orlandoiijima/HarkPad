//
// Created by wbison on 20-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Run.h"

@interface PrintTable : NSObject

@property (retain) NSMutableArray *columns;
@property float pointSize;
@property (retain) NSString *fontName;
@property (retain) NSString *xSpec;
@property (retain) NSString *ySpec;
@property (retain) Run *section;
@property int lineSpace;

+ (PrintTable *) tableFromJson:(NSDictionary *)infoJson;

@end