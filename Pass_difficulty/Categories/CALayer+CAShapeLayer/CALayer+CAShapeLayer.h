//
//  CALayer+CALayer_CAShapeLayer.h
//  Pass_difficulty
//
//  Created by Roman Osadchuk on 08.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (CAShapeLayer)

- (CAShapeLayer *)shapeLayer;

- (void)addShapeLayer:(CAShapeLayer *)shapeLayer;

@end
