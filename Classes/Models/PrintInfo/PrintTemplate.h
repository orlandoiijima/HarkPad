//
// Created by wbison on 15-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "PrintTable.h"
#import "Edge.h"

@interface PrintTemplate : NSObject

typedef struct Margin {
    int top, left, bottom, right;
} Margin;

@property (retain) NSString *name;
@property (retain) NSMutableArray *preRuns;
@property (retain) PrintTable *table;
@property (retain) NSMutableArray *postRuns;
@property float pointSize;
@property (retain) NSString *fontName;

@property(nonatomic) Edge *margin;

+ (PrintTemplate *) templateFromJson:(NSDictionary *)infoJson;
+ (PrintTemplate *) defaultTemplate;

@end