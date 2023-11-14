// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Ledger;

pageextension 31242 "G/L Entries Preview CZA" extends "G/L Entries Preview"
{
    layout
    {
        addafter("Posting Date")
        {
            field("Closed CZA"; Rec."Closed CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that the entry is closed.';
            }
        }
    }
}
