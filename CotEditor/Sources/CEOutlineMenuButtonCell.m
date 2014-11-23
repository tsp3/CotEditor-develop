/*
 ==============================================================================
 CEOutlineMenuButtonCell
 
 CotEditor
 http://coteditor.com
 
 Created on 2005-08-25 by nakamuxu
 encoding="UTF-8"
 ------------------------------------------------------------------------------
 
 © 2004-2007 nakamuxu
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

#import "CEOutlineMenuButtonCell.h"


@implementation CEOutlineMenuButtonCell

#pragma mark Superclass Methods

// ------------------------------------------------------
/// draw cell
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
// ------------------------------------------------------
{
    // draw background
    [super drawBezelWithFrame:cellFrame inView:controlView];
    
    // draw popup arrow image
    NSImage *arrowImage = [NSImage imageNamed:@"PopUpButtonArrowTemplate"];
    NSRect imageFrame = NSMakeRect(NSMaxX(cellFrame) - [arrowImage size].width - 5, NSMinY(cellFrame),
                                   [arrowImage size].width, NSHeight(cellFrame));
    [self drawImage:arrowImage withFrame:imageFrame inView:controlView];
    
    // shift content 1px
    cellFrame.origin.y += 1.0;
    
    // draw text
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
