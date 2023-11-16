// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Setup;

pageextension 31166 "General Posting Setup Card CZL" extends "General Posting Setup Card"
{
    layout
    {
        addlast(Inventory)
        {
            field("Invt. Rounding Adj. Acc. CZL"; Rec."Invt. Rounding Adj. Acc. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the inventory rounding adjustment account.';
            }
        }
    }
}
