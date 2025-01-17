// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.Reflection;
using System.Telemetry;
using System.Utilities;

codeunit 10826 "Generate File FEC"
{
    Access = Internal;

    var
        GLRegisterGlobal: Record "G/L Register";
        TypeHelper: Codeunit "Type Helper";
        DataHandlingFEC: Codeunit "Data Handling FEC";
        CurrentSourceType: Enum "Gen. Journal Source Type";
        CurrentTransactionNo: Integer;
        StartingDate: Date;
        EndingDate: Date;
        LinesList: List of [Text];
        CRLF: Text[2];
        CustVendLedgEntryPartyNo: Code[20];
        CustVendLedgEntryPartyName: Text[100];
        CustVendLedgEntryFCYAmount: Text[250];
        CustVendLedgEntryCurrencyCode: Code[10];
        CustVendDocNoSet: Text;
        CustVendDateApplied: Date;
        PayRecAccount: Code[20];
        DefaultSourceCode: Code[10];
        SourceCodesDescription: Dictionary of [Code[10], Text[100]];
        PayablesAccounts: Dictionary of [Code[20], Code[20]];
        ReceivablesAccounts: Dictionary of [Code[20], Code[20]];
        BankAccounts: Dictionary of [Code[20], Text[100]];
        BankAccPostingGroups: Dictionary of [Code[20], Code[20]];
        ProgressDialog: Dialog;
        FECAuditFileTok: label 'FEC Audit File', Locked = true;
        BeforeFilterExprTxt: label '..%1', Locked = true;
        NoEntriestoExportErr: Label 'There are no entries to export within the defined filter. The file was not created.';
        CreateFileTxt: label 'Creating FEC audit file\';
        ProcessTransactionsTxt: label 'Processing transactions: #1###', Comment = '#1 - percent of processed G/L Entries';

    procedure GenerateFileContent(AuditFileExportLine: Record "Audit File Export Line"; var TempBlob: Codeunit "Temp Blob")
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        AuditFileExportHeader.Get(AuditFileExportLine.ID);
        CheckGLEntriesExist(AuditFileExportHeader);
        InitGlobalVariables(AuditFileExportHeader);

        OpenProgressDialog(CreateFileTxt + ProcessTransactionsTxt);

        // process the data
        WriteHeader();
        if AuditFileExportHeader."Include Opening Balances" then
            WriteOpeningBalance(AuditFileExportHeader);
        WriteGLEntries(AuditFileExportHeader);

        CloseProgressDialog();
        WriteFileContentToTempBlob(TempBlob);

        FeatureTelemetry.LogUptake('0000K70', FECAuditFileTok, Enum::"Feature Uptake Status"::"Used");
    end;

    local procedure CheckGLEntriesExist(AuditFileExportHeader: Record "Audit File Export Header")
    var
        GLEntry: Record "G/L Entry";
        GLAccount: Record "G/L Account";
        GLAccNoFilter: Text;
    begin
        GLAccount.SetView(AuditFileExportHeader."G/L Account View String");
        if GLAccount.GetFilter("No.") <> '' then
            GLAccNoFilter := GLAccount.GetFilter("No.");

        GLEntry.SetRange("Posting Date", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
        GLEntry.SetFilter("G/L Account No.", GLAccNoFilter);
        GLEntry.SetFilter(Amount, '<>%1', 0);
        if GLEntry.IsEmpty() then
            Error(NoEntriestoExportErr);
    end;

    local procedure WriteOpeningBalance(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
        OpeningBalance: Decimal;
        DetailedBalance: Decimal;
        TotalDetailedBalance: Decimal;
    begin
        GLAccount.SetLoadFields("Account Type", Name, "Detailed Balance");
        SetFiltersGLAccount(GLAccount, AuditFileExportHeader."G/L Account View String");
        if GLAccount.FindSet() then
            repeat
                OpeningBalance := GetOpeningBalance(GLAccount, AuditFileExportHeader."Starting Date");

                TotalDetailedBalance := 0;
                if GLAccount."Detailed Balance" then begin
                    Customer.SetLoadFields(Name);
                    if Customer.FindSet() then
                        repeat
                            DetailedBalance := CalcDetailedBalanceBySource(GLAccount."No.", "Gen. Journal Source Type"::Customer, Customer."No.");
                            WriteDetailedGLAccountBySource(GLAccount."No.", GLAccount.Name, Customer."No.", Customer.Name, DetailedBalance);
                            TotalDetailedBalance += DetailedBalance;
                        until Customer.Next() = 0;
                    Vendor.SetLoadFields(Name);
                    if Vendor.FindSet() then
                        repeat
                            DetailedBalance := CalcDetailedBalanceBySource(GLAccount."No.", "Gen. Journal Source Type"::Vendor, Vendor."No.");
                            WriteDetailedGLAccountBySource(GLAccount."No.", GLAccount.Name, Vendor."No.", Vendor.Name, DetailedBalance);
                            TotalDetailedBalance += DetailedBalance;
                        until Vendor.Next() = 0;
                    BankAccount.SetLoadFields(Name);
                    if BankAccount.FindSet() then
                        repeat
                            DetailedBalance := CalcDetailedBalanceBySource(GLAccount."No.", "Gen. Journal Source Type"::"Bank Account", BankAccount."No.");
                            WriteDetailedGLAccountBySource(GLAccount."No.", GLAccount.Name, BankAccount."No.", BankAccount.Name, DetailedBalance);
                            TotalDetailedBalance += DetailedBalance;
                        until BankAccount.Next() = 0;
                end;

                if OpeningBalance - TotalDetailedBalance <> 0 then
                    WriteGLAccount(GLAccount."No.", GLAccount.Name, OpeningBalance - TotalDetailedBalance);
            until GLAccount.Next() = 0;
    end;

    local procedure WriteGLEntries(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        Counter: Integer;
        CounterTotal: Integer;
    begin
        GLAccount.SetView(AuditFileExportHeader."G/L Account View String");

        GLEntry.SetLoadFields(
            "Transaction No.", "Source Type", "Source No.", "Source Code", "G/L Account No.", "G/L Account Name",
            "Posting Date", "Document No.", "Document Date", Description, Amount, "Debit Amount", "Credit Amount");

        GLEntry.SetRange("Posting Date", StartingDate, EndingDate);
        GLEntry.SetFilter("G/L Account No.", GLAccount.GetFilter("No."));
        GLEntry.SetFilter(Amount, '<>%1', 0);
        CounterTotal := GLEntry.Count();
        if GLEntry.FindSet() then
            repeat
                Counter += 1;
                UpdateProgressDialog(1, Format(Round(Counter / CounterTotal * 100, 1)));

                if GLEntry."Posting Date" <> ClosingDate(GLEntry."Posting Date") then
                    ProcessGLEntry(GLEntry);
            until GLEntry.Next() = 0;
    end;

    local procedure ProcessGLEntry(var GLEntry: Record "G/L Entry")
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        GLRegister: Record "G/L Register";
        Customer: Record Customer;
        Vendor: Record Vendor;
        PartyNo: Code[20];
        PartyName: Text[100];
        FCYAmount: Text[250];
        CurrencyCode: Code[10];
        DocNoApplied: Text;
        DateApplied: Date;
        DateCreated: Date;
    begin
        PartyNo := '';
        PartyName := '';

        if (GLEntry."Transaction No." <> CurrentTransactionNo) or (GLEntry."Source Type" <> CurrentSourceType) then begin
            ResetTransactionData();
            GetLedgerEntryDataForCustVend(
              GLEntry."Transaction No.", GLEntry."Source Type",
              CustVendLedgEntryPartyNo,
              CustVendLedgEntryPartyName,
              CustVendLedgEntryFCYAmount,
              CustVendLedgEntryCurrencyCode,
              CustVendDocNoSet,
              CustVendDateApplied);

            CurrentTransactionNo := GLEntry."Transaction No.";
            CurrentSourceType := GLEntry."Source Type";
        end;

        BankAccountLedgerEntry.SetLoadFields("Bank Acc. Posting Group", "Bank Account No.", "Currency Code", Amount);
        if BankAccountLedgerEntry.Get(GLEntry."Entry No.") then
            GetBankLedgerEntryData(BankAccountLedgerEntry, GLEntry."G/L Account No.", PartyNo, PartyName, FCYAmount, CurrencyCode, DocNoApplied, DateApplied);

        if GLEntry."G/L Account No." = PayRecAccount then begin
            PartyNo := CustVendLedgEntryPartyNo;
            PartyName := CustVendLedgEntryPartyName;
            FCYAmount := CustVendLedgEntryFCYAmount;
            CurrencyCode := CustVendLedgEntryCurrencyCode;
            DocNoApplied := CustVendDocNoSet;
            DateApplied := CustVendDateApplied;
        end;

        if CustVendLedgEntryPartyNo = '*' then
            case GLEntry."Source Type" of
                GLEntry."Source Type"::Customer:
                    begin
                        Customer.SetLoadFields("Customer Posting Group", Name);
                        Customer.Get(GLEntry."Source No.");
                        if GetReceivablesAccount(Customer."Customer Posting Group") = GLEntry."G/L Account No." then begin
                            PartyNo := Customer."No.";
                            PartyName := Customer.Name;
                        end;
                    end;
                GLEntry."Source Type"::Vendor:
                    begin
                        Vendor.SetLoadFields("Vendor Posting Group", Name);
                        Vendor.Get(GLEntry."Source No.");
                        if GetPayablesAccount(Vendor."Vendor Posting Group") = GLEntry."G/L Account No." then begin
                            PartyNo := Vendor."No.";
                            PartyName := Vendor.Name;
                        end;
                    end;

            end;

        FindGLRegister(GLRegister, GLEntry."Entry No.");
        if GLRegister.SystemCreatedAt <> 0DT then
            DateCreated := DT2Date(GLRegister.SystemCreatedAt)
        else
            DateCreated := GLRegister."Creation Date";

        WriteGLEntryToFile(
            GLEntry,
            GLEntry."Transaction No.",
            DateCreated, PartyNo, PartyName, FCYAmount, CurrencyCode, DocNoApplied, DateApplied);
    end;

    local procedure CalcDetailedBalanceBySource(GLAccountNo: Code[20]; SourceType: Enum "Gen. Journal Source Type"; SourceNo: Code[20]) TotalAmt: Decimal
    var
        GLEntry: Record "G/L Entry";
        UnrealizedAmt: Decimal;
    begin
        GLEntry.SetLoadFields("Posting Date", "G/L Account No.", "Source Type", "Source No.", "Bal. Account Type", Amount);
        GLEntry.SetFilter("Posting Date", '..%1', StartingDate - 1);
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.SetRange("Source Type", SourceType);
        GLEntry.SetRange("Source No.", SourceNo);
        case SourceType of
            GLEntry."Source Type"::Customer:
                GLEntry.SetFilter("Bal. Account Type", '<>%1', GLEntry."Bal. Account Type"::Customer);
            GLEntry."Source Type"::Vendor:
                GLEntry.SetFilter("Bal. Account Type", '<>%1', GLEntry."Bal. Account Type"::Vendor);
            GLEntry."Source Type"::"Bank Account":
                GLEntry.SetFilter("Bal. Account Type", '<>%1', GLEntry."Bal. Account Type"::"Bank Account");
        end;
        GLEntry.CalcSums(Amount);

        case SourceType of
            GLEntry."Source Type"::Customer:
                UnrealizedAmt := GetCustomerUnrealizedAmount(GLAccountNo, SourceNo);
            GLEntry."Source Type"::Vendor:
                UnrealizedAmt := GetVendorUnrealizedAmount(GLAccountNo, SourceNo);
        end;

        TotalAmt := GLEntry.Amount + UnrealizedAmt;
    end;

    local procedure FindGLRegister(var GLRegister: Record "G/L Register"; EntryNo: Integer)
    begin
        if (EntryNo >= GLRegisterGlobal."From Entry No.") and (EntryNo <= GLRegisterGlobal."To Entry No.") then begin
            GLRegister := GLRegisterGlobal;
            exit;
        end;

        GLRegister.SetLoadFields("From Entry No.", "To Entry No.", "Creation Date");
        if EntryNo > GLRegisterGlobal."To Entry No." then
            GLRegister.SetFilter("No.", '>%1', GLRegisterGlobal."No.");
        GLRegister.SetFilter("From Entry No.", '<=%1', EntryNo);
        GLRegister.SetFilter("To Entry No.", '>=%1', EntryNo);
        GLRegister.FindFirst();
        CopyGLRegisterToGlobal(GLRegister);
    end;

    local procedure CopyGLRegisterToGlobal(var GLRegister: Record "G/L Register")
    begin
        GLRegisterGlobal."No." := GLRegister."No.";
        GLRegisterGlobal."From Entry No." := GLRegister."From Entry No.";
        GLRegisterGlobal."To Entry No." := GLRegister."To Entry No.";
        GLRegisterGlobal."Creation Date" := GLRegister."Creation Date";
        GLRegisterGlobal.SystemCreatedAt := GLRegister.SystemCreatedAt;
    end;

    local procedure GetOpeningBalance(var GLAccount: Record "G/L Account"; PeriodStartDate: Date): Decimal
    begin
        GLAccount.SetFilter("Date Filter", StrSubstNo(BeforeFilterExprTxt, ClosingDate(CalcDate('<-1D>', PeriodStartDate))));
        GLAccount.CalcFields("Balance at Date");
        exit(GLAccount."Balance at Date")
    end;

    local procedure GetCustomerUnrealizedAmount(GLAccountNo: Code[20]; CustomerNo: Code[20]): Decimal
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        DetailedCustLedgEntry.SetLoadFields("Customer No.", "Entry Type", "Posting Date", Unapplied, "Curr. Adjmt. G/L Account No.", "Amount (LCY)");
        DetailedCustLedgEntry.SetRange("Customer No.", CustomerNo);
        DetailedCustLedgEntry.SetFilter("Entry Type", '%1|%2', DetailedCustLedgEntry."Entry Type"::"Unrealized Gain", DetailedCustLedgEntry."Entry Type"::"Unrealized Loss");
        DetailedCustLedgEntry.SetFilter("Posting Date", '..%1', StartingDate - 1);
        DetailedCustLedgEntry.SetRange(Unapplied, false);
        DetailedCustLedgEntry.SetRange("Curr. Adjmt. G/L Account No.", GLAccountNo);
        DetailedCustLedgEntry.CalcSums("Amount (LCY)");
        exit(DetailedCustLedgEntry."Amount (LCY)");
    end;

    local procedure GetVendorUnrealizedAmount(GLAccountNo: Code[20]; VendorNo: Code[20]): Decimal
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        DetailedVendorLedgEntry.SetLoadFields("Vendor No.", "Entry Type", "Posting Date", Unapplied, "Curr. Adjmt. G/L Account No.", "Amount (LCY)");
        DetailedVendorLedgEntry.SetRange("Vendor No.", VendorNo);
        DetailedVendorLedgEntry.SetFilter("Entry Type", '%1|%2', DetailedVendorLedgEntry."Entry Type"::"Unrealized Gain", DetailedVendorLedgEntry."Entry Type"::"Unrealized Loss");
        DetailedVendorLedgEntry.SetFilter("Posting Date", '..%1', StartingDate - 1);
        DetailedVendorLedgEntry.SetRange(Unapplied, false);
        DetailedVendorLedgEntry.SetRange("Curr. Adjmt. G/L Account No.", GLAccountNo);
        DetailedVendorLedgEntry.CalcSums("Amount (LCY)");
        exit(DetailedVendorLedgEntry."Amount (LCY)");
    end;

    procedure GetLedgerEntryDataForCustVend(TransactionNo: Integer; SourceType: Enum "Gen. Journal Source Type"; var PartyNo: Code[20]; var PartyName: Text[100]; var FCYAmount: Text[250]; var CurrencyCode: Code[10]; var DocNoSet: Text; var DateApplied: Date)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntryMult: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntryMult: Record "Vendor Ledger Entry";
        GLSourceType: Enum "Gen. Journal Source Type";
        CountOfGLEntriesInTransaction: Integer;
        LedgerAmount: Decimal;
    begin
        DocNoSet := '';
        DateApplied := 0D;

        case SourceType of
            GLSourceType::Customer:
                begin
                    CustLedgerEntry.SetLoadFields("Transaction No.", "Customer No.", "Customer Name", "Customer Posting Group", "Currency Code");
                    CustLedgerEntry.SetCurrentKey("Transaction No.");
                    CustLedgerEntry.SetRange("Transaction No.", TransactionNo);
                    if CustLedgerEntry.FindSet() then begin
                        // if there are multiple customers within the transaction
                        CustLedgerEntryMult.SetRange("Transaction No.", TransactionNo);
                        CustLedgerEntryMult.SetFilter("Customer No.", '<>%1', CustLedgerEntry."Customer No.");
                        if not CustLedgerEntryMult.IsEmpty() then begin
                            PartyName := 'multi-clients';
                            PartyNo := '*';
                            FCYAmount := '';
                            exit;
                        end;

                        PartyNo := CustLedgerEntry."Customer No.";
                        PartyName := CustLedgerEntry."Customer Name";
                        PayRecAccount := GetReceivablesAccount(CustLedgerEntry."Customer Posting Group");
                        CountOfGLEntriesInTransaction := GetTransPayRecEntriesCount(CustLedgerEntry."Transaction No.", PayRecAccount);
                        repeat
                            GetAppliedCustLedgEntry(CustLedgerEntry."Entry No.", DocNoSet, DateApplied);
                            if (CustLedgerEntry."Currency Code" <> '') and (CountOfGLEntriesInTransaction = 1) then begin
                                CustLedgerEntry.CalcFields("Original Amount");
                                LedgerAmount += CustLedgerEntry."Original Amount";
                                CurrencyCode := CustLedgerEntry."Currency Code";
                                FCYAmount := FormatAmount(Abs(LedgerAmount));
                            end;
                        until CustLedgerEntry.Next() = 0;
                        DocNoSet := DelChr(DocNoSet, '>', ';');
                    end;
                end;

            GLSourceType::Vendor:
                begin
                    VendorLedgerEntry.SetLoadFields("Transaction No.", "Vendor No.", "Vendor Name", "Vendor Posting Group", "Currency Code");
                    VendorLedgerEntry.SetCurrentKey("Transaction No.");
                    VendorLedgerEntry.SetRange("Transaction No.", TransactionNo);
                    if VendorLedgerEntry.FindSet() then begin
                        // if there are multiple vendors within the transaction
                        VendorLedgerEntryMult.SetRange("Transaction No.", TransactionNo);
                        VendorLedgerEntryMult.SetFilter("Vendor No.", '<>%1', VendorLedgerEntry."Vendor No.");
                        if not VendorLedgerEntryMult.IsEmpty() then begin
                            PartyName := 'multi-fournisseurs';
                            PartyNo := '*';
                            FCYAmount := '';
                            exit;
                        end;

                        PartyNo := VendorLedgerEntry."Vendor No.";
                        PartyName := VendorLedgerEntry."Vendor Name";
                        PayRecAccount := GetPayablesAccount(VendorLedgerEntry."Vendor Posting Group");
                        CountOfGLEntriesInTransaction := GetTransPayRecEntriesCount(VendorLedgerEntry."Transaction No.", PayRecAccount);
                        repeat
                            GetAppliedVendorLedgEntry(VendorLedgerEntry."Entry No.", DocNoSet, DateApplied);
                            if (VendorLedgerEntry."Currency Code" <> '') and (CountOfGLEntriesInTransaction = 1) then begin
                                VendorLedgerEntry.CalcFields("Original Amount");
                                LedgerAmount += VendorLedgerEntry."Original Amount";
                                CurrencyCode := VendorLedgerEntry."Currency Code";
                                FCYAmount := FormatAmount(Abs(LedgerAmount));
                            end;
                        until VendorLedgerEntry.Next() = 0;
                        DocNoSet := DelChr(DocNoSet, '>', ';');
                    end;
                end;
        end;
    end;

    local procedure GetBankLedgerEntryData(var BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; GLAccountNo: Code[20]; var PartyNo: Code[20]; var PartyName: Text[100]; var Amount: Text[250]; var CurrencyCode: Code[10]; var DocNoApplied: Text; var DateApplied: Date)
    begin
        if GetBankPostingGLAccount(BankAccountLedgerEntry."Bank Acc. Posting Group") = GLAccountNo then
            GetBankAccountData(BankAccountLedgerEntry."Bank Account No.", PartyNo, PartyName);

        if BankAccountLedgerEntry."Currency Code" <> '' then begin
            Amount := FormatAmount(Abs(BankAccountLedgerEntry.Amount));
            CurrencyCode := BankAccountLedgerEntry."Currency Code";
        end;
        GetAppliedBankLedgEntry(BankAccountLedgerEntry, DocNoApplied, DateApplied);
    end;

    local procedure GetBankPostingGLAccount(PostingGroupCode: Code[20]) PostingGroupGLAccount: Code[20]
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
    begin
        if BankAccPostingGroups.Get(PostingGroupCode, PostingGroupGLAccount) then
            exit;

        if BankAccountPostingGroup.Get(PostingGroupCode) then begin
            BankAccPostingGroups.Add(BankAccountPostingGroup.Code, BankAccountPostingGroup."G/L Account No.");
            PostingGroupGLAccount := BankAccountPostingGroup."G/L Account No.";
        end;
    end;

    local procedure GetBankAccountData(BankAccountNo: Code[20]; var PartyNo: Code[20]; var PartyName: Text[100])
    var
        BankAccount: Record "Bank Account";
    begin
        if BankAccounts.Get(BankAccountNo, PartyName) then begin
            PartyNo := BankAccountNo;
            exit;
        end;

        BankAccount.SetLoadFields(Name);
        if BankAccount.Get(BankAccountNo) then begin
            BankAccounts.Add(BankAccount."No.", BankAccount.Name);
            PartyNo := BankAccount."No.";
            PartyName := BankAccount.Name;
        end;
    end;

    local procedure GetSourceCode(var GLEntry: Record "G/L Entry"): Code[10]
    begin
        if GLEntry."Source Code" = '' then
            exit(DefaultSourceCode);
        exit(GLEntry."Source Code");
    end;

    local procedure GetSourceCodeDesc(CodeValue: Code[10]) DescriptionValue: Text[100]
    var
        SourceCode: Record "Source Code";
    begin
        if SourceCodesDescription.Get(CodeValue, DescriptionValue) then
            exit;

        if SourceCode.Get(CodeValue) then begin
            SourceCodesDescription.Add(SourceCode.Code, SourceCode.Description);
            DescriptionValue := SourceCode.Description;
        end;
    end;

    local procedure GetTransPayRecEntriesCount(TransactionNo: Integer; PayRecAcc: Code[20]): Integer
    var
        GLEntry: Record "G/L Entry";
        GLEntryCount: Integer;
    begin
        GLEntry.SetCurrentKey("Transaction No.");
        // global filters
        GLEntry.SetRange("Posting Date", StartingDate, EndingDate);
        GLEntry.SetFilter(Amount, '<>%1', 0);

        // local filters
        GLEntry.SetRange("G/L Account No.", PayRecAcc);
        GLEntry.SetRange("Transaction No.", TransactionNo);
        GLEntryCount := GLEntry.Count();
        exit(GLEntryCount)
    end;

    local procedure GetAppliedBankLedgEntry(BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; var DocNo: Text; var AppliedDate: Date)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        CustLedgerEntry.SetLoadFields();
        if CustLedgerEntry.Get(BankAccountLedgerEntry."Entry No.") then
            GetAppliedCustLedgEntry(CustLedgerEntry."Entry No.", DocNo, AppliedDate)
        else begin
            VendorLedgerEntry.SetLoadFields();
            if VendorLedgerEntry.Get(BankAccountLedgerEntry."Entry No.") then
                GetAppliedVendorLedgEntry(VendorLedgerEntry."Entry No.", DocNo, AppliedDate);
        end;
    end;

    local procedure GetAppliedCustLedgEntry(OriginalCustLedgerEntryNo: Integer; var DocNo: Text; var AppliedDate: Date)
    var
        DetailedCustLedgEntryOriginal: Record "Detailed Cust. Ledg. Entry";
        DetailedCustLedgEntryApplied: Record "Detailed Cust. Ledg. Entry";
        CustLedgEntryApplied: Record "Cust. Ledger Entry";
    begin
        AppliedDate := 0D;
        DetailedCustLedgEntryOriginal.SetCurrentKey("Cust. Ledger Entry No.");
        DetailedCustLedgEntryOriginal.SetLoadFields("Cust. Ledger Entry No.", Unapplied, "Applied Cust. Ledger Entry No.");
        DetailedCustLedgEntryOriginal.SetRange("Cust. Ledger Entry No.", OriginalCustLedgerEntryNo);
        DetailedCustLedgEntryOriginal.SetRange(Unapplied, false);

        if DetailedCustLedgEntryOriginal.FindSet() then
            repeat
                if DetailedCustLedgEntryOriginal."Cust. Ledger Entry No." = DetailedCustLedgEntryOriginal."Applied Cust. Ledger Entry No." then begin
                    DetailedCustLedgEntryApplied.Init();
                    DetailedCustLedgEntryApplied.SetCurrentKey("Applied Cust. Ledger Entry No.", "Entry Type");
                    DetailedCustLedgEntryApplied.SetLoadFields("Applied Cust. Ledger Entry No.", "Entry Type", Unapplied, "Cust. Ledger Entry No.", "Posting Date");
                    DetailedCustLedgEntryApplied.SetRange("Applied Cust. Ledger Entry No.", DetailedCustLedgEntryOriginal."Applied Cust. Ledger Entry No.");
                    DetailedCustLedgEntryApplied.SetRange("Entry Type", DetailedCustLedgEntryApplied."Entry Type"::Application);
                    DetailedCustLedgEntryApplied.SetRange(Unapplied, false);

                    if DetailedCustLedgEntryApplied.FindSet() then
                        repeat
                            if DetailedCustLedgEntryApplied."Cust. Ledger Entry No." <> DetailedCustLedgEntryApplied."Applied Cust. Ledger Entry No." then begin
                                CustLedgEntryApplied.SetLoadFields("Document No.", "Posting Date");
                                if CustLedgEntryApplied.Get(DetailedCustLedgEntryApplied."Cust. Ledger Entry No.") and
                                   (DetailedCustLedgEntryApplied."Posting Date" < EndingDate)
                                then begin
                                    AddAppliedDocNo(DocNo, CustLedgEntryApplied."Document No.");
                                    GetCustAppliedDate(CustLedgEntryApplied, AppliedDate);
                                end;
                            end;
                        until DetailedCustLedgEntryApplied.Next() = 0;
                end
                else begin
                    CustLedgEntryApplied.SetLoadFields("Document No.", "Posting Date");
                    if CustLedgEntryApplied.Get(DetailedCustLedgEntryOriginal."Applied Cust. Ledger Entry No.") then
                        if CustLedgEntryApplied."Posting Date" < EndingDate then begin
                            AddAppliedDocNo(DocNo, CustLedgEntryApplied."Document No.");
                            GetCustAppliedDate(CustLedgEntryApplied, AppliedDate);
                        end;
                end;
            until DetailedCustLedgEntryOriginal.Next() = 0;
    end;

    local procedure GetAppliedVendorLedgEntry(OriginalVendorLedgerEntryNo: Integer; var DocNo: Text; var AppliedDate: Date)
    var
        DetailedVendorLedgEntryOriginal: Record "Detailed Vendor Ledg. Entry";
        DetailedVendorLedgEntryApplied: Record "Detailed Vendor Ledg. Entry";
        VendorLedgEntryApplied: Record "Vendor Ledger Entry";
    begin
        AppliedDate := 0D;
        DetailedVendorLedgEntryOriginal.SetCurrentKey("Vendor Ledger Entry No.");
        DetailedVendorLedgEntryOriginal.SetLoadFields("Vendor Ledger Entry No.", Unapplied, "Applied Vend. Ledger Entry No.");
        DetailedVendorLedgEntryOriginal.SetRange("Vendor Ledger Entry No.", OriginalVendorLedgerEntryNo);
        DetailedVendorLedgEntryOriginal.SetRange(Unapplied, false);

        if DetailedVendorLedgEntryOriginal.FindSet() then
            repeat
                if DetailedVendorLedgEntryOriginal."Vendor Ledger Entry No." = DetailedVendorLedgEntryOriginal."Applied Vend. Ledger Entry No." then begin
                    DetailedVendorLedgEntryApplied.Init();
                    DetailedVendorLedgEntryApplied.SetCurrentKey("Applied Vend. Ledger Entry No.", "Entry Type");
                    DetailedVendorLedgEntryApplied.SetLoadFields("Applied Vend. Ledger Entry No.", "Entry Type", Unapplied, "Vendor Ledger Entry No.", "Posting Date");
                    DetailedVendorLedgEntryApplied.SetRange("Applied Vend. Ledger Entry No.", DetailedVendorLedgEntryOriginal."Applied Vend. Ledger Entry No.");
                    DetailedVendorLedgEntryApplied.SetRange("Entry Type", DetailedVendorLedgEntryApplied."Entry Type"::Application);
                    DetailedVendorLedgEntryApplied.SetRange(Unapplied, false);

                    if DetailedVendorLedgEntryApplied.FindSet() then
                        repeat
                            if DetailedVendorLedgEntryApplied."Vendor Ledger Entry No." <> DetailedVendorLedgEntryApplied."Applied Vend. Ledger Entry No." then begin
                                VendorLedgEntryApplied.SetLoadFields("Document No.", "Posting Date");
                                if VendorLedgEntryApplied.Get(DetailedVendorLedgEntryApplied."Vendor Ledger Entry No.") and
                                   (DetailedVendorLedgEntryApplied."Posting Date" < EndingDate)
                                then begin
                                    AddAppliedDocNo(DocNo, VendorLedgEntryApplied."Document No.");
                                    GetVendorAppliedDate(VendorLedgEntryApplied, AppliedDate);
                                end;
                            end;
                        until DetailedVendorLedgEntryApplied.Next() = 0;
                end
                else begin
                    VendorLedgEntryApplied.SetLoadFields("Document No.", "Posting Date");
                    if VendorLedgEntryApplied.Get(DetailedVendorLedgEntryOriginal."Applied Vend. Ledger Entry No.") then
                        if VendorLedgEntryApplied."Posting Date" < EndingDate then begin
                            AddAppliedDocNo(DocNo, VendorLedgEntryApplied."Document No.");
                            GetVendorAppliedDate(VendorLedgEntryApplied, AppliedDate);
                        end;
                end;
            until DetailedVendorLedgEntryOriginal.Next() = 0;
    end;

    local procedure GetCustAppliedDate(var CustLedgEntryApplied: Record "Cust. Ledger Entry"; var AppliedDate: Date)
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        if GetDetailedCustLedgEntry(DetailedCustLedgEntry, CustLedgEntryApplied."Entry No.") then begin
            if DetailedCustLedgEntry."Posting Date" > AppliedDate then
                AppliedDate := DetailedCustLedgEntry."Posting Date";
        end else
            AppliedDate := CustLedgEntryApplied."Posting Date";
    end;

    local procedure GetDetailedCustLedgEntry(var DetailedCustLedgEntryApplied: Record "Detailed Cust. Ledg. Entry"; AppliedCustLedgerEntryNo: Integer): Boolean
    begin
        DetailedCustLedgEntryApplied.SetLoadFields("Applied Cust. Ledger Entry No.", "Entry Type", Unapplied, "Posting Date");
        DetailedCustLedgEntryApplied.SetRange("Applied Cust. Ledger Entry No.", AppliedCustLedgerEntryNo);
        DetailedCustLedgEntryApplied.SetRange("Entry Type", DetailedCustLedgEntryApplied."Entry Type"::Application);
        DetailedCustLedgEntryApplied.SetRange(Unapplied, false);
        exit(DetailedCustLedgEntryApplied.FindFirst())
    end;

    local procedure GetVendorAppliedDate(var VendorLedgEntryApplied: Record "Vendor Ledger Entry"; var AppliedDate: Date)
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        if GetDetailedVendorLedgEntry(DetailedVendorLedgEntry, VendorLedgEntryApplied."Entry No.") then begin
            if DetailedVendorLedgEntry."Posting Date" > AppliedDate then
                AppliedDate := DetailedVendorLedgEntry."Posting Date";
        end else
            AppliedDate := VendorLedgEntryApplied."Posting Date";
    end;

    local procedure GetDetailedVendorLedgEntry(var DetailedVendorLedgEntryApplied: Record "Detailed Vendor Ledg. Entry"; AppliedVendorLedgerEntryNo: Integer): Boolean
    begin
        DetailedVendorLedgEntryApplied.SetLoadFields("Applied Vend. Ledger Entry No.", "Entry Type", Unapplied, "Posting Date");
        DetailedVendorLedgEntryApplied.SetRange("Applied Vend. Ledger Entry No.", AppliedVendorLedgerEntryNo);
        DetailedVendorLedgEntryApplied.SetRange("Entry Type", DetailedVendorLedgEntryApplied."Entry Type"::Application);
        DetailedVendorLedgEntryApplied.SetRange(Unapplied, false);
        exit(DetailedVendorLedgEntryApplied.FindFirst())
    end;

    local procedure GetPayablesAccount(VendorPostingGroupCode: Code[20]) PayablesAcc: Code[20]
    var
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        if PayablesAccounts.Get(VendorPostingGroupCode, PayablesAcc) then
            exit;

        VendorPostingGroup.SetLoadFields("Payables Account");
        if VendorPostingGroup.Get(VendorPostingGroupCode) then begin
            PayablesAccounts.Add(VendorPostingGroup.Code, VendorPostingGroup."Payables Account");
            PayablesAcc := VendorPostingGroup."Payables Account";
        end;
    end;

    local procedure GetReceivablesAccount(CustomerPostingGroupCode: Code[20]) ReceivablesAcc: Code[20]
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if ReceivablesAccounts.Get(CustomerPostingGroupCode, ReceivablesAcc) then
            exit;

        CustomerPostingGroup.SetLoadFields("Receivables Account");
        if CustomerPostingGroup.Get(CustomerPostingGroupCode) then begin
            ReceivablesAccounts.Add(CustomerPostingGroup.Code, CustomerPostingGroup."Receivables Account");
            ReceivablesAcc := CustomerPostingGroup."Receivables Account";
        end;
    end;

    local procedure ResetTransactionData()
    begin
        CustVendLedgEntryPartyNo := '';
        CustVendLedgEntryPartyName := '';
        CustVendLedgEntryFCYAmount := '';
        CustVendLedgEntryCurrencyCode := '';
        PayRecAccount := '';
    end;

    local procedure SetFiltersGLAccount(var GLAccount: Record "G/L Account"; GLAccountViewString: Text[1024])
    begin
        GLAccount.SetView(GLAccountViewString);

        GLAccount.FilterGroup(2);
        GLAccount.SetRange("Account Type", "G/L Account Type"::Posting);
        GLAccount.FilterGroup(0);
    end;

    local procedure WriteHeader()
    begin
        AppendLine('JournalCode|JournalLib|EcritureNum|EcritureDate|CompteNum|CompteLib|CompAuxNum|CompAuxLib|PieceRef|' +
          'PieceDate|EcritureLib|Debit|Credit|EcritureLet|DateLet|ValidDate|Montantdevise|Idevise');
    end;

    local procedure WriteDetailedGLAccountBySource(GLAccountNo: Code[20]; GLAccountName: Text[100]; SourceNo: Code[20]; PartyName: Text[100]; Amount: Decimal)
    var
        DebitAmt: Decimal;
        CreditAmt: Decimal;
    begin
        if Amount = 0 then
            exit;

        if Amount > 0 then
            DebitAmt := Amount
        else
            CreditAmt := -Amount;

        AppendLine('00000|' +
          'BALANCE OUVERTURE|' +
          '0|' +
          DataHandlingFEC.GetFormattedDate(StartingDate) + '|' +
          GLAccountNo + '|' +
          GLAccountName + '|' +
          SourceNo + '|' +
          PartyName + '|' +
          '00000|' +
          DataHandlingFEC.GetFormattedDate(StartingDate) + '|' +
          'BAL OUV ' + PartyName + '|' +
          FormatAmount(DebitAmt) + '|' +
          FormatAmount(CreditAmt) + '|' +
          '||' +
          DataHandlingFEC.GetFormattedDate(StartingDate) +
          '||');
    end;

    local procedure WriteGLAccount(GLAccountNo: Code[20]; GLAccountName: Text[100]; OpeningBalance: Decimal)
    var
        CreditAmount: Decimal;
        DebitAmount: Decimal;
    begin
        if OpeningBalance > 0 then
            DebitAmount := OpeningBalance
        else
            CreditAmount := Abs(OpeningBalance);

        AppendLine('00000|' +
          'BALANCE OUVERTURE|' +
          '0|' +
          DataHandlingFEC.GetFormattedDate(StartingDate) + '|' +
          GLAccountNo + '|' +
          GLAccountName + '|' +
          '||' +
          '00000|' +
          DataHandlingFEC.GetFormattedDate(StartingDate) + '|' +
          'BAL OUV ' + GLAccountName + '|' +
          FormatAmount(DebitAmount) + '|' +
          FormatAmount(CreditAmount) + '|' +
          '||' +
          DataHandlingFEC.GetFormattedDate(StartingDate) +
          '||');
    end;

    local procedure WriteGLEntryToFile(var GLEntry: Record "G/L Entry"; ProgressiveNo: Integer; GLRegisterCreationDate: Date; PartyNo: Code[20]; PartyName: Text[100]; FCYAmount: Text[250]; CurrencyCode: Code[10]; DocNoSet: Text; DateApplied: Date)
    begin
        GLEntry.CalcFields(GLEntry."G/L Account Name");

        AppendLine(
          GetSourceCode(GLEntry) + '|' +
          GetSourceCodeDesc(GetSourceCode(GLEntry)) + '|' +
          Format(ProgressiveNo) + '|' +
          DataHandlingFEC.GetFormattedDate(GLEntry."Posting Date") + '|' +
          GLEntry."G/L Account No." + '|' +
          GLEntry."G/L Account Name" + '|' +
          Format(PartyNo) + '|' +
          PartyName + '|' +
          GLEntry."Document No." + '|' +
          DataHandlingFEC.GetFormattedDate(GLEntry."Document Date") + '|' +
          GLEntry.Description + '|' +
          FormatAmount(GLEntry."Debit Amount") + '|' +
          FormatAmount(GLEntry."Credit Amount") + '|' +
          DocNoSet + '|' +
          DataHandlingFEC.GetFormattedDate(DateApplied) + '|' +
          DataHandlingFEC.GetFormattedDate(GLRegisterCreationDate) + '|' +
          FCYAmount + '|' +
          CurrencyCode);
    end;

    local procedure AppendLine(LineContent: Text)
    begin
        LinesList.Add(LineContent + CRLF);
    end;

    local procedure AddAppliedDocNo(var AppliedDocNo: Text; DocNo: Code[20])
    begin
        if StrPos(';' + AppliedDocNo, ';' + DocNo + ';') = 0 then
            AppliedDocNo += DocNo + ';';
    end;

    local procedure FormatAmount(Amount: Decimal): Text[250]
    begin
        exit(Format(Amount, 0, '<Precision,2:2><Sign><Integer><Decimals><comma,,>'));
    end;

    procedure InitGlobalVariables(AuditFileExportHeader: Record "Audit File Export Header")
    begin
        StartingDate := AuditFileExportHeader."Starting Date";
        EndingDate := AuditFileExportHeader."Ending Date";
        DefaultSourceCode := AuditFileExportHeader."Default Source Code";
        CRLF := TypeHelper.CRLFSeparator();
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
            ProgressDialog.Update(Number, NewText + '%');
    end;

    local procedure WriteFileContentToTempBlob(var TempBlob: Codeunit "Temp Blob")
    var
        TextLine: Text;
        BlobOutStream: OutStream;
    begin
        TempBlob.CreateOutStream(BlobOutStream);
        foreach TextLine in LinesList do
            BlobOutStream.WriteText(TextLine);
    end;
}
