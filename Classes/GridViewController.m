//
//  GridViewController.m
//  HarkPad
//
//  Created by Willem Bison on 15-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "GridViewController.h"

@implementation GridViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView
{
    GridView *aView = [[GridView alloc] initWithFrame:CGRectMake(0, 0, 300, 600)];
    self.view = aView;
    
    aView.dataSource = self;
    aView.delegate = self; 
}

- (GridView *) gridView
{
    return (GridView *)self.view;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == self.gridView.topView)
    {
        self.gridView.contentView.contentOffset = CGPointMake(scrollView.contentOffset.x, self.gridView.contentView.contentOffset.y);
    }
    if(scrollView == self.gridView.leftView)
    {
        self.gridView.contentView.contentOffset = CGPointMake(self.gridView.contentView.contentOffset.x, scrollView.contentOffset.y);
    }
//    self.gridView.topView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
//    self.gridView.leftView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);
}


//
//  GridViewDataSource delegate
//

- (NSUInteger) numberOfRowsInGridView: (GridView *)gridView
{
    return 0;
}

- (NSUInteger) numberOfColumnsInGridView: (GridView *)gridView
{
    return 0;
}

- (NSUInteger) numberOfLinesInGridView: (GridView *) gridView column: (NSUInteger)column row:(NSUInteger)row
{
    return 1;
}

- (GridViewCellLine *) gridView:(GridView *)gridView cellLineForPath:(CellPath *)path
{
    NSString *label;
    if(path.column == -1)
        label = [NSString stringWithFormat:@"Row %d", path.row];
    else if(path.row == -1)
        label = [NSString stringWithFormat:@"Column %d", path.column];
    else
        label = [NSString stringWithFormat:@"%d x %d", path.column, path.row];
    GridViewCellLine *cellLine = [[GridViewCellLine alloc] initWithTitle:label path:path];
    return cellLine;
}

- (float) gridView:(GridView *)gridView heightForLineAtPath:(CellPath *)path
{
    return 30.0;
}

//
//  GridViewDelegate
//

//- (void) gridView: (GridView *) gridView startsDragWithCellLine: (GridViewCellLine *)cellLine;
//- (void) gridView: (GridView *) gridView movesDragWithCellLine: (GridViewCellLine *)cellLine;
//- (void) gridView: (GridView *) gridView endsDragWithCellLine: (GridViewCellLine *)cellLine;
//- (void) gridView: (GridView *) gridView didSelectCellLine: (GridViewCellLine *)cellLine;
//- (void) gridView: (GridView *) gridView didDeselectCellLine: (GridViewCellLine *)cellLine;
//- (UIView *)gridView:(GridView *)gridView viewForSelectedCellLine: (GridViewCellLine *)cellLine;

- (bool) gridView: (GridView *) gridView canSelectCellLine: (GridViewCellLine *)cellLine
{
    return YES;
}

- (bool) gridView: (GridView *) gridView canDeleteCellLine: (GridViewCellLine *)cellLine
{
    return YES;
}


- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.gridView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
