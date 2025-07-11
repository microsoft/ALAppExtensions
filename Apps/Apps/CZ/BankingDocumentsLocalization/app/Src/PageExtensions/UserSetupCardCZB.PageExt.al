// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using System.Security.User;

pageextension 31284 "User Setup Card CZB" extends "User Setup Card CZL"
{
    layout
    {
        addlast(Posting)
        {
            field("Check Payment Orders CZB"; Rec."Check Payment Orders CZB")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the payment order processing is allowed only for bank accounts setted up in the lines.';
            }
            field("Check Bank Statements CZB"; Rec."Check Bank Statements CZB")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the bank statements processing is allowed only for bank accounts setted up in the lines.';
            }
        }
    }
}
