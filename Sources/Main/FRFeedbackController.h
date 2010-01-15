/*
 * Copyright 2008, Torsten Curdt
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Cocoa/Cocoa.h>
#import "FRUploader.h"

#define FR_FEEDBACK  @"feedback"
#define FR_EXCEPTION @"exception"
#define FR_CRASH     @"crash"

@interface FRFeedbackController : NSWindowController 
#ifdef MAC_OS_X_VERSION_10_6 // on lines like this to not confuse IB
<NSWindowDelegate>
#endif
{

    IBOutlet NSTextField *messageField;
    IBOutlet NSTextField *informativeTextField;
    IBOutlet NSTextView *commentView;
    IBOutlet NSComboBox *emailField;

    IBOutlet NSButton *detailsButton;

    IBOutlet NSTabView *tabView;
    IBOutlet NSTabViewItem *tabSystem;
    IBOutlet NSTabViewItem *tabConsole;
    IBOutlet NSTabViewItem *tabCrash;
    IBOutlet NSTabViewItem *tabScript;
    IBOutlet NSTabViewItem *tabPreferences;
    IBOutlet NSTabViewItem *tabException;

    IBOutlet NSTextField *commentLabel;
    IBOutlet NSTextField *addressLabel;    
    IBOutlet NSTextField *detailsLabel;

    BOOL detailsShown;

    IBOutlet NSTableView *systemView;
    IBOutlet NSTextView *consoleView;
    IBOutlet NSTextView *crashesView;
    IBOutlet NSTextView *scriptView;
    IBOutlet NSTextView *preferencesView;
    IBOutlet NSTextView *exceptionView;

    IBOutlet NSProgressIndicator *indicator;

    IBOutlet NSButton *cancelButton;
    IBOutlet NSButton *sendButton;
		
	IBOutlet NSButton *sendDetailsCheckbox;
    
    FRUploader *uploader;
    
    id delegate;
    
    NSString *type;
}

#pragma mark Accessors

- (id) delegate;
- (void) setDelegate:(id) delegate;

- (void) setMessage:(NSString*)message;
- (void) setInformativeText:(NSString *)informativeText;
- (void) setComment:(NSString*)comment;
- (void) setCommentLabel:(NSString*)label;
- (void) setException:(NSString*)exception;
- (void) setType:(NSString*)type;

#pragma mark UI

- (IBAction) showDetails:(id)sender;
- (IBAction) cancel:(id)sender;
- (IBAction) send:(id)sender;

#pragma mark Other

- (void) reset;
- (BOOL) isShown;

@end
