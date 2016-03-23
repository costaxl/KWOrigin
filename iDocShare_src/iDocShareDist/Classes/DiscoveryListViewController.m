//
//  DiscoveryListViewController.m
//  PMPlayer
//
//  Created by James_hsieh on 12/8/15.
//
//

#import "DiscoveryListViewController.h"
#import "SelectServerDetialViewController.h"
#import "GUIAPPDelegate.h"
#import "ServerCell.h"


#define PMPFEATURE_CONFIG_SHIFT_DisplayMode 16
#define PMPFEATURE_CONFIG_SHIFT_DisplayView 20

@interface DiscoveryListViewController ()
{
}
@property (copy) NSString* m_LoginCode;
@property(nonatomic) NSInteger m_SelectedIndex;

@end

@implementation DiscoveryListViewController
@synthesize manualRecords;
@synthesize serverListRecords;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc
{
    [super dealloc];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.manualRecords = [self loadRecords];
    self.serverListRecords = [self loadRecords];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
	if (section == 0) {
		return [self.manualRecords count]+1;
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServerCell *cell =(ServerCell *)[tableView dequeueReusableCellWithIdentifier:@"ServerCell"];
    // Configure the cell...
    if ([indexPath row] == 0)
    {
        // configure special row for local view
        cell.serverName.text = @"View Files Only in iPad/iPhone";
        cell.serverIPAddress.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    BelongingsRecordApple * Record = [self.manualRecords objectAtIndex:[indexPath row]-1];
    NSLog(@"row %d cell %p",indexPath.row,cell);
    NSLog(Record.m_Name);
	cell.serverName.text = Record.m_Name;
    cell.serverIPAddress.text = Record.m_Address;
    if (Record.m_WantedFeature == kFeatureTypeDesktopFlag)
    {
        cell.curentFeature.image = [UIImage imageNamed:@"ICON_T_3X.png"];
    }
    else if (Record.m_WantedFeature == kFeatureTypeCamFlag)
    {
        cell.curentFeature.image = [UIImage imageNamed:@"ICON_W_1X.png"];
    }
    
    if(Record.m_SupportedFeatures == 1)
    {
        cell.desktopFeature.image = [UIImage imageNamed:@"ICON_T_3.png"];

    }
    else if(Record.m_SupportedFeatures == 2)
    {
        cell.camFeature.image = [UIImage imageNamed:@"ICON_W.png"];
    }
    else if(Record.m_SupportedFeatures == 3)
    {
        cell.desktopFeature.image = [UIImage imageNamed:@"ICON_T_3.png"];
        cell.camFeature.image = [UIImage imageNamed:@"ICON_W.png"];
        //cell.captureDeviceFeature.image = [UIImage imageNamed:@"ICON_P_3.png"];
    }

    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
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
    if ([indexPath row]==0)
    {
        [self performSegueWithIdentifier:@"ShowDocs" sender:self];

        return;
    }
    
    self.m_SelectedIndex = [indexPath row];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Enter security code" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    [alert release];

    return;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
    self.m_LoginCode = [[alertView textFieldAtIndex:0] text];

    BelongingsRecordApple * Record = [self.manualRecords objectAtIndex:self.m_SelectedIndex-1];
    Record.m_Password = self.m_LoginCode;
    // test multiple view, display mode = 2, display view = 0
//    Record.m_FeatureOptions = Record.m_FeatureOptions |(2 << PMPFEATURE_CONFIG_SHIFT_DisplayMode) ;
//    Record.m_FeatureOptions = Record.m_FeatureOptions | (3 << PMPFEATURE_CONFIG_SHIFT_DisplayView) ;

    if (Record != nil) {
        [[GUIAPPDelegate defaultAppDelegate] PlayPeerMedia:Record];
    }
    [self performSegueWithIdentifier:@"ShowDocs" sender:self];

}

- (void)saveRecords
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/PMPlayer.dat", directory];
    
    [NSKeyedArchiver archiveRootObject:self.serverListRecords toFile:fileName];
}

- (NSMutableArray *)loadRecords
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/PMPlayer.dat", directory];
    
    NSMutableArray *records = [[NSKeyedUnarchiver unarchiveObjectWithFile:fileName] retain];
    //NSMutableArray *records = nil;
    if (records == nil) {
        records = [[NSMutableArray alloc] init];
    }
    
    return records;
}

- (void)addBelongingRecord:(BelongingsRecordApple *)record
{
    if (record.m_CommWay != DC_MANUAL)
    {
        if ([self IsBelongingRecordExist:record] != nil)
        {
            return;
        }
        
        /*if(record.m_CommWay == DC_Jingle)
        {
            if(record.m_SupportedFeatures==0)
            {
                return;
            }
        }*/
    }
    BelongingsRecordApple *newRecord = [[BelongingsRecordApple alloc] init];
    [newRecord Copy:record];
    [self performSelectorOnMainThread:@selector(addRecord:) withObject:newRecord waitUntilDone:YES];


}

- (void)delBelongingRecord:(BelongingsRecordApple *)record
{
    BelongingsRecordApple* existRecord;
    if (record.m_CommWay != DC_MANUAL)
    {
        existRecord = [self IsBelongingRecordExist:record];
        if (existRecord == nil)
        {
            return;
        }
    }
    [self deleteRecord:existRecord];    
}

- (void)addRecord:(BelongingsRecordApple *)record
{
    if ([self.manualRecords containsObject:record]) {
        [self saveRecords];
        return;
    }
    
    
    BelongingsRecordApple *candidate;
    NSIndexPath *oldPath;
    NSIndexPath *newPath;
    
    if(record.m_SupportedFeatures == 1)
    {
        record.m_WantedFeature =  kFeatureTypeDesktopFlag;
    }
    else if(record.m_SupportedFeatures == 2)
    {
        record.m_WantedFeature =  kFeatureTypeCamFlag;
    }
    else if(record.m_SupportedFeatures == 3)
    {
        record.m_WantedFeature =  kFeatureTypeDesktopFlag;
    }
    else
    {
        record.m_WantedFeature =  kFeatureTypeDesktopFlag;
    }
    candidate = record;

    [self.manualRecords addObject:candidate];
    newPath = [NSIndexPath indexPathForRow:[self.manualRecords indexOfObject:candidate]+1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
    //[self reloadData];
    //[self saveRecords];
}

- (void)addManualRecord:(BelongingsRecordApple *)record
{
    if ([self.serverListRecords containsObject:record]) {
        [self saveRecords];
        return;
    }
    

    
    BelongingsRecordApple *candidate;
    NSIndexPath *oldPath;
    NSIndexPath *newPath;
    
    candidate = record;
    
    [self.manualRecords addObject:candidate];
    [self.serverListRecords addObject:candidate];
    newPath = [NSIndexPath indexPathForRow:[self.manualRecords indexOfObject:candidate]+1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
    //[self reloadData];
    [self saveRecords];
}

- (BelongingsRecordApple *)IsBelongingRecordExist:(BelongingsRecordApple *)record
{
    BelongingsRecordApple* comRecord;
    
    for (NSUInteger i = 0; i < [self.manualRecords count]; i++)
    {
        comRecord = [self.manualRecords objectAtIndex:i];
        if (record.m_CommWay == DC_Jingle)
        {
            if ([record.jid compare:comRecord.jid] == 0)
                return comRecord;
        }
        else if (record.m_CommWay == DC_Lan)
        {
            if ([record.m_Address compare:comRecord.m_Address] == 0)
                return comRecord;
            
        }
    }
    return nil;
    
}



- (void)deleteRecord:(BelongingsRecordApple *)Record
{
    NSInteger indexOfRecord = [self.manualRecords indexOfObject:Record];
    
    [self.manualRecords removeObjectAtIndex:indexOfRecord];
    
    //[self saveRecords];
    
}

- (void)serverDetialViewControllerDidCancel:(ServerDetialViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)serverDetialViewControllerDidDone:(ServerDetialViewController *)controller didAddServer:(BelongingsRecordApple *)server
{
    [self addManualRecord:server];
}

-(void)selectServerDetialViewControllerDidDone:(SelectServerDetialViewController *)controller didUpdateServer:(BelongingsRecordApple *)server
{
    NSLog(@"%d",selectedIndex);
    [self.manualRecords replaceObjectAtIndex:selectedIndex withObject:server];
    BelongingsRecordApple* comRecord;
    for (NSUInteger i = 0; i < [self.serverListRecords count]; i++)
    {
        comRecord = [self.serverListRecords objectAtIndex:i];
        
        if ([server.m_Name compare:comRecord.m_Name] == 0)
        {
            NSLog(@"Update Manual Server");
            [self.serverListRecords replaceObjectAtIndex:i withObject:server];
            [self saveRecords];
            break;
        }
    }
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"AddServer"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        ServerDetialViewController *serverDetailsViewController =
        [[navigationController viewControllers] objectAtIndex:0];
        serverDetailsViewController.delegate = self;
    }
    
    if([segue.identifier isEqualToString:@"DetialServer"])
    {
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        BelongingsRecordApple *selectServer =(BelongingsRecordApple *)[self.manualRecords objectAtIndex:selectedIndex];
        SelectServerDetialViewController *selectServerDetialViewController = (SelectServerDetialViewController *)[segue destinationViewController];
        selectServerDetialViewController.delegate=self;
        selectServerDetialViewController.server = selectServer;
        
        
    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Select Detial");
    BelongingsRecordApple * Record = [self.manualRecords objectAtIndex:[indexPath row]];
    selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"DetialServer" sender:self];
    NSLog(Record.m_Name);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        BelongingsRecordApple * Record = [self.manualRecords objectAtIndex:[indexPath row]];
        BelongingsRecordApple* comRecord;
     
        for (NSUInteger i = 0; i < [self.serverListRecords count]; i++)
        {
            comRecord = [self.serverListRecords objectAtIndex:i];
            
            if ([Record.m_Name compare:comRecord.m_Name] == 0)
            {
                NSLog(@"Delete Manual Server"); 
                [self.serverListRecords removeObjectAtIndex:i];
                [self saveRecords];
                break;
            }
        }        
        [self.manualRecords removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

        
    }
}
@end
