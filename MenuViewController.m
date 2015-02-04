//
//  MenuViewController.m
//  Speedy Mouse
//
//  Created by Scott Lassen on 2/3/15.
//  Copyright (c) 2015 Scott Lassen. All rights reserved.
//

#import "MenuViewController.h"
#import "SELRootController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Create the background image.
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoadingScreen2208Loading.png"]];
    imageView.userInteractionEnabled = true;
    imageView.frame = self.view.frame;
    [self.view addSubview:imageView];

    // Create the button for the endless maze on the right side of the screen.
    UIButton *endlessMazeButton = [[UIButton alloc] init];
    CGSize endlessMazeButtonSize = CGSizeMake(80, 80);
    CGRect endlessMazeButtonFrame = CGRectMake(self.view.frame.size.width - endlessMazeButtonSize.width - 10, self.view.frame.size.height - endlessMazeButtonSize.height - 10, endlessMazeButtonSize.width, endlessMazeButtonSize.height);
    [endlessMazeButton setFrame:endlessMazeButtonFrame];
    [endlessMazeButton setImage:[UIImage imageNamed:@"cheese.png"] forState:UIControlStateNormal];
    [endlessMazeButton addTarget:self action:@selector(launchEndlessMaze:) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:endlessMazeButton];
}

-(void)launchEndlessMaze: (id)sender {
    SELRootController *endlessMaze = [[SELRootController alloc] init];
    [self presentViewController:endlessMaze animated:true completion:nil];
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
