// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Foundation.Address;
using System.Text;
using System.Utilities;

page 6254 "Sust. ESG Reporting Preview"
{
    Caption = 'ESG Reporting Preview';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SaveValues = true;
    SourceTable = "Sust. ESG Reporting Name";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Date Filter';
                    ToolTip = 'Specifies the dates that will be used to filter the amounts in the window.';

                    trigger OnValidate()
                    var
                        FilterTokens: Codeunit "Filter Tokens";
                    begin
                        FilterTokens.MakeDateFilter(DateFilter);
                        Rec.SetFilter("Date Filter", DateFilter);
                        UpdateSubPage();
                        CurrPage.Update();
                    end;
                }
                field("Country/Region Filter"; CountryRegionFilter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Country/Region Filter';
                    TableRelation = "Country/Region";
                    ToolTip = 'Specifies the country/region to filter the entries.';

                    trigger OnValidate()
                    begin
                        UpdateSubPage();
                        CurrPage.Update();
                    end;
                }
            }
            part(ESGReportingPreviewSubPage; "Sust. ESG Reporting Prev. Line")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "ESG Reporting Template Name" = field("ESG Reporting Template Name"),
                              "ESG Reporting Name" = field(Name);
                SubPageView = sorting("ESG Reporting Template Name", "ESG Reporting Name", "Line No.");
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateSubPage();
    end;

    trigger OnOpenPage()
    begin
        DateFilter := '';
        SetDateAndCountryFilter();
        if Rec.GetFilter("Date Filter") <> '' then
            DateFilter := Rec.GetFilter("Date Filter");

        UpdateSubPage();
    end;

    protected var
        DateFilter: Text[30];
        CountryRegionFilter: Text;

    procedure UpdateSubPage()
    begin
        CurrPage.ESGReportingPreviewSubPage.PAGE.UpdateSubPage(Rec, CountryRegionFilter);
    end;

    local procedure SetDateAndCountryFilter()
    var
        ESGReportingName: Record "Sust. ESG Reporting Name";
        Period: Record Date;
    begin
        ESGReportingName.Get(Rec."ESG Reporting Template Name", Rec.Name);

        Period.SetRange("Period Type", Period."Period Type"::Year);
        Period.SetRange("Period No.", ESGReportingName.Period);
        if Period.FindFirst() then
            Rec.SetRange("Date Filter", Period."Period Start", CalcDate('<CY>', Period."Period Start"));

        CountryRegionFilter := ESGReportingName."Country/Region Code";
    end;
}