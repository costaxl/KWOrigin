//
//  FeaturePickerViewController.m
//  PMPlayer
//
//  Created by James_hsieh on 12/8/20.
//
//

#import "FeaturePickerViewController.h"
#import "BelongingsManagerCommonType.h"

@interface FeaturePickerViewController ()

@end

@implementation FeaturePickerViewController

@synthesize delegate,feature,supportfeature;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    features = [[NSMutableArray alloc] init];
    
    if (supportfeature & kFeatureTypeDesktopFlag)
    {
        [features addObject: @"Desktop"];
    }
    if (supportfeature & kFeatureTypeCamFlag)
    {
        [features addObject: @"Cam"];
    }
    if (supportfeature & kFeatureTypePushDesktopFlag)
    {
        [features addObject: @"PushCam"];
    }
    
   
    selectedIndex =[features indexOfObject:self.feature];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    features=nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    uint32_t FeatureFlags = supportfeature;
    uint32_t FeatureMask = 1;
    int totalFeatures=0;
    
    for (int i=0;i < 32;i++)
    {
        if ((FeatureFlags & FeatureMask) != 0)
        {
            totalFeatures++;
        }
        FeatureMask = FeatureMask << 1;
    }
    return totalFeatures;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FeatureCell"];
    features = [[NSMutableArray alloc] init];
    
    if (supportfeature & kFeatureTypeDesktopFlag)
    {
        [features addObject: @"Desktop"];
    }
    if (supportfeature & kFeatureTypeCamFlag)
    {
        [features addObject: @"Cam"];
    }
    if (supportfeature & kFeatureTypePushDesktopFlag)
    {
        [features addObject: @"PushCam"];
    }

    

    cell.textLabel.text =[features objectAtIndex:indexPath.row];

    //NSLog(@"row %d cell %p",indexPath.row,cell);
    // Configure the cell...
    if(indexPath.row == selectedIndex)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    features = [[NSMutableArray alloc] init];
    
    if (supportfeature & kFeatureTypeDesktopFlag)
    {
        [features addObject: @"Desktop"];
    }
    if (supportfeature & kFeatureTypeCamFlag)
    {
        [features addObject: @"Cam"];
    }
    if (supportfeature & kFeatureTypePushDesktopFlag)
    {
        [features addObject: @"PushCam"];
    }

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(selectedIndex != NSNotFound){
        UITableViewCell *cell =[tableView cellForRowAtIndexPath:
                                [NSIndexPath indexPathForRow:selectedIndex inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    selectedIndex = indexPath.row;
    UITableViewCell *cell =[tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    NSString *theFeature =[features objectAtIndex:indexPath.row];
    [self.delegate featurePickerViewController:self didSelectFeature:theFeature];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
