// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// The available 2D barcode symbologies.
/// </summary>
enum 9205 "Barcode Symbology 2D"
{
    Access = Public;
    Extensible = true;

    /// <summary>
    /// Aztec barcodes are very efficient two-dimensional (2D) symbologies that use square modules with a unique finder pattern in the middle of the symbol, which helps the barcode scanner to determine cell locations to decode the symbol.
    /// Characters, numbers, text and bytes of data may be encoded in an Aztec barcode. The IDAutomation implementation of the Aztec barcode symbol is based on the ISO standard version released into the public domain by its inventor, Honeywell.
    /// </summary>
    value(10; Aztec)
    {
        Caption = 'Aztec', Locked = true;
    }

    /// <summary>
    /// Data Matrix is a very efficient, two-dimensional (2D) barcode symbology that uses a small area of square modules with a unique perimeter pattern, which helps the barcode scanner determine cell locations and decode the symbol.
    /// Characters, numbers, text and actual bytes of data may be encoded, including Unicode characters and photos.
    /// The encoding and decoding process of Data Matrix is very complex. Several methods have been used for error correction in the past. All current implementations have been standardized on the ECC200 error correction method, which is approved by ANSI/AIM BC11 and the ISO/IEC 16022 specification.
    /// IDAutomation 2D Data Matrix barcode products all support ECC200 by default and are based on the ANSI/AIM BC11 and the ISO/IEC 16022 specifications. The Reed-Solomon error correction algorithms of ECC200 allow the recognition of barcodes that are up to 60% damaged.
    /// </summary>
    value(20; "Data Matrix")
    {
        Caption = 'Data Matrix', Locked = true;
    }

    /// <summary>
    /// Maxicode is an international 2D (two-dimensional) barcode that is currently used by UPS on shipping labels for world-wide addressing and package sortation. MaxiCode symbols are fixed in size and are made up of offset rows of hexagonal modules arranged around a unique finder pattern.
    /// MaxiCode includes error correction, which enables the symbol to be decoded when it is slightly damaged.
    /// </summary>
    value(30; "Maxi Code")
    {
        Caption = 'Maxi Code', Locked = true;
    }

    /// <summary>
    /// The PDF417 barcode is a two-dimensional (2D), high-density symbology capable of encoding text, numbers, files and actual data bytes.
    /// Large amounts of text and data can be stored securely and inexpensively when using the PDF417 barcode symbology. The printed symbol consists of several linear rows of stacked codewords. Each codeword represents 1 of 929 possible values from one of three different clusters.
    /// A different cluster is chosen for each row, repeating after every three rows. Because the codewords in each cluster are unique, the scanner is able to determine what line each cluster is from.
    /// </summary>
    value(40; PDF417)
    {
        Caption = 'PDF417', Locked = true;
    }

    /// <summary>
    /// QR-Code is a two-dimensional (2D) barcode type similar to Data Matrix or Aztec, which is capable of encoding large amounts of data. QR means Quick Response, as the inventor intended the symbol to be quickly decoded. The data encoded in a QR-Code may include alphabetic characters, text, numbers, double characters and URLs.
    /// The symbology uses a small area of square modules with a unique perimeter pattern, which helps the barcode scanner determine cell locations to decode the symbol. IDAutomation’s implementation of QR-Code is based on the ISO/IEC 18004:2006 standard (also known as QR-Code 2005) and conforms to ISO/IEC 18004:2015 specifications.
    /// </summary>
    value(50; "QR-Code")
    {
        Caption = 'QR-Code', Locked = true;
    }
}