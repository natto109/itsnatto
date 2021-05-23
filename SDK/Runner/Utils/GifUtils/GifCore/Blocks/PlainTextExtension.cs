﻿//   
// Copyright (c) Jesse Freeman, Pixel Vision 8. All rights reserved.  
//  
// Licensed under the Microsoft Public License (MS-PL) except for a few
// portions of the code. See LICENSE file in the project root for full 
// license information. Third-party libraries used by Pixel Vision 8 are 
// under their own licenses. Please refer to those libraries for details 
// on the license they use.
//
// Based on SimpleGif (https://github.com/hippogamesunity/simplegif) by
// Nate River of Hippo Games
// 
// Contributors
// --------------------------------------------------------
// This is the official list of Pixel Vision 8 contributors:
//  
// Jesse Freeman - @JesseFreeman
// Christina-Antoinette Neofotistou @CastPixel
// Christer Kaitila - @McFunkypants
// Pedro Medeiros - @saint11
// Shawn Rakowski - @shwany
//

using System;

namespace PixelVision8.Runner.Utils
{
	internal class PlainTextExtension : Block
	{
		public byte BlockSize;
		public ushort TextGridLeftPosition;
		public ushort TextGridTopPosition;
		public ushort TextGridWidth;
		public ushort TextGridHeight;
		public byte CharacterCellWidth;
		public byte CharacterCellHeight;
		public byte TextForegroundColorIndex;
		public byte TextBackgroundColorIndex;
		public byte[] PlainTextData;

		public PlainTextExtension(byte[] bytes, ref int index)
		{
			if (bytes[index++] != ExtensionIntroducer) throw new Exception("Expected :" + ExtensionIntroducer);
			if (bytes[index++] != PlainTextExtensionLabel) throw new Exception("Expected :" + PlainTextExtensionLabel);

			BlockSize = bytes[index++];
			TextGridLeftPosition = BitHelper.ReadInt16(bytes, ref index);
			TextGridTopPosition = BitHelper.ReadInt16(bytes, ref index);
			TextGridWidth = BitHelper.ReadInt16(bytes, ref index);
			TextGridHeight = BitHelper.ReadInt16(bytes, ref index);
			CharacterCellWidth = bytes[index++];
			CharacterCellHeight = bytes[index++];
			TextForegroundColorIndex = bytes[index++];
			TextBackgroundColorIndex = bytes[index++];
			PlainTextData = ReadDataSubBlocks(bytes, ref index);

			if (bytes[index++] != BlockTerminatorLabel) throw new Exception("Expected: " + BlockTerminatorLabel);
		}
	}
}