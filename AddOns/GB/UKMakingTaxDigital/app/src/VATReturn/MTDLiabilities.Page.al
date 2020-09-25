// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 10530 "MTD Liabilities"
{
    Caption = 'VAT Liabilities';
    ApplicationArea = Basic, Suite;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "MTD Liability";
    UsageCategory = Lists;
    SaveValues = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("From Date"; "From Date")
                {
                    ToolTip = 'Specifies the from date of this tax period.';
                    ApplicationArea = Basic, Suite;
                }
                field("To Date"; "To Date")
                {
                    ToolTip = 'Specifies the to date of this tax period.';
                    ApplicationArea = Basic, Suite;
                }
                field(Type; Type)
                {
                    ToolTip = 'Specifies the charge type of this liability.';
                    ApplicationArea = Basic, Suite;
                }
                field("Original Amount"; "Original Amount")
                {
                    ToolTip = 'Specifies the original liability value.';
                    ApplicationArea = Basic, Suite;
                }
                field("Outstanding Amount"; "Outstanding Amount")
                {
                    ToolTip = 'Specifies the outstanding liability value.';
                    ApplicationArea = Basic, Suite;
                }
                field("Due Date"; "Due Date")
                {
                    ToolTip = 'Specifies the liability due date.';
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Get VAT Liabilities")
            {
                Caption = 'Get Liabilities';
                ToolTip = 'Retrieve and sync VAT liabilities from HMRC service.';
                Image = RefreshLines;
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    GetMTDRecords: Report "Get MTD Records";
                    CaptionOption: Option ReturnPeriods,Payments,Liabilities;
                begin
                    GetMTDRecords.Initialize(CaptionOption::Liabilities);
                    GetMTDRecords.RunModal();
                end;
            }
        }
    }
}

