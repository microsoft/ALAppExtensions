// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using System.Integration.Excel;

page 18808 "Customer Concessional Codes"
{
    PageType = List;
    UsageCategory = Lists;
    DelayedInsert = true;
    SourceTable = "Customer Concessional Code";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("TCS Nature of Collection"; Rec."TCS Nature of Collection")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the TCS Nature of collection under which tax has been collected.';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the TCS Nature of Collection.';
                }
                field("Concessional Code"; Rec."Concessional Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Concessional Code if concessional rate is applicable.';
                }
                field("Reference No."; Rec."Concessional Form No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the concessional form/certificate number.';
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
                    EditinExcel.EditPageInExcel('Customer Concessional Codes', Page::"Customer Concessional Codes");
                end;
            }
        }
    }
}
