//
//  ViewDownloadedImageViewController.m
//  MobiquityJW
//
//  Created by Justin Wanajrat on 11/11/14.
//  Copyright (c) 2014 Justin Wanajrat. All rights reserved.
//

#import "ViewDownloadedImageViewController.h"

@interface ViewDownloadedImageViewController ()

@end

@implementation ViewDownloadedImageViewController
@synthesize downloadedImagePath;
- (void)viewDidLoad {
    [super viewDidLoad];
//    UIImage *img = [UIImage imageWithContentsOfFile:downloadedImagePath];
//    imageV.image = img;
    imageV.image = downloadedImagePath;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(DBRestClient *)restClient
{
    if (!restClient)
    {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    
    return restClient;
}
-(IBAction)dismissController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)uploadImage:(id)sender
{
    fileName = @"MobiQuityCamera";
    NSString *tmpPngFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",fileName]];
    UIImage *image = [self imageWithImage:imageV.image scaledToSize:CGSizeMake(75,75)];
            [UIImagePNGRepresentation(image) writeToFile:tmpPngFile atomically:YES];
            NSString *destDir = @"/Photos";
            [[self restClient] uploadFile:@"myFile.png" toPath:destDir
                            withParentRev:nil fromPath:tmpPngFile];
    
}
- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
-(void) restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata
{
    NSLog(@"file upload successfully to path: %@",metadata.path);
    NSString *message = @"file uploaded successfully!";
    //[Utils makeAlert:message];
    [self stopProgressBar];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dropbox" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    NSLog(@"File upload failed with error - %@", error);
    NSString *message = @"File upload failed";
    //[Utils makeAlert:message];
    [self stopProgressBar];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dropbox" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}
-(void)startProgress
{
    if (m_ctrlActivity ==nil)
    {
        m_ctrlActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    m_ctrlActivity.frame = CGRectMake(0.0, self.view.frame.size.height/2, 80.0, 80.0);
    m_ctrlActivity.center = self.view.center;
    [self.view addSubview:m_ctrlActivity];
    m_ctrlActivity.backgroundColor = [UIColor grayColor];
    [m_ctrlActivity layer].opacity = .8;
    [m_ctrlActivity layer].cornerRadius = 8.0;
    // [m_ctrlActivity bringSubviewToFront:self.navigationController.view];
    m_ctrlActivity.hidden = NO;
    [m_ctrlActivity startAnimating];
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [self.view setUserInteractionEnabled:NO];
}
-(void)stopProgressBar
{
    if (m_ctrlActivity != nil)
    {
        [m_ctrlActivity stopAnimating];
        m_ctrlActivity.hidden = YES;
        [self.view setUserInteractionEnabled:YES];
    }
    
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
