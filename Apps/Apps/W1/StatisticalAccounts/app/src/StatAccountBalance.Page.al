namespace Microsoft.Finance.Analysis.StatisticalAccount;

using Microsoft.Foundation.Enums;
using Microsoft.Finance.Dimension;
using System.Telemetry;

page 2623 "Stat. Account Balance"
{
    Caption = 'Statistical Account Balance';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = ListPlus;
    SaveValues = true;
    SourceTable = "Statistical Account";

    layout
    {
        area(content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(ClosingEntryFilter; ClosingEntryFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Closing Entries';
                    OptionCaption = 'Include,Exclude';
                    ToolTip = 'Specifies whether the balance shown will include closing entries. If you want to see the amounts on income statement accounts in closed years, you must exclude closing entries.';

                    trigger OnValidate()
                    begin
                        UpdateSubForm();
                    end;
                }
                field(PeriodType; PeriodType)
                {
                    ApplicationArea = All;
                    Caption = 'View by';
                    ToolTip = 'Specifies by which period amounts are displayed.';

                    trigger OnValidate()
                    begin
                        if PeriodType = PeriodType::"Accounting Period" then
                            AccountingPerioPeriodTypeOnVal();
                        if PeriodType = PeriodType::Year then
                            YearPeriodTypeOnValidate();
                        if PeriodType = PeriodType::Quarter then
                            QuarterPeriodTypeOnValidate();
                        if PeriodType = PeriodType::Month then
                            MonthPeriodTypeOnValidate();
                        if PeriodType = PeriodType::Week then
                            WeekPeriodTypeOnValidate();
                        if PeriodType = PeriodType::Day then
                            DayPeriodTypeOnValidate();
                    end;
                }
                field(AmountType; AmountType)
                {
                    ApplicationArea = All;
                    Caption = 'View as';
                    ToolTip = 'Specifies how amounts are displayed. Net Change: The net change in the balance for the selected period. Balance at Date: The balance as of the last day in the selected period.';

                    trigger OnValidate()
                    begin
                        if AmountType = AmountType::"Balance at Date" then
                            BalanceatDateAmountTypeOnValid();
                        if AmountType = AmountType::"Net Change" then
                            NetChangeAmountTypeOnValidate();
                    end;
                }
            }
            part(StatisticalAccountBalanceLines; "Stat. Account Balance Lines")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("A&ccount")
            {
                action(Dimensions)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = const(2632),
                                  "No." = field("No.");
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                }
                action(LedgerEntries)
                {
                    ApplicationArea = All;
                    Caption = 'Ledger Entries';
                    Image = Ledger;
                    RunObject = Page "Statistical Ledger Entry List";
                    RunPageLink = "Statistical Account No." = field("No.");
                    ToolTip = 'View the statistical ledger entries for selected account.';
                }
            }
            group("Periodic Activities")
            {
                Caption = 'Periodic Activities';
                action("Statistical Accounts Journal")
                {
                    ApplicationArea = All;
                    Caption = 'Statistical Accounts Journal';
                    Image = Journal;
                    RunObject = Page "Statistical Accounts Journal";
                    ToolTip = 'Open the statistical accounts journal, for example, to record or post an update to non-transactional data.';
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref("StatisticalAccountsJournal_Promoted"; "Statistical Accounts Journal")
                {
                }
                actionref("Dimensions_Promoted"; Dimensions)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
    begin
        Rec.Reset();
        FeatureTelemetry.LogUptake('0000KDS', StatAccTelemetry.GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000KDT', StatAccTelemetry.GetFeatureTelemetryName(), 'Opened Balances Page');
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateSubForm();
    end;

    var
        PeriodType: Enum "Analysis Period Type";
        AmountType: Enum "Analysis Amount Type";
        ClosingEntryFilter: Option Include,Exclude;

    local procedure UpdateSubForm()
    begin
        CurrPage.StatisticalAccountBalanceLines.PAGE.SetLines(Rec, PeriodType, AmountType, ClosingEntryFilter);
    end;

    local procedure DayPeriodTypeOnPush()
    begin
        UpdateSubForm();
    end;

    local procedure WeekPeriodTypeOnPush()
    begin
        UpdateSubForm();
    end;

    local procedure MonthPeriodTypeOnPush()
    begin
        UpdateSubForm();
    end;

    local procedure QuarterPeriodTypeOnPush()
    begin
        UpdateSubForm();
    end;

    local procedure YearPeriodTypeOnPush()
    begin
        UpdateSubForm();
    end;

    local procedure AccountingPerioPeriodTypeOnPush()
    begin
        UpdateSubForm();
    end;

    local procedure BalanceatDateAmountTypeOnPush()
    begin
        UpdateSubForm();
    end;

    local procedure NetChangeAmountTypeOnPush()
    begin
        UpdateSubForm();
    end;

    local procedure DayPeriodTypeOnValidate()
    begin
        DayPeriodTypeOnPush();
    end;

    local procedure WeekPeriodTypeOnValidate()
    begin
        WeekPeriodTypeOnPush();
    end;

    local procedure MonthPeriodTypeOnValidate()
    begin
        MonthPeriodTypeOnPush();
    end;

    local procedure QuarterPeriodTypeOnValidate()
    begin
        QuarterPeriodTypeOnPush();
    end;

    local procedure YearPeriodTypeOnValidate()
    begin
        YearPeriodTypeOnPush();
    end;

    local procedure AccountingPerioPeriodTypeOnVal()
    begin
        AccountingPerioPeriodTypeOnPush();
    end;

    local procedure NetChangeAmountTypeOnValidate()
    begin
        NetChangeAmountTypeOnPush();
    end;

    local procedure BalanceatDateAmountTypeOnValid()
    begin
        BalanceatDateAmountTypeOnPush();
    end;
}

