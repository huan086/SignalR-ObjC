//
//  ConnectionStatusViewController.m
//  SignalR
//
//  Created by Alex Billingsley on 11/3/11.
//  Copyright (c) 2011 DyKnow LLC. All rights reserved.
//

#import "ConnectionStatusViewController.h"

#import "Router.h"

@interface ConnectionStatusViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation ConnectionStatusViewController

@synthesize messageTable;

@synthesize detailItem = _detailItem;
@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - View Actions

- (IBAction)connectClicked:(id)sender
{
    NSString *server = [Router sharedRouter].server_url;
    connection = [SRHubConnection connectionWithURL:server];
    hub = [connection createProxy:@"SignalR.Samples.Hubs.ConnectDisconnect.Status"];
    [hub on:@"joined" perform:self selector:@selector(joined:when:)];
    [hub on:@"leave" perform:self selector:@selector(leave:when:)];
    
    [connection setDelegate:self];
    [connection start];
    
    if(messagesReceived == nil)
    {
        messagesReceived = [[NSMutableArray alloc] init];
    }
}

#pragma mark - Connect Disconnect Sample Project
- (void)joined:(NSString *)id when:(NSString *)when
{
    if([id isEqualToString:connection.connectionId])
    {
        [messagesReceived addObject:[NSString stringWithFormat:@"I joined at: %@",when]];
    }
    else
    {
        [messagesReceived addObject:[NSString stringWithFormat:@"%@ joined at: %@",id,when]];
    }
    [messageTable reloadData];
}

- (void)leave:(NSString *)id when:(NSString *)when
{
    [messagesReceived addObject:[NSString stringWithFormat:@"%@ left at: %@",id,when]];
    [messageTable reloadData];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [messagesReceived count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [messagesReceived objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma SRConnection Delegate

- (void)SRConnectionDidOpen:(SRConnection *)connection
{
    NSLog(@"Connection OPENED");
    [hub invoke:@"Join" withArgs:[NSArray arrayWithObjects: nil]];
}

- (void)SRConnectionDidClose:(SRConnection *)connection
{
    NSLog(@"Connection CLOSED");
}

- (void)SRConnection:(SRConnection *)connection didReceiveError:(NSError *)error
{
    //NSLog(@"Connection Error: %@",error.localizedDescription);
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }         
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}
@end