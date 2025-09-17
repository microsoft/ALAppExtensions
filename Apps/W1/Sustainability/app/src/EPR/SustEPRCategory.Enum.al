// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.EPR;

enum 6225 "Sust. EPR Category"
{
    Caption = 'EPR Category';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Packaging)
    {
        Caption = 'Packaging';
    }
    value(2; Electronics)
    {
        Caption = 'Electronics';
    }
    value(3; Batteries)
    {
        Caption = 'Batteries';
    }
    value(4; Textiles)
    {
        Caption = 'Textiles';
    }
    value(5; "Hazardous Waste")
    {
        Caption = 'Hazardous Waste';
    }
}