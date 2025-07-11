// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

pageextension 31209 "Chart of Accs. (An. View) CZL" extends "Chart of Accs. (Analysis View)"
{
    layout
    {
        addafter("Net Change")
        {
            field("Debit Amount CZL"; Rec."Debit Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the total of the debit entries that have been posted to the account.';
                Visible = false;
            }
            field("Credit Amount CZL"; Rec."Credit Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the total of the credit entries that have been posted to the account.';
                Visible = false;
            }
        }
    }
}
