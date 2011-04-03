#import <Cocoa/Cocoa.h>

#define START_COUNTER (60*25)

@interface tomato : NSObject 
{
    NSWindow *window;
	NSWindow *statsWindow;
	NSComboBox *combo;
	NSButton *submit;
	NSButton *cancel;
	NSMenu *statusMenu;
	NSMenuItem *startMenuItem;

	NSStatusItem* statusItem;

    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;

	Boolean started;
	NSInteger timeCounter;
	NSString * currentTask;

	NSEntityDescription* tasks;
	NSSound* tick;
	NSTimer* timer;
	NSImage* icon;

	NSSpeechSynthesizer* speech;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *statsWindow;
@property (assign) IBOutlet NSComboBox *combo;
@property (assign) IBOutlet NSButton *submit;
@property (assign) IBOutlet NSButton *cancel;
@property (assign) IBOutlet NSMenu *statusMenu;
@property (assign) IBOutlet NSMenuItem *startMenuItem;

@property (assign) IBOutlet NSSpeechSynthesizer *speech;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)openAction:sender;
- (IBAction)cancelAction:sender;
- (IBAction)startAction:sender;
- (IBAction)quitAction:sender;

- (void) updateStatusBar;
- (void) perSecond;
- (void) startCounter;
- (void) stopCounter;

@end
