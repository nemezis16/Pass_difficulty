//
//  CheckPassTableViewController.m
//  Pass_difficulty
//
//  Created by Roman Osadchuk on 09.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "CheckPassTableViewController.h"

#import "CALayer+CAShapeLayer.h"

typedef NS_ENUM(NSUInteger, CellStateSize) {
    CellStateSizeLow = 30,
    CellStateSizeMedium = 50,
    CellStateSizeHigh = 80,
};

static NSInteger const typeStepForIndicator = 3;

static CGFloat const indicatorInterval = 10.f;
static CGFloat const indicatorHeight = 8.f;
static CGFloat const shapeLineWidth = 8.f;

static CGFloat const alphaAnimationDuration = 0.3f;
static CGFloat const strokeAnimationDuration = 0.1f;

@interface CheckPassTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *validateTextField;
@property (weak, nonatomic) IBOutlet UIView *indicatorContainerView;
@property (weak, nonatomic) IBOutlet UIView *commentIndicatorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@property (strong, nonatomic) NSMutableArray *indicatorLayersArray;

@property (strong, nonatomic) NSArray <UIColor *> *colorIndicatorArray;
@property (strong, nonatomic) NSArray <NSString *> *commentTextArray;

@property (assign, nonatomic) CellStateSize cellStateSize;

@end

@implementation CheckPassTableViewController
@synthesize colorIndicatorArray = _colorIndicatorArray;

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareIndicators];
    [self prepareInitialState];
    [self addObserverToIndicators];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Accessors

- (void)setColorIndicatorArray:(NSArray<UIColor *> *)colorIndicatorArray
{
    _colorIndicatorArray = colorIndicatorArray ;
    
    [self prepareIndicators];
    [self updateIndicators];
}

- (NSArray *)colorIndicatorArray
{
    if (!_colorIndicatorArray) {
        _colorIndicatorArray = @[[UIColor redColor],[UIColor orangeColor],[UIColor yellowColor],[UIColor greenColor]];
    }
    
    return _colorIndicatorArray;
}

- (NSArray<NSString *> *)commentTextArray
{
    if (!_commentTextArray) {
        _commentTextArray = @[@"Bad", @"Better", @"Good", @"Nice!"];
    }
    
    return _commentTextArray;
}

#pragma mark - IBActions

- (IBAction)validateTextFieldDidBeginEditing:(id)sender
{
    [self showIfBeginEditing];
}

- (IBAction)validateTextFieldDidEndEditing:(id)sender
{

}

- (IBAction)validateTextFieldDidChangeCharacters:(UITextField *)sender
{
    NSInteger lenght = sender.text.length;
    [self configureIndicatorsWithTextLenght:lenght];
}

#pragma mark - UITableViewDataSource

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

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"bounds"]){
        [self updateIndicators];
    }
}

#pragma mark - Private

#pragma mark - Perfomance

- (void)prepareIndicators
{
    self.indicatorLayersArray = [NSMutableArray array];
    for (int i =0; i < self.colorIndicatorArray.count; i++) {
        UIColor *color = self.colorIndicatorArray[i];
        NSString *layerName = [NSString stringWithFormat:@"%@_%i",color.description,i];
        
        CALayer *layer = [self indicatorLayerWithName:layerName];
        [self.indicatorContainerView.layer addSublayer:layer];
        [self.indicatorLayersArray addObject:layer];
    }
}

- (void)prepareInitialState
{
    self.cellStateSize = CellStateSizeLow;
    self.commentIndicatorContainerView.layer.opacity = 0.f;
    self.commentLabel.layer.opacity = 0.f;
}

- (void)showIfBeginEditing
{
    if (!self.commentIndicatorContainerView.layer.opacity) {
        [self addAnimationToShowIndicators:YES];
    }
    
    if (self.cellStateSize == CellStateSizeLow) {
        self.cellStateSize = CellStateSizeMedium;
    }
    
    [self reloadTableViewCells];
}

- (void)configureIndicatorsWithTextLenght:(NSInteger)lenght
{
    if (lenght && !self.commentLabel.layer.opacity) {
        [self addAnimationToShowCommentLabel:YES];
    } else if (!lenght){
        [self addAnimationToShowCommentLabel:NO];
    }
    
    [self progressAnimationsWithTextLenght:lenght];
    [self regressAnimationsWithTextLenght:lenght];
    
    self.cellStateSize = lenght ? CellStateSizeHigh : CellStateSizeMedium;
    [self reloadTableViewCells];
}

- (void)updateIndicators
{
    NSInteger indicatorCount = self.colorIndicatorArray.count;
    CGFloat quartPart = CGRectGetWidth(self.indicatorContainerView.frame)/ self.indicatorLayersArray.count;
    
    CGFloat yPoint = CGRectGetHeight(self.indicatorContainerView.bounds) / 2;
    CGFloat indicatorWidth = quartPart - ((indicatorCount - 1) * indicatorInterval /  indicatorCount);
    
    for (int i = 0; i < self.indicatorLayersArray.count; i++) {
        CALayer *layer = self.indicatorLayersArray[i];
        if ([self.indicatorContainerView.layer.sublayers containsObject:layer]) {
            CGRect layerFrame = CGRectMake((indicatorWidth + indicatorInterval) * i, yPoint, indicatorWidth, indicatorHeight);
            layer.frame = layerFrame;
            [self updateShapeLayerAtLayer:layer];
        }
    }
}

- (void)updateShapeLayerAtLayer:(CALayer *)layer
{
    CAShapeLayer *shapeLayer = [layer shapeLayer];
    if (shapeLayer) {
        CGColorRef shapeLayerColor = [layer shapeLayer].strokeColor;
        [shapeLayer removeFromSuperlayer];
        
        shapeLayer = [self shapeLayerForLayer:layer withCGColor:shapeLayerColor];
        [layer addShapeLayer:shapeLayer];
    }
}

#pragma mark - Drawings

- (CALayer *)indicatorLayerWithName:(NSString *)name
{
    CALayer *indicatorLayer = [[CALayer alloc] init];
    indicatorLayer.name = name;
    indicatorLayer.borderWidth = 0.5f;
    indicatorLayer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.3f].CGColor;
    indicatorLayer.backgroundColor = [UIColor colorWithWhite:0.8f alpha:0.1f].CGColor;
    
    return indicatorLayer;
}

- (UIBezierPath *)bezierPathForRect:(CGRect)rect
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0, CGRectGetHeight(rect) / 2)];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect) / 2)];
    [bezierPath closePath];
    
    return bezierPath;
}

- (CAShapeLayer *)shapeLayerForLayer:(CALayer *)layer withCGColor:(CGColorRef)color
{
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.name = layer.name;
    pathLayer.frame = layer.bounds;
    pathLayer.strokeColor = color;
    pathLayer.path = [self bezierPathForRect:layer.bounds].CGPath;
    pathLayer.lineWidth = shapeLineWidth;
    
    return pathLayer;
}

#pragma mark - ManageAnimations

- (void)addAnimationToShowIndicators:(BOOL)show
{
    CGFloat toValue = show ? 1.f : 0.f;
    CGFloat fromValue = show ? 0.f : 1.f;
    
    CABasicAnimation *alphaAnimation = [self alphaAnimationFromValue:fromValue toValue:toValue duration:alphaAnimationDuration];
    self.commentIndicatorContainerView.layer.opacity = toValue;
    [self.commentIndicatorContainerView.layer addAnimation:alphaAnimation forKey:nil];
}

- (void)addAnimationToShowCommentLabel:(BOOL)show
{
    CABasicAnimation *alphaAnimation = [self alphaAnimationFromValue:0.f toValue:1.f duration:alphaAnimationDuration * 3];
    self.commentLabel.layer.opacity = 1.f;
    [self.commentLabel.layer addAnimation:alphaAnimation forKey:nil];
}

- (void)strokeEndAnimationWithIndicatorLayer:(CALayer *)layer CGColor:(CGColorRef)color
{
    CABasicAnimation *pathAnimation = [self strokeAnimationFromValue:0 toValue:1 duration:strokeAnimationDuration strokeEnd:YES];
    
    CAShapeLayer *shapeLayer = [self shapeLayerForLayer:layer withCGColor:color];
    [layer addShapeLayer:shapeLayer];
    [shapeLayer addAnimation:pathAnimation forKey:nil];
}

- (void)strokeStartAnimationWithIndicatorLayer:(CALayer *)layer
{
    CABasicAnimation *pathAnimation = [self strokeAnimationFromValue:0 toValue:1 duration:strokeAnimationDuration strokeEnd:NO];
    
    CAShapeLayer *shapeLayer = [layer shapeLayer];
    
    if (![shapeLayer animationForKey:@"strokeStart"]) {
        [CATransaction begin];
        [CATransaction setCompletionBlock: ^{
            [shapeLayer removeFromSuperlayer];
        }];
        shapeLayer.strokeStart = [pathAnimation.toValue floatValue];
        [shapeLayer addAnimation:pathAnimation forKey:@"strokeStart"];
        [CATransaction commit];
    }
}

- (void)progressAnimationsWithTextLenght:(NSInteger)lenght
{
    NSInteger countIndicator = lenght / typeStepForIndicator;
    
    if (countIndicator < self.indicatorLayersArray.count) {
        UIColor *color = self.colorIndicatorArray[countIndicator];
        self.commentLabel.textColor = color;
        
        for (int i = 0; i < self.indicatorLayersArray.count; i++) {
            CALayer *layer = self.indicatorLayersArray[i];
            UIColor *color = self.colorIndicatorArray[i];
            [self strokeEndAnimationWithIndicatorLayer:layer CGColor:color.CGColor];
        }
    }
    
    if (countIndicator < self.commentTextArray.count) {
        self.commentLabel.text = self.commentTextArray[countIndicator];
    }
}

- (void)regressAnimationsWithTextLenght:(NSInteger)lenght
{
    NSInteger countIndicator = lenght / typeStepForIndicator + 1;
    
    if (countIndicator < self.indicatorLayersArray.count) {
        [self strokeStartAnimationWithIndicatorLayer:self.indicatorLayersArray[countIndicator]];
        
        for (int i = 0; i < self.indicatorLayersArray.count; i++) {
            if (i > countIndicator) {
                [self strokeStartAnimationWithIndicatorLayer:self.indicatorLayersArray[i]];
            }
        }
        if (!lenght) {
            self.commentLabel.text = @"";
            for (int i = 0; i < self.indicatorLayersArray.count; i++) {
                [self strokeStartAnimationWithIndicatorLayer:self.indicatorLayersArray[i]];
            }
        }
    }
}

#pragma mark - Animations

- (CABasicAnimation *)alphaAnimationFromValue:(CGFloat)from toValue:(CGFloat)to duration:(CGFloat)duration
{
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.duration = duration;
    alphaAnimation.fromValue =  @(from);
    alphaAnimation.toValue = @(to);
    
    return alphaAnimation;
}

- (CABasicAnimation *)strokeAnimationFromValue:(CGFloat)from toValue:(CGFloat)to duration:(CGFloat)duration strokeEnd:(BOOL)strokeEnd
{
    NSString *keyPath = strokeEnd ? @"strokeEnd" : @"strokeStart";
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
    pathAnimation.delegate = self;
    pathAnimation.duration = duration;
    pathAnimation.fromValue = @(from);
    pathAnimation.toValue = @(to);
    
    return pathAnimation;
}

#pragma mark - AdditionalMethods

- (void)addObserverToIndicators
{
    [self.indicatorContainerView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)reloadTableViewCells
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end

