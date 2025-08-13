// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Reports;

using Microsoft.Sustainability.ESGReporting;

report 6220 "Sust. CSRD Preparation"
{
    DefaultRenderingLayout = CSRDPreparationExcel;
    ApplicationArea = Basic, Suite;
    Caption = 'CSRD Preparation Report';
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Sust. Posted ESG Report Header"; "Sust. Posted ESG Report Header")
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";

            column(No_; "No.")
            {
                IncludeCaption = true;
            }
            column(ESG_Reporting_Template_Name; "ESG Reporting Template Name")
            {
                IncludeCaption = true;
            }
            column(Name; Name)
            {
                IncludeCaption = true;
            }
            column(Standard; Standard)
            {
                IncludeCaption = true;
            }
            column(Period_Name; "Period Name")
            {
                IncludeCaption = true;
            }
            column(Period_Starting_Date; "Period Starting Date")
            {
                IncludeCaption = true;
            }
            column(Period_Ending_Date; "Period Ending Date")
            {
                IncludeCaption = true;
            }
            dataitem("Sust. Posted ESG Report Line"; "Sust. Posted ESG Report Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.") where(Show = const(true));

                column(Row_No_; "Row No.")
                {
                    IncludeCaption = true;
                }
                column(Reporting_Code; "Reporting Code")
                {
                    IncludeCaption = true;
                }
                column(Concept; Concept)
                {
                    IncludeCaption = true;
                }
                column(Concept_Link; "Concept Link")
                {
                    IncludeCaption = true;
                }
                column(Reporting_Unit; "Reporting Unit")
                {
                    IncludeCaption = true;
                }
                column(Posted_Amount; "Posted Amount")
                {
                    IncludeCaption = true;
                }
            }
        }
    }
    rendering
    {
        layout(CSRDPreparationExcel)
        {
            Type = Excel;
            Caption = 'CSRD Preparation Excel Layout';
            LayoutFile = './src/Reports/CSRDPreparation.xlsx';
        }
    }
    labels
    {
        CSRDPreparation = 'CSRD Preparation';
        CSRDPreparationPrint = 'CSRD Preparation (Print)', MaxLength = 31, Comment = 'Excel worksheet name.';
        PageCaption = 'Page';
        CompName = 'Company Name';
        DocumentNo = 'Document No.';
        StandardType = 'Standard';
        RowNo = 'Row No.';
        PeriodName = 'Period';
        PeriodStartingDate = 'Period Starting Date';
        PeriodEndingDate = 'Period Ending Date';
        ReportingCode = 'Reporting Code';
        Cpt = 'Concept';
        ConceptLink = 'Concept Link';
        ReportingUnit = 'Reporting Unit';
        PostedAmount = 'Posted Amount';
        DataRetrieved = 'Data retrieved:';
        // About the report labels
        AboutTheReportLabel = 'About the report', MaxLength = 31, Comment = 'Excel worksheet name.';
        EnvironmentLabel = 'Environment';
        CompanyLabel = 'Company';
        UserLabel = 'User';
        RunOnLabel = 'Run on';
        ReportNameLabel = 'Report name';
        DocumentationLabel = 'Documentation';
    }
}