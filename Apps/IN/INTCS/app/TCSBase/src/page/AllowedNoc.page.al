// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using System.Integration.Excel;

page 18807 "Allowed NOC"
{
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "Allowed NOC";
    Caption = 'Allowed NOC';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("TCS Nature of Collection"; Rec."TCS Nature of Collection")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Nature of Collection on which TCS is applied.';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the TCS Nature of Collection.';
                }
                field("Default NOC"; Rec."Default NOC")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default TCS Nature of collection that the customer is linked to.';
                }
                field("Threshold Overlook"; Rec."Threshold Overlook")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Select the check mark if you want to overlook the TCS threshold amount.';
                }
                field("Surcharge Overlook"; Rec."Surcharge Overlook")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Select the check mark if you want to overlook the TCS surcharge amount.';
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
                    EditinExcel.EditPageInExcel('Allowed NOC', Page::"Allowed NOC");
                end;
            }
        }
    }
}
