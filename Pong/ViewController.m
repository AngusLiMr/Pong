//
//  ViewController.m
//  Pong
//
//  Created by AngusLi on 15/9/26.
//  Copyright (c) 2015年 AngusLi. All rights reserved.
//

#import "ViewController.h"
#define MAX_SCORE 2

@interface ViewController ()<UIAlertViewDelegate>
{
    
    UITouch *touch1,*touch2;
    float dx,dy,speed;
    NSTimer* timer;
    UIAlertView* alert;
}
@property(nonatomic,strong)IBOutlet UIView *com1,*com2,*ball;
@property(nonatomic,strong)IBOutlet UILabel *score1,*score2;
@end

@implementation ViewController
@synthesize com1,com2,ball,score1,score2;
CGSize mainSize;

- (void)viewDidLoad {
    [super viewDidLoad];
    

    mainSize = [UIScreen mainScreen].bounds.size;
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view setMultipleTouchEnabled:YES];
    
    com1 = [[UIView alloc]initWithFrame:CGRectMake((mainSize.width-60)/2, 60, 60, 20)];
    [com1 setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:com1];
    
    
    com2 = [[UIView alloc]initWithFrame:CGRectMake((mainSize.width-60)/2, mainSize.height-80, 60, 20)];
    [com2 setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:com2];
    
    ball = [[UIView alloc]initWithFrame:CGRectMake(mainSize.width/2, mainSize.height/2, 10, 10)];
    [ball setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:ball];
    
    score1 = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 100, 30)];
    [score1 setTextColor:[UIColor whiteColor]];
    [self.view addSubview:score1];
    
    score2 = [[UILabel alloc]initWithFrame:CGRectMake(20, mainSize.height-20, 100, 30)];
    [score2 setTextColor:[UIColor whiteColor]];
    [self.view addSubview:score2];

    
    score1.text = @"0";
    score2.text = @"0";
    
    [self newGame];
    
}
//game round control
-(void)reset{
    if((arc4random()%2)==0)dx=-1;else dx=1;
    
    if(dy!=0)dy=-dy;else if((arc4random()%2)==0)dy=-1;else dy=1;
    
    ball.center = CGPointMake(15+arc4random()%(320-30), 240);
    
    speed = 2;
                            
}



-(void)start{
    if(timer == nil){
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(animate) userInfo:nil repeats:YES];
        ball.hidden = NO;
    
    }
}

-(void)stop{
    if(timer!=nil){
        timer = nil;
    }
    ball.hidden=YES;
}

//animation and collision
-(void)animate{
    ball.center = CGPointMake(ball.center.x+dx*speed, ball.center.y+dy*speed);
    
    [self checkCollision:CGRectMake(-5, 0, 10, mainSize.height) Dirx:fabs(dx) Diry:0];
    [self checkCollision:CGRectMake(mainSize.width+5, 0, 10, mainSize.height) Dirx:-fabs(dx) Diry:0];
    [self checkCollision:com1.frame Dirx:(ball.center.x-com1.center.x)/10 Diry:1];
    [self checkCollision:com2.frame Dirx:(ball.center.x-com2.center.x)/10 Diry:-1];

    [self checkGoal];
}

-(BOOL)checkCollision:(CGRect)rect Dirx:(float)x Diry:(float)y{
    if(CGRectIntersectsRect(ball.frame, rect)){
        if(x!=0) dx=x;
        if(y!=0) dy=y;
        return YES;
    }
    return NO;
}

-(void)displayMessage:(NSString*)msg{
    if(alert)return;
    
    [self stop];
    
    alert = [[UIAlertView alloc]initWithTitle:@"Game" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}

-(void)newGame{
    [self reset];
    
    score1.text = @"0";
    score2.text = @"0";
    
    [self displayMessage:@"Ready to play?"];
}

-(BOOL)checkGoal{
    if(ball.center.y<0||ball.center.y>mainSize.height){
        int s1 = [score1.text intValue];
        int s2 = [score2.text intValue];
        if(alert==nil){
            if(ball.center.y<0)++s2;else ++s1;
        }
        
        score1.text = [NSString stringWithFormat:@"%u",s1];
        score2.text = [NSString stringWithFormat:@"%u",s2];
        
        
        if([self gameOver]==1){
            [self displayMessage:@"Player1 has won."];
            
        }else if ([self gameOver]==2){
            [self displayMessage:@"Player2 has won"];
        
        }else{
            [self reset];
        }
        //return true fall goal
        return  true;
    }
    //no goal
    return false;
}


-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    alert = nil;
    if([self gameOver]){
        [self newGame];
        return;
    }
    [self reset];
    [self start];
    
}

-(int)gameOver{
    
    if([score1.text intValue]>=MAX_SCORE)return 1;
    if([score2.text intValue]>=MAX_SCORE)return 2;
    
    return 0;
}

//touch event
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touch Began");
 
    for(UITouch* touch in touches){
        CGPoint touchPoint = [touch locationInView: self.view];
        if (touch1==nil&&touchPoint.y<mainSize.height/2) {
            touch1 = touch;
            com1.center = CGPointMake(touchPoint.x, com1.center.y);
        }
        else if(touch2==nil&&touchPoint.y>mainSize.height/2){
            touch2 = touch;
            com2.center = CGPointMake(touchPoint.x, com2.center.y);
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touch moved");
    for (UITouch* touch in touches) {
        CGPoint touchPoint = [touch locationInView:self.view];
        if(touch==touch1){
            com1.center = CGPointMake(touchPoint.x, com1.center.y);
        }else if(touch==touch2){
            com2.center = CGPointMake(touchPoint.x, com2.center.y);
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touch ended");
    for (UITouch* touch in touches) {
        if(touch == touch1)touch1 = nil;
        else if(touch==touch2)touch2 = nil;
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touch canceled");
    [self touchesEnded:touches withEvent:event];
}



@end
