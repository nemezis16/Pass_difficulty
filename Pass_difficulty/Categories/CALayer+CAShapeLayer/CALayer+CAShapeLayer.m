//
//  CALayer+CALayer_CAShapeLayer.m
//  Pass_difficulty
//
//  Created by Roman Osadchuk on 08.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "CALayer+CAShapeLayer.h"

@implementation CALayer (CAShapeLayer)

- (CAShapeLayer *)shapeLayer
{
    CAShapeLayer *shapeLayer = nil;
    for (CALayer *sublayer in [self.sublayers copy]) {
        if ([sublayer.name isEqualToString:self.name] && [sublayer isKindOfClass:[CAShapeLayer class]]) {
            shapeLayer = (CAShapeLayer *)sublayer;
            break;
        }
    }
    
    return shapeLayer;
}

- (void)addShapeLayer:(CAShapeLayer *)shapeLayer
{
    if (self.sublayers.count) {
        for (CALayer *sublayer in [self.sublayers copy]) {
            if ([sublayer.name isEqualToString:shapeLayer.name]) {
                break;
            }
        }
    } else {
        [self addSublayer:shapeLayer];
    }
}

@end
