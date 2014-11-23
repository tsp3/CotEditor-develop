/*
 ==============================================================================
 CEGoToSheetController
 
 CotEditor
 http://coteditor.com
 
 Created by 2014-03-16 by 1024jp
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

#import "CEGoToSheetController.h"


@interface CEGoToSheetController ()

@property (nonatomic) NSString *location;
@property (nonatomic) CEGoToType gotoType;

@end




#pragma mark -

@implementation CEGoToSheetController

#pragma mark Superclass Methods

// ------------------------------------------------------
/// initializer of sheetController
- (instancetype)init;
// ------------------------------------------------------
{
    return [super initWithWindowNibName:@"GoToSheet"];
}



#pragma mark Public Methods

// ------------------------------------------------------
/// begin sheet for document
- (void)beginSheetForDocument:(CEDocument *)document
// ------------------------------------------------------
{
    [self setDocument:document];
    
    [NSApp beginSheet:[self window]
       modalForWindow:[document windowForSheet]
        modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    [NSApp runModalForWindow:[self window]];
}



#pragma mark Action Messages

// ------------------------------------------------------
/// apply to the parent document window
- (IBAction)apply:(id)sender
// ------------------------------------------------------
{
    NSArray *locLen = [[self location] componentsSeparatedByString:@":"];
    
    if ([locLen count] > 0) {
        NSInteger location = [locLen[0] integerValue];
        NSInteger length = ([locLen count] > 1) ? [locLen[1] integerValue] : 0;
        
        [[self document] gotoLocation:location length:length type:[self gotoType]];
    }
    [self close:sender];
}


// ------------------------------------------------------
/// close sheet
- (IBAction)close:(id)sender
// ------------------------------------------------------
{
    [NSApp stopModal];
    [NSApp endSheet:[self window]];
    [self close];
    
}

@end
