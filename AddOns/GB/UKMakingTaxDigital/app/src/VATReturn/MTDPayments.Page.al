// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 10531 "MTD Payments"
{
    Caption = 'VAT Payments';
    ApplicationArea = Basic, Suite;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "MTD Payment";
    UsageCategory = Lists;
    SaveValues = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Start Date"; "Start Date")
                {
                    ToolTip = 'Specifies the start date of the period.';
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; "End Date")
                {
                    ToolTip = 'Specifies the end date of the period.';
                    ApplicationArea = Basic, Suite;
                }
                field("Received Date"; "Received Date")
                {
                    ToolTip = 'Specifies the payment received date.';
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Amount)
                {
                    ToolTip = 'Specifies the payment value.';
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Get VAT Payments")
            {
                Caption = 'Get Payments';
                ToolTip = 'Retrieve and sync VAT payments from HMRC service.';
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
                    GetMTDRecords.Initialize(CaptionOption::Payments);
                    GetMTDRecords.RunModal();
                end;
            }
        }
    }
}

