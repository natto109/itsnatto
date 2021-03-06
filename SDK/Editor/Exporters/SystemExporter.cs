//   
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

using System.Text;
using PixelVision8.Engine;
using PixelVision8.Engine.Chips;
using PixelVision8.Runner.Utils;

namespace PixelVision8.Runner.Exporters
{
    public class SystemExporter : AbstractExporter
    {
        private readonly IEngine engine;
        private StringBuilder sb;

        public SystemExporter(string fileName, IEngine engine) : base(fileName)
        {
            this.engine = engine;

            //            CalculateSteps();
        }

        public override void CalculateSteps()
        {
            base.CalculateSteps();

            // Create a new string builder
            steps.Add(CreateStringBuilder);

            // Serialize Color Chip
            if (engine.ColorChip != null && engine.ColorChip.export)
                steps.Add(delegate { SerializeColorChip(engine.ColorChip); });

            // Serialize Display
            if (engine.DisplayChip != null && engine.DisplayChip.export)
                steps.Add(delegate { SerializeDisplay(engine.DisplayChip); });

            //             Serialize Controller
            if (engine.ControllerChip != null && engine.ControllerChip.export)
                steps.Add(delegate { SerializeControllerChip(engine.ControllerChip); });

            // Serialize Font
            if (engine.FontChip != null && engine.FontChip.export)
                steps.Add(delegate { SerializeFontChip(engine.FontChip); });

            // Serialize Game
            if (engine.GameChip != null && engine.GameChip.export)
                steps.Add(delegate { SerializeGameChip(engine.GameChip); });

            // Serialize Music
            if (engine.MusicChip != null && engine.MusicChip.export)
                steps.Add(delegate { SerializeMusicChip(engine.MusicChip); });

            // Serialize Sound
            if (engine.SoundChip != null && engine.SoundChip.export)
                steps.Add(delegate { SerializeSoundChip(engine.SoundChip); });

            // Serialize Sprite
            if (engine.SpriteChip != null && engine.SpriteChip.export)
                steps.Add(delegate { SerializeSpriteChip(engine.SpriteChip); });

            // Serialize Tilemap
            if (engine.TilemapChip != null && engine.TilemapChip.export)
                steps.Add(delegate { SerializeTilemapChip(engine.TilemapChip); });

            // Save the final string builder
            steps.Add(CloseStringBuilder);
        }

        private void CreateStringBuilder()
        {
            sb = new StringBuilder();

            // Start the json string
            sb.Append("{");

            JsonUtil.indentLevel = 1;

            currentStep++;
        }

        private void CloseStringBuilder()
        {
            // TODO test to see if there is actually a comma
            // Chances are the last item will have an extra comma so let's remove the last character
            sb.Length--;

            JsonUtil.indentLevel = 0;

            JsonUtil.GetLineBreak(sb);

            // Close the object
            sb.Append("}");

            //            Debug.Log("Save bytes");
            bytes = Encoding.UTF8.GetBytes(sb.ToString());

            currentStep++;
        }

        private void SerializeDisplay(DisplayChip display)
        {
            if (display.export == false) return;

            JsonUtil.GetLineBreak(sb);
            sb.Append("\"DisplayChip\":");

            JsonUtil.GetLineBreak(sb);
            sb.Append("{");
            JsonUtil.GetLineBreak(sb, 1);

            // Width Value
            sb.Append("\"width\":");
            sb.Append(display.Width);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            // Height Value
            sb.Append("\"height\":");
            sb.Append(display.Height);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"overscanX\":");
            sb.Append(display.OverscanX);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"overscanY\":");
            sb.Append(display.OverscanY);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"layers\":");
            sb.Append(display.layers);

            JsonUtil.GetLineBreak(sb);
            sb.Append("}");

            sb.Append(",");

            currentStep++;
        }

        private void SerializeColorChip(ColorChip colorChip)
        {
            if (colorChip.export == false) return;

            // TODO this needs to be moved into the chip so it can be correctly overriden

            JsonUtil.GetLineBreak(sb);
            sb.Append("\"ColorChip\":");

            JsonUtil.GetLineBreak(sb);
            sb.Append("{");
            JsonUtil.GetLineBreak(sb, 1);

            // sb.Append("\"maxColors\":");
            // sb.Append(colorChip.maxColors);
            // sb.Append(",");
            // JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"backgroundColor\":");
            sb.Append(colorChip.backgroundColor);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"maskColor\":\"");
            sb.Append(colorChip.maskColor);
            sb.Append("\"");
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"unique\":");
            sb.Append(colorChip.unique.ToString().ToLower());
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"debug\":");
            sb.Append(colorChip.debugMode.ToString().ToLower());

            JsonUtil.GetLineBreak(sb);
            sb.Append("}");
            sb.Append(",");

            currentStep++;
        }

        private void SerializeControllerChip(IControllerChip controllerChip)
        {
            if (controllerChip.export == false) return;

            JsonUtil.GetLineBreak(sb);
            sb.Append("\"ControllerChip\":");

            JsonUtil.GetLineBreak(sb);
            sb.Append("{");

            JsonUtil.GetLineBreak(sb);
            sb.Append("}");
            sb.Append(",");

            currentStep++;
        }

        private void SerializeFontChip(FontChip fontChip)
        {
            if (fontChip.export == false) return;

            JsonUtil.GetLineBreak(sb);
            sb.Append("\"FontChip\":");
            JsonUtil.GetLineBreak(sb);
            sb.Append("{");
            JsonUtil.GetLineBreak(sb, 1);
            // Mode
            sb.Append("\"unique\":");
            sb.Append(fontChip.unique.ToString().ToLower());
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"pages\":");
            sb.Append(fontChip.pages);

            JsonUtil.GetLineBreak(sb);
            sb.Append("}");
            sb.Append(",");

            currentStep++;
        }

        private void SerializeGameChip(GameChip gameChip)
        {
            JsonUtil.GetLineBreak(sb);
            sb.Append("\"GameChip\":");

            JsonUtil.GetLineBreak(sb);
            sb.Append("{");
            JsonUtil.GetLineBreak(sb, 1);

            // Total Meta Sprites
            sb.Append("\"totalMetaSprites\":");
            sb.Append(gameChip.TotalMetaSprites());
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            // Lock Specs
            sb.Append("\"lockSpecs\":");
            sb.Append(gameChip.lockSpecs.ToString().ToLower());
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            // Max Size
            sb.Append("\"maxSize\":");
            sb.Append(gameChip.maxSize);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            // Save Slots
            sb.Append("\"saveSlots\":");
            sb.Append(gameChip.SaveSlots);
            //            sb.Append(",");
            //            JsonUtil.GetLineBreak(sb, 1);

            JsonUtil.GetLineBreak(sb);
            sb.Append("}");
            sb.Append(",");

            currentStep++;
        }

        private void SerializeMusicChip(MusicChip musicChip)
        {
            JsonUtil.GetLineBreak(sb);
            sb.Append("\"MusicChip\":");

            JsonUtil.GetLineBreak(sb);
            sb.Append("{");
            JsonUtil.GetLineBreak(sb, 1);

            //            sb.Append("\"totalTracks\":");
            //            sb.Append(musicChip.totalTracks);
            //            sb.Append(",");
            //            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"totalSongs\":");
            sb.Append(musicChip.totalSongs);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"notesPerTrack\":");
            sb.Append(musicChip.maxNoteNum);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"totalPatterns\":");
            sb.Append(musicChip.TotalLoops);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            // TODO legacy property
            // sb.Append("\"totalLoop\":");
            // sb.Append(musicChip.TotalLoops);

            JsonUtil.GetLineBreak(sb);
            sb.Append("}");
            sb.Append(",");

            currentStep++;
        }

        private void SerializeSoundChip(SoundChip soundChip)
        {
            JsonUtil.GetLineBreak(sb);
            sb.Append("\"SoundChip\":");

            JsonUtil.GetLineBreak(sb);
            sb.Append("{");
            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"totalChannels\":");
            sb.Append(soundChip.totalChannels);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"totalSounds\":");
            sb.Append(soundChip.TotalSounds);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"channelTypes\":[");

            var total = soundChip.totalChannels;

            for (var i = 0; i < total; i++)
            {
                //                Console.WriteLine("Channel "+i +" type "+soundChip.ChannelType(i));

                sb.Append((int) soundChip.ChannelType(i));
                if (i < total - 1) sb.Append(",");
            }

            sb.Append("]");

            JsonUtil.GetLineBreak(sb);
            sb.Append("}");
            sb.Append(",");

            currentStep++;
        }

        private void SerializeSpriteChip(SpriteChip spriteChip)
        {
            //            var sb = new StringBuilder();
            JsonUtil.GetLineBreak(sb);

            JsonUtil.GetLineBreak(sb);
            sb.Append("\"SpriteChip\":");

            sb.Append("{");
            JsonUtil.GetLineBreak(sb, 1);

            // Max Sprite Count Value
            sb.Append("\"maxSpriteCount\":");
            sb.Append(spriteChip.maxSpriteCount);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            // Mode
            sb.Append("\"unique\":");
            sb.Append(spriteChip.unique.ToString().ToLower());
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            // Mode
            sb.Append("\"spriteWidth\":");
            sb.Append(spriteChip.width);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"spriteHeight\":");
            sb.Append(spriteChip.height);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"pages\":");
            sb.Append(spriteChip.pages);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            // Height
            sb.Append("\"cps\":");
            sb.Append(spriteChip.colorsPerSprite);

            //            if (serializePixelData)
            //            {
            //                sb.Append(",");
            //                JsonUtil.GetLineBreak(sb, 1);
            //
            //                //TODO this should just use the TextureData's
            //                // serializePixelData
            //                sb.Append("\"serializePixelData\":");
            //                sb.Append(Convert.ToInt32(serializePixelData));
            //
            //                sb.Append(",");
            //
            //                //TODO this should capture all of the texture settings
            //                sb.Append("\"pixelData\":");
            //                sb.Append(DataUtil.SerializedTextureData(_texture));
            //
            //                //sb.Append(_texture.SerializeData());
            //            }

            JsonUtil.GetLineBreak(sb);
            sb.Append("}");
            sb.Append(",");

            currentStep++;
        }

        private void SerializeTilemapChip(TilemapChip tilemapChip)
        {
            JsonUtil.GetLineBreak(sb);
            sb.Append("\"TilemapChip\":");

            JsonUtil.GetLineBreak(sb);
            sb.Append("{");
            JsonUtil.GetLineBreak(sb, 1);

            // Columns
            sb.Append("\"columns\":");
            sb.Append(tilemapChip.columns);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            // Rows
            sb.Append("\"rows\":");
            sb.Append(tilemapChip.rows);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            // Total Flags
            sb.Append("\"totalFlags\":");
            sb.Append(tilemapChip.totalFlags);
            sb.Append(",");
            JsonUtil.GetLineBreak(sb, 1);

            sb.Append("\"autoImport\":");
            sb.Append(tilemapChip.autoImport.ToString().ToLower());

            JsonUtil.GetLineBreak(sb);
            sb.Append("}");
            sb.Append(",");

            currentStep++;
        }
    }
}