// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Device;

/// <summary>
/// Specifies several of the units of measure used for printing.
/// </summary>
enum 2750 "Universal Printer Paper Unit"
{
    Extensible = false;
    value(0; Inches)
    {
        Caption = 'Inches (in)';
    }

    value(1; Millimeters)
    {
        Caption = 'Millimeters (mm)';
    }
}
