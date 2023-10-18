// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN23
namespace Microsoft.Finance.GST.Sales;

using Microsoft.Finance.GST.Base;
using System.Integration.Excel;

page 18141 "E-Commerce Merchant Id"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "e-Commerce Merchant";
    Caption = 'e-Commerce Merchant';
    ObsoleteReason = 'New page 18146 introduced as "E-Comm. Merchant Id" with customer No. field length as 20';
    ObsoleteState = Pending;
    ObsoleteTag = '23.0';

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
                        Page::"E-Commerce Merchant Id");
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        Error(UnusedFieldLbl);
    end;

    var
        UnusedFieldLbl: Label 'This Page has been marked as obsolete and will be removed from version 23.0. Instead of this Page use â€˜E-Comm. Merchant Id';
}
#endif
