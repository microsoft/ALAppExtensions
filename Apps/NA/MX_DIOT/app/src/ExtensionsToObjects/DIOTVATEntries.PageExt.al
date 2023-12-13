// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Ledger;

pageextension 27037 "DIOT VAT Entries" extends "VAT Entries"
{
    layout
    {
        addafter("Country/Region Code")
        {
            field("DIOT Type of Operation"; "DIOT Type of Operation")
            {
                ApplicationArea = BasicMX;
                Caption = 'DIOT Type of Operation';
                ToolTip = 'Specifies the DIOT operation type for this entry.';
            }
        }
    }
}
