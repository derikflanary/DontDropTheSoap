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
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic, strong) UIButton *restartButton;
@property (nonatomic, assign) BOOL gameStarted;
@property (nonatomic, assign) BOOL startGame;
@property (nonatomic, assign) BOOL gameOver;
@property (nonatomic, strong) SKLabelNode *timerNode;

@end

@implementation GameScene

- (id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor cyanColor];
        
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 0.2;
        
            }
    return self;
}

- (void)didMoveToView:(SKView *)view {
    
    SKSpriteNode *background = [[SKSpriteNode alloc]initWithColor:[UIColor cyanColor] size:self.view.frame.size];
    background.size = self.view.frame.size;
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    background.zPosition = 0;
    [self addChild:background];
    
    self.restartButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, 10, 100, 20)];
    [self.restartButton setTitle:@"Restart" forState:UIControlStateNormal];
    [self.restartButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.restartButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    self.restartButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [self.restartButton addTarget:self action:@selector(restartGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.restartButton];
    
    self.timerNode = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
    self.timerNode.fontSize = 40;
    self.timerNode.position = CGPointMake(CGRectGetMidX(self.frame),
                                          580);
    self.timerNode.fontColor = [SKColor blackColor];
    self.timerNode.name = @"countDown";
    self.timerNode.zPosition = 2;
    [self addChild:self.timerNode];
    
    [self setUpScene];
}

- (void)setUpScene{
    /* Setup your scene here */
    self.soap = [[SKSpriteNode alloc]initWithImageNamed:@"soap"];
    self.soap.size = CGSizeMake(50, 15);
    self.soap.position = CGPointMake(self.view.frame.size.width/2, 150);
    self.soap.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.soap.size];
    self.soap.physicsBody.dynamic = YES;
    self.soap.physicsBody.allowsRotation = YES;
    self.soap.physicsBody.usesPreciseCollisionDetection = YES;
    self.soap.physicsBody.categoryBitMask = CollisionCategorySoap;
    self.soap.physicsBody.contactTestBitMask = CollisionCategoryDish;
    self.soap.physicsBody.mass = 0.02;
    self.soap.physicsBody.friction = 0.0;
    self.soap.zPosition = 1;
    
    self.dish = [[SKSpriteNode alloc]initWithImageNamed:@"dish"];
    self.dish.size = CGSizeMake(120, 7);
    self.dish.position = CGPointMake(self.view.frame.size.width/2, CGRectGetMinY(self.soap.frame) - 50);
    self.dish.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.dish.size];
    self.dish.physicsBody.dynamic = NO;
    self.dish.physicsBody.allowsRotation = YES;
    self.dish.physicsBody.usesPreciseCollisionDetection = YES;
    self.dish.physicsBody.categoryBitMask = CollisionCategoryDish;
    self.dish.physicsBody.contactTestBitMask = CollisionCategorySoap;
    self.dish.zPosition = 1;
    [self addChild:self.dish];
    
    
    self.physicsWorld.gravity = CGVectorMake(0.0f, -5.0f);
    

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
    if (fabs(data.acceleration.x) > 0.0) {
        NSLog(@"acceleration value = %f",data.acceleration.x);
        [self.soap.physicsBody applyForce:CGVectorMake(30.0 * data.acceleration.x, 0.0)];
    }
}

- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [self updateSoapPositionFromMotionManager];
    
    if (self.startGame) {
        self.startTime = currentTime;
        self.startGame = NO;
        self.gameStarted = YES;
        self.lastUpdateTimeInterval = 0;
    }
    
    CFTimeInterval timeSinceLast;
    if (self.gameStarted && !self.gameOver) {
        self.timerNode.text = [NSString stringWithFormat:@"%i", (int)(currentTime - self.startTime)];
        timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    }
    
    if (timeSinceLast > 1.0) {
        [self applyRandomForceToSoap];
        self.lastUpdateTimeInterval = currentTime;
    }

    if (self.soap.position.y < -20) {
        [self.soap removeFromParent];
        self.gameOver = YES;
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
    
    [self.soap.physicsBody applyForce:CGVectorMake(100.0 * r, 0.0)];

}

- (void)endGame{
    [self stopMonitoringAcceleration];
}

- (void)restartGame{
    self.gameStarted = NO;
    self.gameOver = NO;
    
    [self.soap removeFromParent];
    [self.dish removeFromParent];
    [self removeAllActions];
    
    self.timerNode.text = @"0";

    [self setUpScene];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!self.gameStarted) {
        [self addChild:self.soap];
        [self startMonitoringAcceleration];
        self.startGame = YES;
        
    }
}



@end
