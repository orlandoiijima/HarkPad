//
// Created by wbison on 15-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PrintInfo.h"
#import "OrderLineFilter.h"
#import "PrinterInfo.h"


@implementation PrintInfo {

}
@synthesize templates = _templates;
@synthesize documents = _documents;
@synthesize printers = _printers;


+ (PrintInfo *) infoFromJson:(NSMutableDictionary *)infoJson
{
    PrintInfo *info = [[PrintInfo alloc] init];
    info.templates = [[NSMutableArray alloc] init];
    for(NSDictionary *templateDic in [infoJson valueForKey:@"templates"])
    {
        PrintTemplate *template = [PrintTemplate templateFromJson:templateDic];
        [info.templates addObject: template];
    }

    info.printers = [[NSMutableArray alloc] init];
    for(NSDictionary *dic in [infoJson valueForKey:@"printers"])
    {
        PrinterInfo *printer = [PrinterInfo printerFromJson:dic];
        [info.printers addObject: printer];
    }

    info.documents = [[NSMutableArray alloc] init];
    for(NSDictionary *documentDic in [infoJson valueForKey:@"orderDocuments"])
    {
        OrderDocument *document = [OrderDocument documentFromJson:documentDic printInfo: info];
        [info.documents addObject: document];
    }

    return info;
}

- (PrintTemplate *) getTemplateNamed:(NSString *)templateName {
    for(PrintTemplate *template in self.templates) {
        if ([template.name compare:templateName options:NSCaseInsensitiveSearch] == NSOrderedSame)
            return template;
    }
    return [PrintTemplate defaultTemplate];
}

- (PrinterInfo *) getPrinterNamed:(NSString *)printerName {
    for(PrinterInfo *printer in self.printers) {
        if ([printer.name compare:printerName options:NSCaseInsensitiveSearch] == NSOrderedSame)
            return printer;
    }
    return nil;
}

- (NSMutableArray *)getDocumentInfoForTrigger: (OrderTrigger)trigger {
    NSMutableArray *infos = [[NSMutableArray alloc] init];
    for (OrderDocument *document in self.documents) {
        if (document.trigger == trigger) {
            [infos addObject:document];
        }
    }
    return infos;
}

@end


@implementation OrderDocument {
}

@synthesize name = _name;
@synthesize template = _template;
@synthesize trigger = _trigger;
@synthesize filter = _filter;
@synthesize printer = _printer;
@synthesize totalizeProducts = _totalizeProducts;


+ (OrderDocument *) documentFromJson:(NSDictionary *)documentJson printInfo: (PrintInfo *)printInfo
{
    OrderDocument *doc = [[OrderDocument alloc] init];
    doc.name = [documentJson objectForKey:@"name"];
    doc.template  = [printInfo getTemplateNamed: [documentJson objectForKey:@"templateName"]];
    doc.trigger = (OrderTrigger) [[documentJson objectForKey:@"trigger"] intValue];
    doc.printer = [printInfo getPrinterNamed: [documentJson objectForKey:@"printer"]];
    doc.filter = [OrderLineFilter filterFromJson: [documentJson objectForKey:@"include"]];
    doc.totalizeProducts = (bool)[[documentJson objectForKey:@"totalizeProducts"] intValue];
    return doc;
}

@end


