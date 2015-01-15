#import "tomato.h"

@implementation tomato

@synthesize statsWindow;
@synthesize window;
@synthesize combo;
@synthesize submit;
@synthesize statusMenu;
@synthesize startMenuItem;

@synthesize speech;

/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "tomato" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */
- (NSString *)applicationSupportDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Tomato"];
}

/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
                                                configuration:nil 
                                                URL:url 
                                                options:nil 
                                                error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */ 
- (void) persist {

    NSError *error = nil;

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

// stops counter
- (void) stopCounter {
	if (!started) { return; }

	started = FALSE;
	if ([timer isValid]) {
		[timer invalidate];
		timer = nil;
	}
	[self updateStatusBar];
  [speech startSpeakingString:@"Well done!"];

  [window makeKeyAndOrderFront:nil];
  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

-(void) saveAction:(id)sender {
  // get task name from combo box
  NSString * currentTask = [combo stringValue];

  // close window
  [window orderOut:sender];

	// log
	NSString * secondsPassed = [NSString stringWithFormat:@"%ld", START_COUNTER - timeCounter];

	if (secondsPassed > 0) {
		NSManagedObject * contentObject = [NSEntityDescription insertNewObjectForEntityForName:@"Time" inManagedObjectContext: managedObjectContext];
		[contentObject setValue:[NSDate date] forKey:@"created_at"];
		[contentObject setValue:secondsPassed forKey:@"duration"];
		[contentObject setValue:currentTask forKey:@"task"];
		[managedObjectContext processPendingChanges];

		[self persist];
	}
}

// closes window
- (IBAction) cancelAction:(id)sender {
	[window orderOut:sender];
}

// start/stop timer
- (IBAction) startAction:(id)sender {
  if (started) {
    [self stopCounter];
  } else {
    [self startCounter];
  }
}

// opens stats window
- (IBAction) openStatsAction:(id)sender {
  [statsWindow makeKeyAndOrderFront:sender];
  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (IBAction) closeStatsAction:(id)sender {
  [statsWindow orderOut:sender];
}

- (IBAction) exportStatsAction:(id)sender {

  NSAlert *alert = [[NSAlert alloc] init];
  [alert addButtonWithTitle:@"OK"];
  [alert setMessageText:@"Export functionality is incomplete"];
  [alert setInformativeText:@"If you need it, please contribute at\nhttps://github.com/pitr/tomato"];
  [[alert.buttons objectAtIndex:0] setKeyEquivalent:@"\e"];
  [alert setAlertStyle:NSInformationalAlertStyle];
  [alert runModal];
  [alert release];

  return;


  NSMutableString *data = [NSMutableString string];

  // TODO: add code here

  // Set the default name for the file and show the panel.
  NSSavePanel* panel = [NSSavePanel savePanel];
  [panel setNameFieldStringValue:@"Pomodoro Tasks.csv"];
  [panel setAllowedFileTypes:@[@"csv"]];
  [panel beginSheetModalForWindow:statsWindow completionHandler:^(NSInteger result){
    if (result == NSFileHandlingPanelOKButton) {
      NSURL* file = [panel URL];
      [data writeToURL:file atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
  }];
}

// update status menu
- (void) updateStatusBar {
	if (started) {
		[statusItem setTitle:[NSString stringWithFormat:@"%ld:%.2ld", timeCounter/60, timeCounter%60]];
		[statusItem setImage:nil];
		[startMenuItem setTitle:@"Stop"];
	} else {
		[statusItem setTitle:@""];
		[statusItem setImage:icon];
		[startMenuItem setTitle:@"Start"];
	}
}

// counter step
- (void) stepCounter:(NSTimer *)aTimer {
	if (!started) return;

	timeCounter--;

	if (timeCounter < 0) {
		[self stopCounter];
	} else {
		[tick play];
		[self updateStatusBar];
	}
}

// starts counter
- (void) startCounter {
	timeCounter = START_COUNTER;
	started = TRUE;

	timer = [NSTimer  timerWithTimeInterval:1
					  target:self
					  selector:@selector(stepCounter:)
					  userInfo:nil
					  repeats:YES];

	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

// quiting
- (IBAction)quitAction:(id)sender {
	[[NSApplication sharedApplication] terminate:sender];
}

- (void)awakeFromNib {
	started = FALSE;

	icon = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tomato" ofType:@"png"]];

	tick = [NSSound soundNamed:@"tick.wav"];
	[tick setVolume:2/10.0];

	[speech setVolume:5/10.0];

	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:statusMenu];
	[self updateStatusBar];

	[statsWindow setLevel:3];
	[window setLevel:3]; // on top of others
	[window setShowsResizeIndicator:NO]; // no resize
}

- (void)dealloc {
	[icon release];
	[tick release];
	[statusItem release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];

    [super dealloc];
}

@end
