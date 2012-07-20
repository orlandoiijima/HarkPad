//
// Created by wbison on 15-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PrintInfo.h"
#import "Menu.h"
#import "PrintTemplate.h"


@implementation PrintInfo {

}
@synthesize templates = _templates;

+ (PrintInfo *) infoFromJson:(NSMutableDictionary *)infoJson
{
    PrintInfo *info = [[PrintInfo alloc] init];
    info.templates = [[NSMutableArray alloc] init];
    for(NSDictionary *templateDic in [infoJson valueForKey:@"Templates"])
    {
        PrintTemplate *template = [PrintTemplate templateFromJson:templateDic];
        [info.templates addObject: template];
    }
    return info;
}

- (PrintTemplate *) getTemplateNamed:(NSString *)templateName {
    for(PrintTemplate *template in self.templates) {
        if ([template.name isEqualToString:templateName])
            return template;
    }
    return [PrintTemplate defaultTemplate];
}

@end