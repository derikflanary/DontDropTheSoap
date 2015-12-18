//
//  GameScene.m
//  DontDropTheSoap
//
//  Created by Derik Flanary on 11/12/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

#import "GameScene.h"
#import <CoreMotion/CoreMotion.h>

typedef NS_OPTIONS(uint32_t, CollisionCategory) {
    CollisionCategorySoap   = 0x1 << 0,
    CollisionCategoryDish     = 0x1 << 1,
};

@interface GameScene ()

@property (nonatomic, strong) SKSpriteNode *soap;
@property (nonatomic, strong) SKSpriteNode *dish;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@end

@implementation GameScene

- (id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor cyanColor];
        
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 0.2;
        // 2
    }
    return self;
}

- (void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.soap = [[SKSpriteNode alloc]initWithColor:[UIColor whiteColor] size:CGSizeMake(50, 15)];
    self.soap.position = CGPointMake(self.view.frame.size.width/2, 100);
    self.soap.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.soap.size];
    self.soap.physicsBody.dynamic = YES;
    self.soap.physicsBody.allowsRotation = YES;
    self.soap.physicsBody.usesPreciseCollisionDetection = YES;
    self.soap.physicsBody.categoryBitMask = CollisionCategorySoap;
    self.soap.physicsBody.contactTestBitMask = CollisionCategoryDish;
    self.soap.physicsBody.mass = 0.02;
    self.soap.physicsBody.friction = 0.0;
    [self addChild:self.soap];
    
    self.dish = [[SKSpriteNode alloc]initWithColor:[UIColor lightGrayColor] size:CGSizeMake(120, 10)];
    self.dish.position = CGPointMake(self.view.frame.size.width/2, CGRectGetMinY(self.soap.frame));
    self.dish.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.dish.size];
    self.dish.physicsBody.dynamic = NO;
    self.dish.physicsBody.allowsRotation = YES;
    self.dish.physicsBody.usesPreciseCollisionDetection = YES;
    self.dish.physicsBody.categoryBitMask = CollisionCategoryDish;
    self.dish.physicsBody.contactTestBitMask = CollisionCategorySoap;
    [self addChild:self.dish];
    
    self.physicsWorld.gravity = CGVectorMake(0.0f, -3.0f);
    
    [self startMonitoringAcceleration];
}

- (void)startMonitoringAcceleration{
    if (_motionManager.accelerometerAvailable) {
        [_motionManager startAccelerometerUpdates];
        NSLog(@"accelerometer updates on...");
    }
}

- (void)stopMonitoringAcceleration{
    if (_motionManager.accelerometerAvailable && _motionManager.accelerometerActive) {
        [_motionManager stopAccelerometerUpdates];
        NSLog(@"accelerometer updates off...");
    }
}

- (void)updateSoapPositionFromMotionManager{
    CMAccelerometerData* data = _motionManager.accelerometerData;
    if (fabs(data.acceleration.x) > 0.2) {
        NSLog(@"acceleration value = %f",data.acceleration.y);
        [self.soap.physicsBody applyForce:CGVectorMake(40.0 * data.acceleration.y, 0.0)];
    }
}

- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [self updateSoapPositionFromMotionManager];
    
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    
    if (timeSinceLast > 5.0) {
        [self applyRandomForceToSoap];
    }
}

- (void)applyRandomForceToSoap{
    srand48(time(0));
    double r = drand48();
    r = r/5;
    NSUInteger i = arc4random_uniform(2);
    
    if (i == 1) {
        r = r * -1;
    }
    
    [self.soap.physicsBody applyForce:CGVectorMake(60.0 * r, 0.0)];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
//    for (UITouch *touch in touches) {
//        
//    }
}



@end
