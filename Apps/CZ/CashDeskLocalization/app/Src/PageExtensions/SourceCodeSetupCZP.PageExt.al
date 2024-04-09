// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Foundation.AuditCodes;

pageextension 31156 "Source Code Setup CZP" extends "Source Code Setup"
{
    layout
    {
        addlast(General)
        {
            field("Cash Desk CZP"; Rec."Cash Desk CZP")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the source code linked to entries that are related to cash desk.';
            }
        }
    }
}
