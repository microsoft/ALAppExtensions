// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// The available barcode symbologies.
/// </summary>
enum 9204 "Barcode Symbology"
{
    Access = Public;
    Extensible = true;

    /// <summary>
    /// Code 39 - An alpha-numeric barcode that encodes uppercase letters, numbers and some symbols; it is also referred to as Barcode/39, the 3 of 9 Code and LOGMARS Code.
    /// </summary>
    value(100; Code39)
    {
        Caption = 'Code-39', Locked = true;
    }

    /// <summary>
    /// Codabar - A numeric barcode encoding numbers with a slightly higher density than Code 39.
    /// </summary>
    value(105; Codabar)
    {
        Caption = 'Codabar', Locked = true;
    }

    /// <summary>
    /// Code 128 - Alpha-numeric barcode with three character sets. Supports Code-128, GS1-128 (Formerly known as UCC/EAN-128) and ISBT-128.
    /// </summary>
    value(110; Code128)
    {
        Caption = 'Code-128', Locked = true;
    }

    /// <summary>
    /// Code 93 - Similar to Code 39, but requires two checksum characters.
    /// </summary>
    value(115; Code93)
    {
        Caption = 'Code-93', Locked = true;
    }

    /// <summary>
    /// Interleaved 2 of 5 - The Interleaved 2 of 5 barcode symbology encodes numbers in pairs, similar to Code 128 set C.
    /// </summary>
    value(120; Interleaved2of5)
    {
        Caption = 'Interleaved 2 of 5', Locked = true;
    }

    /// <summary>
    /// Postenet - The Intelligent Mail customer barcode combines the information of both the POSTNET and PLANET symbologies, and additional information, into a single barcode that is about the same size as the traditional POSTNET symbol. 
    /// </summary>
    value(125; Postnet)
    {
        Caption = 'Postnet', Locked = true;
    }

    /// <summary>
    /// MIS - The MSI Plessey barcode symbology was designed in the 1970s by the Plessey Company in England and has practiced primarily in libraries and retail applications. 
    /// </summary>
    value(130; MSI)
    {
        Caption = 'MSI', Locked = true;
    }

    /// <summary>
    /// EAN-8 - The MSI Plessey barcode symbology was designed in the 1970s by the Plessey Company in England and has practiced primarily in libraries and retail applications. 
    /// </summary>
    value(200; "EAN-8")
    {
        Caption = 'EAN-8', Locked = true;
    }

    /// <summary>
    /// EAN-13 - The EAN-13 was developed as a superset of UPC-A, adding an extra digit to the beginning of every UPC-A number. 
    /// </summary>
    value(201; "EAN-13")
    {
        Caption = 'EAN-13', Locked = true;
    }

    /// <summary>
    /// UPC-A - The Universal Product Code (UPC; redundantly: UPC code) is a barcode symbology that is widely used in the United States, Canada, Europe, Australia, New Zealand, and other countries for tracking trade items in stores.
    /// </summary>
    value(202; "UPC-A")
    {
        Caption = 'UPC-A', Locked = true;
    }

    /// <summary>
    /// UPC-E -  To allow the use of UPC barcodes on smaller packages, where a full 12-digit barcode may not fit, a 'zero-suppressed version of UPC was developed, called UPC-E.
    /// </summary>
    value(203; "UPC-E")
    {
        Caption = 'UPC-E', Locked = true;
    }
}