// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Period;
using System.Environment;
using System.Reflection;
using System.Telemetry;
using System.Utilities;

codeunit 5318 "Generate File SIE"
{
    var
        ApplicationSystemConstants: Codeunit "Application System Constants";
        TypeHelper: Codeunit "Type Helper";
        AccPeriodStart: Date;
        AccPeriodEnd: Date;
        PrevAccPeriodStart: Date;
        PrevAccPeriodEnd: Date;
        PeriodExport: Boolean;
        ObjectExport: Boolean;
        LinesList: List of [Text];
        CRLF: Text[2];
        ProgressDialog: Dialog;
        CreateFileTxt: label 'Creating SIE file\';
        SIETypeTxt: label 'SIE type                           #2##################\', Comment = '#2 - File Type SIE';
        ProcessGLAccTxt: label 'Processing G/L Account             #3#### @4@@@@@@@@@@@\', Comment = '#3 - current G/L Account No.';
        ProcessPeriodicBalAccTxt: label 'Processing periodic balance amount #5#### @6@@@@@@@@@@@\', Comment = '#5 - current G/L Account No.';
        ProcessObjectBalAmountTxt: label 'Processing object balance amount   #7#### @8@@@@@@@@@@@\', Comment = '#7 - current G/L Account No.';
        ProcessTransactTxt: label 'Processing transactions            #5#### @6@@@@@@@@@@@\', Comment = '#5 - current G/L Entry Document No.';
        SieTok: label 'Audit File Export SIE', Locked = true;

#pragma warning disable AA0217
    procedure GenerateFileContent(AuditFileExportLine: Record "Audit File Export Line"; var TempBlob: Codeunit "Temp Blob")
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        AuditFileExportHeader.Get(AuditFileExportLine.ID);
        InitAccountingPeriodDates(AuditFileExportHeader);
        CRLF := TypeHelper.CRLFSeparator();

        case AuditFileExportHeader."File Type" of
            "File Type SIE"::"1. Year - End Balances":
                CreateFileType1YearEndBalances(AuditFileExportHeader);
            "File Type SIE"::"2. Periodic Balances":
                CreatFileType2PeriodicBalances(AuditFileExportHeader);
            "File Type SIE"::"3. Object Balances":
                CreatFileType3ObjectBalances(AuditFileExportHeader);
            "File Type SIE"::"4. Transactions":
                CreatFileType4Transactions(AuditFileExportHeader);
        end;

        CloseProgressDialog();
        WriteFileContentToTempBlob(TempBlob);

        FeatureTelemetry.LogUptake('0000JPM', SieTok, Enum::"Feature Uptake Status"::"Used");
    end;

    local procedure CreateFileType1YearEndBalances(var AuditFileExportHeader: Record "Audit File Export Header")
    begin
        OpenProgressDialog(CreateFileTxt + SIETypeTxt + ProcessGLAccTxt);
        WriteHeader(AuditFileExportHeader);
        WriteGLAccounts(AuditFileExportHeader);
        WriteGLAccountsBalance(AuditFileExportHeader);
    end;

    local procedure CreatFileType2PeriodicBalances(var AuditFileExportHeader: Record "Audit File Export Header")
    begin
        OpenProgressDialog(CreateFileTxt + SIETypeTxt + ProcessGLAccTxt + ProcessObjectBalAmountTxt);
        PeriodExport := true;
        WriteHeader(AuditFileExportHeader);
        WriteGLAccounts(AuditFileExportHeader);
        WriteDimensions();
        WriteGLAccountsBalance(AuditFileExportHeader);
        WriteGLAccEndBalanceAndBudget(AuditFileExportHeader);
    end;

    local procedure CreatFileType3ObjectBalances(var AuditFileExportHeader: Record "Audit File Export Header")
    begin
        OpenProgressDialog(CreateFileTxt + SIETypeTxt + ProcessGLAccTxt + ProcessPeriodicBalAccTxt + ProcessObjectBalAmountTxt);
        ObjectExport := true;
        WriteHeader(AuditFileExportHeader);
        WriteGLAccounts(AuditFileExportHeader);
        WriteDimensions();
        WriteGLAccountsBalance(AuditFileExportHeader);
        WriteGLAccOpeningClosingBalance(AuditFileExportHeader);
        WriteGLAccEndBalanceAndBudget(AuditFileExportHeader);
    end;

    local procedure CreatFileType4Transactions(var AuditFileExportHeader: Record "Audit File Export Header")
    begin
        OpenProgressDialog(CreateFileTxt + SIETypeTxt + ProcessGLAccTxt + ProcessTransactTxt);
        WriteHeader(AuditFileExportHeader);
        WriteDimensions();
        WriteGLAccounts(AuditFileExportHeader);
        WriteGLAccountsBalance(AuditFileExportHeader);
        WriteTransactions(AuditFileExportHeader);
    end;

    local procedure WriteHeader(AuditFileExportHeader: Record "Audit File Export Header")
    var
        CompanyInformation: Record "Company Information";
    begin
        UpdateProgressDialog(2, Format(AuditFileExportHeader."File Type"));

        CompanyInformation.Get();
        AppendLine(StrSubstNo('#FLAGGA  %1', 0));
        AppendLine(StrSubstNo('#PROGRAM  "%1"  "%2"', 'Microsoft Dynamics NAV', ApplicationSystemConstants.ApplicationVersion()));
        AppendLine(StrSubstNo('#FORMAT  %1', 'PC8'));
        AppendLine(StrSubstNo('#GEN  %1  %2', FormatDate(Today), UserId()));
        AppendLine(StrSubstNo('#SIETYP  %1', Format(CopyStr(Format(AuditFileExportHeader."File Type"), 1, 1))));
        if AuditFileExportHeader."Header Comment" <> '' then
            AppendLine(StrSubstNo('#PROSA  "%1"', Ascii2Ansi(AuditFileExportHeader."Header Comment")));
        AppendLine(StrSubstNo('#ORGNR  "%1"', CompanyInformation."Registration No."));

        AppendLine(
            StrSubstNo(
                '#ADRESS  "%1"  "%2"  "%3 %4"  "%5"', Ascii2Ansi(AuditFileExportHeader.Contact),
                Ascii2Ansi(CompanyInformation.Address), Ascii2Ansi(CompanyInformation."Post Code"), Ascii2Ansi(CompanyInformation.City),
                CompanyInformation."Phone No."));

        AppendLine(StrSubstNo('#FNAMN  "%1"', Ascii2Ansi(CompanyInformation.Name)));
        AppendLine(StrSubstNo('#RAR  %1  %2  %3', 0, Format(FormatDate(AccPeriodStart), 10), Format(FormatDate(AccPeriodEnd), 10)));
        AppendLine(
          StrSubstNo('#RAR  %1  %2  %3', -1, Format(FormatDate(PrevAccPeriodStart), 10), Format(FormatDate(PrevAccPeriodEnd), 10)));
        if AuditFileExportHeader."Fiscal Year" <> '' then
            AppendLine(StrSubstNo('#TAXAR  %1', AuditFileExportHeader."Fiscal Year"));

        if PeriodExport or ObjectExport then
            AppendLine(StrSubstNo('#OMFATTN  %1', Format(FormatDate(AuditFileExportHeader."Ending Date"), 10)));
    end;

    local procedure WriteDimensions()
    var
        DimensionSie: Record "Dimension SIE";
        DimensionValue: Record "Dimension Value";
    begin
        DimensionSie.SetCurrentKey("SIE Dimension");
        DimensionSie.SetRange(Selected, true);
        if DimensionSie.FindSet() then
            repeat
                AppendLine(StrSubstNo('#DIM  %1  "%2"', DimensionSie."SIE Dimension", Ascii2Ansi(DimensionSie."Dimension Code")));
            until DimensionSie.Next() = 0;

        if DimensionSie.FindSet() then
            repeat
                DimensionValue.SetLoadFields(Name);
                DimensionValue.SetRange("Dimension Code", DimensionSie."Dimension Code");
                if DimensionValue.FindSet() then
                    repeat
                        AppendLine(
                            StrSubstNo(
                                '#OBJEKT  %1  "%2"  "%3"', DimensionSie."SIE Dimension", Ascii2Ansi(DimensionValue.Code),
                                Ascii2Ansi(DimensionValue.Name)));
                    until DimensionValue.Next() = 0;
            until DimensionSie.Next() = 0;
    end;

    local procedure WriteGLAccounts(AuditFileExportHeader: Record "Audit File Export Header")
    var
        GLAccount: Record "G/L Account";
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        SRUCode: Code[20];
    begin
        GetFilteredGLAccount(GLAccount, AuditFileExportHeader."G/L Account View String");
        GLAccount.SetLoadFields(Name);
        if GLAccount.FindSet() then
            repeat
                AppendLine(StrSubstNo('#KONTO  %1  "%2"', GLAccount."No.", Ascii2Ansi(GLAccount.Name)));
                if AuditFileExportHeader."Fiscal Year" <> '' then begin
                    SRUCode := '';
                    if GLAccountMappingLine.Get(AuditFileExportHeader."G/L Account Mapping Code", GLAccount."No.") then
                        SRUCode := GLAccountMappingLine."Standard Account No.";
                    AppendLine(StrSubstNo('#SRU  %1  %2', GLAccount."No.", SRUCode));
                end;
            until GLAccount.Next() = 0;
    end;

    local procedure WriteGLAccountsBalance(AuditFileExportHeader: Record "Audit File Export Header")
    var
        GLAccount: Record "G/L Account";
        GLAccountPrevAccPeriod: Record "G/L Account";
        CounterTotal: Integer;
        Counter: Integer;
    begin
        GetFilteredGLAccount(GLAccount, AuditFileExportHeader."G/L Account View String");
        CounterTotal := GLAccount.Count();
        if GLAccount.FindSet() then
            repeat
                Counter += 1;
                GetFilteredGLAccFromPrevAccPeriod(GLAccountPrevAccPeriod, GLAccount);
                GLAccountPrevAccPeriod.CalcFields("Balance at Date");

                GLAccount.SetRange("Date Filter", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
                GLAccount.CalcFields("Balance at Date", "Net Change");

                if GLAccount."Income/Balance" = GLAccount."Income/Balance"::"Balance Sheet" then
                    BalanceGLAccBalanceSheet(GLAccount, GLAccountPrevAccPeriod)
                else
                    BalanceGLAccProfitAndLoss(GLAccount, GLAccountPrevAccPeriod);

                UpdateProgressDialog(3, GLAccount."No.");
                UpdateProgressDialog(4, Format(Round(Counter / CounterTotal * 10000, 1)));
            until GLAccount.Next() = 0;
    end;

    local procedure BalanceGLAccBalanceSheet(var GLAccount: Record "G/L Account"; var GLAccountPrevAccPeriod: Record "G/L Account")
    begin
        if (GLAccount."Balance at Date" - GLAccount."Net Change") <> 0 then
            AppendLine(StrSubstNo('#IB  %1  %2  %3', 0, GLAccount."No.", FormatAmount(GLAccount."Balance at Date" - GLAccount."Net Change")));

        if GLAccount."Balance at Date" <> 0 then
            AppendLine(StrSubstNo('#UB  %1  %2  %3', 0, GLAccount."No.", FormatAmount(GLAccount."Balance at Date")));

        if GLAccountPrevAccPeriod."Balance at Date" <> 0 then
            AppendLine(StrSubstNo('#UB  %1  %2  %3', -1, GLAccount."No.", FormatAmount(GLAccountPrevAccPeriod."Balance at Date")));
    end;

    local procedure BalanceGLAccProfitAndLoss(var GLAccount: Record "G/L Account"; var GLAccountPrevAccPeriod: Record "G/L Account")
    begin
        if GLAccount."Balance at Date" <> 0 then
            AppendLine(StrSubstNo('#RES  %1  %2  %3', 0, GLAccount."No.", FormatAmount(GLAccount."Balance at Date")));

        if GLAccountPrevAccPeriod."Balance at Date" <> 0 then
            AppendLine(StrSubstNo('#RES  %1  %2  %3', -1, GLAccount."No.", FormatAmount(GLAccountPrevAccPeriod."Balance at Date")));
    end;

    local procedure WriteGLAccEndBalanceAndBudget(AuditFileExportHeader: Record "Audit File Export Header")
    var
        DimensionSie: Record "Dimension SIE";
        DimensionValue: Record "Dimension Value";
        GLAccount: Record "G/L Account";
        GLAccountPosting: Record "G/L Account";
        GLAccountPrevAccPeriod: Record "G/L Account";
        GeneralLedgerSetup: Record "General Ledger Setup";
        AccountBudgetFilter: Text;
        Counter: Integer;
        CounterTotal: Integer;
    begin
        GeneralLedgerSetup.Get();

        GLAccountPosting.SetView(AuditFileExportHeader."G/L Account View String");
        AccountBudgetFilter := GLAccountPosting.GetFilter("Budget Filter");

        GLAccountPosting.SetRange("Account Type", GLAccountPosting."Account Type"::Posting);
        CounterTotal := GLAccountPosting.Count();
        if GLAccountPosting.FindSet() then
            repeat
                Counter += 1;
                GLAccount := GLAccountPosting;
                if not PeriodExport then begin
                    DimensionSie.SetCurrentKey("SIE Dimension");
                    DimensionSie.SetRange(Selected, true);
                    if DimensionSie.FindSet() then
                        repeat
                            DimensionValue.SetRange("Dimension Code", DimensionSie."Dimension Code");
                            if DimensionValue.FindSet() then
                                repeat
                                    GLAccount.Reset();
                                    if DimensionValue."Dimension Code" = GeneralLedgerSetup."Global Dimension 1 Code" then begin
                                        GLAccount.SetFilter("Global Dimension 1 Filter", DimensionValue.Code);
                                        GLAccount.SetFilter("Global Dimension 2 Filter", '');
                                    end;
                                    if DimensionValue."Dimension Code" = GeneralLedgerSetup."Global Dimension 2 Code" then begin
                                        GLAccount.SetFilter("Global Dimension 2 Filter", DimensionValue.Code);
                                        GLAccount.SetFilter("Global Dimension 1 Filter", '');
                                    end;
                                    GetFilteredGLAccFromPrevAccPeriod(GLAccountPrevAccPeriod, GLAccount);
                                    GLAccountPrevAccPeriod.CalcFields("Net Change");
                                    GLAccount.SetRange("Date Filter", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
                                    GLAccount.CalcFields("Net Change");
                                    if GLAccount."Net Change" <> 0 then
                                        AppendLine(StrSubstNo('#PSALDO   %1  %2  %3  {%4 "%5"} %6', 0, Format(FormatDate(GLAccount.GetRangeMax
                                                ("Date Filter")), 6), GLAccount."No.", DimensionSie."SIE Dimension",
                                            Ascii2Ansi(DimensionValue.Code), FormatAmount(GLAccount."Net Change")));
                                    if GLAccountPrevAccPeriod."Net Change" <> 0 then
                                        AppendLine(StrSubstNo('#PSALDO  %1  %2  %3  {%4 "%5"} %6', -1, Format(FormatDate(GLAccountPrevAccPeriod.GetRangeMax
                                                ("Date Filter")), 6), GLAccountPrevAccPeriod."No.", DimensionSie."SIE Dimension",
                                            Ascii2Ansi(DimensionValue.Code), FormatAmount(GLAccountPrevAccPeriod."Net Change")));
                                    if AccountBudgetFilter <> '' then begin
                                        GLAccount.SetRange("Date Filter", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
                                        GLAccount.SetFilter("Budget Filter", AccountBudgetFilter);
                                        GLAccount.CalcFields("Budget at Date");
                                        if GLAccount."Budgeted Amount" <> 0 then
                                            AppendLine(StrSubstNo('#PBUDGET   %1  %2  %3  {%4 "%5"} %6', 0, Format(FormatDate(GLAccount.GetRangeMax
                                                    ("Date Filter")), 6), GLAccount."No.", DimensionSie."SIE Dimension", Ascii2Ansi(DimensionValue.Code),
                                                FormatAmount(GLAccount."Budget at Date")));
                                        GLAccountPrevAccPeriod.SetRange("Date Filter", PrevAccPeriodStart, PrevAccPeriodEnd);
                                        GLAccountPrevAccPeriod.SetFilter("Budget Filter", AccountBudgetFilter);
                                        GLAccountPrevAccPeriod.CalcFields("Budget at Date");
                                        if GLAccountPrevAccPeriod."Budgeted Amount" <> 0 then
                                            AppendLine(StrSubstNo('#PBUDGET  %1  %2  %3  {%4 "%5"} %6', -1, Format(FormatDate(GLAccountPrevAccPeriod.GetRangeMax
                                                    ("Date Filter")), 6), GLAccountPrevAccPeriod."No.", DimensionSie."SIE Dimension", Ascii2Ansi(DimensionValue.Code),
                                                FormatAmount(GLAccountPrevAccPeriod."Budget at Date")));
                                    end;
                                until DimensionValue.Next() = 0;
                        until DimensionSie.Next() = 0;
                end;
                GLAccount.Reset();
                GLAccount := GLAccountPosting;
                GLAccount.SetFilter("Global Dimension 1 Filter", '');
                GLAccount.SetFilter("Global Dimension 2 Filter", '');
                GLAccount.SetRange("Date Filter", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
                GLAccount.CalcFields("Net Change");
                if GLAccount."Net Change" <> 0 then
                    AppendLine(StrSubstNo('#PSALDO   %1  %2  %3  {} %4', 0, Format(FormatDate(GLAccount.GetRangeMax
                            ("Date Filter")), 6), GLAccount."No.", FormatAmount(GLAccount."Net Change")));

                GetFilteredGLAccFromPrevAccPeriod(GLAccountPrevAccPeriod, GLAccount);
                GLAccountPrevAccPeriod.CalcFields("Net Change");
                if GLAccountPrevAccPeriod."Net Change" <> 0 then
                    AppendLine(StrSubstNo('#PSALDO  %1  %2  %3  {} %4', -1, Format(FormatDate(GLAccountPrevAccPeriod.GetRangeMax
                            ("Date Filter")), 6), GLAccountPrevAccPeriod."No.", FormatAmount(GLAccountPrevAccPeriod."Net Change")));
                if AccountBudgetFilter <> '' then begin
                    GLAccount.Reset();
                    GLAccount.SetFilter("Global Dimension 1 Filter", '');
                    GLAccount.SetFilter("Global Dimension 2 Filter", '');
                    GLAccount.SetRange("Date Filter", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
                    GLAccount.SetFilter("Budget Filter", AccountBudgetFilter);
                    GLAccount.CalcFields("Budgeted Amount");
                    if GLAccount."Budgeted Amount" <> 0 then
                        AppendLine(StrSubstNo('#PBUDGET   %1  %2  %3  {} %4', 0, Format(FormatDate(GLAccount.GetRangeMax
                                ("Date Filter")), 6), GLAccount."No.", FormatAmount(GLAccount."Budgeted Amount")));
                    GetFilteredGLAccFromPrevAccPeriod(GLAccountPrevAccPeriod, GLAccount);
                    GLAccountPrevAccPeriod.CalcFields("Budgeted Amount");
                    if GLAccountPrevAccPeriod."Budgeted Amount" <> 0 then
                        AppendLine(StrSubstNo('#PBUDGET  %1  %2  %3  {} %4', -1, Format(FormatDate(GLAccountPrevAccPeriod.GetRangeMax
                                ("Date Filter")), 6), GLAccountPrevAccPeriod."No.", FormatAmount(GLAccountPrevAccPeriod."Budgeted Amount")));
                end;

                UpdateProgressDialog(7, GLAccount."No.");
                UpdateProgressDialog(8, Format(Round(Counter / CounterTotal * 10000, 1)));
            until GLAccountPosting.Next() = 0;
    end;

    local procedure WriteGLAccOpeningClosingBalance(AuditFileExportHeader: Record "Audit File Export Header")
    var
        DimensionSie: Record "Dimension SIE";
        DimensionValue: Record "Dimension Value";
        GLAccount: Record "G/L Account";
        GLAccountPosting: Record "G/L Account";
        GLAccountPrevAccPeriod: Record "G/L Account";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Counter: Integer;
        CounterTotal: Integer;
    begin
        GeneralLedgerSetup.Get();

        GetFilteredGLAccount(GLAccountPosting, AuditFileExportHeader."G/L Account View String");
        CounterTotal := GLAccountPosting.Count();
        if GLAccountPosting.FindSet() then
            repeat
                Counter += 1;
                GLAccount := GLAccountPosting;
                DimensionSie.SetCurrentKey("SIE Dimension");
                DimensionSie.SetRange(Selected, true);
                if DimensionSie.FindSet() then
                    repeat
                        DimensionValue.SetRange("Dimension Code", DimensionSie."Dimension Code");
                        if DimensionValue.FindSet() then
                            repeat
                                GLAccount.Reset();
                                if DimensionValue."Dimension Code" = GeneralLedgerSetup."Global Dimension 1 Code" then
                                    GLAccount.SetFilter("Global Dimension 1 Filter", DimensionValue.Code);
                                if DimensionValue."Dimension Code" = GeneralLedgerSetup."Global Dimension 2 Code" then
                                    GLAccount.SetFilter("Global Dimension 2 Filter", DimensionValue.Code);
                                GLAccount.SetRange("Date Filter", 0D, ClosingDate(AuditFileExportHeader."Starting Date" - 1));
                                GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
                                GLAccount.CalcFields("Balance at Date");

                                GetFilteredGLAccFromPrevAccPeriod(GLAccountPrevAccPeriod, GLAccount);
                                GLAccountPrevAccPeriod.SetRange("Date Filter", 0D, ClosingDate(GLAccountPrevAccPeriod.GetRangeMax("Date Filter")));
                                GLAccountPrevAccPeriod.CalcFields("Balance at Date");
                                if GLAccount."Balance at Date" <> 0 then
                                    AppendLine(StrSubstNo('#OIB  %1  %2  {%3 "%4"}  %5', 0, GLAccount."No.", DimensionSie."SIE Dimension",
                                        Ascii2Ansi(DimensionValue.Code), FormatAmount(GLAccount."Balance at Date")));
                                if GLAccountPrevAccPeriod."Balance at Date" <> 0 then
                                    AppendLine(StrSubstNo('#OUB  %1  %2  {%3 "%4"}  %5', 0, GLAccount."No.", DimensionSie."SIE Dimension",
                                        Ascii2Ansi(DimensionValue.Code), FormatAmount(GLAccountPrevAccPeriod."Balance at Date")));

                                GLAccount.SetRange("Date Filter", 0D, ClosingDate(PrevAccPeriodStart - 1));
                                GLAccount.SetFilter("Global Dimension 1 Filter", DimensionValue.Code);
                                GLAccount.CalcFields("Balance at Date");
                                GetFilteredGLAccFromPrevAccPeriod(GLAccountPrevAccPeriod, GLAccount);
                                GLAccountPrevAccPeriod.SetRange("Date Filter", 0D, ClosingDate(GLAccountPrevAccPeriod.GetRangeMax("Date Filter")));
                                GLAccountPrevAccPeriod.SetFilter("Global Dimension 1 Filter", DimensionValue.Code);
                                GLAccountPrevAccPeriod.CalcFields("Balance at Date");
                                if GLAccount."Balance at Date" <> 0 then
                                    AppendLine(StrSubstNo('#OIB  %1  %2  {%3 "%4"}  %5', -1, GLAccount."No.", DimensionSie."SIE Dimension",
                                        Ascii2Ansi(DimensionValue.Code), FormatAmount(GLAccount."Balance at Date")));
                                if GLAccountPrevAccPeriod."Balance at Date" <> 0 then
                                    AppendLine(StrSubstNo('#OUB  %1  %2  {%3 "%4"}  %5', -1, GLAccount."No.", DimensionSie."SIE Dimension",
                                        Ascii2Ansi(DimensionValue.Code), FormatAmount(GLAccountPrevAccPeriod."Balance at Date")));
                            until DimensionValue.Next() = 0;
                    until DimensionSie.Next() = 0;

                UpdateProgressDialog(5, GLAccount."No.");
                UpdateProgressDialog(6, Format(Round(Counter / CounterTotal * 10000, 1)));
            until GLAccountPosting.Next() = 0;
    end;

    local procedure WriteTransactions(AuditFileExportHeader: Record "Audit File Export Header")
    var
        GLEntry: Record "G/L Entry";
        DimensionSetEntry: Record "Dimension Set Entry";
        DimensionSie: Record "Dimension SIE";
        PrevDocNo: Code[20];
        DimensionString: Text[250];
        Counter: Integer;
        CounterTotal: Integer;
        PrevPostingDate: Date;
        IsFirstTransactWritten: Boolean;
    begin
        PrevDocNo := '';
        PrevPostingDate := 0D;

        GLEntry.SetCurrentKey("Document No.", "Posting Date");
        GLEntry.SetLoadFields("G/L Account No.", "Posting Date", "Document No.", Description, Amount, "Dimension Set ID");
        GLEntry.SetRange("Posting Date", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
        CounterTotal := GLEntry.Count();
        if GLEntry.FindSet() then
            repeat
                DimensionString := '';
                Counter += 1;
                if (GLEntry."Document No." <> PrevDocNo) or (GLEntry."Posting Date" <> PrevPostingDate) then
                    WriteTransactionHeader(GLEntry, IsFirstTransactWritten);

                DimensionSetEntry.SetRange("Dimension Set ID", GLEntry."Dimension Set ID");
                if DimensionSetEntry.FindSet() then begin
                    repeat
                        DimensionSie.SetRange(Selected, true);
                        DimensionSie.SetRange("Dimension Code", DimensionSetEntry."Dimension Code");
                        if DimensionSie.FindFirst() then
                            DimensionString += ' "' + Format(DimensionSie."SIE Dimension") + '" "' + DimensionSetEntry."Dimension Value Code" + '"';
                    until DimensionSetEntry.Next() = 0;
                    AppendLine(
                      StrSubstNo('  #TRANS  %1  {%2}  %3  %4',
                        GLEntry."G/L Account No.", Ascii2Ansi(DimensionString), FormatAmount(GLEntry.Amount), FormatDate(GLEntry."Posting Date")));
                end else
                    AppendLine(
                      StrSubstNo('  #TRANS  %1  {}  %2  %3',
                        GLEntry."G/L Account No.", FormatAmount(GLEntry.Amount), FormatDate(GLEntry."Posting Date")));

                PrevDocNo := GLEntry."Document No.";
                PrevPostingDate := GLEntry."Posting Date";

                UpdateProgressDialog(5, Format(Counter));
                UpdateProgressDialog(6, Format(Round(Counter / CounterTotal * 10000, 1)));
            until GLEntry.Next() = 0;
        if PrevDocNo <> '' then
            AppendLine('}');
    end;

    local procedure WriteTransactionHeader(var GLEntry: Record "G/L Entry"; var IsFirstTransactWritten: Boolean)
    begin
        UpdateProgressDialog(5, GLEntry."Document No.");

        if IsFirstTransactWritten then
            AppendLine('}');
        AppendLine(
          StrSubstNo(
            '#VER  %1  "%2"   %3  "%4"',
            'A', Ascii2Ansi(GLEntry."Document No."), FormatDate(GLEntry."Posting Date"), Ascii2Ansi(GLEntry.Description)));
        AppendLine('{');
        IsFirstTransactWritten := true;
    end;

    local procedure Ascii2Ansi(AsciText: Text[250]): Text[250]
    var
        AsciiStr: Text[30];
        AnsiStr: Text[30];
        AE: Char;
        UE: Char;
        Lilla: Char;
        Stora: Char;
    begin
        AsciiStr := 'åäöüÅÄÖÜéêèâàç';
        AE := 196;
        UE := 220;
        Lilla := 229;
        Stora := 197;
        AnsiStr := Format(Lilla) + 'õ÷³' + Format(Stora) + Format(AE) + 'Í' + Format(UE) + 'ÚÛÞÔÓþ';

        exit(ConvertStr(AsciText, AsciiStr, AnsiStr));
    end;

    local procedure FormatAmount(Amount: Decimal): Text[30]
    begin
        exit(CopyStr(Format(Amount, 0, 9), 1, 30));
    end;

    local procedure FormatDate(Date: Date): Text[30]
    begin
        exit(Format(Date, 8, '<Year4><month,2><day,2>'));
    end;

    local procedure GetFilteredGLAccFromPrevAccPeriod(var GLAccountTo: Record "G/L Account"; var GLAccountFrom: Record "G/L Account")
    begin
        GLAccountTo.Reset();
        GLAccountTo.Copy(GLAccountFrom);
        GLAccountTo.SetRange("Date Filter", PrevAccPeriodStart, PrevAccPeriodEnd);
    end;

    local procedure GetFilteredGLAccount(var GLAccount: Record "G/L Account"; GLAccountViewString: Text[1024])
    begin
        GLAccount.SetView(GLAccountViewString);

        GLAccount.FilterGroup(2);
        GLAccount.SetRange("Account Type", "G/L Account Type"::Posting);
        GLAccount.FilterGroup(0);
    end;

    local procedure AppendLine(LineContent: Text)
    begin
        LinesList.Add(LineContent + CRLF);
    end;

    local procedure InitAccountingPeriodDates(AuditFileExportHeader: Record "Audit File Export Header")
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        AccPeriodStart := AccountingPeriod.GetFiscalYearStartDate(AuditFileExportHeader."Starting Date");
        AccPeriodEnd := AccountingPeriod.GetFiscalYearEndDate(AuditFileExportHeader."Starting Date");

        PrevAccPeriodStart := AccountingPeriod.GetFiscalYearStartDate(AccPeriodStart - 1);
        PrevAccPeriodEnd := AccountingPeriod.GetFiscalYearEndDate(AccPeriodStart - 1);
    end;

    local procedure OpenProgressDialog(DialogContent: Text)
    begin
        if GuiAllowed() then
            ProgressDialog.Open(DialogContent);
    end;

    local procedure CloseProgressDialog()
    begin
        if GuiAllowed() then
            ProgressDialog.Close();
    end;

    local procedure UpdateProgressDialog(Number: Integer; NewText: Text)
    begin
        if GuiAllowed() then
            ProgressDialog.Update(Number, NewText);
    end;

    local procedure WriteFileContentToTempBlob(var TempBlob: Codeunit "Temp Blob")
    var
        FileContent: BigText;   // max 2 Gb both for blob and bigtext
        TextLine: Text;
        BlobOutStream: OutStream;
    begin
        foreach TextLine in LinesList do
            FileContent.AddText(TextLine);
        TempBlob.CreateOutStream(BlobOutStream);
        FileContent.Write(BlobOutStream);
    end;
#pragma warning restore
}
