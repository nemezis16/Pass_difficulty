//
//  ViewController.m
//  Pass_difficulty
//
//  Created by Roman Osadchuk on 01.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "CheckPassViewController.h"

static NSString *const CellLoginIdentifier = @"loginCell";
static NSString *const CellEmailIdentifier = @"emailCell";

@interface CheckPassViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) CellStateSize cellStateSize;

@end

@implementation CheckPassViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellStateSize = CellStateSizeLow;
    [self registerCell];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case 0: {
            cell = [tableView dequeueReusableCellWithIdentifier:CellLoginIdentifier];
            
            break;
        }
        case 1: {
            CheckPassTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CheckPassTableViewCell class])];
            cell.delegate = self;
            cell.colorIndicatorArray = @[[UIColor blueColor],[UIColor greenColor],[UIColor greenColor],[UIColor brownColor],[UIColor blueColor],[UIColor greenColor],[UIColor greenColor],[UIColor brownColor]];
            
            return cell;
        }
        case 2: {
            cell = [tableView dequeueReusableCellWithIdentifier:CellEmailIdentifier];
            
            break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 1: {
            return (CGFloat)self.cellStateSize;
            break;
        }
        default: {
            return (CGFloat)CellStateSizeLow;
            break;
        }
    }
}

#pragma mark - CheckPassTableViewCellDelegate

- (void)validateTextFieldDidBeginEditing:(UITextField *)textField
{
    [self showIfBeginEditing];
}

- (void)validateTextFieldDidChangeCharacters:(UITextField *)sender
{
    [self cellStateForLenght:sender.text.length];
}

#pragma mark - Private

- (void)showIfBeginEditing
{
    if (self.cellStateSize == CellStateSizeLow) {
        self.cellStateSize = CellStateSizeMedium;
    }
    [self reloadTableViewCells];
}

- (void)cellStateForLenght:(NSInteger)lenght
{
    self.cellStateSize = lenght ? CellStateSizeHigh : CellStateSizeMedium;
    [self reloadTableViewCells];
}

- (void)registerCell
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([CheckPassTableViewCell class]) bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:NSStringFromClass([CheckPassTableViewCell class])];
}

- (void)reloadTableViewCells
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end
