//
// Created by wbison on 21-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "StarPrintJob.h"
#import "Cache.h"
#import "PrintInfo.h"
#import "PrintColumn.h"
#import <StarIO/SMPort.h>
#import <sys/time.h>

@implementation StarPrintJob {

@private
    PrintTemplate *_template;
    id _delegate;
}
@synthesize template = _template;
@synthesize port = _port;
@synthesize delegate = _delegate;


+ (StarPrintJob *)jobWithTemplateNamed:(NSString *)templateName delegate: (id) delegate {
    StarPrintJob *job = [[StarPrintJob alloc] init];
    job.delegate = delegate;
    job.template = [[[Cache getInstance] printInfo] getTemplateNamed: templateName]; 
    return job;
}

-(void) print {
    @try {
        self.port = [SMPort getPort:@"aaa" :@"" :10000];

        for(Run *run in self.template.preRuns) {
            [self print:run row:-1 section:-1];
        }
    
        int countSections = [self.delegate numberOfSections];
        for (NSUInteger section=0; section < countSections; section++) {
            int countRows = [self.delegate numberOfRowsInSection:section];
            if (countRows == 0)
                continue;
    
            [self print:self.template.table.section row:-1 section: section];
            for(NSUInteger row = 0; row < countRows; row++) {
                for(PrintColumn *column in self.template.table.columns) {
                    [self print:column.cell row:row section:section];
                }
            }
        }
        
    }
    @catch(PortException *e) {

    }

}

-(void) print:(Run *)run row:(int)row section:(int)section {
    NSString *textToDraw = [run evaluateWithProvider:_delegate row:row section:section];
    NSData *textNSData = [textToDraw dataUsingEncoding:NSWindowsCP1252StringEncoding];
    unsigned char *textData = (unsigned char *)malloc([textNSData length]);
    [textNSData getBytes:textData];

    NSMutableData *commands = [[NSMutableData alloc] init];

//    unsigned char leftMarginCommand[] = {0x1b, 0x6c, 0x00};
//    leftMarginCommand[2] = [run.xSpec intValue];
//    [commands appendBytes:leftMarginCommand length:3];

    unsigned char alignmentCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    switch (run.alignment)
    {
        case UITextAlignmentLeft:
            alignmentCommand[3] = 48;
            break;
        case UITextAlignmentCenter:
            alignmentCommand[3] = 49;
            break;
        case UITextAlignmentRight:
            alignmentCommand[3] = 50;
            break;
    }
    [commands appendBytes:alignmentCommand length:4];
    
    [commands appendBytes:textData length:[textNSData length]];
    
    unsigned char lf = 0x0a;
    [commands appendBytes:&lf length:1];
    
    size_t commandSize = [commands length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commands getBytes:dataToSentToPrinter];

    struct timeval endTime;
    gettimeofday(&endTime, NULL);
    endTime.tv_sec += 30;
    
    u_int32_t totalAmountWritten = 0;
    while(totalAmountWritten < commandSize)
    {
        int amountWritten = [_port writePort:dataToSentToPrinter : totalAmountWritten :commandSize];
        totalAmountWritten += amountWritten;
        
        struct timeval now;
        gettimeofday(&now, NULL);
        if(now.tv_sec > endTime.tv_sec)
        {
            break;
        }
    }
}

@end