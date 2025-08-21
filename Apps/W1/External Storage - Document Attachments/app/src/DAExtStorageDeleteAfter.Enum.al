// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Defines when attachments should be deleted from internal storage after upload to external storage.
/// </summary>
enum 8750 "DA Ext. Storage - Delete After"
{
    Extensible = true;

    value(0; "Immediately")
    {
        Caption = 'Immediately';
    }
    value(1; "1 Day")
    {
        Caption = '1 Day';
    }
    value(7; "7 Days")
    {
        Caption = '7 Days';
    }
    value(14; "14 Days")
    {
        Caption = '14 Days';
    }
}
