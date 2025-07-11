// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSForCustomer;

using System.Integration.Excel;

page 18661 "Customer Allowed Sections"
{
    PageType = List;
    SourceTable = "Customer Allowed Sections";
    DelayedInsert = true;
    ShowFilter = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Customer No"; Rec."Customer No")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Customer No. ';
                    Visible = false;
                }
                field("TDS Section"; Rec."TDS Section")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the section codes as per the Income Tax Act 1961';
                }
                field("TDS Section Description"; Rec."TDS Section Description")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the section description as per the Income Tax Act 1961';
                }
                field("Threshold Overlook"; Rec."Threshold Overlook")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Select the check mark in this field to overlook the TDS Threshold amount.';
                }
                field("Surcharge Overlook"; Rec."Surcharge Overlook")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Select the check mark in this field to overlook the TDS surcharge amount.';
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
                    EditinExcel.EditPageInExcel('Allowed Sections', Page::"Customer Allowed Sections");
                end;
            }
        }
    }
}
