// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

pageextension 31215 "Reconciliation CZL" extends Reconciliation
{
    layout
    {
        modify("No.")
        {
            Visible = false;
        }
        addafter("No.")
        {
            field("Account Type CZL"; Rec."Account Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the account type that is being reconciled.';
            }
            field("Account No. CZL"; Rec."Account No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the account no. that is being reconciled.';
            }
        }
        addlast(Control6)
        {
            field("Net Change in Jnl. Curr. CZL"; Rec."Net Change in Jnl. Curr. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Net Change in Journal (in Currency).';
            }
            field("Balance after Posting Curr.CZL"; Rec."Balance after Posting Curr.CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Balance after Posting (in Currency).';
            }
        }
    }
}
