// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Finance.RoleCenters;

pageextension 31203 "Accountant CZ Role Center CZB" extends "Accountant CZ Role Center CZL"
{
    actions
    {
        addafter("Bank Accounts")
        {
            action("Payment Orders CZB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment Orders';
                Ellipsis = true;
                Image = ApplicationWorksheet;
                RunObject = Page "Payment Orders CZB";
                ToolTip = 'View or edit payment orders.';
            }
            action("Bank Statements CZB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Statements';
                Ellipsis = true;
                Image = ApplicationWorksheet;
                RunObject = Page "Bank Statements CZB";
                ToolTip = 'View or edit bank statements.';
            }
        }
        addlast("Cash Management")
        {
            action("Issued Payment Orders CZB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Issued Payment Orders';
                Ellipsis = true;
                Image = ApplicationWorksheet;
                RunObject = Page "Iss. Payment Orders CZB";
                ToolTip = 'View issued payment orders.';
            }
            action("Issued Bank Statements CZB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Issued Bank Statements';
                Ellipsis = true;
                Image = ApplicationWorksheet;
                RunObject = Page "Iss. Bank Statements CZB";
                ToolTip = 'View issued bank statements.';
            }
        }
    }
}
