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
    template.name  = [infoJson objectForKey:@"Name"];
    template.fontName  = [infoJson objectForKey:@"FontName"];
    template.pointSize = [[infoJson objectForKey:@"PointSize"] floatValue];
    template.preRuns = [[NSMutableArray alloc] init];
    template.table = [PrintTable tableFromJson: [infoJson objectForKey:@"Table"]];
    for(NSDictionary *runDic in [infoJson valueForKey:@"PreRuns"])
    {
        Run *run = [Run runFromJson: runDic];
        [template.preRuns addObject: run];
    }
    template.postRuns = [[NSMutableArray alloc] init];
    for(NSDictionary *runDic in [infoJson valueForKey:@"PostRuns"])
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