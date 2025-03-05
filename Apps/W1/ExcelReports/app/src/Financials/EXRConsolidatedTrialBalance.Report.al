namespace Microsoft.Finance.ExcelReports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.Consolidation;
using Microsoft.ExcelReports;

report 4410 "EXR Consolidated Trial Balance"
{
    ApplicationArea = All;
    Caption = 'Consolidated Trial Balance (Excel)';
    DataAccessIntent = ReadOnly;
    DefaultRenderingLayout = ConsolidatedTrialBalanceExcel;
    ExcelLayoutMultipleDataSheets = true;
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    MaximumDatasetSize = 1000000;

    dataset
    {
        dataitem(GLAccounts; "G/L Account")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            column(AccountNumber; "No.") { IncludeCaption = true; }
            column(AccountName; Name) { IncludeCaption = true; }
            column(IncomeBalance; "Income/Balance") { IncludeCaption = true; }
            column(AccountCategory; "Account Category") { IncludeCaption = true; }
            column(AccountSubcategory; "Account Subcategory Descript.") { IncludeCaption = true; }
            column(AccountType; "Account Type") { IncludeCaption = true; }
            column(Indentation; Indentation) { IncludeCaption = true; }
            column(IndentedAccountName; IndentedAccountName) { }

            trigger OnAfterGetRecord()
            begin
                IndentedAccountName := PadStr('', GLAccounts.Indentation * 2, ' ') + GLAccounts.Name;
            end;
        }
        dataitem(Dimension1; "Dimension Value")
        {
            DataItemTableView = sorting("Code");
            UseTemporary = true;

            column(Dim1Code; Dimension1."Code") { IncludeCaption = true; }
            column(Dim1Name; Dimension1.Name) { IncludeCaption = true; }
        }
        dataitem(Dimension2; "Dimension Value")
        {
            DataItemTableView = sorting("Code");
            UseTemporary = true;

            column(Dim2Code; Dimension2."Code") { IncludeCaption = true; }
            column(Dim2Name; Dimension2.Name) { IncludeCaption = true; }
        }
        dataitem(BusinessUnits; "Business Unit")
        {
            DataItemTableView = sorting("Code");
            column(Code; Code) { IncludeCaption = true; }
            column(Name; Name) { IncludeCaption = true; }
        }
        dataitem(TrialBalanceData; "EXR Trial Balance Buffer")
        {
            RequestFilterFields = "Business Unit Code", "Net Change", Balance;
            column(Account; "G/L Account No.") { IncludeCaption = true; }
            column(Dimension1Code; "Dimension 1 Code") { IncludeCaption = true; }
            column(Dimension2Code; "Dimension 2 Code") { IncludeCaption = true; }
            column(NetChange; "Net Change") { IncludeCaption = true; }
            column(Balance; Balance) { IncludeCaption = true; }
            column(NetChangeACY; "Net Change (ACY)") { IncludeCaption = true; }
            column(BalanceACY; "Balance (ACY)") { IncludeCaption = true; }
            column(BusinessUnitCode; "Business Unit Code") { IncludeCaption = true; }
        }
    }
    requestpage
    {
        SaveValues = true;
        AboutTitle = 'About Consolidated Trial Balance (Excel)';
        AboutText = 'View a snapshot of your consolidated chart of accounts at a given point to check the debit and credit net change and closing balance. You can see the trial balance in both your local currency (LCY) and additional reporting currency (ACY).';
        layout
        {
            area(Content)
            {
                field(StartingDateField; StartingDate)
                {
                    ApplicationArea = All;
                    Caption = 'Starting Date';
                    ClosingDates = true;
                    ToolTip = 'Specifies the starting date of the period for which the report is generated.';
                }
                field(EndingDateField; EndingDate)
                {
                    ApplicationArea = All;
                    Caption = 'Ending Date';
                    ClosingDates = true;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the ending date of the period for which the report is generated.';
                }
            }
        }
    }
    rendering
    {
        layout(ConsolidatedTrialBalanceExcel)
        {
            Type = Excel;
            LayoutFile = './ReportLayouts/Excel/GeneralLedger/ConsolidatedTrialBalanceExcel.xlsx';
            Caption = 'Consolidated Trial Balance Excel';
            Summary = 'Built in layout for Consolidated Trial Balance.';
        }
    }
    labels
    {
        DataRetrieved = 'Data retrieved:';
        ConsolidatedTrialBalance = 'Consolidated Trial Balance';
        ConsolidatedTrialBalPrint = 'Consolidated Trial Bal. (Print)', MaxLength = 31, Comment = 'Excel worksheet name.';
        TrialBalanceLCY = 'Trial Balance (LCY)', MaxLength = 31, Comment = 'Excel worksheet name.';
        TrialBalanceACY = 'Trial Balance (ACY)', MaxLength = 31, Comment = 'Excel worksheet name.';
        TrialBalanceLCYByBusinessUnit = 'Trial Balance by Business Unit (LCY)';
        TrialBalanceACYByBusinessUnit = 'Trial Balance by Business Unit (ACY)';
        BlankBU = '(Blank)';
        Period = 'Period:';
        UntilDate = 'Until:';
        ByBusinessUnitLCY = 'By Business Unit (LCY)', MaxLength = 31, Comment = 'Excel worksheet name.';
        ByBusinessUnitACY = 'By Business Unit (ACY)', MaxLength = 31, Comment = 'Excel worksheet name.';
        // About the report labels
        AboutTheReportLabel = 'About the report', MaxLength = 31, Comment = 'Excel worksheet name.';
        EnvironmentLabel = 'Environment';
        CompanyLabel = 'Company';
        UserLabel = 'User';
        RunOnLabel = 'Run on';
        ReportNameLabel = 'Report name';
        DocumentationLabel = 'Documentation';
    }

    trigger OnPreReport()
    var
        BusinessUnit: Record "Business Unit";
        TrialBalance: Codeunit "Trial Balance";
    begin
        if EndingDate = 0D then
            Error(EnterAnEndingDateErr);
        if BusinessUnit.IsEmpty() then
            Error(NoBusinessUnitsErr);

        ExcelReportsTelemetry.LogReportUsage(Report::"EXR Consolidated Trial Balance");
        GLAccounts.SetRange("Date Filter", StartingDate, EndingDate);

        TrialBalance.ConfigureTrialBalance(true, true);
        TrialBalance.InsertTrialBalanceReportData(GLAccounts, Dimension1, Dimension2, TrialBalanceData);
    end;

    var
        ExcelReportsTelemetry: Codeunit "Excel Reports Telemetry";
        IndentedAccountName: Text;
        StartingDate, EndingDate : Date;
        EnterAnEndingDateErr: Label 'Please enter an ending date.';
        NoBusinessUnitsErr: Label 'There are no business units configured for the current company. Please run this report from the consolidation company.';
}