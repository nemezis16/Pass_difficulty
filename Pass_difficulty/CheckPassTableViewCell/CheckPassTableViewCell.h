//
//  CheckPassTableViewCell.h
//  Pass_difficulty
//
//  Created by Roman Osadchuk on 01.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CellStateSize) {
    CellStateSizeLow = 30,
    CellStateSizeMedium = 50,
    CellStateSizeHigh = 80,
};

@protocol CheckPassTableViewCellDelegate <NSObject>

@required
- (void)validateTextFieldDidBeginEditing:(UITextField *)textField;
- (void)validateTextFieldDidChangeCharacters:(UITextField *)sender;

@optional
- (void)validateTextFieldDidEndEditing:(UITextField *)textField;

@end

@interface CheckPassTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (strong, nonatomic) NSArray <UIColor *> *colorIndicatorArray;
@property (strong, nonatomic) NSArray <NSString *> *commentTextArray;

@property (weak, nonatomic) id <CheckPassTableViewCellDelegate> delegate;

@end
