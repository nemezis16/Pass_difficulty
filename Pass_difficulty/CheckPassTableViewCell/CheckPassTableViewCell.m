//
//  CheckPassTableViewCell.m
//  Pass_difficulty
//
//  Created by Roman Osadchuk on 01.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "CheckPassTableViewCell.h"
#import "CALayer+CAShapeLayer.h"

static NSInteger const typeStepForIndicator = 3;

static CGFloat const indicatorInterval = 10.f;
static CGFloat const indicatorHeight = 8.f;
static CGFloat const shapeLineWidth = 8.f;

static CGFloat const alphaAnimationDuration = 0.3f;
static CGFloat const strokeAnimationDuration = 0.1f;

@interface CheckPassTableViewCell ()

@property (weak, nonatomic) IBOutlet UITextField *validateTextField;
@property (weak, nonatomic) IBOutlet UIView *indicatorContainerView;
@property (weak, nonatomic) IBOutlet UIView *commentIndicatorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@property (strong, nonatomic) NSMutableArray *indicatorLayersArray;

@end

@implementation CheckPassTableViewCell
@synthesize colorIndicatorArray = _colorIndicatorArray;

#pragma mark - LifeCycle

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    self.validateTextField.text = @"";
    self.commentLabel.text = @"";
    [self hideIndicatorsWithAnimation];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self prepareIndicators];
    
    self.commentIndicatorContainerView.layer.opacity = 0.f;
    self.commentLabel.layer.opacity = 0.f;
    
    //[self hideIndicatorsWithAnimation];
    [self.indicatorContainerView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
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
    if (!self.commentIndicatorContainerView.layer.opacity) {
        [self showIndicatorsWithAnimation];
    }
    
    if ([self.delegate respondsToSelector:@selector(validateTextFieldDidBeginEditing:)] && self.delegate) {
        [self.delegate validateTextFieldDidBeginEditing:self.validateTextField];
    }
}

- (IBAction)validateTextFieldDidEndEditing:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(validateTextFieldDidEndEditing:)] && self.delegate) {
        [self.delegate validateTextFieldDidEndEditing:self.validateTextField];
    }
}

- (IBAction)validateTextFieldDidChangeCharacters:(UITextField *)sender
{
    NSInteger lenght = self.validateTextField.text.length;
    if (lenght && !self.commentLabel.layer.opacity) {
        [self showCommentLabelWithAnimation];
    } else if (!lenght){
        [self hideCommentLabelWithAnimation];
    }
    
    [self progressAnimationsWithTextLenght:lenght];
    [self regressAnimationsWithTextLenght:lenght];
    
    if ([self.delegate respondsToSelector:@selector(validateTextFieldDidChangeCharacters:)]) {
        [self.delegate validateTextFieldDidChangeCharacters:sender];
    }
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"bounds"]){
        [self setNeedsLayout];
        [self layoutIfNeeded];
        [self updateIndicators];
    }
}

#pragma mark - Private

#pragma mark - Perfomance

- (CALayer *)addIndicatorLayerWithName:(NSString *)name
{
    CALayer *indicatorLayer = [[CALayer alloc] init];
    indicatorLayer.name = name;
    indicatorLayer.borderWidth = 0.5f;
    indicatorLayer.backgroundColor = [UIColor colorWithWhite:0.8f alpha:0.1f].CGColor;
    indicatorLayer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.3f].CGColor;
    [self.indicatorContainerView.layer addSublayer:indicatorLayer];
    
    return indicatorLayer;
}

- (void)prepareIndicators
{
    self.indicatorLayersArray = [NSMutableArray array];
    for (int i =0; i < self.colorIndicatorArray.count; i++) {
        UIColor *color = self.colorIndicatorArray[i];
        NSString *layerName = [NSString stringWithFormat:@"%@_%i",color.description,i];
        
        CALayer *layer = [self addIndicatorLayerWithName:layerName];
        [self.indicatorLayersArray addObject:layer];
    }
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

-(void)updateShapeLayerAtLayer:(CALayer *)layer
{
    CAShapeLayer *shapeLayer = [layer shapeLayer];
    if (shapeLayer) {
        CGColorRef shapeLayerColor = [layer shapeLayer].strokeColor;
        [shapeLayer removeFromSuperlayer];
        [self addShapeLayerToIndicatorLayer:layer withCGColor:shapeLayerColor];
    }
}

- (CAShapeLayer *)addShapeLayerToIndicatorLayer:(CALayer *)layer withCGColor:(CGColorRef)color
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0, CGRectGetHeight(layer.bounds) / 2)];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(layer.bounds), CGRectGetHeight(layer.bounds) / 2)];
    [bezierPath closePath];
    
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = layer.bounds;
    pathLayer.path = bezierPath.CGPath;
    pathLayer.strokeColor = color;
    pathLayer.lineWidth = shapeLineWidth;
    pathLayer.name = layer.name;
    
    [layer addShapeLayer:pathLayer];
    
    return pathLayer;
}

#pragma mark - ManageAnimations

- (void)showIndicatorsWithAnimation
{
    CABasicAnimation *alphaAnimation = [self alphaAnimationFromValue:0.f toValue:1.f duration:alphaAnimationDuration];
    self.commentIndicatorContainerView.layer.opacity = 1.f;
    [self.commentIndicatorContainerView.layer addAnimation:alphaAnimation forKey:nil];
}

- (void)hideIndicatorsWithAnimation
{
    CABasicAnimation *alphaAnimation = [self alphaAnimationFromValue:1.f toValue:0.f duration:alphaAnimationDuration];
    self.commentIndicatorContainerView.layer.opacity = 0.f;
    [self.commentIndicatorContainerView.layer addAnimation:alphaAnimation forKey:nil];
}

- (void)showCommentLabelWithAnimation
{
    CABasicAnimation *alphaAnimation = [self alphaAnimationFromValue:0.f toValue:1.f duration:alphaAnimationDuration];
    self.commentLabel.layer.opacity = 1.f;
    [self.commentLabel.layer addAnimation:alphaAnimation forKey:nil];
}

- (void)hideCommentLabelWithAnimation
{
    CABasicAnimation *alphaAnimation = [self alphaAnimationFromValue:1.f toValue:0.f duration:alphaAnimationDuration];
    self.commentLabel.layer.opacity = 0.f;
    [self.commentLabel.layer addAnimation:alphaAnimation forKey:nil];
}

- (void)strokeEndAnimationWithIndicatorLayer:(CALayer *)layer CGColor:(CGColorRef)color
{
    CABasicAnimation *pathAnimation = [self strokeAnimationFromValue:0 toValue:1 duration:strokeAnimationDuration strokeEnd:YES];
    
    CAShapeLayer *shapeLayer = [self addShapeLayerToIndicatorLayer:layer withCGColor:color];
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

@end
