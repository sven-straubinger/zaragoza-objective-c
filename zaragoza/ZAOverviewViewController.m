//
//  ZAOverviewViewController.m
//  zaragoza
//
//  Created by Sven Straubinger on 01/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import "ZAOverviewViewController.h"
#import "ZABusStop.h"
#import "ZAImageDownloader.h"
#import "ZAStopTableViewCell.h"
#import "ZAApiService.h"
#import "UIAlertController+Collections.h"
#import "UIScrollView+Helper.h"

static NSString *kCellIdentifier = @"StopTableViewCell";

@interface ZAOverviewViewController () <UITableViewDelegate, UITableViewDataSource>

// Storage for all bus stops
@property (nonatomic, strong) NSArray *busStops;

// Storage for all pending ImageDownloader objects
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

// Reference to API service (Singleton) for easier reusability
@property (nonatomic, strong) ZAApiService *apiService;

@end

@implementation ZAOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initalize properties
    self.busStops = [[NSArray alloc]init];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.apiService = [ZAApiService sharedInstance];
    
    // Set title image view
    UIImage *image = [UIImage imageNamed:@"header.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    // Add UIRefreshControl
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    [self.tableView sendSubviewToBack:refreshControl];
    
    // Request data
    [self requestData];
}


#pragma mark - Data

- (void)requestData {
    // Terminate all pending requests
    [self terminateAllImageDownloads];
    
    // Request all bus stops
    [self.apiService requestBusStopsWithSuccessBlock:^(NSArray *busStops) {
        
        // Store result
        self.busStops = busStops;
        
        // Update UI (we are on the main thread and safe)
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        
    } failureBlock:^(NSString *errorMessage) {
        UIAlertController *alert = [UIAlertController controllerWithTitle:@"An error occured"
                                                                  message:errorMessage
                                                              actionTitle:@"Ok"];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl {
    [self requestData];
    [refreshControl endRefreshing];
}


#pragma mark - Lifecyclye

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self terminateAllImageDownloads];
}

- (void)dealloc {
    [self terminateAllImageDownloads];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.busStops count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Re-use cell
    ZAStopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier
                                                            forIndexPath:indexPath];
    
    // Fill cells
    ZABusStop *busStop = [self.busStops objectAtIndex:indexPath.row];
    cell.identifierLabel.text = busStop.identifier;
    cell.nameLabel.text = busStop.name;
    
    // Display cached images (if available) or defer new downloads until scrolling ends
    if (!busStop.image) {
        if ([self.tableView isScrollEnding]) {
            [self startImageDownload:busStop forIndexPath:indexPath];
        }
        // No image available ATM, nilify to clear images by re-used cells
        cell.mapImageView.image = nil;
    } else {
        // Set cached image
        cell.mapImageView.image = busStop.image;
    }
    
    // Display ETA data (if available) or defer new data download until scrolling ends
    if(!busStop.estimate) {
        if ([self.tableView isScrollEnding]) {
            [self startEstimateDownload:busStop forIndexPath:indexPath];
        }
        // No data available ATM, show loading hint
        cell.etaLabel.text = @"Loading ...";
    } else {
        // Set cached estiamte
        [cell.etaLabel setText:[NSString stringWithFormat:@"%ld Minutes", busStop.estimate.estimate]];
    }
    
    return cell;
}


#pragma mark - Image support & UIScrollViewDelegate methods

/*  -------------------------------------------------------------------------------
 *   This section implements the samples from:
 *   https://developer.apple.com/library/ios/samplecode/LazyTableImages/Introduction/Intro.html
 *  ------------------------------------------------------------------------------- */

/*  -------------------------------------------------------------------------------
 *   Begin image download for a specific index path.
 *  ------------------------------------------------------------------------------- */
- (void)startImageDownload:(ZABusStop *)busStop forIndexPath:(NSIndexPath *)indexPath {
    ZAImageDownloader *imageDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (imageDownloader == nil) {
        imageDownloader = [[ZAImageDownloader alloc] init];
        imageDownloader.busStop = busStop;
        [imageDownloader setCompletionHandler:^{
            
            ZAStopTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            // Apply start values for animation
            [cell.mapImageView setAlpha:0.0];
            
            // Set image
            cell.mapImageView.image = busStop.image;
            
            // Animate
            [UIView animateWithDuration:0.3
                             animations:^{
                                 [cell.mapImageView setAlpha:1.0];
                             }];
            
            // Remove the ImageDownloader from the progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        (self.imageDownloadsInProgress)[indexPath] = imageDownloader;
        [imageDownloader startDownload];
    }
}

/*  -------------------------------------------------------------------------------
 *   Begin ETA download for a specific index path.
 *  ------------------------------------------------------------------------------- */
- (void)startEstimateDownload:(ZABusStop *)busStop forIndexPath:(NSIndexPath *)indexPath {
    ZAApiService *service = [ZAApiService sharedInstance];
    [service estimateForBusStopWithId:busStop.identifier
                     withSuccessBlock:^(ZAEstimate *estimate) {
                         // Store estimate
                         busStop.estimate = estimate;
                         
                         // Update UI, completion block runs on the main thread
                         ZAStopTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                         [cell.etaLabel setText:[NSString stringWithFormat:@"%ld Minutes", estimate.estimate]];
                         
                     } failureBlock:^(NSString *errorMessage) {
                         DLog(@"%@", errorMessage);
                         
                         // Update UI, completion block runs on the main thread
                         ZAStopTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                         [cell.etaLabel setText:@"An error occured."];
 
                     }];
}

/*  -------------------------------------------------------------------------------
 *   This method is used in case the user scrolled into a set of cells that don't
 *   have their additional data (image & ETA) yet.
 *  ------------------------------------------------------------------------------- */
- (void)loadDataAdditionsForOnscreenRows {
    if ([self.busStops count] > 0) {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths) {
            ZABusStop *busStop = (self.busStops)[indexPath.row];
            
            // Load image – if not already set
            if (!busStop.image) {
                [self startImageDownload:busStop forIndexPath:indexPath];
            }
            
            // Load estimate – if not already set
            if (!busStop.estimate) {
                [self startEstimateDownload:busStop forIndexPath:indexPath];
            }
        }
    }
}

/*  -------------------------------------------------------------------------------
 *   Load additional data (image & ETA) for all onscreen rows when scrolling is finished.
 *  ------------------------------------------------------------------------------- */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadDataAdditionsForOnscreenRows];
    }
}

/*  -------------------------------------------------------------------------------
 *   When scrolling stops, proceed to load additional data (images & ETA) for images that are on screen.
 *  ------------------------------------------------------------------------------- */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadDataAdditionsForOnscreenRows];
}

/*  -------------------------------------------------------------------------------
 *   Terminate all pending image downloads.
 *  ------------------------------------------------------------------------------- */
- (void)terminateAllImageDownloads {
    // Terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}

@end
