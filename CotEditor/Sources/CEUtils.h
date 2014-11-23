/*
 ==============================================================================
 CEUtils
 
 CotEditor
 http://coteditor.com
 
 Created on 2014-04-20 by nakamuxu
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

@import Foundation;


@interface CEUtils : NSObject

/// 非表示半角スペース表示用文字を返す
+ (unichar)invisibleSpaceChar:(NSUInteger)index;
+ (NSString *)invisibleSpaceCharacter:(NSUInteger)index;

/// 非表示タブ表示用文字を返す
+ (unichar)invisibleTabChar:(NSUInteger)index;
+ (NSString *)invisibleTabCharacter:(NSUInteger)index;

/// 非表示改行表示用文字を返す
+ (unichar)invisibleNewLineChar:(NSUInteger)index;
+ (NSString *)invisibleNewLineCharacter:(NSUInteger)index;

/// 非表示全角スペース表示用文字を返す
+ (unichar)invisibleFullwidthSpaceChar:(NSUInteger)index;
+ (NSString *)invisibleFullwidthSpaceCharacter:(NSUInteger)index;

/// エンコーディング名からNSStringEncodingを返す
+ (NSStringEncoding)encodingFromName:(NSString *)encodingName;

/// エンコーディング名からNSStringEncodingを返す
+ (BOOL)isInvalidYenEncoding:(NSStringEncoding)encoding;

/// 文字列からキーボードショートカット定義を読み取る
+ (NSString *)keyEquivalentAndModifierMask:(NSUInteger *)modifierMask
                                fromString:(NSString *)string
                       includingCommandKey:(BOOL)needsIncludingCommandKey;

@end
