// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the type of a printer.
/// </summary>
enum 2619 "Printer Type"
{
    Extensible = false;
    value(0; "Local Printer")
    {
        Caption = 'Local Printer';
    }
    value(1; "Network Printer")
    {
        Caption = 'Cloud Printer';
    }
}
