﻿//   
// Copyright (c) Jesse Freeman, Pixel Vision 8. All rights reserved.  
//  
// Licensed under the Microsoft Public License (MS-PL) except for a few
// portions of the code. See LICENSE file in the project root for full 
// license information. Third-party libraries used by Pixel Vision 8 are 
// under their own licenses. Please refer to those libraries for details 
// on the license they use.
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

namespace PixelVision8.Engine.Chips
{
    /// <summary>
    ///     This internal is for classes that need to be part of
    ///     the engine's Draw system.
    /// </summary>
    public interface IDraw
    {
        /// <summary>
        ///     This Draw() method is called as part of the engine's life-cycle. Use
        ///     this method for rendering logic. It is called once per frame.
        /// </summary>
        void Draw();
    }
}