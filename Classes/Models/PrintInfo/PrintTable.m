//
// Created by wbison on 20-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PrintTable.h"
#import "PrintColumn.h"


@implementation PrintTable {

@private
    NSMutableArray *_columns;
    NSString *_fontName;
    float _pointSize;
    NSString *_ySpec;
    NSString *_xSpec;
    Run *_section;
}
@synthesize columns = _columns;
@synthesize fontName = _fontName;
@synthesize pointSize = _pointSize;
@synthesize ySpec = _ySpec;
@synthesize xSpec = _xSpec;
@synthesize section = _section;


+ (PrintTable *) tableFromJson:(NSDictionary *)infoJson
{
    PrintTable *table = [[PrintTable alloc] init];
    table.columns  = [[NSMutableArray alloc] init];
    table.pointSize = [[infoJson objectForKey:@"pointSize"] floatValue];
    table.fontName  = [infoJson objectForKey:@"fontName"];
    table.lineSpace  = [[infoJson objectForKey:@"lineSpace"] intValue];
    table.xSpec  = [infoJson objectForKey:@"xSpec"];
    table.ySpec  = [infoJson objectForKey:@"ySpec"];
    table.section = [Run runFromJson: [infoJson objectForKey:@"section"]];
    for(NSDictionary *templateDic in [infoJson valueForKey:@"columns"])
    {
        PrintColumn *column = [PrintColumn columnFromJson:templateDic];
        [table.columns addObject: column];
    }
    return table;
}

@end