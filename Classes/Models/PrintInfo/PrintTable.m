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
    table.pointSize = [[infoJson objectForKey:@"PointSize"] floatValue];
    table.fontName  = [infoJson objectForKey:@"FontName"];
    table.xSpec  = [infoJson objectForKey:@"XSpec"];
    table.ySpec  = [infoJson objectForKey:@"YSpec"];
    table.section = [Run runFromJson: [infoJson objectForKey:@"Section"]];
    for(NSDictionary *templateDic in [infoJson valueForKey:@"Columns"])
    {
        PrintColumn *column = [PrintColumn columnFromJson:templateDic];
        [table.columns addObject: column];
    }
    return table;
}

@end