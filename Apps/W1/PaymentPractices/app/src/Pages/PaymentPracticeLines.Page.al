// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

page 688 "Payment Practice Lines"
{
    ApplicationArea = All;
    Caption = 'Lines';
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Payment Practice Line";

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the number of the payment practice line.';
                }
                field("Aggregation Type"; Rec."Aggregation Type")
                {
                    Editable = false;
                    ToolTip = 'Specifies the type of aggregation.';
                    Visible = false;
                }
                field("Source Type"; Rec."Source Type")
                {
                    Editable = false;
                    ToolTip = 'Specifies the source for the payment data.';
                    Visible = HeaderType = HeaderType::"Vendor+Customer";
                }
                field("Company Size Code"; Rec."Company Size Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the company size code.';
                    Visible = AggregationType = AggregationType::"Company Size";
                }
                field("Payment Period Code"; Rec."Payment Period Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the payment period code.';
                    Visible = false;
                }
                field("Payment Period Description"; Rec."Payment Period Description")
                {
                    Editable = false;
                    ToolTip = 'Specifies the payment period description.';
                    Visible = AggregationType = AggregationType::Period;
                }
                field("Average Agreed Payment Period"; Rec."Average Agreed Payment Period")
                {
                    ToolTip = 'Specifies the average agreed payment period.';
                    Visible = AggregationType = AggregationType::"Company Size";
                }
                field("Average Actual Payment Period"; Rec."Average Actual Payment Period")
                {
                    ToolTip = 'Specifies the average actual payment period.';
                    Visible = AggregationType = AggregationType::"Company Size";
                }
                field("Pct Paid on Time"; Rec."Pct Paid on Time")
                {
                    ToolTip = 'Specifies the percentage paid on time.';
                    Visible = AggregationType = AggregationType::"Company Size";

                    trigger OnAssistEdit()
                    begin
                        ShowLineDataLines();
                    end;
                }
                field("Pct Paid in Period"; Rec."Pct Paid in Period")
                {
                    ToolTip = 'Specifies the percentage paid in period.';
                    Visible = AggregationType = AggregationType::Period;

                    trigger OnAssistEdit()
                    begin
                        ShowLineDataLines();
                    end;
                }
                field("Pct Paid in Period (Amount)"; Rec."Pct Paid in Period (Amount)")
                {
                    ToolTip = 'Specifies the percentage paid in period (amount).';
                    Visible = AggregationType = AggregationType::Period;
                }
                field("Modified Manully"; Rec."Modified Manually")
                {
                    Editable = false;
                    ToolTip = 'Specifies whether the line has been modified manually.';
                }
            }
        }
    }

    procedure UpdateVisibility(newAggregationType: enum "Paym. Prac. Aggregation Type"; newHeaderType: enum "Paym. Prac. Header Type")
    begin
        AggregationType := newAggregationType;
        HeaderType := newHeaderType;
    end;

    var
        AggregationType: enum "Paym. Prac. Aggregation Type";
        HeaderType: enum "Paym. Prac. Header Type";

    local procedure ShowLineDataLines()
    var
        PaymentPracticeData: Record "Payment Practice Data";
    begin
        PaymentPracticeData.SetFilterForLine(Rec);
        Page.RunModal(Page::"Payment Practice Data List", PaymentPracticeData);
    end;
}
