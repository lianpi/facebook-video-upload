//
//  VideoUploadViewController.m
//  FacebookVideoUpload
//
//  Created by Will on 2/12/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import "VideoUploadViewController.h"
#import "VideoUploadAppDelegate.h"

@interface VideoUploadViewController ()
@property (strong, nonatomic) UINavigationController* navController;
@end

@implementation VideoUploadViewController

//@synthesize facebook = _facebook;
//@synthesize facebook;
@synthesize navController = _navController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //facebook = [[Facebook alloc] initWithAppId:@"537815409585422" andDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)buttonClicked:(id)sender
{
    VideoUploadAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    // The user has initiated a login, so call the openSession method
    // and show the login UX if necessary.
    [appDelegate openSessionWithAllowLoginUI:YES];
}


@end
