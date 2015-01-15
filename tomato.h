#import <Cocoa/Cocoa.h>

#define START_COUNTER (60*25)

@interface tomato : NSObject
{
  NSWindow *window;
  NSWindow *statsWindow;
  NSComboBox *combo;
  NSButton *submit;
  NSMenu *statusMenu;
  NSMenuItem *startMenuItem;

  NSStatusItem* statusItem;

  NSPersistentStoreCoordinator *persistentStoreCoordinator;
  NSManagedObjectModel *managedObjectModel;
  NSManagedObjectContext *managedObjectContext;

  Boolean started;
  NSInteger timeCounter;

  NSSound* tick;
  NSTimer* timer;
  NSImage* icon;

  NSSpeechSynthesizer* speech;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *statsWindow;
@property (assign) IBOutlet NSComboBox *combo;
@property (assign) IBOutlet NSButton *submit;
@property (assign) IBOutlet NSMenu *statusMenu;
@property (assign) IBOutlet NSMenuItem *startMenuItem;

@property (assign) IBOutlet NSSpeechSynthesizer *speech;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)cancelAction:sender;
- (IBAction)saveAction:sender;
- (IBAction)startAction:sender;
- (IBAction)quitAction:sender;
- (IBAction)openStatsAction:sender;
- (IBAction)closeStatsAction:sender;
- (IBAction)exportStatsAction:sender;

- (void) updateStatusBar;
- (void) startCounter;
- (void) stopCounter;

@end
