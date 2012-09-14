//
// Created by wbison on 13-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Print.h"
#import "PrinterInfo.h"
#import "PrintInfo.h"
#import "PdfCreator.h"
#import "StarPrintJob.h"


@implementation Print {

}
@synthesize documentInfo = _documentInfo;
@synthesize printer = _printer;
@synthesize datasource = _datasource;


+ (void)printWithDataSource:(id)dataSource withDocument:(OrderDocument *)documentInfo toPrinter: (PrinterInfo *)printer {
    if (printer.type == PrinterTypeAirplay) {
        PdfCreator *creator = [PdfCreator pdfCreatorWithTemplate:documentInfo.template dataSource:dataSource];
        NSString *fileName = [NSString stringWithFormat:@"Invoice.pdf"];

        NSString *pdfFilename = [creator createFileNamed: fileName];

         NSData *pdfData = [NSData dataWithContentsOfFile:pdfFilename];
         if ([UIPrintInteractionController canPrintData: pdfData]) {
             UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
             controller.printingItem = pdfData;
             UIPrintInfo *info = [UIPrintInfo printInfo];
             info.jobName = pdfFilename;
             info.outputType = UIPrintInfoOutputGeneral;
             controller.printInfo = info;
             [controller presentAnimated:YES completionHandler:nil];
         }
    }
    else {
        StarPrintJob *printJob = [StarPrintJob jobWithTemplate:documentInfo.template dataSource:dataSource ip:printer.address];
        [printJob print];
    }
    return;
 }

@end