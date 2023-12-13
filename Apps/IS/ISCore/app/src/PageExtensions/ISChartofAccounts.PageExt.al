// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Account;

pageextension 14602 "IS Chart of Accounts" extends "Chart of Accounts"
{
    layout
    {
        addafter("Gen. Prod. Posting Group")
        {
            field("IRS No."; Rec."IRS No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Internal Revenue Service (IRS) tax numbers for the account.';
#if not CLEAN24
                Visible = IsISCoreAppEnabled;
                Enabled = IsISCoreAppEnabled;
#endif
            }
        }
    }
}
