//
//  ViewController.m
//  Flickr
//
//  Created by Charles Northup on 3/27/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//


#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "CellWithImageCollectionViewCell.h"
#import "MapViewController.h"
#import "PhotosCollectionView.h"



@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITabBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate>
{
    __weak IBOutlet UICollectionView *myCollectionView;
    NSInteger columns;
    NSInteger rows;
    __weak IBOutlet UICollectionViewFlowLayout *controllerOfLayout;
    NSArray* photos;
    UIImage* bear;
    NSMutableArray* parsedUrls;
    NSMutableArray* arrayOfPhotoData;
    NSMutableArray* arrayOfAnimalPhotos;
    __weak IBOutlet UITabBarItem *lionTabItem;
    __weak IBOutlet UITabBarItem *tigerTabItem;
    __weak IBOutlet UITabBarItem *bearTabItem;
    NSString* latitude;
    NSString* longitiude;
    NSMutableArray* sortedPhotos;
}

@end

@implementation ViewController

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    columns = 2;
    myCollectionView.delegate = self;
    myCollectionView.dataSource = self;
    parsedUrls = [NSMutableArray new];
    arrayOfPhotoData = [NSMutableArray new];
    arrayOfAnimalPhotos = [NSMutableArray new];
    sortedPhotos = [NSMutableArray new];
    rows = arrayOfAnimalPhotos.count;
    NSURL* url = [NSURL URLWithString:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3b9f5d531b74e0c59b9393be78a30157&tags=grizzlybear&safe_search=1&per_page=100&place_id&has_geo&extras=+geo&format=json&nojsoncallback=1"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError* error;
        NSDictionary* bears = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSDictionary* bearPhotos = bears[@"photos"];
        photos = bearPhotos[@"photo"];
        
        for (NSDictionary*photo in photos) {
            NSString* string = photo[@"latitude"];
            NSLog(@"%@", string);
            if (string.doubleValue > 3) {
                [sortedPhotos addObject:photo];
            }
        }
        
        for (NSDictionary*photoInfo in sortedPhotos) {
            NSURL* photoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_m.jpg", photoInfo[@"farm"], photoInfo[@"server"], photoInfo[@"id"], photoInfo[@"secret"]]];
            [parsedUrls addObject:photoUrl];
        }
        for (NSURL*currentUrl in parsedUrls) {
            NSData* photoData = [NSData dataWithContentsOfURL:currentUrl];
            [arrayOfPhotoData addObject:photoData];
            
        }
        for (NSData*currentPhotoData in arrayOfPhotoData) {
            UIImage* animalImage = [UIImage imageWithData:currentPhotoData];
            [arrayOfAnimalPhotos addObject:animalImage];
            
        }
        rows = arrayOfAnimalPhotos.count;
        [myCollectionView reloadData];
    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return arrayOfAnimalPhotos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CellWithImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionReuseCellID" forIndexPath:indexPath];
    cell.image.image = [arrayOfAnimalPhotos objectAtIndex:indexPath.row];
    return cell;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if (fromInterfaceOrientation == UIUserInterfaceLayoutDirectionLeftToRight||
        fromInterfaceOrientation == UIUserInterfaceLayoutDirectionRightToLeft) {
        columns = 1;
        rows = arrayOfAnimalPhotos.count;
        controllerOfLayout.sectionInset = UIEdgeInsetsMake(0, 1, 0, 0);
        controllerOfLayout.itemSize = CGSizeMake(298, 200);
        controllerOfLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
    }
    else{
        columns = 2;
        rows = arrayOfAnimalPhotos.count;
        controllerOfLayout.sectionInset = UIEdgeInsetsMake(0, 10, 1, 10);
        controllerOfLayout.itemSize = CGSizeMake(149, 100);
        controllerOfLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    
    [myCollectionView reloadData];
    [self updateViewConstraints];
}

//-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
//    NSString* selected = tabBarController.tabBarItem.title;
//    [self search:selected];
//    NSLog(@"searching");
//    
//}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if ([item isEqual:bearTabItem]) {
        [self search:@"grizzlybear"];
    }else if ([item isEqual:tigerTabItem]){
        [self search:@"bangeltiger"];
    }else if ([item isEqual:lionTabItem]){
        [self search:@"africanlion"];
    }
    
}

-(void)collectionView:(PhotosCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    latitude = [sortedPhotos[indexPath.row][@"latitude"] stringValue];
    longitiude = [sortedPhotos[indexPath.row][@"longitude"] stringValue];
    NSLog(@"%@", latitude);
    NSLog(@"%@", longitiude);
//    [self performSegueWithIdentifier:@"MAX_IS_BEST" sender:cell];
}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    MapViewController* vc = segue.destinationViewController;
//    vc.lat = latitude;
//    vc.lonG = longitiude;
//}


-(void)search:(NSString*)string{
    
    parsedUrls = [NSMutableArray new];
    arrayOfPhotoData = [NSMutableArray new];
    arrayOfAnimalPhotos = [NSMutableArray new];
    rows = arrayOfAnimalPhotos.count;
    NSString* animalModifier = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3b9f5d531b74e0c59b9393be78a30157&tags=%@,-sports,-baseball,-basketball,-football,-weddings,-soccer,-sealions,-rugby&safe_search=1&per_page=100&format=json&nojsoncallback=1", string];
    NSURL* url = [NSURL URLWithString:animalModifier];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError* error;
        NSDictionary* animals = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSDictionary* animalPhotos = animals[@"photos"];
        photos = animalPhotos[@"photo"];
        
        for (NSDictionary*photoInfo in photos) {
            NSURL* photoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_m.jpg", photoInfo[@"farm"], photoInfo[@"server"], photoInfo[@"id"], photoInfo[@"secret"]]];
            [parsedUrls addObject:photoUrl];
        }
        for (NSURL*currentUrl in parsedUrls) {
            NSData* photoData = [NSData dataWithContentsOfURL:currentUrl];
            [arrayOfPhotoData addObject:photoData];
            
        }
        for (NSData*currentPhotoData in arrayOfPhotoData) {
            UIImage* animalImage = [UIImage imageWithData:currentPhotoData];
            [arrayOfAnimalPhotos addObject:animalImage];
            
        }
        rows = arrayOfAnimalPhotos.count;
        [myCollectionView reloadData];
    }];
    
}

@end
