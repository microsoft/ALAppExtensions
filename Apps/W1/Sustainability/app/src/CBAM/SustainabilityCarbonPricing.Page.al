// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.CBAM;

using Microsoft.Sustainability.Setup;

page 6260 "Sustainability Carbon Pricing"
{
    Caption = 'Carbon Pricing';
    DataCaptionExpression = PageCaptionText;
    ApplicationArea = Basic, Suite;
    PageType = List;
    SourceTable = "Sustainability Carbon Pricing";
    AdditionalSearchTerms = 'Carbon Pricing, CBAM Rates';
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Country/Region of Origin"; Rec."Country/Region of Origin")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Country/Region of Origin field.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Starting Date field.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Ending Date field.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field.';
                }
                field("Threshold Quantity"; Rec."Threshold Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Threshold Quantity field.';
                }
                field("Rounding Type"; Rec."Rounding Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Rounding field.';
                }
                field("Carbon Price"; Rec."Carbon Price")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Carbon Price field.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        PageCaptionText := GetCaption();
    end;

    var
        PageCaptionText: Text;
        CBAMRatesLbl: Label 'CBAM Rates';

    local procedure GetCaption(): Text
    var
        CaptainClassMgt: Codeunit "Sust. CaptionClass Mgt";
    begin
        if CaptainClassMgt.IsEUCountry() then
            exit(CBAMRatesLbl);

        exit(CurrPage.Caption());
    end;
}