//
// Created by wbison on 15-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DTO.h"
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
        OrderDocumentDefinition *document = [OrderDocumentDefinition documentFromJson:documentDic printInfo:info];
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

- (NSMutableArray *)getDocumentDefinitionsForTrigger: (OrderTrigger)trigger {
    NSMutableArray *infos = [[NSMutableArray alloc] init];
    for (OrderDocumentDefinition *document in self.documents) {
        if (document.trigger == trigger) {
            [infos addObject:document];
        }
    }
    return infos;
}


- (NSMutableDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [super toDictionary];

    NSMutableArray *printers = [[NSMutableArray alloc] init];
    for (PrinterInfo *printerInfo in self.printers) {
        [printers addObject:[printerInfo toDictionary]];
    }
    [dictionary setObject: printers forKey:@"printers"];

    return dictionary;
}

@end


@implementation OrderDocumentDefinition {
}

@synthesize name = _name;
@synthesize template = _template;
@synthesize trigger = _trigger;
@synthesize filter = _filter;
@synthesize printer = _printer;
@synthesize totalizeProducts = _totalizeProducts;


+ (OrderDocumentDefinition *) documentFromJson:(NSDictionary *)documentJson printInfo: (PrintInfo *)printInfo
{
    OrderDocumentDefinition *doc = [[OrderDocumentDefinition alloc] init];
    doc.name = [documentJson objectForKey:@"name"];
    doc.template  = [printInfo getTemplateNamed: [documentJson objectForKey:@"templateName"]];
    doc.trigger = (OrderTrigger) [[documentJson objectForKey:@"trigger"] intValue];
    doc.printer = [printInfo getPrinterNamed: [documentJson objectForKey:@"printer"]];
    doc.filter = [OrderLineFilter filterFromJson: [documentJson objectForKey:@"include"]];
    doc.totalizeProducts = (bool)[[documentJson objectForKey:@"totalizeProducts"] intValue];
    return doc;
}

@end


