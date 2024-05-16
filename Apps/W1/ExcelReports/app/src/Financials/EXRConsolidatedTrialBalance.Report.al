namespace Microsoft.Finance.ExcelReports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Consolidation;
using Microsoft.Finance.Dimension;

report 4410 "EXR Consolidated Trial Balance"
{
    ApplicationArea = All;
    Caption = 'Consolidated Trial Balance Excel (Preview)';
    DataAccessIntent = ReadOnly;
    DefaultRenderingLayout = ConsolidatedTrialBalanceExcel;
    ExcelLayoutMultipleDataSheets = true;
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    MaximumDatasetSize = 1000000;

    dataset
    {
        dataitem(TrialBalanceData; "G/L Account")
        {
            DataItemTableView = sorting("No.");
            column(AccountNumber; "No.") { IncludeCaption = true; }
            column(AccountName; Name) { IncludeCaption = true; }
            column(IncomeBalance; "Income/Balance") { IncludeCaption = true; }
            column(AccountCategory; "Account Category") { IncludeCaption = true; }
            column(AccountSubcategory; "Account Subcategory Descript.") { IncludeCaption = true; }
            column(AccountType; "Account Type") { IncludeCaption = true; }
            column(Indentation; Indentation) { IncludeCaption = true; }
            column(IndentedAccountName; IndentedAccountName) { }
            dataitem(EXRTrialBalanceBuffer; "EXR Trial Balance Buffer")
            {
                DataItemLink = "G/L Account No." = field("No.");
                column(Dimension1Code; "Dimension 1 Code") { IncludeCaption = true; }
                column(Dimension2Code; "Dimension 2 Code") { IncludeCaption = true; }
                column(NetChange; "Net Change") { IncludeCaption = true; }
                column(Balance; Balance) { IncludeCaption = true; }
                column(NetChangeACY; "Net Change (ACY)") { IncludeCaption = true; }
                column(BalanceACY; "Balance (ACY)") { IncludeCaption = true; }
                column(BusinessUnitCode; "Business Unit Code") { IncludeCaption = true; }
            }
            trigger OnAfterGetRecord()
            var
                TrialBalance: Codeunit "Trial Balance";
            begin
                IndentedAccountName := PadStr('', TrialBalanceData.Indentation * 2, ' ') + TrialBalanceData.Name;
                TrialBalance.InsertBreakdownForGLAccount(TrialBalanceData, Dimension1Values, Dimension2Values, BusinessUnitCodes, EXRTrialBalanceBuffer);
            end;

            trigger OnPreDataItem()
            var
                BusinessUnit: Record "Business Unit";
                DimensionValue: Record "Dimension Value";
            begin
                if EndingDate = 0D then
                    Error(EnterAnEndingDateErr);
                TrialBalanceData.SetRange("Date Filter", StartingDate, EndingDate);

                DimensionValue.SetRange("Global Dimension No.", 1);
                if DimensionValue.FindSet() then
                    repeat
                        Dimension1Values.Add(DimensionValue.Code);
                    until DimensionValue.Next() = 0;
                Dimension1Values.Add('');
                DimensionValue.SetRange("Global Dimension No.", 2);
                if DimensionValue.FindSet() then
                    repeat
                        Dimension2Values.Add(DimensionValue.Code);
                    until DimensionValue.Next() = 0;
                Dimension2Values.Add('');
                if BusinessUnit.FindSet() then
                    repeat
                        BusinessUnitCodes.Add(BusinessUnit.Code);
                    until BusinessUnit.Next() = 0;
                BusinessUnitCodes.Add('');
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        AboutTitle = 'Consolidated Trial Balance Excel';
        AboutText = 'This report contains Net Change or Balance of the different G/L Accounts for the selected period, aggregated per business unit.';
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
        TrialBalanceLCY = 'Trial Balance (LCY)', Comment = 'Worksheet name, shouldn''t exceed 31 characters';
        TrialBalanceACY = 'Trial Balance (ACY)', Comment = 'Worksheet name, shouldn''t exceed 31 characters';
        TrialBalanceLCYByBusinessUnit = 'Trial Balance by Business Unit (LCY)';
        TrialBalanceACYByBusinessUnit = 'Trial Balance by Business Unit (ACY)';
        BlankBU = '(Blank)';
        Period = 'Period:';
        UntilDate = 'Until:';
        ByBusinessUnitLCY = 'By Business Unit (LCY)', Comment = 'Worksheet name, shouldn''t exceed 31 characters';
        ByBusinessUnitACY = 'By Business Unit (ACY)', Comment = 'Worksheet name, shouldn''t exceed 31 characters';
    }
    var
        Dimension1Values: List of [Code[20]];
        Dimension2Values: List of [Code[20]];
        BusinessUnitCodes: List of [Code[20]];
        IndentedAccountName: Text;
        StartingDate, EndingDate : Date;
        EnterAnEndingDateErr: Label 'Please enter an ending date.';
}