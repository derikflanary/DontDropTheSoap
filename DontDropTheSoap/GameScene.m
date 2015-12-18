//
//  GameScene.m
//  DontDropTheSoap
//
//  Created by Derik Flanary on 11/12/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

#import "GameScene.h"

typedef NS_OPTIONS(uint32_t, CollisionCategory) {
    CollisionCategorySoap   = 0x1 << 0,
    CollisionCategoryDish     = 0x1 << 1,
};

@interface GameScene ()

@property (nonatomic, strong) SKSpriteNode *soap;
@property (nonatomic, strong) SKSpriteNode *dish;

@end

@implementation GameScene

- (id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor blueColor];
    }
    return self;
}
-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.soap = [[SKSpriteNode alloc]initWithColor:[UIColor whiteColor] size:CGSizeMake(100, 30)];
    self.soap.position = CGPointMake(self.view.frame.size.width/2, 100);
    self.soap.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.soap.size];
    self.soap.physicsBody.dynamic = YES;
    self.soap.physicsBody.allowsRotation = YES;
    self.soap.physicsBody.usesPreciseCollisionDetection = YES;
    self.soap.physicsBody.categoryBitMask = CollisionCategorySoap;
    self.soap.physicsBody.contactTestBitMask = CollisionCategoryDish;
    [self addChild:self.soap];
    
    self.dish = [[SKSpriteNode alloc]initWithColor:[UIColor lightGrayColor] size:CGSizeMake(200, 10)];
    self.dish.position = CGPointMake(self.view.frame.size.width/2, CGRectGetMinY(self.soap.frame));
    self.dish.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.dish.size];
    self.dish.physicsBody.dynamic = NO;
    self.dish.physicsBody.allowsRotation = YES;
    self.dish.physicsBody.usesPreciseCollisionDetection = YES;
    self.dish.physicsBody.categoryBitMask = CollisionCategoryDish;
    self.dish.physicsBody.contactTestBitMask = CollisionCategorySoap;
    [self addChild:self.dish];
    
    self.physicsWorld.gravity = CGVectorMake(0.0f, -3.0f);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
