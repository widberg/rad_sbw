using System;
using System.Drawing;
using CharactorLib.Common;
using CharactorLib.Format;

namespace XaviXFormat
{
    public class BitReader
    {
        private Byte[] Data;
        public int BitIndex { get; set; }

        public BitReader(Byte[] data)
        {
            this.Data = data;
            this.BitIndex = 0;
        }

        public bool ReadBit()
        {
            if (BitIndex >= Data.Length * 8)
                throw new IndexOutOfRangeException("No more bits to read.");

            int byteIndex = BitIndex / 8;
            int bitIndex = BitIndex % 8;

            bool bit = ((Data[byteIndex] >> bitIndex) & 1) != 0;
            ++BitIndex;
            return bit;
        }

        public int ReadBits(int count)
        {
            if (count < 1 || count > 32)
                throw new ArgumentOutOfRangeException("count", "Count must be between 1 and 32.");

            int value = 0;
            for (int i = 0; i < count; ++i)
            {
                value |= (ReadBit() ? 1 : 0) << i;
            }
            return value;
        }
    }

    public class BitWriter
    {
        private Byte[] Data;
        public int BitIndex { get; set; }

        public BitWriter(Byte[] data)
        {
            this.Data = data;
            this.BitIndex = 0;
        }

        public void WriteBit(bool bit)
        {
            if (BitIndex >= Data.Length * 8)
                throw new IndexOutOfRangeException("No more bits can be written.");

            int byteIndex = BitIndex / 8;
            int bitIndex = BitIndex % 8;

            if (bit)
            {
                Data[byteIndex] |= (byte)(1 << bitIndex);
            }
            else
            {
                Data[byteIndex] &= (byte)~(1 << bitIndex);
            }

            ++BitIndex;
        }

        public void WriteBits(int count, int bits)
        {
           if (count < 1 || count > 32)
                throw new ArgumentOutOfRangeException("count", "Count must be between 1 and 32.");

            for (int i = 0; i < count; ++i)
            {
                WriteBit(((bits >> i) & 1) != 0);
            }
        }
    }

    // YY-CHR doesn't like abstract classes so make the base class 1bpp 8x8 by default
    public class XaviXFormatBase : FormatBase
    {
        public XaviXFormatBase() : this(1, 8, 8) { }

        public XaviXFormatBase(int colorBit, int charWidth, int charHeight)
        {
            base.FormatText = "[8][8]";
            base.Name = String.Format("{0}BPP XaviX {1}x{2}", colorBit, charWidth, charHeight);
            base.Extension = String.Format("xavix_{0}bpp_{1}x{2}", colorBit, charWidth, charHeight);

            base.ColorBit = colorBit;
            base.ColorNum = 1 << colorBit;
            base.Width = 128;
            base.Height = 128;
            base.CharWidth = charWidth;
            base.CharHeight = charHeight;

            base.Readonly = false;
            base.IsSupportMirror = true;
            base.IsSupportRotate = true;
            base.IsCompressed = false;
            base.EnableAdf = true;

            base.Author = "widberg";
            base.Url = "https://github.com/widberg/cs-yychr-plugins";
        }

        public override void ConvertMemToChr(Byte[] sourceData, int addr, Bytemap bytemap, int px, int py)
        {
            BitReader bitReader = new BitReader(sourceData);
            bitReader.BitIndex = addr * 8;

            for (int y = 0; y < CharHeight; ++y)
            {
                for (int x = 0; x < CharWidth; ++x)
                {
                    Point p = base.GetAdvancePixelPoint(px + x, py + y);
                    int bytemapAddr = bytemap.GetPointAddress(p.X, p.Y);
                    bytemap.Data[bytemapAddr] = (byte)bitReader.ReadBits(ColorBit);
                }
            }
        }

        public override void ConvertChrToMem(Byte[] sourceData, int addr, Bytemap bytemap, int px, int py)
        {
            BitWriter bitWriter = new BitWriter(sourceData);
            bitWriter.BitIndex = addr * 8;

            for (int y = 0; y < CharHeight; ++y)
            {
                for (int x = 0; x < CharWidth; ++x)
                {
                    Point p = base.GetAdvancePixelPoint(px + x, py + y);
                    int bytemapAddr = bytemap.GetPointAddress(p.X, p.Y);
                    bitWriter.WriteBits(ColorBit, bytemap.Data[bytemapAddr]);
                }
            }
        }
    }

    // 8x8
    //public class XaviX1Bpp8x8Format : XaviXFormatBase { public XaviX1Bpp8x8Format() : base(1, 8, 8) { } }
    public class XaviX2Bpp8x8Format : XaviXFormatBase { public XaviX2Bpp8x8Format() : base(2, 8, 8) { } }
    public class XaviX3Bpp8x8Format : XaviXFormatBase { public XaviX3Bpp8x8Format() : base(3, 8, 8) { } }
    public class XaviX4Bpp8x8Format : XaviXFormatBase { public XaviX4Bpp8x8Format() : base(4, 8, 8) { } }
    public class XaviX5Bpp8x8Format : XaviXFormatBase { public XaviX5Bpp8x8Format() : base(5, 8, 8) { } }
    public class XaviX8Bpp8x8Format : XaviXFormatBase { public XaviX8Bpp8x8Format() : base(8, 8, 8) { } }

    // 16x16
    public class XaviX1Bpp16x16Format : XaviXFormatBase { public XaviX1Bpp16x16Format() : base(1, 16, 16) { } }
    public class XaviX2Bpp16x16Format : XaviXFormatBase { public XaviX2Bpp16x16Format() : base(2, 16, 16) { } }
    public class XaviX3Bpp16x16Format : XaviXFormatBase { public XaviX3Bpp16x16Format() : base(3, 16, 16) { } }
    public class XaviX4Bpp16x16Format : XaviXFormatBase { public XaviX4Bpp16x16Format() : base(4, 16, 16) { } }
    public class XaviX5Bpp16x16Format : XaviXFormatBase { public XaviX5Bpp16x16Format() : base(5, 16, 16) { } }
    public class XaviX8Bpp16x16Format : XaviXFormatBase { public XaviX8Bpp16x16Format() : base(8, 16, 16) { } }

    // 32x32
    public class XaviX1Bpp32x32Format : XaviXFormatBase { public XaviX1Bpp32x32Format() : base(1, 32, 32) { } }
    public class XaviX2Bpp32x32Format : XaviXFormatBase { public XaviX2Bpp32x32Format() : base(2, 32, 32) { } }
    public class XaviX3Bpp32x32Format : XaviXFormatBase { public XaviX3Bpp32x32Format() : base(3, 32, 32) { } }
    public class XaviX4Bpp32x32Format : XaviXFormatBase { public XaviX4Bpp32x32Format() : base(4, 32, 32) { } }
    public class XaviX5Bpp32x32Format : XaviXFormatBase { public XaviX5Bpp32x32Format() : base(5, 32, 32) { } }
    public class XaviX8Bpp32x32Format : XaviXFormatBase { public XaviX8Bpp32x32Format() : base(8, 32, 32) { } }

    // 8x16
    public class XaviX1Bpp8x16Format : XaviXFormatBase { public XaviX1Bpp8x16Format() : base(1, 8, 16) { } }
    public class XaviX2Bpp8x16Format : XaviXFormatBase { public XaviX2Bpp8x16Format() : base(2, 8, 16) { } }
    public class XaviX3Bpp8x16Format : XaviXFormatBase { public XaviX3Bpp8x16Format() : base(3, 8, 16) { } }
    public class XaviX4Bpp8x16Format : XaviXFormatBase { public XaviX4Bpp8x16Format() : base(4, 8, 16) { } }
    public class XaviX5Bpp8x16Format : XaviXFormatBase { public XaviX5Bpp8x16Format() : base(5, 8, 16) { } }
    public class XaviX8Bpp8x16Format : XaviXFormatBase { public XaviX8Bpp8x16Format() : base(8, 8, 16) { } }
}
