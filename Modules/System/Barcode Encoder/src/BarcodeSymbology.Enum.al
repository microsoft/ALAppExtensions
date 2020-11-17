// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// Enumeration determining the option for encoding modules for over 100 different barcode types and standards. 
/// All linear and two-dimensional barcodes in common use (and many uncommon ones) are available. 
/// Values can be either:
/// <param name="Code39">
/// Code 39 - An alpha-numeric barcode that encodes uppercase letters, numbers and some symbols; it is also referred to as Barcode/39, the 3 of 9 Code and LOGMARS Code.
/// </param>
/// <param name="Codabar">
/// Codabar - A numeric barcode encoding numbers with a slightly higher density than Code 39.
/// </param>
/// <param name="Code128">
/// Code 128 - Alpha-numeric barcode with three character sets. Supports Code-128, GS1-128 (Formerly known as UCC/EAN-128) and ISBT-128.
/// </param>
/// <param name="Code93">
/// Code 93 - Similar to Code 39, but requires two checksum characters.
/// </param>
/// <param name="Interleaved2of5">
/// Interleaved 2 of 5 - The Interleaved 2 of 5 barcode symbology encodes numbers in pairs, similar to Code 128 set C.
/// </param>
/// <param name="Postnet">
/// Postenet - The Intelligent Mail customer barcode combines the information of both the POSTNET and PLANET symbologies, and additional information, into a single barcode that is about the same size as the traditional POSTNET symbol. 
/// </param>
/// <param name="MSI">
/// MIS - The MSI Plessey barcode symbology was designed in the 1970s by the Plessey Company in England and has practiced primarily in libraries and retail applications. 
/// </param>
/// <param name="EAN8">
/// EAN-8 - The MSI Plessey barcode symbology was designed in the 1970s by the Plessey Company in England and has practiced primarily in libraries and retail applications. 
/// </param>
/// <param name="EAN13">
/// EAN-13 - The EAN-13 was developed as a superset of UPC-A, adding an extra digit to the beginning of every UPC-A number. 
/// </param>
/// <param name="UPC-A">
/// UPC-A - The Universal Product Code (UPC; redundantly: UPC code) is a barcode symbology that is widely used in the United States, Canada, Europe, Australia, New Zealand, and other countries for tracking trade items in stores.
/// </param>
/// <param name="UPC-E">
/// UPC-E -  To allow the use of UPC barcodes on smaller packages, where a full 12-digit barcode may not fit, a 'zero-suppressed version of UPC was developed, called UPC-E.
/// </param>
/// </summary>
enum 9201 BarcodeSymbology implements IBarcodeEncoder
{
    Extensible = true;

    //#Region Linear Barcode Fonts
    value(100; code39)
    {
        Caption = 'Code-39', Locked = true;
        Implementation = IBarcodeEncoder = Code39BarcodeEncoder;
    }
    value(105; codabar)
    {
        Caption = 'Codabar', Locked = true;
        Implementation = IBarcodeEncoder = CodabarBarcodeEncoder;
    }

    value(110; code128)
    {
        Caption = 'Code-128', Locked = true;
        Implementation = IBarcodeEncoder = Code128BarcodeEncoder;
    }
    value(115; code93)
    {
        Caption = 'Code-93', Locked = true;
        Implementation = IBarcodeEncoder = Code93BarcodeEncoder;
    }

    value(120; interleaved2of5)
    {
        Caption = 'Interleaved 2 of 5', Locked = true;
        Implementation = IBarcodeEncoder = I2of5BarcodeEncoder;
    }
    value(125; postnet)
    {
        Caption = 'Postnet', Locked = true;
        Implementation = IBarcodeEncoder = PostnetBarcodeEncoder;
    }
    value(130; MSI)
    {
        Caption = 'MSI', Locked = true;
        Implementation = IBarcodeEncoder = MSIBarcodeEncoder;
    }

    value(200; ean8)
    {
        Caption = 'EAN-8', Locked = true;
        Implementation = IBarcodeEncoder = EAN8BarcodeEncoder;
    }
    value(201; ean13)
    {
        Caption = 'EAN-13', Locked = true;
        Implementation = IBarcodeEncoder = EAN13BarcodeEncoder;
    }
    value(202; "upc-a")
    {
        Caption = 'UPC-A', Locked = true;
        Implementation = IBarcodeEncoder = UPCA_BarcodeEncoder;
    }
    value(203; "upc-e")
    {
        Caption = 'UPC-E', Locked = true;
        Implementation = IBarcodeEncoder = UPCE_BarcodeEncoder;
    }
    //#EndRegion Liniar Barcode Fonts
}


