// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Setup;
using Microsoft.Finance;

pageextension 14606 "IS Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    layout
    {
        addafter(Printing)
        {
            field("Electronic Invoicing Reminder"; Rec."Electronic Invoicing Reminder")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the company complies with the requirement of tracking invoicing electronically, when printing invoices in single copy.';
            }
        }
    }
    actions
    {
        addfirst(navigation)
        {
            group(Action)
            {
                Caption = 'Actions';
                action("Print Statements")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Print Statement';
                    RunObject = report "IS IRS notification";
                    Image = "Report";
                    ToolTip = 'Generate a letter that can be sent to the Internal Revenue Service (IRS) if the company wants to print invoices in a single copy. The report includes the company information by default. To change the wording, you must modify the text in Visual Studio Report Designer.';
                }
            }
        }
        addfirst(Category_Report)
        {
            actionref("Print Statement_Promoted2"; "Print Statements")
            {
            }
        }
    }
}