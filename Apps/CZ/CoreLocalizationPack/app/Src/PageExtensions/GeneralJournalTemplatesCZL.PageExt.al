// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

pageextension 31142 "General Journal Templates CZL" extends "General Journal Templates"
{
    layout
    {
        addlast(Control1)
        {
            field("Not Check Doc. Type CZL"; Rec."Not Check Doc. Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether to suppress the document balance check according to document type.';
                Visible = false;
            }
        }
    }
}
