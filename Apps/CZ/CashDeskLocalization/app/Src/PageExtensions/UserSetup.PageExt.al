// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using System.Security.User;

pageextension 31157 "User Setup CZP" extends "User Setup"
{
    layout
    {
        addafter("Service Resp. Ctr. Filter")
        {
            field("Cash Resp. Ctr. Filter CZP"; Rec."Cash Resp. Ctr. Filter CZP")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for the responsibility center you want to assign to the user. The user will only be able to see cash documents for the responsibility center specified in the field. This responsibility center will also be the default responsibility center when the user creates new cash desk documents.';
            }
        }
    }
}
