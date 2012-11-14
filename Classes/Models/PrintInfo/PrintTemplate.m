//
// Created by wbison on 15-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PrintTemplate.h"
#import "PrintTable.h"
#import "Run.h"
#import "TemplatePrintDataSource.h"
#import "Table.h"


@implementation PrintTemplate {

@private
    NSString *_fontName;
    NSString *_name;
    float _pointSize;
    NSMutableArray *_postRuns;
    NSMutableArray *_preRuns;
    PrintTable *_table;
}

@synthesize fontName = _fontName, name = _name, pointSize = _pointSize, postRuns = _postRuns, preRuns = _preRuns, table = _table;

+ (PrintTemplate *) templateFromJson:(NSDictionary *)infoJson
{
    PrintTemplate *template = [[PrintTemplate alloc] init];
    template.name  = [infoJson objectForKey:@"name"];
    template.fontName  = [infoJson objectForKey:@"fontName"];
    template.pointSize = [[infoJson objectForKey:@"pointSize"] floatValue];
    id margin = [infoJson objectForKey:@"margin"];
    if (margin != nil) {
        template.margin = [[Edge alloc] initWithDictionary:margin];
    }
    else
        template.margin = [[Edge alloc] init];
    template.preRuns = [[NSMutableArray alloc] init];
    template.table = [PrintTable tableFromJson: [infoJson objectForKey:@"table"]];
    for(NSDictionary *runDic in [infoJson valueForKey:@"preRuns"])
    {
        Run *run = [Run runFromJson: runDic];
        [template.preRuns addObject: run];
    }
    template.postRuns = [[NSMutableArray alloc] init];
    for(NSDictionary *runDic in [infoJson valueForKey:@"postRuns"])
    {
        Run *run = [Run runFromJson: runDic];
        [template.postRuns addObject: run];
    }
    return template;
}

+ (PrintTemplate *) defaultTemplate {
    PrintTemplate *template = [[PrintTemplate alloc] init];
    return template;
}

@end