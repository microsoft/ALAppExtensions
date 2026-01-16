// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 11487 "Create Column Layout Name US"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertColumnLayoutName(PeriodandYeartoDate(), PeriodandYeartoDateLbl, PeriodandYeartoDateInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(PeriodandYeartoDatewithPercentofTotalRevenue(), PeriodandYeartoDatewithPercentofTotalRevenueLbl, PeriodandYeartoDatewithPercentTotalRevenueInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(ThisYeartoDatevsPriorYeartoDate(), ThisYeartoDatevsPriorYeartoDateLbl, ThisYeartoDatevsPriorYeartoDateInternalDescriptionLbl);
    end;

    procedure PeriodandYeartoDate(): Code[10]
    begin
        exit(PeriodandYeartoDateTok);
    end;

    procedure PeriodandYeartoDatewithPercentofTotalRevenue(): Code[10]
    begin
        exit(PeriodandYeartoDatewithPercentofTotalRevenueTok);
    end;

    procedure ThisYeartoDatevsPriorYeartoDate(): Code[10]
    begin
        exit(ThisYeartoDatevsPriorYeartoDateTok);
    end;

    var
        PeriodandYeartoDateInternalDescriptionLbl: Label 'Two-column layout displaying figures for the current period and year-to-date using net change and net amount from general ledger entries. This structure provides a clear view of short-term performance alongside cumulative totals, enabling quick comparisons and trend analysis. Useful for income statement reporting, monitoring monthly results against overall progress, and supporting management decisions with accurate period and year-to-date financial insights.', MaxLength = 500;
        PeriodandYeartoDateLbl: Label 'Period and Year to Date', MaxLength = 80;
        PeriodandYeartoDateTok: Label 'PTD + YTD', MaxLength = 10;
        PeriodandYeartoDatewithPercentofTotalRevenueLbl: Label 'Period and Year to Date with Percent of Total Revenue', MaxLength = 80;
        PeriodandYeartoDatewithPercentofTotalRevenueTok: Label 'PTD+YTD+%', MaxLength = 10;
        PeriodandYeartoDatewithPercentTotalRevenueInternalDescriptionLbl: Label 'Four-column layout displaying current period and year-to-date amounts along with percentages of total revenue for each. Combines actual and budget data using net amounts from general ledger entries and formulas for PTD% and YTD%. Ideal for monitoring short-term and cumulative performance, evaluating revenue contribution, and comparing actuals against budgets in financial analysis and reporting.', MaxLength = 500;
        ThisYeartoDatevsPriorYeartoDateInternalDescriptionLbl: Label 'Five-column layout comparing current year-to-date and prior year-to-date amounts, including percentage contributions for each and a calculated difference column. Uses net amounts from general ledger entries with formulas for CUR%, PRIOR%, and CUR-PRIOR. Useful for trend analysis, evaluating year-over-year performance, and identifying growth or decline across financial periods in reports.', MaxLength = 500;
        ThisYeartoDatevsPriorYeartoDateLbl: Label 'This Year to Date vs. Prior Year to Date', MaxLength = 80;
        ThisYeartoDatevsPriorYeartoDateTok: Label 'YTDCOMPARE', MaxLength = 10;
}
