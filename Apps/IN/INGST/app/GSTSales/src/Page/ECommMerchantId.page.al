// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Sales;

using Microsoft.Finance.GST.Base;
using System.Integration.Excel;

page 18146 "E-Comm. Merchant Id"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "E-Comm. Merchant";
    Caption = 'E-Comm. Merchant';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the customer number for which merchant id has to be recorded.';
                }
                field("Merchant Id"; Rec."Merchant Id")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the merchant id provided to customers by their payment processor.';
                }
                field("Company GST Reg. No."; Rec."Company GST Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company''s GST Reg. number issued by authorized body.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(EditInExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Edit in Excel';
                Image = Excel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Send the data in the page to an Excel file for analysis or editing';

                trigger OnAction()
                var
                    EditinExcel: Codeunit "Edit in Excel";
                begin
                    EditinExcel.EditPageInExcel(
                        'e-Commerce Merchant Id',
                        Page::"E-Comm. Merchant Id");
                end;
            }
        }
    }
}
