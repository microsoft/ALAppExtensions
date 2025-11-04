/// <summary>
/// Provides utility functions for creating and managing cash flow forecasts and related test scenarios.
/// </summary>
codeunit 131331 "Library - Cash Flow"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";

    procedure FindCashFlowCard(var CashFlowForecast: Record "Cash Flow Forecast")
    begin
        CashFlowForecast.FindFirst();
    end;

    procedure FindCashFlowAccount(var CashFlowAccount: Record "Cash Flow Account")
    begin
        CashFlowAccount.SetRange("Account Type", CashFlowAccount."Account Type"::Entry);
        CashFlowAccount.FindFirst();
    end;

    procedure FindCashFlowAnalysisView(var AnalysisView: Record "Analysis View")
    begin
        AnalysisView.Reset();
        AnalysisView.SetRange("Account Source", AnalysisView."Account Source"::"Cash Flow Account");
        AnalysisView.FindFirst();
    end;

    procedure CreateJournalLine(var CFWorksheetLine: Record "Cash Flow Worksheet Line"; CFNo: Code[20]; CFAccountNo: Code[20])
    var
        LibraryUtility: Codeunit "Library - Utility";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(CFWorksheetLine);
        CFWorksheetLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, CFWorksheetLine.FieldNo("Line No.")));
        CFWorksheetLine.Insert(true);
        CFWorksheetLine.Validate("Cash Flow Forecast No.", CFNo);
        CFWorksheetLine.Validate("Cash Flow Account No.", CFAccountNo);
        CFWorksheetLine.Validate("Cash Flow Date", WorkDate());  // Defaults to work date.
        CFWorksheetLine.Modify(true);
    end;

    procedure DeleteJournalLine()
    begin
    end;

    procedure FillJournal(ConsiderSource: array[16] of Boolean; CFNo: Code[20]; GroupByDocumentType: Boolean)
    var
        CFWorksheetLine: Record "Cash Flow Worksheet Line";
        SuggestWorksheetLines: Report "Suggest Worksheet Lines";
    begin
        CFWorksheetLine.Init();
        SuggestWorksheetLines.InitializeRequest(ConsiderSource, CFNo, '', GroupByDocumentType);
        SuggestWorksheetLines.UseRequestPage := false;
        SuggestWorksheetLines.Run();
    end;

    procedure FillBudgetJournal(CFFunds: Boolean; CFNo: Code[20]; GLBudgetName: Code[10])
    var
        CFWorksheetLine: Record "Cash Flow Worksheet Line";
        SuggestWorksheetLines: Report "Suggest Worksheet Lines";
        ConsiderSource: array[16] of Boolean;
        SourceType: Option ,Customer,Vendor,"Liquid Funds","Cash Flow Manual Expense","Cash Flow Manual Revenue","Sales Order","Purchase Order","Budgeted Fixed Asset","Sale of Fixed Asset","Service Order","G/L Budget",,,Jobs,Tax;
    begin
        CFWorksheetLine.Init();
        ConsiderSource[SourceType::"Liquid Funds"] := CFFunds;
        ConsiderSource[SourceType::"G/L Budget"] := true;
        SuggestWorksheetLines.InitializeRequest(ConsiderSource, CFNo, GLBudgetName, false);
        SuggestWorksheetLines.UseRequestPage := false;
        SuggestWorksheetLines.Run();
    end;

    procedure ClearJournal()
    var
        CFWorksheetLine: Record "Cash Flow Worksheet Line";
    begin
        CFWorksheetLine.DeleteAll(true);
    end;

    procedure PostJournal()
    var
        CFWorksheetLine: Record "Cash Flow Worksheet Line";
    begin
        CODEUNIT.Run(CODEUNIT::"Cash Flow Wksh.-Register Batch", CFWorksheetLine);
    end;

    procedure PostJournalLines(var CFWorksheetLine: Record "Cash Flow Worksheet Line")
    begin
        CFWorksheetLine.FindSet();
        CODEUNIT.Run(CODEUNIT::"Cash Flow Wksh.-Register Batch", CFWorksheetLine);
    end;

    procedure CreateManualLinePayment(var CFManualExpense: Record "Cash Flow Manual Expense"; CFAccountNo: Code[20])
    begin
        CFManualExpense.Init();
        CFManualExpense.Validate("Cash Flow Account No.", CFAccountNo);
        CFManualExpense.Validate(Code,
          LibraryUtility.GenerateRandomCode(CFManualExpense.FieldNo(Code), DATABASE::"Cash Flow Manual Expense"));
        CFManualExpense.Validate("Starting Date", WorkDate());  // Required field to post
        CFManualExpense.Insert(true);
    end;

    procedure CreateManualLineRevenue(var CFManualRevenue: Record "Cash Flow Manual Revenue"; CFAccountNo: Code[20])
    begin
        CFManualRevenue.Init();
        CFManualRevenue.Validate("Cash Flow Account No.", CFAccountNo);
        CFManualRevenue.Validate(Code,
          LibraryUtility.GenerateRandomCode(CFManualRevenue.FieldNo(Code), DATABASE::"Cash Flow Manual Revenue"));
        CFManualRevenue.Validate("Starting Date", WorkDate());  // Required field to post
        CFManualRevenue.Insert(true);
    end;

    procedure DeleteManualLine()
    begin
    end;

    procedure CreateCashFlowCard(var CashFlowForecast: Record "Cash Flow Forecast")
    begin
        CashFlowForecast.Init();
        CashFlowForecast.Validate(
          "No.", LibraryUtility.GenerateRandomCode(CashFlowForecast.FieldNo("No."), DATABASE::"Cash Flow Forecast"));
        CashFlowForecast.Insert(true);
    end;

    procedure CreateCashFlowAccount(var CashFlowAccount: Record "Cash Flow Account"; AccountType: Enum "Cash Flow Account Type")
    begin
        CashFlowAccount.Init();
        CashFlowAccount.Validate("No.",
          LibraryUtility.GenerateRandomCode(CashFlowAccount.FieldNo("No."), DATABASE::"Cash Flow Account"));
        CashFlowAccount.Validate("Account Type", AccountType);
        CashFlowAccount.Validate(Name,
          LibraryUtility.GenerateRandomCode(CashFlowAccount.FieldNo(Name), DATABASE::"Cash Flow Account"));
        CashFlowAccount.Insert(true);
    end;

    procedure MockCashFlowCustOverdueData()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        LibraryERM.SelectLastGenJnBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Customer, LibrarySales.CreateCustomerNo(),
          GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(),
          LibraryRandom.RandDecInRange(100, 200, 2));
        GenJournalLine."Due Date" := GenJournalLine."Posting Date" - 1;
        GenJournalLine.Modify();
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;
}

