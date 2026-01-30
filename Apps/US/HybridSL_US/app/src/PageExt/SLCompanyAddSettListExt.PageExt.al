// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

pageextension 47201 "SL Company Add. Sett. List Ext" extends "SL Company Add. Settings List"
{
    layout
    {
        addlast(General)
        {
            field("Migrate Current 1099 Year"; Rec."Migrate Current 1099 Year")
            {
                ApplicationArea = All;
                Caption = 'Migrate Current 1099 Year';
                ToolTip = 'Specifies whether to migrate current 1099 year data.';
            }
            field("Migrate Next 1099 Year"; Rec."Migrate Next 1099 Year")
            {
                ApplicationArea = All;
                Caption = 'Migrate Next 1099 Year';
                ToolTip = 'Specifies whether to migrate next 1099 year data.';
            }
        }
    }
}