//
//  ViewController.m
//  Pass_difficulty
//
//  Created by Roman Osadchuk on 01.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "ViewController.h"

static NSString *const CellIdentifier = @"loginCell";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

//@property (assign, nonatomic) BOOL validateFieldSelected;

@property (assign, nonatomic) CellStateSize cellStateSize;

@end

@implementation ViewController

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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        CheckPassTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CheckPassTableViewCell class])];
        cell.delegate = self;
//        cell.colorIndicatorArray = @[[UIColor blueColor],[UIColor greenColor],[UIColor greenColor],[UIColor brownColor],[UIColor blueColor],[UIColor greenColor],[UIColor greenColor],[UIColor brownColor]];
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        return cell;
    }
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
    if (self.cellStateSize == CellStateSizeLow) {
        self.cellStateSize = CellStateSizeMedium;
    }
    [self reloadTableViewCells];
}

- (void)validateTextFieldDidEndEditing:(UITextField *)textField
{
    
}

- (void)validateTextFieldDidChangeCharacters:(UITextField *)sender
{
    NSInteger lenght = sender.text.length;
    self.cellStateSize = lenght ? CellStateSizeHigh : CellStateSizeMedium;
    [self reloadTableViewCells];
}

#pragma mark - Private

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
