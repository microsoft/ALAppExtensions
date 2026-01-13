// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Certificate;

enum 6224 "Sust. Source of Emission"
{
    Caption = 'Source of Emission';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Vendor)
    {
        Caption = 'Vendor';
    }
    value(2; Calculation)
    {
        Caption = 'Calculation';
    }
    value(3; Other)
    {
        Caption = 'Other';
    }
}