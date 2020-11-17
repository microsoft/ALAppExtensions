// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// Enumeration determining the provider for barcode encoding module. 
/// Microsoft uses the 1D-fonts from ID-Automation to generate the barcodes. 
/// 
/// Values can be either:
/// <param name="Default">Default Microsoft Provider</param>
/// 
/// or can be extended  with your own providers
/// </summary>
enum 9200 BarcodeProviders implements IBarcodeProvider
{
    Extensible = true;

    /// <summary>
    /// uses the default 1D-barcode provider from Microsoft.
    /// </summary>
    value(0; default)
    {
        Caption = 'Default Provider';
        Implementation = IBarcodeProvider = BarcodeProvider;
    }
}
