//
// Created by wbison on 20-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PrintColumn.h"
#import "PrintTable.h"
#import "Run.h"


@implementation PrintColumn {

@private
    NSString *_header;
    Run *_cell;
}
@synthesize cell = _cell;
@synthesize header = _header;


+ (PrintColumn *) columnFromJson:(NSDictionary *)infoJson
{
    PrintColumn *column = [[PrintColumn alloc] init];
    column.header  = [infoJson objectForKey:@"Name"];
    column.cell  = [Run runFromJson: [infoJson objectForKey:@"Cell"]];
    return column;
}

@end