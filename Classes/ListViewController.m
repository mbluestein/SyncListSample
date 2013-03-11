//
//  ListViewController.m
//  iPhoneListSample
//
//  Copyright 2010 Microsoft. All rights reserved.
//
#import "iPhoneListSampleAppDelegate.h"
#import "ListViewController.h"
#import "Utils.h"
#import "ItemViewController.h"
#import "ListDescriptionViewController.h"
#import "SyncController.h"

@interface ListViewController()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation ListViewController

@synthesize fetchedResultsController, managedObjectContext;


- (NSManagedObjectContext *) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
	managedObjectContext = [(iPhoneListSampleAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	return managedObjectContext;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	//[self.navigationItem setHidesBackButton:YES];

	[self setManagedObjectContext:[(iPhoneListSampleAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]];

	self.navigationItem.title = @"My Lists";
    [self.navigationController   setToolbarHidden:FALSE];
 
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
//	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
//																			   target:self action:@selector(insertNewObject:)];
//	self.navigationItem.rightBarButtonItem = addButton;
		
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
		[Utils showAlert:@"Failed to load lists" withMessage:[NSString stringWithFormat:@"Failed to fetch lists from local cache. \n Error: %@ %@.",
															  error, [error userInfo]]	withDelegate:self];
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }	
	
	UIBarButtonItem *spacerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem *syncButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(synchronize:)];
	UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Salir" style:UIBarButtonItemStyleBordered target:self action:@selector(logout:)];
	self.toolbarItems = [NSArray arrayWithObjects:logoutButton, spacerButton, syncButton, nil];
	
	if (![Utils clientHasSynced:self.managedObjectContext])
	{
		[self.navigationItem.rightBarButtonItem setEnabled:NO];
		[self.editButtonItem setEnabled:NO];
		[self synchronize:self];
	}
	else 
	{
		[self.navigationItem.rightBarButtonItem setEnabled:YES];
		[self.editButtonItem setEnabled:YES];
	}
	
}

#pragma mark 
#pragma mark SyncController Delegate
- (void)syncDone:(id)delegate
{
	[self.navigationItem.leftBarButtonItem setEnabled:YES];
	[self.navigationItem.rightBarButtonItem setEnabled:YES];
}

#pragma mark 
#pragma mark Refresh Button Delegate
-(void)synchronize:sender
{
    iPhoneListSampleAppDelegate *app = (iPhoneListSampleAppDelegate *) [[UIApplication sharedApplication] delegate];

	SyncController *controller = [[SyncController alloc] initWithContext:self.managedObjectContext withBaseUrl:app.BaseUrl delegate:self];
	[controller synchronize];
}


-(void)logout:sender
{
    [Utils cleanupCache:self.managedObjectContext];
    [self.navigationController popToRootViewControllerAnimated:TRUE];

}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [managedObject valueForKey:@"listName"];
}

#pragma mark -
#pragma mark Add Button Delegate

- (void)insertNewObject:sender {
    
	ListDescriptionViewController * listDescriptionController = [[ListDescriptionViewController alloc]init];
	listDescriptionController.inAddMode = true;
	
	[self.navigationController pushViewController:listDescriptionController animated:YES];
	
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
		[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	}
    
    // Configure the cell...
	NSManagedObject *list = [fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = [NSString stringWithFormat:@"%@", [list valueForKey:@"listName"]];
	
    return cell;
}

// Enable row edit to delete list entities
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		// delete list and its items
		[Utils deleteList:[self.fetchedResultsController objectAtIndexPath:indexPath] inContext:self.managedObjectContext];
	}  
}

#pragma mark -
#pragma mark Table view delegate



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"ListDescription"]) {
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        
        ListDescriptionViewController * listDescriptionController = segue.destinationViewController;
        listDescriptionController.inAddMode = false;
        
        listDescriptionController.listToEdit = [fetchedResultsController objectAtIndexPath:selectedIndexPath];
        
    } else  if ([segue.identifier isEqualToString:@"newListDescription"]) {
  
        ListDescriptionViewController * listDescriptionController = segue.destinationViewController;
        listDescriptionController.inAddMode = true;
        
    }
}


-(void)viewItems:(NSIndexPath*)indexPath
{
//    // Navigation logic may go here. Create and push another view controller.
//	ItemViewController *itemViewController = [[ItemViewController alloc]init];
//	itemViewController.list = [fetchedResultsController objectAtIndexPath:indexPath];
//	[self.navigationController pushViewController:itemViewController animated:YES];
	
}

-(void) viewDetails:(NSIndexPath*)indexPath
{
//	ListDescriptionViewController * listDescriptionController = [[ListDescriptionViewController alloc]init];
//	listDescriptionController.inAddMode = false;
//	
//	listDescriptionController.listToEdit = [fetchedResultsController objectAtIndexPath:indexPath];
//	[self.navigationController pushViewController:listDescriptionController animated:YES];

}

-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
	//[self viewDetails:indexPath];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	//[self viewItems:indexPath];
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"List" inManagedObjectContext:self.managedObjectContext]];

	// only fetch list for the user logged in
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"IsTombstone == %@", [NSNumber numberWithBool:false]] ;
	[fetchRequest setPredicate:predicate];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"listName" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    
    return fetchedResultsController;
}    


#pragma mark -
#pragma mark Fetched results controller delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}




@end

