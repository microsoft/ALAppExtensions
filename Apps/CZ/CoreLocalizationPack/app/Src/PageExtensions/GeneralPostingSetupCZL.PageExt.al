// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Setup;

pageextension 31165 "General Posting Setup CZL" extends "General Posting Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("Invt. Rounding Adj. Acc. CZL"; Rec."Invt. Rounding Adj. Acc. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the inventory rounding adjustment account.';
            }
        }
    }
}
