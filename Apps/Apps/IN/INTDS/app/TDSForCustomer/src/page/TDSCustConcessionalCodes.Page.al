// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSForCustomer;

using System.Integration.Excel;

page 18662 "TDS Cust Concessional Codes"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    DelayedInsert = true;
    SourceTable = "TDS Customer Concessional Code";
    Caption = 'TDS Customer Concessional Codes';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the Customer code';
                }
                field("TDS Section Code"; Rec."TDS Section Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the Section codes under which tax has been deducted.';
                }

                field("Concessional Code"; Rec."Concessional Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the concessional code if concessional rate is applicable.';
                }
                field("Certificate No."; Rec."Certificate No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the concessional form/certificate number of the deductee.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the starting date of concessional certificate issued.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the ending date of concessional certificate issued.';
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
                ToolTip = 'Send the data in the  page to an Excel file for analysis or editing';

                trigger OnAction()
                var
                    EditinExcel: Codeunit "Edit in Excel";
                begin
                    EditinExcel.EditPageInExcel('Customer Concessional Codes', Page::"TDS Cust Concessional Codes");
                end;
            }
        }
    }
}
