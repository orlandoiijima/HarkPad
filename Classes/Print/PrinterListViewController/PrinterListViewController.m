//
//  PrinterListViewController.m
//  HarkPad
//
//  Created by Willem Bison on 11/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <StarIO/SMPort.h>
#import "PrinterListViewController.h"
#import "Cache.h"
#import "PrintInfo.h"
#import "PrinterCell.h"
#import "PrinterInfo.h"
#import "Service.h"
#import "ProgressInfo.h"

@interface PrinterListViewController ()

@end

@implementation PrinterListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _printers = [[[Cache getInstance] printInfo] printers];

    UINib *nib = [UINib nibWithNibName:@"PrinterCell" bundle:[NSBundle mainBundle]];
    [_printersView registerNib:nib forCellWithReuseIdentifier:@"xjsjw"];

    [self findStarPrinters];
    
}

- (void) findStarPrinters {
    _progressInfo = [ProgressInfo progressWithHudText:NSLocalizedString(@"Looking for printers...", nil) parentView:self.view];
    [_progressInfo start];
    dispatch_queue_t myQueue = dispatch_queue_create("com.theattic.myqueue", 0);
    dispatch_async(myQueue, ^{
        NSArray *onlineStarPrinters = [SMPort searchPrinter];
        for (PrinterInfo *printerInfo in _printers) {
            printerInfo.isOnline = [self isPrinter:printerInfo inOnlineList:onlineStarPrinters];
        }
        for (PortInfo *onlineStarPrinter in onlineStarPrinters) {
             PrinterInfo *printerInfo = [self printerByAddress:[onlineStarPrinter.portName substringFromIndex:4]];
             if (printerInfo == nil) {
                 [self addPrinterWithAddress: [onlineStarPrinter.portName substringFromIndex:4]];
             }
         }
         dispatch_sync(dispatch_get_main_queue(), ^{
             [_progressInfo stop];
             [_printersView reloadData];
         });//end block
     });
}

- (void)addPrinterWithAddress:(NSString *)address {
    PrinterInfo *newPrinter = [[PrinterInfo alloc] init];
    newPrinter.isOnline = YES;
    newPrinter.type = PrinterTypeStar;
    newPrinter.address = address;
    [_printers addObject:newPrinter];
}

- (PrinterInfo *)printerByAddress:(NSString *)address {
    for (PrinterInfo *printerInfo in _printers) {
        if ([printerInfo.address isEqualToString: address]) {
            return printerInfo;
        }
    }
    return nil;
}

- (BOOL)isPrinter:(PrinterInfo *)printerInfo inOnlineList:(NSArray *)onlineStarPrinters {
    for (PortInfo *portInfo in onlineStarPrinters) {
        if ([[portInfo.portName substringFromIndex:4] isEqualToString:printerInfo.address]) {
            return YES;
        }
    }
    return NO;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"xjsjw";
    PrinterCell *cell = (PrinterCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setPrinter: [self printerAtIndexPath:indexPath] delegate:self];
    return cell;
}

- (PrinterInfo *)printerAtIndexPath:(NSIndexPath *)indexPath {
    return [_printers objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForPrinter:(PrinterInfo *) findPrinter {
    int row = 0;
    for (PrinterInfo *printerInfo in _printers) {
        if ([printerInfo.address isEqualToString: findPrinter.address]) {
            return [NSIndexPath indexPathForItem:row inSection:0];
        }
        row++;
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_printers count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [_printersView indexPathForCell: (UICollectionViewCell *)textField.superview.superview];
    if (indexPath == nil) return;
    PrinterInfo *printerInfo = [self printerAtIndexPath:indexPath];
    if (printerInfo == nil) return;
    printerInfo.name = textField.text;
    [self updatePrinter:printerInfo];
}

- (void)updatePrinter:(PrinterInfo *)printerInfo {
    PrintInfo *printInfo = [[Cache getInstance] printInfo];
    NSMutableDictionary *dictionary = [printInfo toDictionary];
    [[Service getInstance] requestResource:@"printinfo" id:@"1" action:nil arguments:nil body:dictionary verb:HttpVerbPut success:^(ServiceResult *serviceResult) {

    }                                error:^(ServiceResult *serviceResult) {

    }                         progressInfo:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
