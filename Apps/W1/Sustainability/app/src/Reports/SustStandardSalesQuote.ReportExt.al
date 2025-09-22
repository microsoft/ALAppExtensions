// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Reports;

using Microsoft.Sales.Document;
using Microsoft.Sustainability.Setup;

reportextension 6298 "Sust. Standard Sales Quote" extends "Standard Sales - Quote"
{
    dataset
    {
        add(Header)
        {
            column(Disclaimer_Lbl; GetDisclaimer())
            {
            }
            column(CO2ePerUnit_Lbl; CO2ePerUnitTxt)
            {
            }
            column(TotalCO2e_Lbl; TotalCO2eTxt)
            {
            }
        }
        add("line")
        {
            column(CO2ePerUnit_Line; FormattedCO2ePerUnit)
            {
                AutoFormatType = 11;
                AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            }
        }
        add("Totals")
        {
            column(TotalCO2e; TotalCO2e)
            {
                AutoFormatType = 11;
                AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            }
        }
        modify("Line")
        {
            trigger OnBeforePreDataItem()
            begin
                TotalCO2e := 0;
            end;

            trigger OnAfterAfterGetRecord()
            begin
                FormattedCO2ePerUnit := Format("CO2e per Unit", 0, SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places")));
                TotalCO2e += "Total CO2e";
            end;
        }
    }
    rendering
    {
        layout("StandardESGSalesQuote.docx")
        {
            Type = Word;
            Caption = 'Standard ESG Sales Quote (Word)';
            Summary = 'The Standard ESG Sales Quote (Word) provides a basic layout.';
            LayoutFile = 'src\Reports\StandardESGSalesQuote.docx';
        }
        layout("StandardESGSalesQuoteBlue.docx")
        {
            Type = Word;
            Caption = 'Standard ESG Sales Quote - Blue (Word)';
            Summary = 'The Standard ESG Sales Quote (Word) provides a basic layout with blue theme.	';
            LayoutFile = 'src\Reports\StandardESGSalesQuoteBlue.docx';
        }
    }

    trigger OnPreReport()
    begin
        SetCO2ePerUnitAndTotalCO2eCaption();
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        TotalCO2e: Decimal;
        CO2ePerUnitTxt: Text;
        TotalCO2eTxt: Text;
        FormattedCO2ePerUnit: Text;
        CO2ePerUnitLbl: Label 'CO2e [%1] per Unit', Comment = '%1 = Emission Unit of Measure';
        TotalCO2eLbl: Label '%1 [%2]', Comment = '%1 = Field Caption, %2 = Emission Unit of Measure';

    local procedure SetCO2ePerUnitAndTotalCO2eCaption()
    begin
        SustainabilitySetup.GetRecordOnce();

        if SustainabilitySetup."Emission Unit of Measure Code" <> '' then
            CO2ePerUnitTxt := StrSubstNo(CO2ePerUnitLbl, SustainabilitySetup."Emission Unit of Measure Code")
        else
            CO2ePerUnitTxt := Line.FieldCaption("CO2e per Unit");

        if SustainabilitySetup."Emission Unit of Measure Code" <> '' then
            TotalCO2eTxt := StrSubstNo(TotalCO2eLbl, Line.FieldCaption("Total CO2e"), SustainabilitySetup."Emission Unit of Measure Code")
        else
            TotalCO2eTxt := Line.FieldCaption("Total CO2e");
    end;

    local procedure GetDisclaimer(): Text
    var
        SustainabilityDisclaimer: Record "Sustainability Disclaimer";
    begin
        SustainabilityDisclaimer.SetRange("Document Type", SustainabilityDisclaimer."Document Type"::"Sales Quote");
        if SustainabilityDisclaimer.FindFirst() then
            exit(SustainabilityDisclaimer.Disclaimer);
    end;
}