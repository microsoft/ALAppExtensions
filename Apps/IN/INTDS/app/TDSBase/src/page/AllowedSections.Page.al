// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using System.Integration.Excel;

page 18687 "Allowed Sections"
{
    PageType = List;
    SourceTable = "Allowed Sections";
    DelayedInsert = true;
    ShowFilter = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Vendor No"; Rec."Vendor No")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Vendor No. ';
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
                field("Default Section"; Rec."Default Section")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Select the check mark if the section has to be auto updated in the transaction.';
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
                field("Non Resident Payments"; Rec."Non Resident Payments")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the section belongs to Non Resident payments.';
                }
                field("Nature of Remittance"; Rec."Nature of Remittance")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the type of remittance deductee deals with.';
                }
                field("Act Applicable"; Rec."Act Applicable")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the tax rates prescribed under the IT Act or DTAA.';
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
                    EditinExcel.EditPageInExcel('Allowed Sections', Page::"Allowed Sections");
                end;
            }
        }
    }
}
