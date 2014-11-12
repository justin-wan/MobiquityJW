//
//  DownloadImagesViewController.h
//  MobiquityJW
//
//  Created by Justin Wanajrat on 11/11/14.
//  Copyright (c) 2014 Justin Wanajrat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "ViewDownloadedImageViewController.h"
#import "CollectionImageCellCollectionViewCell.h"
@interface DownloadImagesViewController : UIViewController<UIAlertViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    IBOutlet UITableView *imagesPathTable;
    DBRestClient *restClient;
    UIActivityIndicatorView *m_ctrlActivity;
    NSString *downloadedImagePath;
    NSMutableArray *downloadedImagesArray;
    
    IBOutlet UICollectionView *imagesPathCollectionView;
    
    IBOutlet UIView *streachView;
    IBOutlet UIImageView *streachImageView;
    IBOutlet UILabel *latitudeLabel;
    IBOutlet UILabel *longitudeLabel;
    IBOutlet UIButton *closeButton;
    int iv;
    
}
@property(nonatomic,retain) NSMutableArray *pathsArray;
@property(nonatomic,retain) NSMutableArray *uploadArray;
-(DBRestClient *)restClient;
-(IBAction)dismissController:(id)sender;
-(IBAction)removeStreachView:(id)sender;
@end
