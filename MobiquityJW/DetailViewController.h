//
//  DetailViewController.h
//  MobiquityJW
//
//  Created by Justin Wanajrat on 11/11/14.
//  Copyright (c) 2014 Justin Wanajrat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ViewDownloadedImageViewController.h"
#import "DownloadImagesViewController.h"
@interface DetailViewController : UIViewController<DBRestClientDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    DBRestClient *restClient;
    NSMutableArray *paths;
     UIActivityIndicatorView *m_ctrlActivity;
    UIImagePickerController *imagePicker;
    ALAssetsLibrary         *library;
    NSString *fileName;
    NSString *url;
    
    IBOutlet UIButton *albumButton;
    IBOutlet UIButton *uploadButton;
    IBOutlet UIButton *logOffButton;
    UIImage *selectedImage;
    BOOL isPhotoTaken;

}
-(IBAction)getAlbums:(id)sender;
-(IBAction)uploadImages:(id)sender;
-(IBAction)logOff:(id)sender;
-(DBRestClient *)restClient;
@end
