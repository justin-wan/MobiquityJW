//
//  DetailViewController.m
//  MobiquityJW
//
//  Created by Justin Wanajrat on 11/11/14.
//  Copyright (c) 2014 Justin Wanajrat. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
-(DBRestClient *)restClient
{
    if (!restClient)
    {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    
    return restClient;
}
-(void) viewWillAppear:(BOOL)animated
{
//    if (isPhotoTaken == YES) {
//        ViewDownloadedImageViewController *view = [[ViewDownloadedImageViewController alloc] initWithNibName:@"ViewDownloadedImageViewController" bundle:nil];
//        view.downloadedImagePath = selectedImage;
//        [self presentViewController:view animated:YES completion:nil];
// 
//    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    isPhotoTaken = NO;
    library = [[ALAssetsLibrary alloc] init];
    albumButton.layer.cornerRadius = 10.0f;
    albumButton.layer.masksToBounds = YES;
    uploadButton.layer.cornerRadius = 10.0f;
    uploadButton.layer.masksToBounds = YES;
    logOffButton.layer.cornerRadius = 10.0f;
    logOffButton.layer.masksToBounds = YES;
    // Do any additional setup after loading the view from its nib.
}
-(void) viewDidAppear:(BOOL)animated
{
    //[self performSelector:@selector(takePhoto) withObject:nil afterDelay:0.3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -load meta data from DropBox

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    [self stopProgressBar];
    if (metadata.isDirectory)
    {
        
        NSLog(@"Folder '%@' contains:", metadata.path);
        paths = [[NSMutableArray alloc] init];
        for (DBMetadata *file in metadata.contents)
        {
            NSLog(@"%@", file.filename);
            [paths addObject:[NSString stringWithFormat:@"%@/%@",metadata.path,file.filename]];
        }
        
        NSLog(@"path array: %@",paths);
        
        DownloadImagesViewController *detailView = [[DownloadImagesViewController alloc] initWithNibName:@"DownloadImagesViewController" bundle:nil];
        
        detailView.pathsArray = paths;
        [self presentViewController:detailView animated:YES completion:nil];
    }
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error
{
    [self stopProgressBar];
    NSLog(@"Error loading metadata: %@", error);
    
    NSString *message = @"Error in loading metadata";
    [self stopProgressBar];
    //[Utils makeAlert:message];
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
# pragma mark action sheet delegate method
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self takePhoto];
    }
    else if (buttonIndex == 1)
    {
        [self uploadPhoto];
    }
    
    
    
}
#pragma mark method for taking the photo
-(void) takePhoto
{
    [self startCameraControllerFromViewController: self
                                    usingDelegate: self];
    
}

#pragma mark method for uploading a photo from the library
-(void) uploadPhoto
{
    imagePicker=[[UIImagePickerController alloc] init];
    imagePicker.delegate=(id)self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    //cameraUI.allowsEditing = YES;
    
    cameraUI.delegate = delegate;
    
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        selectedImage = imageToSave;
        fileName = @"MobiQuityCamera";
        NSString *tmpPngFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",fileName]];
        UIImage *image = [self imageWithImage:selectedImage scaledToSize:CGSizeMake(75,75)];
        [UIImagePNGRepresentation(image) writeToFile:tmpPngFile atomically:YES];
        NSString *destDir = @"/Photos";
        [[self restClient] uploadFile:@"myFile.png" toPath:destDir
                        withParentRev:nil fromPath:tmpPngFile];
        [self startProgress];
        
        isPhotoTaken = YES;
        // Save the new image (original or edited) to the Camera Roll
        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        
        
    }
    
    // Handle a movie capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        
        NSString *moviePath = [[info objectForKey:
                                UIImagePickerControllerMediaURL] path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (
                                                 moviePath, nil, nil, nil);
        }
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
}
- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
//-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    //    NSString *filePath = NSHomeDirectory();
//    // NSLog(@"%@",filePath);
//    [self startProgress];
//    UIImage *image = [info valueForKey:@"UIImagePickerControllerEditedImage"];
//    fileName = @"MobiQuityCamera";
//    if(picker.sourceType != UIImagePickerControllerSourceTypePhotoLibrary)
//    {
//        
//        [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
//                 resultBlock:^(ALAsset *asset) {
//                     
//                     ALAssetRepresentation *image_representation = [asset defaultRepresentation];
//                     NSDictionary *data = image_representation.metadata;
//                     NSLog(@"%@",data);
//                     NSUInteger size = (NSUInteger)image_representation.size;
//                     // create a buffer to hold image data
//                     uint8_t *buffer = (Byte*)malloc(size);
//                     NSUInteger length = [image_representation getBytes:buffer fromOffset: 0.0  length:size error:nil];
//                     
//                     if (length != 0)  {
//                         
//                         // buffer -> NSData object; free buffer afterwards
//                         NSData *adata = [[NSData alloc] initWithBytesNoCopy:buffer length:size freeWhenDone:YES];
//                         NSString *str = [[NSString alloc] initWithData:adata encoding:NSASCIIStringEncoding];
//                         NSLog(@"%@",str);
//                         
//                         //                         EXFJpeg *jpegScanner = [[EXFJpeg alloc] init];
//                         //                         [jpegScanner scanImageData: adata];
//                         //                         EXFMetaData* exifData = jpegScanner.exifMetaData;
//                         //
//                         //                         id latitudeValue = [exifData tagValue:[NSNumber numberWithInt:EXIF_GPSLatitude]];
//                         //                         id longitudeValue = [exifData tagValue:[NSNumber numberWithInt:EXIF_GPSLongitude]];
//                         //                         id datetime = [exifData tagValue:[NSNumber numberWithInt:EXIF_DateTime]];
//                         //                         id t = [exifData tagValue:[NSNumber numberWithInt:EXIF_Model]];
//                         // NSLog(@"%@ , %@", latitudeValue,longitudeValue);
//                         //NSLog(@"%@ , %@",datetime,t);
//                         // self.locationLabel.text = [NSString stringWithFormat:@"Local: %@ - %@",latitudeValue,longitudeValue];
//                         //self.dateLavel.text = [NSString stringWithFormat:@"Data: %@", datetime];
//                         
//                     }
//                     else {
//                         NSLog(@"image_representation buffer length == 0");
//                     }
//                 }
//                failureBlock:^(NSError *error) {
//                    NSLog(@"couldn't get asset: %@", error);
//                }
//         ];
//        
//        
//        
//        
//        
////        [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation
////                              completionBlock:^(NSURL* assetURL, NSError* error) {
////                                  
////                                  //error handling
////                                  if (error!=nil) {
////                                      // completionBlock(error);
////                                      NSLog(@"imagePickerController error ");
////                                      [picker dismissViewControllerAnimated:NO completion:nil];
////                                      return;
////                                  }
////                                  NSLog(@"Asset URL is %@", assetURL);
////                                  //selectedImage.image = image;
////                                  [picker dismissViewControllerAnimated:NO completion:nil];
////                                  NSString *tmpPngFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",fileName]];
////                                  [UIImagePNGRepresentation(image) writeToFile:tmpPngFile atomically:YES];
////                                  NSString *destDir = @"/";
////                                  [[self restClient] uploadFile:@"myFile.png" toPath:destDir
////                                                  withParentRev:nil fromPath:tmpPngFile];
////                                  [picker dismissViewControllerAnimated:NO completion:nil];
////                                  
////                              }];
//        
//        //        selectedImage.image = image;
//        //        [picker dismissViewControllerAnimated:NO completion:nil];
//        //        NSString *tmpPngFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",fileName]];
//        //        [UIImagePNGRepresentation(selectedImage.image) writeToFile:tmpPngFile atomically:YES];
//        //        NSString *destDir = @"/";
//        //        [[self restClient] uploadFile:@"myFile.png" toPath:destDir
//        //                        withParentRev:nil fromPath:tmpPngFile];
//        
//    }
//    else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
//    {
////        NSURL *urlStr = [info valueForKey:@"UIImagePickerControllerReferenceURL"];
////        NSLog(@"%@",urlStr);
////        url = [NSString stringWithFormat:@"%@",urlStr];
////        
////        NSMutableArray *subStrings = [NSMutableArray new];
////        NSScanner *scanner = [NSScanner scannerWithString:url];
////        [scanner scanUpToString:@"?" intoString:nil];
////        while (![scanner isAtEnd]) {
////            NSString *subString = nil;
////            [scanner scanString:@"?" intoString:nil];
////            if ([scanner scanUpToString:@"&" intoString:&subString]) {
////                [subStrings addObject:subString];
////            }
////            [scanner scanUpToString:@"?" intoString:nil];
////        }
////        NSLog(@"%@",subStrings);
////        NSString *idString = [subStrings objectAtIndex:0];
////        fileName = [idString stringByReplacingOccurrencesOfString:@"id=" withString:@""];
////        [library writeImageToSavedPhotosAlbum:image.CGImage
////                                  orientation:(ALAssetOrientation)image.imageOrientation
////                              completionBlock:^(NSURL* assetURL, NSError* error)
////         {
////             
////             //error handling
////             
////             if (error!=nil) {
////                 // completionBlock(error);
////                 NSLog(@"imagePickerController error ");
////                 [picker dismissViewControllerAnimated:NO completion:nil];
////                 return;
////             }
////             NSLog(@"Asset URL is %@", assetURL);
////             
////             [picker dismissViewControllerAnimated:NO completion:nil];
////         }];
//        
//       // ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
//                 resultBlock:^(ALAsset *asset) {
//                     
//                     ALAssetRepresentation *image_representation = [asset defaultRepresentation];
//                     NSDictionary *data = image_representation.metadata;
//                     NSUInteger size = (NSUInteger)image_representation.size;
//                     // create a buffer to hold image data
//                     uint8_t *buffer = (Byte*)malloc(size);
//                     NSUInteger length = [image_representation getBytes:buffer fromOffset: 0.0  length:size error:nil];
//                     
//                     if (length != 0)  {
//                         
//                         // buffer -> NSData object; free buffer afterwards
//                         NSData *adata = [[NSData alloc] initWithBytesNoCopy:buffer length:size freeWhenDone:YES];
//                         NSString *str = [[NSString alloc] initWithData:adata encoding:NSASCIIStringEncoding];
//                         NSLog(@"%@",str);
//                         
////                         EXFJpeg *jpegScanner = [[EXFJpeg alloc] init];
////                         [jpegScanner scanImageData: adata];
////                         EXFMetaData* exifData = jpegScanner.exifMetaData;
////                         
////                         id latitudeValue = [exifData tagValue:[NSNumber numberWithInt:EXIF_GPSLatitude]];
////                         id longitudeValue = [exifData tagValue:[NSNumber numberWithInt:EXIF_GPSLongitude]];
////                         id datetime = [exifData tagValue:[NSNumber numberWithInt:EXIF_DateTime]];
////                         id t = [exifData tagValue:[NSNumber numberWithInt:EXIF_Model]];
//                        // NSLog(@"%@ , %@", latitudeValue,longitudeValue);
//                         //NSLog(@"%@ , %@",datetime,t);
//                        // self.locationLabel.text = [NSString stringWithFormat:@"Local: %@ - %@",latitudeValue,longitudeValue];
//                         //self.dateLavel.text = [NSString stringWithFormat:@"Data: %@", datetime];
//                         
//                     }
//                     else {
//                         NSLog(@"image_representation buffer length == 0");
//                     }
//                 }
//                failureBlock:^(NSError *error) {
//                    NSLog(@"couldn't get asset: %@", error);
//                }
//         ];
//        
//        
//        
//        //selectedImage.image = image;
//        [picker dismissViewControllerAnimated:YES completion:nil];
//        NSString *tmpPngFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",fileName]];
//        [UIImagePNGRepresentation(image) writeToFile:tmpPngFile atomically:YES];
//        NSString *destDir = @"/Photos";
//        [[self restClient] uploadFile:@"myFile.png" toPath:destDir
//                        withParentRev:nil fromPath:tmpPngFile];
//        
//        
//        
//    }
//    
//}
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
-(IBAction)getAlbums:(id)sender
{
    [[self restClient] loadMetadata:@"/Photos"];
    [self startProgress];
    
}
-(IBAction)uploadImages:(id)sender
{
    [self takePhoto];
    
        
}

-(IBAction)logOff:(id)sender
{
     [[DBSession sharedSession] unlinkAll];
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
