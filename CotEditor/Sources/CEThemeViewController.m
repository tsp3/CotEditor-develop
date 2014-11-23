/*
 ==============================================================================
 CEThemeViewController
 
 CotEditor
 http://coteditor.com
 
 Created on 2014-09-12 by 1024jp
 encoding="UTF-8"
 ------------------------------------------------------------------------------
 
 © 2014 CotEditor Project
 
 This program is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License as published by the Free Software
 Foundation; either version 2 of the License, or (at your option) any later
 version.
 
 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this program; if not, write to the Free Software Foundation, Inc., 59 Temple
 Place - Suite 330, Boston, MA  02111-1307, USA.
 
 ==============================================================================
 */

#import "CEThemeViewController.h"
#import "CEThemeManager.h"
#import "NSColor+WFColorCode.h"
#import "constants.h"


@interface CEThemeViewController () <NSPopoverDelegate, NSTextFieldDelegate>

@property (nonatomic, getter=isMetadataEdited) BOOL metadataEdited;

@property (nonatomic) IBOutlet NSPopover *popover;

@end




#pragma mark -

@implementation CEThemeViewController

#pragma mark Superclass methods

// ------------------------------------------------------
/// init
- (instancetype)init
// ------------------------------------------------------
{
    return [super initWithNibName:@"ThemeView" bundle:nil];
}


// ------------------------------------------------------
/// clean up (end theme change observation)
- (void)dealloc
// ------------------------------------------------------
{
    _delegate = nil;
    [self endObservingTheme];
}


// ------------------------------------------------------
/// observe theme dict changes
- (void)setRepresentedObject:(id)representedObject
// ------------------------------------------------------
{
    // remove current observing (in case when the theme is restored)
    [self endObservingTheme];
    
    // observe input theme
    NSDictionary *theme = representedObject;
    [self observeTheme:theme];
    
    [super setRepresentedObject:theme];
}


// ------------------------------------------------------
/// theme is modified
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
// ------------------------------------------------------
{
    if (object == [self representedObject]) {
        [[self delegate] didUpdateTheme:object];
    }
}



#pragma mark Delegate

// ------------------------------------------------------
/// meta data was possible edited
- (void)controlTextDidChange:(NSNotification *)obj
// ------------------------------------------------------
{
    [self setMetadataEdited:YES];
}


// ------------------------------------------------------
/// popover closed
- (void)popoverDidClose:(NSNotification *)notification
// ------------------------------------------------------
{
    if ([self isMetadataEdited]) {
        [[self delegate] didUpdateTheme:[self representedObject]];
        [self setMetadataEdited:NO];
    }
}



#pragma mark Action Messages

// ------------------------------------------------------
/// apply system highlight color to color well
- (IBAction)applySystemSelectionColor:(id)sender
// ------------------------------------------------------
{
    if ([sender state] == NSOnState) {
        NSColor *color = [NSColor selectedTextBackgroundColor];
        [self representedObject][CEThemeSelectionKey][CEThemeColorKey] = [[color colorUsingColorSpaceName:NSCalibratedRGBColorSpace] colorCodeWithType:WFColorCodeHex];
    }
}


// ------------------------------------------------------
/// show medatada of theme file via popover
- (IBAction)showMedatada:(id)sender
// ------------------------------------------------------
{
    [[self popover] showRelativeToRect:[sender frame] ofView:[self view] preferredEdge:NSMaxYEdge];
    [[sender window] makeFirstResponder:[sender window]];
}


// ------------------------------------------------------
/// jump to theme's destribution URL
- (IBAction)jumpToURL:(id)sender
// ------------------------------------------------------
{
    NSURL *URL = [NSURL URLWithString:[self representedObject][CEMetadataKey][CEDistributionURLKey]];
    
    if (!URL) {
        NSBeep();
        return;
    }
    
    [[NSWorkspace sharedWorkspace] openURL:URL];
}



#pragma mark Private Methods

// ------------------------------------------------------
/// start observing theme change
- (void)observeTheme:(NSDictionary *)theme
// ------------------------------------------------------
{
    for (NSString *key in [theme allKeys]) {
        if ([key isEqualToString:CEMetadataKey]) { continue; }
        
        for (NSString *subKey in [theme[key] allKeys]) {
            NSString *keyPath = [NSString stringWithFormat:@"%@.%@", key, subKey];
            
            [theme addObserver:self forKeyPath:keyPath options:0 context:NULL];
        }
    }
}


// ------------------------------------------------------
/// end observing current theme
- (void)endObservingTheme
// ------------------------------------------------------
{
    NSDictionary *theme = [self representedObject];
    
    if (!theme) { return; }
    
    for (NSString *key in [theme allKeys]) {
        if ([key isEqualToString:CEMetadataKey]) { continue; }
        
        for (NSString *subKey in [theme[key] allKeys]) {
            NSString *keyPath = [NSString stringWithFormat:@"%@.%@", key, subKey];
            
            [theme removeObserver:self forKeyPath:keyPath];
        }
    }
}

@end
