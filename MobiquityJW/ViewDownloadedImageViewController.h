//
//  ViewDownloadedImageViewController.h
//  MobiquityJW
//
//  Created by Justin Wanajrat on 11/11/14.
//  Copyright (c) 2014 Justin Wanajrat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
@interface ViewDownloadedImageViewController : UIViewController<DBRestClientDelegate>
{
    IBOutlet UIImageView *imageV;
    NSString *fileName;
    DBRestClient *restClient;
     UIActivityIndicatorView *m_ctrlActivity;
}
-(IBAction)uploadImage:(id)sender;
@property(nonatomic,retain) UIImage *downloadedImagePath;
-(IBAction)dismissController:(id)sender;
@end
