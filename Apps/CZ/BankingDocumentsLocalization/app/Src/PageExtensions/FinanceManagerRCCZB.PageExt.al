// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Finance.RoleCenters;

pageextension 31291 "Finance Manager RC CZB" extends "Finance Manager Role Center"
{
    actions
    {
        addlast(Group13)
        {
            action("Payment Orders CZB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment Orders';
                RunObject = page "Payment Orders CZB";
                ToolTip = 'View or edit payment orders.';
            }
            action("Issued Payment Orders CZB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Issued Payment Orders';
                RunObject = page "Iss. Payment Orders CZB";
                ToolTip = 'View issued payment orders.';
            }
            action("Bank Statements CZB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Statements';
                RunObject = page "Bank Statements CZB";
                ToolTip = 'View or edit bank statements.';
            }
            action("Issued Bank Statements CZB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Issued Bank Statements';
                RunObject = page "Iss. Bank Statements CZB";
                ToolTip = 'View issued bank statements.';
            }
        }
    }
}
