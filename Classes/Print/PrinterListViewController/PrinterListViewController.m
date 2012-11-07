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

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(200, 100);
    _printersView = [[UICollectionView alloc] initWithFrame:CGRectMake(100, 100, 300, 300) collectionViewLayout:layout];
    [self.view  addSubview:_printersView];
    _printersView.dataSource = self;

    UINib *nib = [UINib nibWithNibName:@"PrinterCell" bundle:[NSBundle mainBundle]];
    [_printersView registerNib:nib forCellWithReuseIdentifier:@"xjsjw"];
 //   [_printersView reloadData];

    [self findStarPrinters];
    
}

- (void) findStarPrinters {
    dispatch_queue_t myQueue = dispatch_queue_create("com.gazapps.myqueue", 0);
     dispatch_async(myQueue, ^{
         NSArray *activeStarPrinters = [SMPort searchPrinter];
         for (PortInfo *activeStarPrinter in activeStarPrinters) {
             PrinterInfo *printerInfo = [self printerByAddress:activeStarPrinter.portName];
             if (printerInfo != nil) {
                 printerInfo.isOnline = YES;
             }
         }
         dispatch_sync(dispatch_get_main_queue(), ^{
         });//end block
     });
}

- (PrinterInfo *)printerByAddress:(NSString *)name {
    for (PrinterInfo *printerInfo in _printers) {
        if ([printerInfo.address isEqualToString: name]) {
            return printerInfo;
        }
    }
    return nil;
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
    [[Service getInstance] requestResource:@"printinfo" id:@"1" action:nil arguments:nil body:dictionary method:@"PUT" success:^(ServiceResult *serviceResult) {

    } error: ^(ServiceResult *serviceResult) {

    } progressInfo:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
