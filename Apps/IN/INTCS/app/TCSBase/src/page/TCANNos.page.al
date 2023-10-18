// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using System.Integration.Excel;

page 18809 "T.C.A.N. Nos."
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "T.C.A.N. No.";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'T.C.A.N. number is allotted by Income Tax Department to the collector.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the T.C.A.N. Number.';
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
                    EditinExcelFilters: Codeunit "Edit in Excel Filters";
                begin
                    EditinExcelFilters.AddField('Code', Enum::"Edit in Excel Filter Type"::Equal, Rec.Code, Enum::"Edit in Excel Edm Type"::"Edm.String");
                    EditinExcel.EditPageInExcel('T.C.A.N. No.', Page::"T.C.A.N. Nos.", EditinExcelFilters);
                end;
            }
        }
    }
}
