// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using System.Integration.Excel;

page 18547 "States"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = State;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state codes as per the Income Tax Act 1961';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of state codes';
                }
                field("State Code for eTDS/TCS"; Rec."State Code for eTDS/TCS")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the numeric code for state which is mandatory if deductor type is State Govt. (code S), Statutory body - State Govt. (code E), Autonomous body - State Govt. code H) and Local Authority - State Govt. (code N).';
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
                    EditinExcelFilters: Codeunit "Edit in Excel Filters";
                begin
                    EditinExcelFilters.AddField('Code', Enum::"Edit in Excel Filter Type"::Equal, Rec.Code, Enum::"Edit in Excel Edm Type"::"Edm.String");

                    EditinExcel.EditPageInExcel(
                        'States',
                        Page::States,
                        EditinExcelFilters);
                end;
            }
        }
    }
}
