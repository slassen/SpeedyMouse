//
//  SELRootController.m
//  Speedy Mouse
//
//  Created by Scott Lassen on 12/14/14.
//  Copyright (c) 2014 Scott Lassen. All rights reserved.
//

#import "SELRootController.h"

@interface SELRootController ()

@end

@implementation SELRootController

-(instancetype) init {
//    _gameViewController = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
    _gameViewController = [GameViewController gameView];
    self = [super initWithRootViewController:_gameViewController];
    if (self) {
        self.navigationBarHidden = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
