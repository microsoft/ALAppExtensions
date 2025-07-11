// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using System.Automation;

pageextension 31170 "Approval User Setup CZB" extends "Approval User Setup"
{
    layout
    {
        addafter("Unlimited Request Approval")
        {
            field("Bank Amount Approval Limit CZB"; Rec."Bank Amount Approval Limit CZB")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies the maximum amount in LCY that this user is allowed to approve for this record.';
            }
            field("Unlimited Bank Approval CZB"; Rec."Unlimited Bank Approval CZB")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies that the user on this line is allowed to approve payment orders records with no maximum amount. If you select this check box, then you cannot fill the Bank Amount Approval Limit field.';
            }
        }
    }
}
