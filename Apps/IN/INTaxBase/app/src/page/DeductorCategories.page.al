// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using System.Integration.Excel;

page 18545 "Deductor Categories"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Deductor Category";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of type of deductor /employer.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the type of deductor /employer.';
                }
                field("PAO Code Mandatory"; Rec."PAO Code Mandatory")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the Pay and Accounts Office (PAO) is mandatory for deductor type Central Government.';
                }
                field("DDO Code Mandatory"; Rec."DDO Code Mandatory")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the Drawing and Disbursing Officer (DDO) is mandatory for deductor type - Central Government.';
                }
                field("State Code Mandatory"; Rec."State Code Mandatory")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the state code is mandatory for deductor type -  State Government.';
                }
                field("Ministry Details Mandatory"; Rec."Ministry Details Mandatory")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the ministry details (ministry name and other) are mandatory for deductor type - Central Govt (A), Statutory body - Central Govt. (D) & Autonomous body - Central Govt. (G).';
                }
                field("Transfer Voucher No. Mandatory"; Rec."Transfer Voucher No. Mandatory")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the Transfer Voucher number is mandatory if the transaction is by book entry.';
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
                        'Deductor Categories',
                        Page::"Deductor Categories",
                        EditinExcelFilters);
                end;
            }
        }
    }
}
