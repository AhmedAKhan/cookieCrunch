//
//  RWTViewController.m
//  cookieCrunch
//
//  Created by Ahmed Arif Khan on 2014-06-21.
//  Copyright (c) 2014 Ahmed Khan. All rights reserved.
//

#import "RWTViewController.h"
#import "RWTMyScene.h"
#import "RWTLevel.h"
@import AVFoundation;

@interface RWTViewController ()

@property (strong, nonatomic) RWTLevel * level;
@property (strong, nonatomic) RWTMyScene * scene;

@property (assign, nonatomic) NSUInteger movesLeft;
@property (assign, nonatomic) NSUInteger score;

@property (weak, nonatomic) IBOutlet UILabel * targetLabel;
@property (weak, nonatomic) IBOutlet UILabel * movesLabel;
@property (weak, nonatomic) IBOutlet UILabel * scoreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *gameOverPanel;
@property (weak, nonatomic) IBOutlet UIButton * shuffleButton;

@property (strong, nonatomic) UITapGestureRecognizer * tapGestureRecognizer;

@property (strong, nonatomic) AVAudioPlayer * backgroundMusic;

@end

@implementation RWTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.multipleTouchEnabled = NO;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    self.scene = [RWTMyScene sceneWithSize:skView.bounds.size];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    
    self.level = [[RWTLevel alloc] initWithFile:@"Level_1"];
    self.scene.level = self.level;
    [self.scene addTiles];
    
    id block = ^(RWTSwap *swap){
        self.view.userInteractionEnabled = NO;
        
        if([self.level isPossibleSwap:swap]){
            [self.level performSwap:swap];
            [self.scene animateSwap:swap completion:^{
                //NSLog(@"the game just animated a swap");
                [self handleMathces];//self.view.userInteractionEnabled = YES;
            }];
        }else{
            [self.scene animateInvalidSwap:swap completion:^{
                self.view.userInteractionEnabled = YES;
            }];
        }
    };
    
    self.scene.swipeHandler = block;
    self.gameOverPanel.hidden = YES;
    
    // Present the scene.
    [skView presentScene:self.scene];
    
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"Mining by Moonlight" withExtension:@"mp3"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.backgroundMusic.numberOfLoops = -1;
    [self.backgroundMusic play];
    
    [self beginGame];
}

-(void)updateLabels{
    NSLog(@"movesLeft:%lu", (long)self.movesLeft);
    
    self.targetLabel.text = [NSString stringWithFormat:@"%lu", (long)self.level.targetScore];
    self.movesLabel.text = [NSString stringWithFormat:@"%lu", (long)self.movesLeft];
    self.scoreLabel.text = [NSString stringWithFormat:@"%lu", (long)self.score];
}

-(void)handleMathces{
    
    NSSet * chains = [self.level removeMatches];
    if([chains count] == 0){
        [self beginNextTurn];
        return;
    }
    
    [self.scene animateMatchedCookies:chains completion:^{
        
        for(RWTChain * chain in chains){
            self.score += chain.score;
        }
        [self updateLabels];
        
        NSArray * columns = [self.level fillHoles];
        [self.scene animateFallingCookies:columns completion:^{
            
            NSArray * columns = [self.level topUpCookies];
            [self.scene animateNewCookies:columns completion:^{
                [self handleMathces];
            }];
        }];
    }];
}


-(void)beginNextTurn{
    [self decrementMoves];
    [self.level detectPossibleSwaps];
    [self.level resetComboMultiplier];
    self.view.userInteractionEnabled = YES;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

-(void)beginGame{
    
    self.movesLeft = self.level.maximumMoves;
    self.score = 0;
    [self updateLabels];
    [self.level resetComboMultiplier];
    [self decrementMoves];
    [self.scene animateGameBegin];
    
    [self shuffle];
}

-(void)decrementMoves{
    self.movesLeft--;
    
    NSLog(@"self.score:%i targetScore:%i",self.score, self.level.targetScore);
    if(self.score >= self.level.targetScore){
        NSLog(@"inside the if statement");
        self.gameOverPanel.image = [UIImage imageNamed:@"LevelComplete"];
        [self showGameOver];
    }else if (self.movesLeft == 0){
        NSLog(@"inside the second if statement");
        self.gameOverPanel.image = [UIImage imageNamed:@"GameOver"];
        [self showGameOver];
    }
    
    [self updateLabels];
}

-(void)shuffle{
    [self.scene removeAllCookieSprite];
    
    NSSet * newCookies = [self.level shuffle];
    [self.scene addSpriteForCookies:newCookies];
}

-(void)showGameOver{
    [self.scene animateGameBegin];
    self.gameOverPanel.hidden = NO;
    self.shuffleButton.hidden = YES;
    self.scene.userInteractionEnabled = NO;
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideGameOver)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

-(void)hideGameOver{
    [self.view removeGestureRecognizer:self.tapGestureRecognizer];
    self.tapGestureRecognizer = nil;
    
    self.shuffleButton.hidden = NO;
    self.gameOverPanel.hidden = YES;
    self.scene.userInteractionEnabled = YES;
    
    [self beginGame];
}

-(IBAction)shuffleButtonPressed:(id)sender{
    [self shuffle];
    [self decrementMoves];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
