//
// Created by wbison on 20-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PrintColumn.h"

@implementation PrintColumn {

@private
    NSString *_header;
    NSString *_footer;
    NSMutableArray *_cellRuns;
}
@synthesize cellRuns = _cellRuns;
@synthesize header = _header;


+ (PrintColumn *) columnFromJson:(NSDictionary *)infoJson
{
    PrintColumn *column = [[PrintColumn alloc] init];
    column.header  = [infoJson objectForKey:@"header"];
    column.footer  = [infoJson objectForKey:@"footer"];
    column.cellRuns = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in [infoJson objectForKey:@"cellRuns"]) {
        Run *run = [Run runFromJson: dic];
        [column.cellRuns addObject:run];
    }
    return column;
}

@end