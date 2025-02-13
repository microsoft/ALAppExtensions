// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Currency;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Analysis;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.SalesTax;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Enums;
using Microsoft.HumanResources.Employee;
using Microsoft.HumanResources.Payables;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using Microsoft.Utilities;
using System.Utilities;

report 31004 "Adjust Exchange Rates CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/AdjustExchangeRates.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Adjust Exchange Rates Enhanced';
    Permissions = tabledata "Cust. Ledger Entry" = rimd,
                  tabledata "Vendor Ledger Entry" = rimd,
                  tabledata "Employee Ledger Entry" = rimd,
                  tabledata "Exch. Rate Adjmt. Reg." = rimd,
                  tabledata "VAT Entry" = rimd,
                  tabledata "Detailed Cust. Ledg. Entry" = rimd,
                  tabledata "Detailed Vendor Ledg. Entry" = rimd,
                  tabledata "Detailed Employee Ledger Entry" = rimd;

    UsageCategory = Tasks;

    dataset
    {
        dataitem(Currency; Currency)
        {
            DataItemTableView = sorting(Code);
            RequestFilterFields = "Code";
            column(CompanyNameHdr; COMPANYPROPERTY.DisplayName())
            {
            }
            column(PostVar; format(Post))
            {
            }
            column(BankAccFiltersVar; BankAccFilters)
            {
            }
            column(CustomerFiltersVar; CustFilters)
            {
            }
            column(VendorFiltersVar; VendFilters)
            {
            }
            column(EmployeeFiltersVar; EmployeeFilters)
            {
            }
            column(EndDateVar; Format(EndDate))
            {
            }
            dataitem("Bank Account"; "Bank Account")
            {
                DataItemLink = "Currency Code" = field(Code);
                DataItemTableView = sorting("Bank Acc. Posting Group");
                RequestFilterHeading = 'Bank Account and Cash Desk';
                RequestFilterFields = "No.";
                column(BankAccNo_Fld; "No.")
                {
                }
                column(BankAccName_Fld; Name)
                {
                }
                column(BankAccCurrencyCode_Fld; "Currency Code")
                {
                }
                column(BankAccFactor_Fld; Round(1 / Currency."Currency Factor", 0.001))
                {
                    DecimalPlaces = 3 : 3;
                }
                column(BankAccBalanceDate_Fld; "Balance at Date")
                {
                }
                column(BankAccBalanceDateLCY_Fld; "Balance at Date (LCY)")
                {
                }
                column(BankAccModBalanceDateLCY_Fld; AdjAmount + "Balance at Date (LCY)")
                {
                }
                column(BankAccGainLoss_Fld; GainOrLoss)
                {
                }
                column(BankAccModDebitAmount_Fld; AdjDebit)
                {
                }
                column(BankAccModCrebitAmount_Fld; AdjCredit)
                {
                }
                column(BATableType_Var; TableType)
                {
                }
                dataitem(BankAccountGroupTotal; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    MaxIteration = 1;

                    trigger OnAfterGetRecord()
                    var
                        BankAccount: Record "Bank Account";
                        GroupTotal: Boolean;
                        ExchRateAdjmtAccountType: Enum "Exch. Rate Adjmt. Account Type";
                    begin
                        BankAccount.Copy("Bank Account");
                        if BankAccount.Next() = 1 then begin
                            if BankAccount."Bank Acc. Posting Group" <> "Bank Account"."Bank Acc. Posting Group" then
                                GroupTotal := true;
                        end else
                            GroupTotal := true;

                        if GroupTotal then
                            if TotalAdjAmount <> 0 then begin
                                AdjExchRateBufferUpdate(
                                  "Bank Account"."Currency Code", "Bank Account"."Bank Acc. Posting Group",
                                  TotalAdjBase, TotalAdjBaseLCY, TotalAdjAmount, 0, 0, 0, PostingDate, '',
                                  false, '');
                                InsertExchRateAdjmtReg(ExchRateAdjmtAccountType::"Bank Account", "Bank Account"."Bank Acc. Posting Group", "Bank Account"."Currency Code");
                                TotalBankAccountsAdjusted += 1;
                                TempAdjExchangeRateBufferCZL.Reset();
                                TempAdjExchangeRateBufferCZL.DeleteAll();
                                TotalAdjBase := 0;
                                TotalAdjBaseLCY := 0;
                                TotalAdjAmount := 0;
                            end;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    TempEntryNoAmountBuffer.DeleteAll();
                    BankAccNo := BankAccNo + 1;
                    WindowDialog.Update(1, Round(BankAccNo / BankAccNoTotal * 10000, 1));

                    TempDimensionSetEntry.Reset();
                    TempDimensionSetEntry.DeleteAll();
                    TempDimensionBuffer.Reset();
                    TempDimensionBuffer.DeleteAll();

                    CalcFields("Balance at Date", "Balance at Date (LCY)");
                    AdjBase := "Balance at Date";
                    AdjBaseLCY := "Balance at Date (LCY)";
                    AdjAmount :=
                      Round(
                        CurrencyExchangeRate.ExchangeAmtFCYToLCYAdjmt(
                          PostingDate, Currency.Code, "Balance at Date", Currency."Currency Factor")) -
                      "Balance at Date (LCY)";

                    Clear(AdjDebit);
                    Clear(AdjCredit);

                    if AdjAmount <> 0 then begin
                        GenJournalLine.Validate("Posting Date", PostingDate);
                        GenJournalLine."Document No." := PostingDocNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                        GenJournalLine.Validate("Account No.", "No.");
                        if SummarizeEntries then
                            GenJournalLine.Description :=
                                CopyStr(StrSubstNo(PostingDescription, Currency.Code, AdjBase), 1, MaxStrLen(GenJournalLine.Description))
                        else
                            GenJournalLine.Description :=
                                CopyStr(StrSubstNo(PostingDescription, Currency.Code, AdjBase, '', ''), 1, MaxStrLen(GenJournalLine.Description));
                        GenJournalLine.Validate(Amount, 0);
                        GenJournalLine."Amount (LCY)" := AdjAmount;
                        GenJournalLine."Source Currency Code" := Currency.Code;
                        if Currency.Code = GeneralLedgerSetup."Additional Reporting Currency" then
                            GenJournalLine."Source Currency Amount" := 0;
                        GenJournalLine."Source Code" := SourceCodeSetup."Exchange Rate Adjmt.";
                        GenJournalLine."System-Created Entry" := true;
                        GetJnlLineDefDim(GenJournalLine, TempDimensionSetEntry);
                        CopyDimSetEntryToDimBuf(TempDimensionSetEntry, TempDimensionBuffer);
                        if Post then
                            PostGenJnlLine(GenJournalLine, TempDimensionSetEntry);
                        TempEntryNoAmountBuffer.Init();
                        TempEntryNoAmountBuffer."Business Unit Code" := '';
                        TempEntryNoAmountBuffer."Entry No." := TempEntryNoAmountBuffer."Entry No." + 1;
                        TempEntryNoAmountBuffer.Amount := AdjAmount;
                        TempEntryNoAmountBuffer.Amount2 := AdjBase;
                        TempEntryNoAmountBuffer.Insert();

                        if AdjAmount > 0 then begin
                            GainOrLoss := GainLbl;
                            AdjCredit := AdjAmount;
                        end else begin
                            GainOrLoss := LossLbl;
                            AdjDebit := -AdjAmount;
                        end;

                        Temp2DimensionBuffer.Init();
                        Temp2DimensionBuffer."Table ID" := TempEntryNoAmountBuffer."Entry No.";
                        Temp2DimensionBuffer."Entry No." := GetDimCombID(TempDimensionBuffer);
                        Temp2DimensionBuffer.Insert();
                        TotalAdjBase := TotalAdjBase + AdjBase;
                        TotalAdjBaseLCY := TotalAdjBaseLCY + AdjBaseLCY;
                        TotalAdjAmount := TotalAdjAmount + AdjAmount;
                        WindowDialog.Update(4, TotalAdjAmount);

                        if (TempEntryNoAmountBuffer.Amount <> 0) and Post then begin
                            TempDimensionSetEntry.Reset();
                            TempDimensionSetEntry.DeleteAll();
                            TempDimensionBuffer.Reset();
                            TempDimensionBuffer.DeleteAll();
                            Temp2DimensionBuffer.SetRange("Table ID", TempEntryNoAmountBuffer."Entry No.");
                            if Temp2DimensionBuffer.FindFirst() then
                                DimensionBufferManagement.GetDimensions(Temp2DimensionBuffer."Entry No.", TempDimensionBuffer);
                            DimensionManagement.CopyDimBufToDimSetEntry(TempDimensionBuffer, TempDimensionSetEntry);
                            OnAdjustBankAccountOnBeforePost(TempAdjExchangeRateBufferCZL2, "Bank Account");
                            if TempEntryNoAmountBuffer.Amount > 0 then begin
                                Currency.TestField("Realized Gains Acc.");
                                PostAdjmt(
                                  Currency."Realized Gains Acc.", -TempEntryNoAmountBuffer.Amount, TempEntryNoAmountBuffer.Amount2,
                                  "Currency Code", TempDimensionSetEntry, PostingDate, '');
                            end else begin
                                Currency.TestField("Realized Losses Acc.");
                                PostAdjmt(
                                  Currency."Realized Losses Acc.", -TempEntryNoAmountBuffer.Amount, TempEntryNoAmountBuffer.Amount2,
                                  "Currency Code", TempDimensionSetEntry, PostingDate, '');
                            end;
                        end;
                    end;
                    Temp2DimensionBuffer.DeleteAll();
                end;

                trigger OnPreDataItem()
                begin
                    if not AdjBank then
                        CurrReport.Break();
                    TableType := 1;

                    SetRange("Date Filter", StartDate, EndDate);
                    Temp2DimensionBuffer.DeleteAll();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                "Last Date Adjusted" := PostingDate;
                if Post then
                    Modify();

                "Currency Factor" :=
                  CurrencyExchangeRate.ExchangeRateAdjmt(PostingDate, Code);

                TempCurrency := Currency;
                TempCurrency.Insert();
            end;

            trigger OnPostDataItem()
            begin
                if (Code = '') and (AdjCust or AdjVend or AdjBank) then
                    Error(NoCurrenciesFoundErr);
            end;

            trigger OnPreDataItem()
            begin
                CheckPostingDate();
                if not (AdjCust or AdjVend or AdjBank or AdjEmpl) then
                    CurrReport.Break();

                WindowDialog.Open(
                  AdjExchangeRatesTxt +
                  BankAccountTxt +
                  CustomerTxt +
                  VendorTxt +
                  AdjustmentTxt +
                  EmployeeTxt);

                CustNoTotal := Customer.Count();
                VendNoTotal := Vendor.Count();
                EmplNoTotal := Employee.Count();
                CopyFilter(Code, "Bank Account"."Currency Code");
                FilterGroup(2);
                "Bank Account".SetFilter("Currency Code", '<>%1', '');
                FilterGroup(0);
                BankAccNoTotal := "Bank Account".Count();
                "Bank Account".Reset();
            end;
        }
        dataitem(Customer; Customer)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            dataitem(CustomerLedgerEntryLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(CLEDocumentType_Fld; CopyStr(Format(CustLedgerEntry."Document Type"), 1, 2))
                {
                }
                column(CLEDocumentNo_Fld; CustLedgerEntry."Document No.")
                {
                }
                column(CLEPostingDate_Fld; Format(CustLedgerEntry."Posting Date"))
                {
                }
                column(CLECurrencyCode_Fld; CustLedgerEntry."Currency Code")
                {
                }
                column(CLEOriginalCurrency_Fld; Round(1 / CustLedgerEntry."Adjusted Currency Factor", 0.001))
                {
                    DecimalPlaces = 3 : 3;
                }
                column(CLEModifiedAmt_Fld; Round(AdjustedFactor, 0.001))
                {
                    DecimalPlaces = 3 : 3;
                }
                column(CLERemainingAmt_Fld; CustLedgerEntry."Remaining Amount")
                {
                }
                column(CLERemainingAmtLCY_Fld; CustLedgerEntry."Remaining Amt. (LCY)")
                {
                }
                column(CLEModRemainingAmtLCY_Fld; CustLedgerEntry."Remaining Amt. (LCY)" + AdjAmount2)
                {
                }
                column(CLEGainLoss_Fld; GainOrLoss)
                {
                }
                column(CLEDebitAmount_Fld; AdjDebit)
                {
                }
                column(CLECreditAmount_Fld; AdjCredit)
                {
                }
                column(CLETableType_Var; TableType)
                {
                }
                dataitem("Detailed Cust. Ledg. Entry"; "Detailed Cust. Ledg. Entry")
                {
                    DataItemTableView = sorting("Cust. Ledger Entry No.", "Posting Date");

                    trigger OnAfterGetRecord()
                    begin
                        CalcCustRealGainLossAmount(CustLedgerEntry."Entry No.", "Posting Date");
                        AdjustCustomerLedgerEntry(CustLedgerEntry, "Posting Date");
                    end;

                    trigger OnPostDataItem()
                    begin
                        if not SummarizeEntries then
                            HandlePostAdjmt(1);
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetCurrentKey("Cust. Ledger Entry No.");
                        SetRange("Cust. Ledger Entry No.", CustLedgerEntry."Entry No.");
                        SetFilter("Posting Date", '%1..', CalcDate('<+1D>', PostingDate));

                        CreateCustRealGainLossEntries("Detailed Cust. Ledg. Entry");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    TempSumsDetailedCustLedgEntry.DeleteAll();

                    if FirstEntry then begin
                        TempCustLedgerEntry.FindSet();
                        FirstEntry := false
                    end else
                        if TempCustLedgerEntry.Next() = 0 then
                            CurrReport.Break();
                    CustLedgerEntry.Get(TempCustLedgerEntry."Entry No.");
                    if SkipAdvancePayments then
                        if CustLedgerEntry.RelatedToAdvanceLetterCZL() then
                            CurrReport.Skip();
                    AdjustCustomerLedgerEntry(CustLedgerEntry, PostingDate);

                    Clear(AdjDebit);
                    Clear(AdjCredit);
                    AdjAmount2 := AdjAmount;
                    if AdjAmount2 > 0 then begin
                        GainOrLoss := GainLbl;
                        AdjCredit := AdjAmount2;
                    end else begin
                        GainOrLoss := LossLbl;
                        AdjDebit := -AdjAmount2;
                    end;

                    CustLedgerEntry.SetRange("Date Filter", 0D, EndDateReq);
                    CustLedgerEntry.CalcFields(
                      Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)", "Original Amt. (LCY)",
                      "Debit Amount", "Credit Amount", "Debit Amount (LCY)", "Credit Amount (LCY)");
                end;

                trigger OnPreDataItem()
                begin
                    if TempCustLedgerEntry.IsEmpty() then
                        CurrReport.Break();
                    FirstEntry := true;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CustNo := CustNo + 1;
                WindowDialog.Update(2, Round(CustNo / CustNoTotal * 10000, 1));

                TempCustLedgerEntry.DeleteAll();

                Currency.CopyFilter(Code, CustLedgerEntry."Currency Code");
                CustLedgerEntry.FilterGroup(2);
                CustLedgerEntry.SetFilter("Currency Code", '<>%1', '');
                CustLedgerEntry.FilterGroup(0);

                DetailedCustLedgEntry.Reset();
                DetailedCustLedgEntry.SetCurrentKey("Customer No.", "Posting Date", "Entry Type");
                DetailedCustLedgEntry.SetRange("Customer No.", "No.");
                DetailedCustLedgEntry.SetRange("Posting Date", CalcDate('<+1D>', EndDate), DMY2Date(31, 12, 9999));
                if DetailedCustLedgEntry.FindSet() then
                    repeat
                        CustLedgerEntry."Entry No." := DetailedCustLedgEntry."Cust. Ledger Entry No.";
                        if CustLedgerEntry.Find('=') then
                            if (CustLedgerEntry."Posting Date" >= StartDate) and
                               (CustLedgerEntry."Posting Date" <= EndDate)
                            then begin
                                TempCustLedgerEntry."Entry No." := CustLedgerEntry."Entry No.";
                                if not TempCustLedgerEntry.Insert() then
                                    TempCustLedgerEntry.Init();
                            end;
                    until DetailedCustLedgEntry.Next() = 0;

                CustLedgerEntry.SetCurrentKey("Customer No.", Open);
                CustLedgerEntry.SetRange("Customer No.", "No.");
                CustLedgerEntry.SetRange(Open, true);
                CustLedgerEntry.SetRange("Posting Date", 0D, EndDate);
                if CustLedgerEntry.FindSet() then
                    repeat
                        TempCustLedgerEntry."Entry No." := CustLedgerEntry."Entry No.";
                        if not TempCustLedgerEntry.Insert() then
                            TempCustLedgerEntry.Init();
                    until CustLedgerEntry.Next() = 0;
                CustLedgerEntry.Reset();

                OnCustomerAfterGetRecordOnAfterFindCustLedgerEntriesToAdjust(TempCustLedgerEntry);
            end;

            trigger OnPostDataItem()
            begin
                if (CustNo <> 0) and Post then
                    if SummarizeEntries then
                        HandlePostAdjmt(1); // Customer
            end;

            trigger OnPreDataItem()
            begin
                if not AdjCust then
                    CurrReport.Break();

                DetailedCustLedgEntry.LockTable();
                CustLedgerEntry.LockTable();

                CustNo := 0;

                if DetailedCustLedgEntry.FindLast() then
                    NewEntryNo := DetailedCustLedgEntry."Entry No." + 1
                else
                    NewEntryNo := 1;

                Clear(DimensionManagement);
                TempEntryNoAmountBuffer.DeleteAll();
                TableType := 2;
            end;
        }
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            dataitem(VendorLedgerEntryLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(VLEDocumentType_Fld; CopyStr(Format(VendorLedgerEntry."Document Type"), 1, 2))
                {
                }
                column(VLEDocumentNo_Fld; VendorLedgerEntry."Document No.")
                {
                }
                column(VLEPostingDate_Fld; Format(VendorLedgerEntry."Posting Date"))
                {
                }
                column(VLECurrencyCode_Fld; VendorLedgerEntry."Currency Code")
                {
                }
                column(VLEOriginalCurrency_Fld; Round(1 / VendorLedgerEntry."Adjusted Currency Factor", 0.001))
                {
                    DecimalPlaces = 3 : 3;
                }
                column(VLEModifiedAmt_Fld; Round(AdjustedFactor, 0.001))
                {
                    DecimalPlaces = 3 : 3;
                }
                column(VLERemainingAmt_Fld; VendorLedgerEntry."Remaining Amount")
                {
                }
                column(VLERemainingAmtLCY_Fld; VendorLedgerEntry."Remaining Amt. (LCY)")
                {
                }
                column(VLEModRemainingAmtLCY_Fld; VendorLedgerEntry."Remaining Amt. (LCY)" + AdjAmount2)
                {
                }
                column(VLEGainLoss_Fld; GainOrLoss)
                {
                }
                column(VLEDebitAmount_Fld; AdjDebit)
                {
                }
                column(VLECreditAmount_Fld; AdjCredit)
                {
                }
                column(VLETableType_Var; TableType)
                {
                }
                dataitem("Detailed Vendor Ledg. Entry"; "Detailed Vendor Ledg. Entry")
                {
                    DataItemTableView = sorting("Vendor Ledger Entry No.", "Posting Date");

                    trigger OnAfterGetRecord()
                    begin
                        CalcVendRealGainLossAmount(VendorLedgerEntry."Entry No.", "Posting Date");

                        AdjustVendorLedgerEntry(VendorLedgerEntry, "Posting Date");
                    end;

                    trigger OnPostDataItem()
                    begin
                        if not SummarizeEntries then
                            HandlePostAdjmt(2);
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetCurrentKey("Vendor Ledger Entry No.");
                        SetRange("Vendor Ledger Entry No.", VendorLedgerEntry."Entry No.");
                        SetFilter("Posting Date", '%1..', CalcDate('<+1D>', PostingDate));

                        CreateVendRealGainLossEntries("Detailed Vendor Ledg. Entry");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    TempSumsDetailedVendorLedgEntry.DeleteAll();

                    if FirstEntry then begin
                        TempVendorLedgerEntry.FindSet();
                        FirstEntry := false
                    end else
                        if TempVendorLedgerEntry.Next() = 0 then
                            CurrReport.Break();
                    VendorLedgerEntry.Get(TempVendorLedgerEntry."Entry No.");
                    if SkipAdvancePayments then
                        if VendorLedgerEntry.RelatedToAdvanceLetterCZL() then
                            CurrReport.Skip();
                    AdjustVendorLedgerEntry(VendorLedgerEntry, PostingDate);

                    Clear(AdjDebit);
                    Clear(AdjCredit);
                    AdjAmount2 := AdjAmount;
                    if AdjAmount2 > 0 then begin
                        GainOrLoss := GainLbl;
                        AdjCredit := AdjAmount2;
                    end else begin
                        GainOrLoss := LossLbl;
                        AdjDebit := -AdjAmount2;
                    end;

                    VendorLedgerEntry.SetRange("Date Filter", 0D, EndDateReq);
                    VendorLedgerEntry.CalcFields(
                      Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)", "Original Amt. (LCY)",
                      "Debit Amount", "Credit Amount", "Debit Amount (LCY)", "Credit Amount (LCY)");
                end;

                trigger OnPreDataItem()
                begin
                    if TempVendorLedgerEntry.IsEmpty() then
                        CurrReport.Break();
                    FirstEntry := true;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                VendNo := VendNo + 1;
                WindowDialog.Update(3, Round(VendNo / VendNoTotal * 10000, 1));

                TempVendorLedgerEntry.DeleteAll();

                Currency.CopyFilter(Code, VendorLedgerEntry."Currency Code");
                VendorLedgerEntry.FilterGroup(2);
                VendorLedgerEntry.SetFilter("Currency Code", '<>%1', '');
                VendorLedgerEntry.FilterGroup(0);

                DetailedVendorLedgEntry.Reset();
                DetailedVendorLedgEntry.SetCurrentKey("Vendor No.", "Posting Date", "Entry Type");
                DetailedVendorLedgEntry.SetRange("Vendor No.", "No.");
                DetailedVendorLedgEntry.SetRange("Posting Date", CalcDate('<+1D>', EndDate), DMY2Date(31, 12, 9999));
                if DetailedVendorLedgEntry.FindSet() then
                    repeat
                        VendorLedgerEntry."Entry No." := DetailedVendorLedgEntry."Vendor Ledger Entry No.";
                        if VendorLedgerEntry.Find('=') then
                            if (VendorLedgerEntry."Posting Date" >= StartDate) and
                               (VendorLedgerEntry."Posting Date" <= EndDate)
                            then begin
                                TempVendorLedgerEntry."Entry No." := VendorLedgerEntry."Entry No.";
                                if not TempVendorLedgerEntry.Insert() then
                                    TempVendorLedgerEntry.Init();
                            end;
                    until DetailedVendorLedgEntry.Next() = 0;

                VendorLedgerEntry.SetCurrentKey("Vendor No.", Open);
                VendorLedgerEntry.SetRange("Vendor No.", "No.");
                VendorLedgerEntry.SetRange(Open, true);
                VendorLedgerEntry.SetRange("Posting Date", 0D, EndDate);
                if VendorLedgerEntry.FindSet() then
                    repeat
                        TempVendorLedgerEntry."Entry No." := VendorLedgerEntry."Entry No.";
                        if not TempVendorLedgerEntry.Insert() then
                            TempVendorLedgerEntry.Init();
                    until VendorLedgerEntry.Next() = 0;
                VendorLedgerEntry.Reset();

                OnVendorAfterGetRecordOnAfterFindVendLedgerEntriesToAdjust(TempVendorLedgerEntry);
            end;

            trigger OnPostDataItem()
            begin
                if (VendNo <> 0) and Post then
                    if SummarizeEntries then
                        HandlePostAdjmt(2); // Vendor
            end;

            trigger OnPreDataItem()
            begin
                if not AdjVend then
                    CurrReport.Break();

                DetailedVendorLedgEntry.LockTable();
                VendorLedgerEntry.LockTable();

                VendNo := 0;
                if DetailedVendorLedgEntry.Find('+') then
                    NewEntryNo := DetailedVendorLedgEntry."Entry No." + 1
                else
                    NewEntryNo := 1;

                Clear(DimensionManagement);
                TempEntryNoAmountBuffer.DeleteAll();
                TableType := 3;
            end;
        }
        dataitem(Employee; Employee)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            dataitem(EmployeeLedgerEntryLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(EMPLEDocumentType_Fld; CopyStr(Format(EmployeeLedgerEntry."Document Type"), 1, 2))
                {
                }
                column(EMPLEDocumentNo_Fld; EmployeeLedgerEntry."Document No.")
                {
                }
                column(EMPLEPostingDate_Fld; Format(EmployeeLedgerEntry."Posting Date"))
                {
                }
                column(EMPLECurrencyCode_Fld; EmployeeLedgerEntry."Currency Code")
                {
                }
                column(EMPLEOriginalCurrency_Fld; Round(1 / EmployeeLedgerEntry."Adjusted Currency Factor", 0.001))
                {
                    DecimalPlaces = 3 : 3;
                }
                column(EMPLEModifiedAmt_Fld; Round(AdjustedFactor, 0.001))
                {
                    DecimalPlaces = 3 : 3;
                }
                column(EMPLERemainingAmt_Fld; EmployeeLedgerEntry."Remaining Amount")
                {
                }
                column(EMPLERemainingAmtLCY_Fld; EmployeeLedgerEntry."Remaining Amt. (LCY)")
                {
                }
                column(EMPLEModRemainingAmtLCY_Fld; EmployeeLedgerEntry."Remaining Amt. (LCY)" + AdjAmount2)
                {
                }
                column(EMPLEGainLoss_Fld; GainOrLoss)
                {
                }
                column(EMPLEDebitAmount_Fld; AdjDebit)
                {
                }
                column(EMPLECreditAmount_Fld; AdjCredit)
                {
                }
                column(EMPLETableType_Var; TableType)
                {
                }
                dataitem("Detailed Employee Ledger Entry"; "Detailed Employee Ledger Entry")
                {
                    DataItemTableView = sorting("Employee Ledger Entry No.", "Posting Date");

                    trigger OnAfterGetRecord()
                    begin
                        CalcEmployeeRealGainLossAmount(EmployeeLedgerEntry."Entry No.", "Posting Date");
                        AdjustEmployeeLedgerEntry(EmployeeLedgerEntry, "Posting Date");
                    end;

                    trigger OnPostDataItem()
                    begin
                        if not SummarizeEntries then
                            HandlePostAdjmt(3);
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetCurrentKey("Employee Ledger Entry No.");
                        SetRange("Employee Ledger Entry No.", EmployeeLedgerEntry."Entry No.");
                        SetFilter("Posting Date", '%1..', CalcDate('<+1D>', PostingDate));

                        CreateEmployeeRealGainLossEntries("Detailed Employee Ledger Entry");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    TempSumsDetailedEmployeeLedgerEntry.DeleteAll();

                    if FirstEntry then begin
                        TempEmployeeLedgerEntry.Find('-');
                        FirstEntry := false
                    end else
                        if TempEmployeeLedgerEntry.Next() = 0 then
                            CurrReport.Break();
                    EmployeeLedgerEntry.Get(TempEmployeeLedgerEntry."Entry No.");

                    AdjustEmployeeLedgerEntry(EmployeeLedgerEntry, PostingDate);

                    Clear(AdjDebit);
                    Clear(AdjCredit);
                    AdjAmount2 := AdjAmount;
                    if AdjAmount2 > 0 then begin
                        GainOrLoss := GainLbl;
                        AdjCredit := AdjAmount2;
                    end else begin
                        GainOrLoss := LossLbl;
                        AdjDebit := -AdjAmount2;
                    end;

                    EmployeeLedgerEntry.SetRange("Date Filter", 0D, EndDateReq);
                    EmployeeLedgerEntry.CalcFields(
                      Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)", "Original Amt. (LCY)",
                      "Debit Amount", "Credit Amount", "Debit Amount (LCY)", "Credit Amount (LCY)");
                end;

                trigger OnPreDataItem()
                begin
                    if not TempEmployeeLedgerEntry.Find('-') then
                        CurrReport.Break();
                    FirstEntry := true;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                EmplNo := EmplNo + 1;
                WindowDialog.Update(5, Round(EmplNo / EmplNoTotal * 10000, 1));

                PrepareTempEmplLedgEntry(Employee, TempEmployeeLedgerEntry);

                OnEmployeeAfterGetRecordOnAfterFindEmplLedgerEntriesToAdjust(TempEmployeeLedgerEntry);
            end;

            trigger OnPostDataItem()
            begin
                if (EmplNo <> 0) and Post then
                    if SummarizeEntries then
                        HandlePostAdjmt(3); // Employee
            end;

            trigger OnPreDataItem()
            begin
                if not AdjEmpl then
                    CurrReport.Break();

                DetailedEmployeeLegerEntry.LockTable();
                EmployeeLedgerEntry.LockTable();

                VendNo := 0;
                if DetailedEmployeeLegerEntry.Find('+') then
                    NewEntryNo := DetailedEmployeeLegerEntry."Entry No." + 1
                else
                    NewEntryNo := 1;

                Clear(DimensionManagement);
                TempEntryNoAmountBuffer.DeleteAll();
                TableType := 4;
            end;
        }
        dataitem("VAT Posting Setup"; "VAT Posting Setup")
        {
            DataItemTableView = sorting("VAT Bus. Posting Group", "VAT Prod. Posting Group");

            trigger OnAfterGetRecord()
            begin
                VATEntryNo := VATEntryNo + 1;
                WindowDialog.Update(1, Round(VATEntryNo / VATEntryNoTotal * 10000, 1));

                VATEntry.SetRange("VAT Bus. Posting Group", "VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", "VAT Prod. Posting Group");

                if "VAT Calculation Type" <> "VAT Calculation Type"::"Sales Tax" then begin
                    AdjustVATEntries(VATEntry.Type::Purchase, false);
                    if (TwoVATEntry.Amount <> 0) or (TwoVATEntry."Additional-Currency Amount" <> 0) then begin
                        AdjustVATAccount(
                          GetPurchAccount(false),
                          TwoVATEntry.Amount, TwoVATEntry."Additional-Currency Amount",
                          TotalBaseVATEntry.Amount, TotalBaseVATEntry."Additional-Currency Amount");
                        if "VAT Calculation Type" = "VAT Calculation Type"::"Reverse Charge VAT" then
                            AdjustVATAccount(
                              GetRevChargeAccount(false),
                              -TwoVATEntry.Amount, -TwoVATEntry."Additional-Currency Amount",
                              -TotalBaseVATEntry.Amount, -TotalBaseVATEntry."Additional-Currency Amount");
                    end;
                    if (TwoVATEntry."Remaining Unrealized Amount" <> 0) or
                       (TwoVATEntry."Add.-Curr. Rem. Unreal. Amount" <> 0)
                    then begin
                        TestField("Unrealized VAT Type");
                        AdjustVATAccount(
                          GetPurchAccount(true),
                          TwoVATEntry."Remaining Unrealized Amount",
                          TwoVATEntry."Add.-Curr. Rem. Unreal. Amount",
                          TotalBaseVATEntry."Remaining Unrealized Amount",
                          TotalBaseVATEntry."Add.-Curr. Rem. Unreal. Amount");
                        if "VAT Calculation Type" = "VAT Calculation Type"::"Reverse Charge VAT" then
                            AdjustVATAccount(
                              GetRevChargeAccount(true),
                              -TwoVATEntry."Remaining Unrealized Amount",
                              -TwoVATEntry."Add.-Curr. Rem. Unreal. Amount",
                              -TotalBaseVATEntry."Remaining Unrealized Amount",
                              -TotalBaseVATEntry."Add.-Curr. Rem. Unreal. Amount");
                    end;

                    AdjustVATEntries(VATEntry.Type::Sale, false);
                    if (TwoVATEntry.Amount <> 0) or (TwoVATEntry."Additional-Currency Amount" <> 0) then
                        AdjustVATAccount(
                          GetSalesAccount(false),
                          TwoVATEntry.Amount, TwoVATEntry."Additional-Currency Amount",
                          TotalBaseVATEntry.Amount, TotalBaseVATEntry."Additional-Currency Amount");
                    if (TwoVATEntry."Remaining Unrealized Amount" <> 0) or
                       (TwoVATEntry."Add.-Curr. Rem. Unreal. Amount" <> 0)
                    then begin
                        TestField("Unrealized VAT Type");
                        AdjustVATAccount(
                          GetSalesAccount(true),
                          TwoVATEntry."Remaining Unrealized Amount",
                          TwoVATEntry."Add.-Curr. Rem. Unreal. Amount",
                          TotalBaseVATEntry."Remaining Unrealized Amount",
                          TotalBaseVATEntry."Add.-Curr. Rem. Unreal. Amount");
                    end;
                end else begin
                    if TaxJurisdiction.FindSet() then
                        repeat
                            VATEntry.SetRange("Tax Jurisdiction Code", TaxJurisdiction.Code);
                            AdjustVATEntries(VATEntry.Type::Purchase, false);
                            AdjustPurchTax(false);
                            AdjustVATEntries(VATEntry.Type::Purchase, true);
                            AdjustPurchTax(true);
                            AdjustVATEntries(VATEntry.Type::Sale, false);
                            AdjustSalesTax();
                        until TaxJurisdiction.Next() = 0;
                    VATEntry.SetRange("Tax Jurisdiction Code");
                end;
                Clear(TotalBaseVATEntry);
            end;

            trigger OnPreDataItem()
            begin
                if not Post then
                    CurrReport.Break();

                if not AdjGLAcc or
                   (GeneralLedgerSetup."VAT Exchange Rate Adjustment" = GeneralLedgerSetup."VAT Exchange Rate Adjustment"::"No Adjustment")
                then
                    CurrReport.Break();

                WindowDialog.Open(
                  AdjVATEntriesTxt +
                  VATEntryTxt);

                VATEntryNoTotal := VATEntry.Count();
                if not
                   VATEntry.SetCurrentKey(
                     Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Posting Date")
                then
                    VATEntry.SetCurrentKey(
                      Type, Closed, "Tax Jurisdiction Code", "Use Tax", "Posting Date");
                VATEntry.SetRange(Closed, false);
                VATEntry.SetRange("Posting Date", StartDate, EndDate);
            end;
        }
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = sorting("No.") where("Exchange Rate Adjustment" = filter("Adjust Amount" .. "Adjust Additional-Currency Amount"));

            trigger OnAfterGetRecord()
            begin
                GLAccNo := GLAccNo + 1;
                WindowDialog.Update(1, Round(GLAccNo / GLAccNoTotal * 10000, 1));
                if "Exchange Rate Adjustment" = "Exchange Rate Adjustment"::"No Adjustment" then
                    CurrReport.Skip();

                TempDimensionSetEntry.Reset();
                TempDimensionSetEntry.DeleteAll();
                CalcFields("Net Change", "Additional-Currency Net Change");
                case "Exchange Rate Adjustment" of
                    "Exchange Rate Adjustment"::"Adjust Amount":
                        PostGLAccAdjmt(
                          "No.", "Exchange Rate Adjustment"::"Adjust Amount",
                          Round(
                            TwoCurrencyExchangeRate.ExchangeAmtFCYToLCYAdjmt(
                              PostingDate, GeneralLedgerSetup."Additional Reporting Currency",
                              "Additional-Currency Net Change", AddCurrCurrencyFactor) -
                            "Net Change"),
                          "Net Change",
                          "Additional-Currency Net Change");
                    "Exchange Rate Adjustment"::"Adjust Additional-Currency Amount":
                        PostGLAccAdjmt(
                          "No.", "Exchange Rate Adjustment"::"Adjust Additional-Currency Amount",
                          Round(
                            TwoCurrencyExchangeRate.ExchangeAmtLCYToFCY(
                              PostingDate, GeneralLedgerSetup."Additional Reporting Currency",
                              "Net Change", AddCurrCurrencyFactor) -
                            "Additional-Currency Net Change",
                            TwoCurrency."Amount Rounding Precision"),
                          "Net Change",
                          "Additional-Currency Net Change");
                end;
            end;

            trigger OnPostDataItem()
            begin
                if AdjGLAcc then begin
                    GenJournalLine."Document No." := PostingDocNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Posting Date" := PostingDate;
                    GenJournalLine."Source Code" := SourceCodeSetup."Exchange Rate Adjmt.";

                    if GLAmtTotal <> 0 then begin
                        if GLAmtTotal < 0 then
                            GenJournalLine."Account No." := TwoCurrency."Realized G/L Losses Account"
                        else
                            GenJournalLine."Account No." := TwoCurrency."Realized G/L Gains Account";
                        GenJournalLine.Description :=
                          StrSubstNo(
                            PostingDescription,
                            GeneralLedgerSetup."Additional Reporting Currency",
                            GLAddCurrNetChangeTotal);
                        GenJournalLine."Additional-Currency Posting" := GenJournalLine."Additional-Currency Posting"::"Amount Only";
                        GenJournalLine."Currency Code" := '';
                        GenJournalLine.Amount := -GLAmtTotal;
                        GenJournalLine."Amount (LCY)" := -GLAmtTotal;
                        GetJnlLineDefDim(GenJournalLine, TempDimensionSetEntry);
                        PostGenJnlLine(GenJournalLine, TempDimensionSetEntry);
                    end;
                    if GLAddCurrAmtTotal <> 0 then begin
                        if GLAddCurrAmtTotal < 0 then
                            GenJournalLine."Account No." := TwoCurrency."Realized G/L Losses Account"
                        else
                            GenJournalLine."Account No." := TwoCurrency."Realized G/L Gains Account";
                        GenJournalLine.Description :=
                          StrSubstNo(
                            PostingDescription, '',
                            GLNetChangeTotal);
                        GenJournalLine."Additional-Currency Posting" := GenJournalLine."Additional-Currency Posting"::"Additional-Currency Amount Only";
                        GenJournalLine."Currency Code" := GeneralLedgerSetup."Additional Reporting Currency";
                        GenJournalLine.Amount := -GLAddCurrAmtTotal;
                        GenJournalLine."Amount (LCY)" := 0;
                        GetJnlLineDefDim(GenJournalLine, TempDimensionSetEntry);
                        PostGenJnlLine(GenJournalLine, TempDimensionSetEntry);
                    end;

                    ExchRateAdjmtReg."No." := ExchRateAdjmtReg."No." + 1;
                    ExchRateAdjmtReg."Creation Date" := PostingDate;
                    ExchRateAdjmtReg."Account Type" := ExchRateAdjmtReg."Account Type"::"G/L Account";
                    ExchRateAdjmtReg."Posting Group" := '';
                    ExchRateAdjmtReg."Currency Code" := GeneralLedgerSetup."Additional Reporting Currency";
                    ExchRateAdjmtReg."Currency Factor" := TwoCurrencyExchangeRate."Adjustment Exch. Rate Amount";
                    ExchRateAdjmtReg."Adjusted Base" := 0;
                    ExchRateAdjmtReg."Adjusted Base (LCY)" := GLNetChangeBase;
                    ExchRateAdjmtReg."Adjusted Amt. (LCY)" := GLAmtTotal;
                    ExchRateAdjmtReg."Adjusted Base (Add.-Curr.)" := GLAddCurrNetChangeBase;
                    ExchRateAdjmtReg."Adjusted Amt. (Add.-Curr.)" := GLAddCurrAmtTotal;
                    ExchRateAdjmtReg.Insert();

                    TotalGLAccountsAdjusted += 1;
                end;
            end;

            trigger OnPreDataItem()
            begin
                if not Post then
                    CurrReport.Break();

                if not AdjGLAcc then
                    CurrReport.Break();

                WindowDialog.Open(
                  AdjGeneralLedgerTxt +
                  GLAccountTxt);

                GLAccNoTotal := Count;
                SetRange("Date Filter", StartDate, EndDate);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    group("Adjustment Period")
                    {
                        Caption = 'Adjustment Period';
                        field(StartingDate; StartDate)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Starting Date';
                            ToolTip = 'Specifies the beginning of the period for which entries are adjusted. This field is usually left blank, but you can enter a date.';
                        }
                        field(EndingDate; EndDateReq)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Ending Date';
                            ToolTip = 'Specifies the last date for which entries are adjusted. This date is usually the same as the posting date in the Posting Date field.';

                            trigger OnValidate()
                            begin
                                PostingDate := EndDateReq;
                            end;
                        }
                    }
                    field(PostingDescriptionField; PostingDescription)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Description';
                        ToolTip = 'Specifies text for the general ledger entries that are created by the batch job. The default text is Exchange Rate Adjmt. of %1 %2, in which %1 is replaced by the currency code and %2 is replaced by the currency amount that is adjusted. For example, Exchange Rate Adjmt. of DEM 38,000.';
                    }
                    field(PostingDateField; PostingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the date on which the general ledger entries are posted. This date is usually the same as the ending date in the Ending Date field.';

                        trigger OnValidate()
                        begin
                            CheckPostingDate();
                        end;
                    }
                    field(DocumentNo; PostingDocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the document number that will appear on the general ledger entries that are created by the batch job.';
                    }
                    field(AdjCustField; AdjCust)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Adjust Customer';
                        ToolTip = 'Specifies if customer''s entries have to be adjusted.';
                    }
                    field(AdjVendField; AdjVend)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Adjust Vendor';
                        ToolTip = 'Specifies if vendor''s entries have to be adjusted.';
                    }
                    field(AdjEmplAcc; AdjEmpl)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Adjust Employees';
                        ToolTip = 'Specifies if employee''s entries have to be adjusted.';
                    }
                    field(AdjBankField; AdjBank)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Adjust Bank Accounts and Cash Desks';
                        ToolTip = 'Specifies if bank accounts and cash desks has to be adjusted.';
                    }
                    field(AdjGLAccField; AdjGLAcc)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Adjust G/L Accounts for Add.-Reporting Currency';
                        MultiLine = true;
                        ToolTip = 'Specifies if you want to post in an additional reporting currency and adjust general ledger accounts for currency fluctuations between LCY and the additional reporting currency.';
                    }
                    field(SkipAdvancePaymentsField; SkipAdvancePayments)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Skip Advance Payments';
                        ToolTip = 'Specifies if you want to skip Advance Payments';
                    }
                    field(PostField; Post)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Post';
                        ToolTip = 'Specifies post run. The Entries will be posted.';
                    }
                    field(SummarizeEntriesField; SummarizeEntries)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sumarize Entries';
                        ToolTip = 'Specifies if the entries will be summarized';

                        trigger OnValidate()
                        begin
                            if not SummarizeEntries then
                                PostingDescription := ExchangeRateAdjmtTxt
                            else
                                PostingDescription := ExchRateAdjTxt;
                        end;
                    }
                    group(Dimension)
                    {
                        Caption = 'Dimension';
                        field(DimMoveTypeField; DimMoveType)
                        {
                            ApplicationArea = Dimensions;
                            Caption = 'Dimension Move';
                            OptionCaption = 'No move,Source Entry,By G/L Account';
                            ToolTip = 'Specifies dimension move into new entries - no move, move for source entry or move by G/L account.';
                        }
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            OnBeforeOpenPage(AdjCust, AdjVend, AdjBank, AdjGLAcc, PostingDocNo, AdjEmpl);

            if PostingDescription = '' then begin
                PostingDescription := ExchRateAdjTxt;
                if not SummarizeEntries then
                    PostingDescription := ExchangeRateAdjmtTxt;
            end;
        end;

        trigger OnClosePage()
        begin
            OnCloseRequestPage();
        end;
    }

    labels
    {
        ReportCaption = 'Adjust Exchange Rates';
        DateCaption = 'To date';
        PageCaption = 'Page';
        PostCaption = 'Post';
        TotalCaption = 'Total';
        BankAccNoCaption = 'No';
        BankAccNameCaption = 'Name';
        BankAccCurrencyCodeCaption = 'Currency Code';
        BankAccFactorCaption = 'Factor';
        BankAccBalToDateCaption = 'Balance to Date';
        BankAccBalToDateLCYCaption = 'Balance to Date (LCY)';
        BankAccModBaltoDateLCYCaption = 'Mod. Bal. to Date (LCY)';
        GainLossCaption = 'Gain / Loss';
        ModAmountDebitCaption = 'Mod. Debit Amount (LCY)';
        ModAmountCreditCaption = 'Mod. Credit Amount (LCY)';
        DocumentTypeCaption = 'Type';
        DocumentNoCaption = 'Document No';
        PostingDateCaption = 'Post. Date';
        CurrencyCodeCaption = 'Currency Code';
        OriginalCurrencyCaption = 'Original Factor';
        ModifiedAmtCaption = 'Modified Factor';
        RemainingAmtCaption = 'Remaining Amount';
        RemainingAmtLCYCaption = 'Remaining Amount (LCY)';
        ModRemainingAmtLCYCaption = 'Mod. Remaining Amount (LCY)';
        BankAccountTableCaption = 'Bank Account and Cash Desk';
        CustLdgEntryTableCaption = 'Customer Ledger Entry';
        VendLdgEntryTableCaption = 'Vendor Ledger Entry';
        EmployeeLdgEntryTableCaption = 'Employee Ledger Entry';
    }

    trigger OnInitReport()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOnInitReport(IsHandled);
        if IsHandled then
            exit;
    end;

    trigger OnPostReport()
    begin
        UpdateAnalysisView.UpdateAll(0, true);

        if Post then
            if TotalCustomersAdjusted + TotalVendorsAdjusted + TotalBankAccountsAdjusted + TotalGLAccountsAdjusted + TotalEmployeesAdjusted < 1 then
                Message(NothingToAdjustMsg)
            else
                Message(RatesAdjustedMsg);
    end;

    trigger OnPreReport()
    begin
        if EndDateReq = 0D then
            EndDate := DMY2Date(31, 12, 9999)
        else
            EndDate := EndDateReq;
        if PostingDocNo = '' then
            Error(DocNoFieldCaptionErr, GenJournalLine.FieldCaption("Document No."));
        if (not AdjCust) and (not AdjVend) and (not AdjBank) and (not AdjEmpl) and AdjGLAcc then
            if not Confirm(AdjGenLedgEntriesQst + ContinueQst, false) then
                Error(AdjExchangeRatesErr);

        SourceCodeSetup.Get();

        if ExchRateAdjmtReg.FindLast() then
            ExchRateAdjmtReg.Init();

        GeneralLedgerSetup.Get();

        if AdjGLAcc then begin
            GeneralLedgerSetup.TestField("Additional Reporting Currency");

            TwoCurrency.Get(GeneralLedgerSetup."Additional Reporting Currency");
            "G/L Account".Get(TwoCurrency.GetRealizedGLGainsAccount());
            "G/L Account".TestField("Exchange Rate Adjustment", "G/L Account"."Exchange Rate Adjustment"::"No Adjustment");

            "G/L Account".Get(TwoCurrency.GetRealizedGLLossesAccount());
            "G/L Account".TestField("Exchange Rate Adjustment", "G/L Account"."Exchange Rate Adjustment"::"No Adjustment");

            if TwoVATPostingSetup.FindSet() then
                repeat
                    if TwoVATPostingSetup."VAT Calculation Type" <> TwoVATPostingSetup."VAT Calculation Type"::"Sales Tax" then begin
                        CheckExchRateAdjustment(
                            TwoVATPostingSetup."Purchase VAT Account", TwoVATPostingSetup.TableCaption, TwoVATPostingSetup.FieldCaption("Purchase VAT Account"));
                        CheckExchRateAdjustment(
                            TwoVATPostingSetup."Reverse Chrg. VAT Acc.", TwoVATPostingSetup.TableCaption, TwoVATPostingSetup.FieldCaption("Reverse Chrg. VAT Acc."));
                        CheckExchRateAdjustment(
                            TwoVATPostingSetup."Purch. VAT Unreal. Account", TwoVATPostingSetup.TableCaption, TwoVATPostingSetup.FieldCaption("Purch. VAT Unreal. Account"));
                        CheckExchRateAdjustment(
                            TwoVATPostingSetup."Reverse Chrg. VAT Unreal. Acc.", TwoVATPostingSetup.TableCaption, TwoVATPostingSetup.FieldCaption("Reverse Chrg. VAT Unreal. Acc."));
                        CheckExchRateAdjustment(
                            TwoVATPostingSetup."Sales VAT Account", TwoVATPostingSetup.TableCaption, TwoVATPostingSetup.FieldCaption("Sales VAT Account"));
                        CheckExchRateAdjustment(
                            TwoVATPostingSetup."Sales VAT Unreal. Account", TwoVATPostingSetup.TableCaption, TwoVATPostingSetup.FieldCaption("Sales VAT Unreal. Account"));
                    end;
                until TwoVATPostingSetup.Next() = 0;

            if TwoTaxJurisdiction.FindSet() then
                repeat
                    CheckExchRateAdjustment(
                      TwoTaxJurisdiction."Tax Account (Purchases)", TwoTaxJurisdiction.TableCaption, TwoTaxJurisdiction.FieldCaption("Tax Account (Purchases)"));
                    CheckExchRateAdjustment(
                      TwoTaxJurisdiction."Reverse Charge (Purchases)", TwoTaxJurisdiction.TableCaption, TwoTaxJurisdiction.FieldCaption("Reverse Charge (Purchases)"));
                    CheckExchRateAdjustment(
                      TwoTaxJurisdiction."Unreal. Tax Acc. (Purchases)", TwoTaxJurisdiction.TableCaption, TwoTaxJurisdiction.FieldCaption("Unreal. Tax Acc. (Purchases)"));
                    CheckExchRateAdjustment(
                      TwoTaxJurisdiction."Unreal. Rev. Charge (Purch.)", TwoTaxJurisdiction.TableCaption, TwoTaxJurisdiction.FieldCaption("Unreal. Rev. Charge (Purch.)"));
                    CheckExchRateAdjustment(
                      TwoTaxJurisdiction."Tax Account (Sales)", TwoTaxJurisdiction.TableCaption, TwoTaxJurisdiction.FieldCaption("Tax Account (Sales)"));
                    CheckExchRateAdjustment(
                      TwoTaxJurisdiction."Unreal. Tax Acc. (Sales)", TwoTaxJurisdiction.TableCaption, TwoTaxJurisdiction.FieldCaption("Unreal. Tax Acc. (Sales)"));
                until TwoTaxJurisdiction.Next() = 0;

            AddCurrCurrencyFactor :=
              TwoCurrencyExchangeRate.ExchangeRateAdjmt(PostingDate, GeneralLedgerSetup."Additional Reporting Currency");
        end;

        BankAccFilters := "Bank Account".GetFilters;
        CustFilters := Customer.GetFilters;
        VendFilters := Vendor.GetFilters;
        EmployeeFilters := Employee.GetFilters;
    end;

    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        TempDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry" temporary;
        TempSumsDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry" temporary;
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        TempDetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry" temporary;
        TempSumsDetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry" temporary;
        TempSumsDetailedEmployeeLedgerEntry: Record "Detailed Employee Ledger Entry" temporary;
        TempDetailedEmployeeLedgerEntry: Record "Detailed Employee Ledger Entry" temporary;
        DetailedEmployeeLegerEntry: Record "Detailed Employee Ledger Entry";
        ExchRateAdjmtReg: Record "Exch. Rate Adjmt. Reg.";
        CustomerPostingGroup: Record "Customer Posting Group";
        VendorPostingGroup: Record "Vendor Posting Group";
        GenJournalLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        TempAdjExchangeRateBufferCZL: Record "Adj. Exchange Rate Buffer CZL" temporary;
        TempAdjExchangeRateBufferCZL2: Record "Adj. Exchange Rate Buffer CZL" temporary;
        TempCurrency: Record Currency temporary;
        TwoCurrency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        TwoCurrencyExchangeRate: Record "Currency Exchange Rate";
        GeneralLedgerSetup: Record "General Ledger Setup";
        VATEntry: Record "VAT Entry";
        TwoVATEntry: Record "VAT Entry";
        TotalBaseVATEntry: Record "VAT Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TwoVATPostingSetup: Record "VAT Posting Setup";
        TwoTaxJurisdiction: Record "Tax Jurisdiction";
        TempDimensionBuffer: Record "Dimension Buffer" temporary;
        Temp2DimensionBuffer: Record "Dimension Buffer" temporary;
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        TempEntryNoAmountBuffer: Record "Entry No. Amount Buffer" temporary;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        TempCustLedgerEntry: Record "Cust. Ledger Entry" temporary;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
        TwoDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        TwoDetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        Temp2DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry" temporary;
        Temp2DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry" temporary;
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
        TempEmployeeLedgerEntry: Record "Employee Ledger Entry" temporary;
        Temp2DetailedEmployeeLedgerEntry: Record "Detailed Employee Ledger Entry" temporary;
        TwoDetailedEmployeeLedgerEntry: Record "Detailed Employee Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        UpdateAnalysisView: Codeunit "Update Analysis View";
        DimensionManagement: Codeunit DimensionManagement;
        DimensionBufferManagement: Codeunit "Dimension Buffer Management";
        WindowDialog: Dialog;
        TotalAdjBase: Decimal;
        TotalAdjBaseLCY: Decimal;
        TotalAdjAmount: Decimal;
        GainsAmount: Decimal;
        LossesAmount: Decimal;
        AdjBase: Decimal;
        AdjBaseLCY: Decimal;
        AdjAmount: Decimal;
        AdjAmount2: Decimal;
        CustNo: Decimal;
        CustNoTotal: Decimal;
        VendNo: Decimal;
        VendNoTotal: Decimal;
        EmplNo: Decimal;
        EmplNoTotal: Decimal;
        BankAccNo: Decimal;
        BankAccNoTotal: Decimal;
        GLAccNo: Decimal;
        GLAccNoTotal: Decimal;
        GLAmtTotal: Decimal;
        GLAddCurrAmtTotal: Decimal;
        GLNetChangeTotal: Decimal;
        GLAddCurrNetChangeTotal: Decimal;
        GLNetChangeBase: Decimal;
        GLAddCurrNetChangeBase: Decimal;
        EndDate: Date;
        Correction: Boolean;
        HideUI: Boolean;
        OK: Boolean;
        AddCurrCurrencyFactor: Decimal;
        VATEntryNoTotal: Decimal;
        VATEntryNo: Decimal;
        NewEntryNo: Integer;
        FirstEntry: Boolean;
        MaxAdjExchRateBufIndex: Integer;
        RatesAdjustedMsg: Label 'One or more currency exchange rates have been adjusted.';
        NothingToAdjustMsg: Label 'There is nothing to adjust.';
        TotalBankAccountsAdjusted: Integer;
        TotalCustomersAdjusted: Integer;
        TotalVendorsAdjusted: Integer;
        TotalGLAccountsAdjusted: Integer;
        TotalEmployeesAdjusted: Integer;
        GainOrLoss: Text[30];
        AdjDebit: Decimal;
        AdjCredit: Decimal;
        AdjustedFactor: Decimal;
        RealGainLossAmt: Decimal;
        TableType: Integer;
        BankAccFilters: Text;
        CustFilters: Text;
        VendFilters: Text;
        EmployeeFilters: Text;
        ExchangeRateAdjmtTxt: Label 'Exchange Rate Adjmt. of %1 %2 %3 %4', Comment = '%1 = currency code, %2 = currency amount, %3 = Document Type, %4 = Document No.';
        ExchRateAdjTxt: Label 'Exch. Rate Adj. of %1 %2', Comment = '%1 = currency code, %2 = currency amount';
        GainLbl: Label 'Gain';
        LossLbl: Label 'Loss';
        DocNoFieldCaptionErr: Label '%1 must be entered.', Comment = '%1 = FieldCaption "Document No."';
        AdjGenLedgEntriesQst: Label 'Do you want to adjust general ledger entries for currency fluctuations without adjusting customer, vendor, employee and bank ledger entries? This may result in incorrect currency adjustments to payables, receivables and bank accounts.\\ ';
        ContinueQst: Label 'Do you wish to continue?';
        AdjExchangeRatesErr: Label 'The adjustment of exchange rates has been canceled.';
        AdjExchangeRatesTxt: Label 'Adjusting exchange rates...\\';
        BankAccountTxt: Label 'Bank Account    @1@@@@@@@@@@@@@\\';
        CustomerTxt: Label 'Customer        @2@@@@@@@@@@@@@\';
        VendorTxt: Label 'Vendor          @3@@@@@@@@@@@@@\';
        EmployeeTxt: Label 'Employee          @5@@@@@@@@@@@@@\';
        AdjustmentTxt: Label 'Adjustment      #4#############', Comment = '%1 = TotalAdjAmount';
        NoCurrenciesFoundErr: Label 'No currencies have been found.';
        AdjVATEntriesTxt: Label 'Adjusting VAT Entries...\\';
        VATEntryTxt: Label 'VAT Entry    @1@@@@@@@@@@@@@';
        AdjGeneralLedgerTxt: Label 'Adjusting general ledger...\\';
        GLAccountTxt: Label 'G/L Account    @1@@@@@@@@@@@@@';
        ExchangeRateAdjustmentErr: Label '%1 on %2 %3 must be %4. When this %2 is used in %5, the exchange rate adjustment is defined in the %6 field in the %7. %2 %3 is used in the %8 field in the %5. ', Comment = '%1 = "Exchange Rate Adjustment", %2 = GLAccount.TableCaption, %3 = GLAccount."No.", %4 = GLAccount."Exchange Rate Adjustment", %5 = SetupTableName, %6 = GeneralLedgerSetup.FieldCaption("VAT Exchange Rate Adjustment"), %7 = GeneralLedgerSetup.TableCaption, %8 = SetupFieldName';
        PostingDateEnteredErr: Label 'This posting date cannot be entered because it does not occur within the adjustment period. Reenter the posting date.';

    protected var
        StartDate: Date;
        EndDateReq: Date;
        PostingDate: Date;
        PostingDescription: Text[100];
        PostingDocNo: Code[20];
        AdjCust: Boolean;
        AdjVend: Boolean;
        AdjEmpl: Boolean;
        AdjBank: Boolean;
        AdjGLAcc: Boolean;
        SkipAdvancePayments: Boolean;
        Post: Boolean;
        SummarizeEntries: Boolean;
        DimMoveType: Option "No move","Source Entry","By G/L Account";

    local procedure PostAdjmt(PostGLAccNo: Code[20]; PostingAmount: Decimal; AdjBase2: Decimal; CurrencyCode2: Code[10]; var DimensionSetEntry: Record "Dimension Set Entry"; PostingDate2: Date; ICCode: Code[20]) TransactionNo: Integer
    begin
        if PostingAmount <> 0 then begin
            GenJournalLine.Init();
            GenJournalLine.Validate("Posting Date", PostingDate2);
            GenJournalLine."Document No." := PostingDocNo;
            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
            GenJournalLine.Validate("Account No.", PostGLAccNo);
            GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::" ";
            GenJournalLine."Gen. Bus. Posting Group" := '';
            GenJournalLine."Gen. Prod. Posting Group" := '';
            GenJournalLine."VAT Bus. Posting Group" := '';
            GenJournalLine."VAT Prod. Posting Group" := '';

            if SummarizeEntries then
                GenJournalLine.Description := CopyStr(StrSubstNo(PostingDescription, CurrencyCode2, AdjBase2), 1, MaxStrLen(GenJournalLine.Description))
            else
                GenJournalLine.Description := CopyStr(StrSubstNo(PostingDescription, CurrencyCode2, AdjBase2,
                      TempAdjExchangeRateBufferCZL2."Document Type", TempAdjExchangeRateBufferCZL2."Document No."), 1, MaxStrLen(GenJournalLine.Description));

            GenJournalLine.Validate(Amount, PostingAmount);
            GenJournalLine."Source Currency Code" := CurrencyCode2;
            GenJournalLine."IC Partner Code" := ICCode;
            if CurrencyCode2 = GeneralLedgerSetup."Additional Reporting Currency" then
                GenJournalLine."Source Currency Amount" := 0;
            GenJournalLine."Source Code" := SourceCodeSetup."Exchange Rate Adjmt.";
            GenJournalLine."System-Created Entry" := true;
            OnPostAdjmtOnBeforePostGenJnlLine(GenJournalLine, SummarizeEntries, TempAdjExchangeRateBufferCZL2);
            TransactionNo := PostGenJnlLine(GenJournalLine, DimensionSetEntry);
        end;
    end;

    local procedure InsertExchRateAdjmtReg(ExchRateAdjmtAccountType: Enum "Exch. Rate Adjmt. Account Type"; PostingGrCode: Code[20]; CurrencyCode: Code[10])
    begin
        if not Post then
            exit;

        if TempCurrency.Code <> CurrencyCode then
            TempCurrency.Get(CurrencyCode);

        ExchRateAdjmtReg."No." := ExchRateAdjmtReg."No." + 1;
        ExchRateAdjmtReg."Creation Date" := PostingDate;
        ExchRateAdjmtReg."Account Type" := ExchRateAdjmtAccountType;
        ExchRateAdjmtReg."Posting Group" := PostingGrCode;
        ExchRateAdjmtReg."Currency Code" := TempCurrency.Code;
        ExchRateAdjmtReg."Currency Factor" := TempCurrency."Currency Factor";
        ExchRateAdjmtReg."Adjusted Base" := TempAdjExchangeRateBufferCZL.AdjBase;
        ExchRateAdjmtReg."Adjusted Base (LCY)" := TempAdjExchangeRateBufferCZL.AdjBaseLCY;
        ExchRateAdjmtReg."Adjusted Amt. (LCY)" := TempAdjExchangeRateBufferCZL.AdjAmount;
        ExchRateAdjmtReg.Insert();
    end;

    procedure InitializeRequest(NewStartDate: Date; NewEndDate: Date; NewPostingDescription: Text[100]; NewPostingDate: Date)
    begin
        StartDate := NewStartDate;
        EndDate := NewEndDate;
        PostingDescription := NewPostingDescription;
        PostingDate := NewPostingDate;
        if EndDate = 0D then
            EndDateReq := DMY2Date(31, 12, 9999)
        else
            EndDateReq := EndDate;
    end;

    procedure InitializeRequest2(NewStartDate: Date; NewEndDate: Date; NewPostingDescription: Text[100]; NewPostingDate: Date; NewPostingDocNo: Code[20]; NewAdjCustVendBank: Boolean; NewAdjGLAcc: Boolean)
    begin
        InitializeRequest2(NewStartDate, NewEndDate, NewPostingDescription, NewPostingDate, NewPostingDocNo, NewAdjCustVendBank, NewAdjGLAcc, false);
    end;

    procedure InitializeRequest2(NewStartDate: Date; NewEndDate: Date; NewPostingDescription: Text[100]; NewPostingDate: Date; NewPostingDocNo: Code[20]; NewAdjCustVendBank: Boolean; NewAdjGLAcc: Boolean; NewAdjEmpl: Boolean)
    begin
        InitializeRequest(NewStartDate, NewEndDate, NewPostingDescription, NewPostingDate);
        PostingDocNo := NewPostingDocNo;
        AdjBank := NewAdjCustVendBank;
        AdjCust := NewAdjCustVendBank;
        AdjVend := NewAdjCustVendBank;
        AdjGLAcc := NewAdjGLAcc;
        AdjEmpl := NewAdjEmpl;
    end;

    local procedure AdjExchRateBufferUpdate(CurrencyCode2: Code[10]; PostingGroup2: Code[20]; AdjBase2: Decimal; AdjBaseLCY2: Decimal; AdjExchAmount2: Decimal; GainsAmount2: Decimal; LossesAmount2: Decimal; DimEntryNo: Integer; Postingdate2: Date; ICCode: Code[20]; Advance: Boolean; InitialGLAccNo: Code[20]): Integer
    begin
        TempAdjExchangeRateBufferCZL.Init();

        OK := TempAdjExchangeRateBufferCZL.Get(CurrencyCode2, PostingGroup2, DimEntryNo, Postingdate2, ICCode, Advance, InitialGLAccNo);

        TempAdjExchangeRateBufferCZL.AdjBase := TempAdjExchangeRateBufferCZL.AdjBase + AdjBase2;
        TempAdjExchangeRateBufferCZL.AdjBaseLCY := TempAdjExchangeRateBufferCZL.AdjBaseLCY + AdjBaseLCY2;
        TempAdjExchangeRateBufferCZL.AdjAmount := TempAdjExchangeRateBufferCZL.AdjAmount + AdjExchAmount2;
        TempAdjExchangeRateBufferCZL.TotalGainsAmount := TempAdjExchangeRateBufferCZL.TotalGainsAmount + GainsAmount2;
        TempAdjExchangeRateBufferCZL.TotalLossesAmount := TempAdjExchangeRateBufferCZL.TotalLossesAmount + LossesAmount2;

        if not OK then begin
            TempAdjExchangeRateBufferCZL."Currency Code" := CurrencyCode2;
            TempAdjExchangeRateBufferCZL."Posting Group" := PostingGroup2;
            TempAdjExchangeRateBufferCZL."Dimension Entry No." := DimEntryNo;
            TempAdjExchangeRateBufferCZL."Posting Date" := Postingdate2;
            TempAdjExchangeRateBufferCZL."IC Partner Code" := ICCode;
            MaxAdjExchRateBufIndex += 1;
            TempAdjExchangeRateBufferCZL.Index := MaxAdjExchRateBufIndex;
            TempAdjExchangeRateBufferCZL."Initial G/L Account No." := InitialGLAccNo;
            TempAdjExchangeRateBufferCZL.Insert();
        end else
            TempAdjExchangeRateBufferCZL.Modify();

        exit(TempAdjExchangeRateBufferCZL.Index);
    end;

    local procedure AdjExchRateBufferUpdateUnrealGain(CurrencyCode2: Code[10]; PostingGroup2: Code[20]; AdjBase2: Decimal; AdjBaseLCY2: Decimal; AdjExchAmount2: Decimal; DimEntryNo: Integer; Postingdate2: Date; ICCode: Code[20]; Advance: Boolean; InitialGLAccNo: Code[20]): Integer
    var
        AdjExchRateBufIndex: Integer;
    begin
        AdjExchRateBufferUpdate(
          CurrencyCode2, PostingGroup2, AdjBase2, AdjBaseLCY2, AdjExchAmount2,
          0, 0, DimEntryNo, Postingdate2, ICCode, Advance, InitialGLAccNo);

        GainsAmount := -RealGainLossAmt;
        TotalAdjAmount := TotalAdjAmount + GainsAmount;
        AdjExchRateBufferUpdate(
          CurrencyCode2, PostingGroup2, AdjBase2, AdjBaseLCY2, 0,
          GainsAmount, 0, DimEntryNo, Postingdate2, ICCode, Advance, InitialGLAccNo);

        LossesAmount := AdjAmount - GainsAmount;
        TotalAdjAmount := TotalAdjAmount + LossesAmount;
        AdjExchRateBufIndex :=
          AdjExchRateBufferUpdate(
            CurrencyCode2, PostingGroup2, AdjBase2, AdjBaseLCY2, 0,
            0, LossesAmount, DimEntryNo, Postingdate2, ICCode, Advance, InitialGLAccNo);

        exit(AdjExchRateBufIndex);
    end;

    local procedure AdjExchRateBufferUpdateUnrealLoss(CurrencyCode2: Code[10]; PostingGroup2: Code[20]; AdjBase2: Decimal; AdjBaseLCY2: Decimal; AdjExchAmount2: Decimal; DimEntryNo: Integer; Postingdate2: Date; ICCode: Code[20]; Advance: Boolean; InitialGLAccNo: Code[20]): Integer
    var
        AdjExchRateBufIndex: Integer;
    begin
        AdjExchRateBufferUpdate(
          CurrencyCode2, PostingGroup2, AdjBase2, AdjBaseLCY2, AdjExchAmount2,
          0, 0, DimEntryNo, Postingdate2, ICCode, Advance, InitialGLAccNo);

        LossesAmount := -RealGainLossAmt;
        TotalAdjAmount := TotalAdjAmount + LossesAmount;
        AdjExchRateBufferUpdate(
          CurrencyCode2, PostingGroup2, AdjBase2, AdjBaseLCY2, 0,
          0, LossesAmount, DimEntryNo, Postingdate2, ICCode, Advance, InitialGLAccNo);

        GainsAmount := AdjAmount - LossesAmount;
        TotalAdjAmount := TotalAdjAmount + GainsAmount;
        AdjExchRateBufIndex :=
          AdjExchRateBufferUpdate(
            CurrencyCode2, PostingGroup2, AdjBase2, AdjBaseLCY2, 0,
            GainsAmount, 0, DimEntryNo, Postingdate2, ICCode, Advance, InitialGLAccNo);

        exit(AdjExchRateBufIndex);
    end;

    local procedure HandlePostAdjmt(AdjustAccType: Integer)
    var
        GLEntry: Record "G/L Entry";
        EmployeePostingGroup: Record "Employee Posting Group";
        TempDetailedCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer" temporary;
        LastEntryNo: Integer;
        LastTransactionNo: Integer;
        ExchRateAdjmtAccountType: Enum "Exch. Rate Adjmt. Account Type";
    begin
        if TempAdjExchangeRateBufferCZL.FindSet() then begin
            // Summarize per currency and dimension combination
            repeat
                TempAdjExchangeRateBufferCZL2.Init();
                OK :=
                  TempAdjExchangeRateBufferCZL2.Get(
                    TempAdjExchangeRateBufferCZL."Currency Code",
                    '',
                    TempAdjExchangeRateBufferCZL."Dimension Entry No.",
                    TempAdjExchangeRateBufferCZL."Posting Date",
                    TempAdjExchangeRateBufferCZL."IC Partner Code",
                    false,
                    TempAdjExchangeRateBufferCZL."Initial G/L Account No.");

                TempAdjExchangeRateBufferCZL2.AdjBase := TempAdjExchangeRateBufferCZL2.AdjBase + TempAdjExchangeRateBufferCZL.AdjBase;
                TempAdjExchangeRateBufferCZL2.TotalGainsAmount := TempAdjExchangeRateBufferCZL2.TotalGainsAmount + TempAdjExchangeRateBufferCZL.TotalGainsAmount;
                TempAdjExchangeRateBufferCZL2.TotalLossesAmount := TempAdjExchangeRateBufferCZL2.TotalLossesAmount + TempAdjExchangeRateBufferCZL.TotalLossesAmount;
                TempAdjExchangeRateBufferCZL2."Document Type" := TempAdjExchangeRateBufferCZL."Document Type";
                TempAdjExchangeRateBufferCZL2."Document No." := TempAdjExchangeRateBufferCZL."Document No.";
                if not OK then begin
                    TempAdjExchangeRateBufferCZL2."Currency Code" := TempAdjExchangeRateBufferCZL."Currency Code";
                    TempAdjExchangeRateBufferCZL2."Dimension Entry No." := TempAdjExchangeRateBufferCZL."Dimension Entry No.";
                    TempAdjExchangeRateBufferCZL2."Posting Date" := TempAdjExchangeRateBufferCZL."Posting Date";
                    TempAdjExchangeRateBufferCZL2."IC Partner Code" := TempAdjExchangeRateBufferCZL."IC Partner Code";
                    TempAdjExchangeRateBufferCZL2."Initial G/L Account No." := TempAdjExchangeRateBufferCZL."Initial G/L Account No.";
                    TempAdjExchangeRateBufferCZL2.Insert();
                end else
                    TempAdjExchangeRateBufferCZL2.Modify();
                OnHandlePostAdjmtOnAfterUpdateBuffer(TempAdjExchangeRateBufferCZL2, TempAdjExchangeRateBufferCZL);
            until TempAdjExchangeRateBufferCZL.Next() = 0;

            // Post per posting group and per currency
            if TempAdjExchangeRateBufferCZL2.FindSet() then
                repeat
                    TempAdjExchangeRateBufferCZL.SetRange("Currency Code", TempAdjExchangeRateBufferCZL2."Currency Code");
                    TempAdjExchangeRateBufferCZL.SetRange("Dimension Entry No.", TempAdjExchangeRateBufferCZL2."Dimension Entry No.");
                    TempAdjExchangeRateBufferCZL.SetRange("Posting Date", TempAdjExchangeRateBufferCZL2."Posting Date");
                    TempAdjExchangeRateBufferCZL.SetRange("IC Partner Code", TempAdjExchangeRateBufferCZL2."IC Partner Code");
                    TempAdjExchangeRateBufferCZL.SetRange("Initial G/L Account No.", TempAdjExchangeRateBufferCZL2."Initial G/L Account No.");
                    TempDimensionBuffer.Reset();
                    TempDimensionBuffer.DeleteAll();
                    TempDimensionSetEntry.Reset();
                    TempDimensionSetEntry.DeleteAll();
                    TempAdjExchangeRateBufferCZL.FindSet();
                    DimensionBufferManagement.GetDimensions(TempAdjExchangeRateBufferCZL."Dimension Entry No.", TempDimensionBuffer);
                    DimensionManagement.CopyDimBufToDimSetEntry(TempDimensionBuffer, TempDimensionSetEntry);
                    repeat
                        TempDetailedCVLedgEntryBuffer.Init();
                        TempDetailedCVLedgEntryBuffer."Entry No." := TempAdjExchangeRateBufferCZL.Index;
                        if TempAdjExchangeRateBufferCZL.AdjAmount <> 0 then
                            case AdjustAccType of
                                1: // Customer
                                    begin
                                        CustomerPostingGroup.Get(TempAdjExchangeRateBufferCZL."Posting Group");
                                        TempDetailedCVLedgEntryBuffer."Transaction No." :=
                                            PostAdjmt(
                                            TempAdjExchangeRateBufferCZL."Initial G/L Account No.", TempAdjExchangeRateBufferCZL.AdjAmount, TempAdjExchangeRateBufferCZL.AdjBase, TempAdjExchangeRateBufferCZL."Currency Code", TempDimensionSetEntry,
                                            TempAdjExchangeRateBufferCZL2."Posting Date", TempAdjExchangeRateBufferCZL."IC Partner Code");
                                        if not TempDetailedCVLedgEntryBuffer.Insert() then
                                            TempDetailedCVLedgEntryBuffer."Transaction No." := 0;
                                        InsertExchRateAdjmtReg(ExchRateAdjmtAccountType::Customer, TempAdjExchangeRateBufferCZL."Posting Group", TempAdjExchangeRateBufferCZL."Currency Code");
                                        TotalCustomersAdjusted += 1;
                                    end;
                                2: // Vendor
                                    begin
                                        VendorPostingGroup.Get(TempAdjExchangeRateBufferCZL."Posting Group");
                                        TempDetailedCVLedgEntryBuffer."Transaction No." :=
                                            PostAdjmt(
                                            TempAdjExchangeRateBufferCZL."Initial G/L Account No.", TempAdjExchangeRateBufferCZL.AdjAmount, TempAdjExchangeRateBufferCZL.AdjBase, TempAdjExchangeRateBufferCZL."Currency Code", TempDimensionSetEntry,
                                            TempAdjExchangeRateBufferCZL2."Posting Date", TempAdjExchangeRateBufferCZL."IC Partner Code");
                                        if not TempDetailedCVLedgEntryBuffer.Insert() then
                                            TempDetailedCVLedgEntryBuffer."Transaction No." := 0;
                                        InsertExchRateAdjmtReg(ExchRateAdjmtAccountType::Vendor, TempAdjExchangeRateBufferCZL."Posting Group", TempAdjExchangeRateBufferCZL."Currency Code");
                                        TotalVendorsAdjusted += 1;
                                    end;
                                3: // Employee
                                    begin
                                        EmployeePostingGroup.Get(TempAdjExchangeRateBufferCZL."Posting Group");
                                        TempDetailedCVLedgEntryBuffer."Transaction No." :=
                                            PostAdjmt(
                                            TempAdjExchangeRateBufferCZL."Initial G/L Account No.", TempAdjExchangeRateBufferCZL.AdjAmount, TempAdjExchangeRateBufferCZL.AdjBase, TempAdjExchangeRateBufferCZL."Currency Code", TempDimensionSetEntry,
                                            TempAdjExchangeRateBufferCZL2."Posting Date", TempAdjExchangeRateBufferCZL."IC Partner Code");
                                        if not TempDetailedCVLedgEntryBuffer.Insert() then
                                            TempDetailedCVLedgEntryBuffer."Transaction No." := 0;
                                        InsertExchRateAdjmtReg(ExchRateAdjmtAccountType::Employee, TempAdjExchangeRateBufferCZL."Posting Group", TempAdjExchangeRateBufferCZL."Currency Code");
                                        TotalEmployeesAdjusted += 1;
                                    end;

                            end;
                    until TempAdjExchangeRateBufferCZL.Next() = 0;

                    TempCurrency.Get(TempAdjExchangeRateBufferCZL2."Currency Code");
                    if TempAdjExchangeRateBufferCZL2.TotalGainsAmount <> 0 then begin
                        TempCurrency.TestField("Unrealized Gains Acc.");
                        PostAdjmt(
                            TempCurrency."Unrealized Gains Acc.", -TempAdjExchangeRateBufferCZL2.TotalGainsAmount, TempAdjExchangeRateBufferCZL2.AdjBase, TempAdjExchangeRateBufferCZL2."Currency Code", TempDimensionSetEntry,
                            TempAdjExchangeRateBufferCZL2."Posting Date", TempAdjExchangeRateBufferCZL2."IC Partner Code");
                    end;
                    if TempAdjExchangeRateBufferCZL2.TotalLossesAmount <> 0 then begin
                        TempCurrency.TestField("Unrealized Losses Acc.");
                        PostAdjmt(
                            TempCurrency."Unrealized Losses Acc.", -TempAdjExchangeRateBufferCZL2.TotalLossesAmount, TempAdjExchangeRateBufferCZL2.AdjBase, TempAdjExchangeRateBufferCZL2."Currency Code", TempDimensionSetEntry,
                            TempAdjExchangeRateBufferCZL2."Posting Date", TempAdjExchangeRateBufferCZL2."IC Partner Code");
                    end;
                until TempAdjExchangeRateBufferCZL2.Next() = 0;

            GLEntry.GetLastEntry(LastEntryNo, LastTransactionNo);
            case AdjustAccType of
                1: // Customer
                    if TempDetailedCustLedgEntry.FindSet() then
                        repeat
                            if TempDetailedCVLedgEntryBuffer.Get(TempDetailedCustLedgEntry."Transaction No.") then
                                TempDetailedCustLedgEntry."Transaction No." := TempDetailedCVLedgEntryBuffer."Transaction No."
                            else
                                TempDetailedCustLedgEntry."Transaction No." := LastTransactionNo;
                            DetailedCustLedgEntry := TempDetailedCustLedgEntry;
                            if Post then
                                DetailedCustLedgEntry.Insert(true);
                        until TempDetailedCustLedgEntry.Next() = 0;
                2: // Vendor
                    if TempDetailedVendorLedgEntry.FindSet() then
                        repeat
                            if TempDetailedCVLedgEntryBuffer.Get(TempDetailedVendorLedgEntry."Transaction No.") then
                                TempDetailedVendorLedgEntry."Transaction No." := TempDetailedCVLedgEntryBuffer."Transaction No."
                            else
                                TempDetailedVendorLedgEntry."Transaction No." := LastTransactionNo;
                            DetailedVendorLedgEntry := TempDetailedVendorLedgEntry;
                            if Post then
                                DetailedVendorLedgEntry.Insert(true);
                        until TempDetailedVendorLedgEntry.Next() = 0;
                3: // Employee
                    if TempDetailedEmployeeLedgerEntry.FindSet() then
                        repeat
                            if TempDetailedCVLedgEntryBuffer.Get(TempDetailedEmployeeLedgerEntry."Transaction No.") then
                                TempDetailedEmployeeLedgerEntry."Transaction No." := TempDetailedCVLedgEntryBuffer."Transaction No."
                            else
                                TempDetailedEmployeeLedgerEntry."Transaction No." := LastTransactionNo;
                            DetailedEmployeeLegerEntry := TempDetailedEmployeeLedgerEntry;
                            if Post then
                                DetailedEmployeeLegerEntry.Insert(true);
                        until TempDetailedEmployeeLedgerEntry.Next() = 0;
            end;

            TempAdjExchangeRateBufferCZL.Reset();
            TempAdjExchangeRateBufferCZL.DeleteAll();
            TempAdjExchangeRateBufferCZL2.Reset();
            TempAdjExchangeRateBufferCZL2.DeleteAll();
            TempDetailedCustLedgEntry.Reset();
            TempDetailedCustLedgEntry.DeleteAll();
            TempDetailedVendorLedgEntry.Reset();
            TempDetailedVendorLedgEntry.DeleteAll();
            TempDetailedEmployeeLedgerEntry.Reset();
            TempDetailedEmployeeLedgerEntry.DeleteAll();
        end;
    end;


    local procedure PrepareTempEmplLedgEntry(Employee: Record Employee; var VarTempEmployeeLedgerEntry: Record "Employee Ledger Entry" temporary);
    var
        EmployeeLedgerEntry2: Record "Employee Ledger Entry";
        DetailedEmployeeLedgerEntry2: Record "Detailed Employee Ledger Entry";
    begin
        VarTempEmployeeLedgerEntry.DeleteAll();

        Currency.CopyFilter(Code, EmployeeLedgerEntry2."Currency Code");
        EmployeeLedgerEntry2.FilterGroup(2);
        EmployeeLedgerEntry2.SetFilter("Currency Code", '<>%1', '');
        EmployeeLedgerEntry2.FilterGroup(0);

        DetailedEmployeeLedgerEntry2.Reset();
        DetailedEmployeeLedgerEntry2.SetCurrentKey("Employee No.", "Posting Date", "Entry Type");
        DetailedEmployeeLedgerEntry2.SetRange("Employee No.", Employee."No.");
        DetailedEmployeeLedgerEntry2.SetRange("Posting Date", CalcDate('<+1D>', EndDate), DMY2Date(31, 12, 9999));
        if DetailedEmployeeLedgerEntry2.FindSet() then
            repeat
                EmployeeLedgerEntry2."Entry No." := DetailedEmployeeLedgerEntry2."Employee Ledger Entry No.";
                if EmployeeLedgerEntry2.Find('=') then
                    if (EmployeeLedgerEntry2."Posting Date" >= StartDate) and
                        (EmployeeLedgerEntry2."Posting Date" <= EndDate)
                    then begin
                        VarTempEmployeeLedgerEntry."Entry No." := EmployeeLedgerEntry2."Entry No.";
                        if VarTempEmployeeLedgerEntry.Insert() then;
                    end;
            until DetailedEmployeeLedgerEntry2.Next() = 0;

        EmployeeLedgerEntry2.SetCurrentKey("Employee No.", Open);
        EmployeeLedgerEntry2.SetRange("Employee No.", Employee."No.");
        EmployeeLedgerEntry2.SetRange(Open, true);
        EmployeeLedgerEntry2.SetRange("Posting Date", 0D, EndDate);
        if EmployeeLedgerEntry2.Find('-') then
            repeat
                VarTempEmployeeLedgerEntry."Entry No." := EmployeeLedgerEntry2."Entry No.";
                if VarTempEmployeeLedgerEntry.Insert() then;
            until EmployeeLedgerEntry2.Next() = 0;
        EmployeeLedgerEntry2.Reset();
    end;

    local procedure AdjustVATEntries(VATType: Enum "General Posting Type"; UseTax: Boolean)
    begin
        Clear(TwoVATEntry);
        VATEntry.SetRange(Type, VATType);
        VATEntry.SetRange("Use Tax", UseTax);
        if VATEntry.FindSet() then
            repeat
                Accumulate(TwoVATEntry.Base, VATEntry.Base);
                Accumulate(TwoVATEntry.Amount, VATEntry.Amount);
                Accumulate(TwoVATEntry."Unrealized Amount", VATEntry."Unrealized Amount");
                Accumulate(TwoVATEntry."Unrealized Base", VATEntry."Unrealized Base");
                Accumulate(TwoVATEntry."Remaining Unrealized Amount", VATEntry."Remaining Unrealized Amount");
                Accumulate(TwoVATEntry."Remaining Unrealized Base", VATEntry."Remaining Unrealized Base");
                Accumulate(TwoVATEntry."Additional-Currency Amount", VATEntry."Additional-Currency Amount");
                Accumulate(TwoVATEntry."Additional-Currency Base", VATEntry."Additional-Currency Base");
                Accumulate(TwoVATEntry."Add.-Currency Unrealized Amt.", VATEntry."Add.-Currency Unrealized Amt.");
                Accumulate(TwoVATEntry."Add.-Currency Unrealized Base", VATEntry."Add.-Currency Unrealized Base");
                Accumulate(TwoVATEntry."Add.-Curr. Rem. Unreal. Amount", VATEntry."Add.-Curr. Rem. Unreal. Amount");
                Accumulate(TwoVATEntry."Add.-Curr. Rem. Unreal. Base", VATEntry."Add.-Curr. Rem. Unreal. Base");

                Accumulate(TotalBaseVATEntry.Base, VATEntry.Base);
                Accumulate(TotalBaseVATEntry.Amount, VATEntry.Amount);
                Accumulate(TotalBaseVATEntry."Unrealized Amount", VATEntry."Unrealized Amount");
                Accumulate(TotalBaseVATEntry."Unrealized Base", VATEntry."Unrealized Base");
                Accumulate(TotalBaseVATEntry."Remaining Unrealized Amount", VATEntry."Remaining Unrealized Amount");
                Accumulate(TotalBaseVATEntry."Remaining Unrealized Base", VATEntry."Remaining Unrealized Base");
                Accumulate(TotalBaseVATEntry."Additional-Currency Amount", VATEntry."Additional-Currency Amount");
                Accumulate(TotalBaseVATEntry."Additional-Currency Base", VATEntry."Additional-Currency Base");
                Accumulate(TotalBaseVATEntry."Add.-Currency Unrealized Amt.", VATEntry."Add.-Currency Unrealized Amt.");
                Accumulate(TotalBaseVATEntry."Add.-Currency Unrealized Base", VATEntry."Add.-Currency Unrealized Base");
                Accumulate(
                  TotalBaseVATEntry."Add.-Curr. Rem. Unreal. Amount", VATEntry."Add.-Curr. Rem. Unreal. Amount");
                Accumulate(TotalBaseVATEntry."Add.-Curr. Rem. Unreal. Base", VATEntry."Add.-Curr. Rem. Unreal. Base");

                AdjustVATAmount(VATEntry.Base, VATEntry."Additional-Currency Base");
                AdjustVATAmount(VATEntry.Amount, VATEntry."Additional-Currency Amount");
                AdjustVATAmount(VATEntry."Unrealized Amount", VATEntry."Add.-Currency Unrealized Amt.");
                AdjustVATAmount(VATEntry."Unrealized Base", VATEntry."Add.-Currency Unrealized Base");
                AdjustVATAmount(VATEntry."Remaining Unrealized Amount", VATEntry."Add.-Curr. Rem. Unreal. Amount");
                AdjustVATAmount(VATEntry."Remaining Unrealized Base", VATEntry."Add.-Curr. Rem. Unreal. Base");
                VATEntry.Modify();

                Accumulate(TwoVATEntry.Base, -VATEntry.Base);
                Accumulate(TwoVATEntry.Amount, -VATEntry.Amount);
                Accumulate(TwoVATEntry."Unrealized Amount", -VATEntry."Unrealized Amount");
                Accumulate(TwoVATEntry."Unrealized Base", -VATEntry."Unrealized Base");
                Accumulate(TwoVATEntry."Remaining Unrealized Amount", -VATEntry."Remaining Unrealized Amount");
                Accumulate(TwoVATEntry."Remaining Unrealized Base", -VATEntry."Remaining Unrealized Base");
                Accumulate(TwoVATEntry."Additional-Currency Amount", -VATEntry."Additional-Currency Amount");
                Accumulate(TwoVATEntry."Additional-Currency Base", -VATEntry."Additional-Currency Base");
                Accumulate(TwoVATEntry."Add.-Currency Unrealized Amt.", -VATEntry."Add.-Currency Unrealized Amt.");
                Accumulate(TwoVATEntry."Add.-Currency Unrealized Base", -VATEntry."Add.-Currency Unrealized Base");
                Accumulate(TwoVATEntry."Add.-Curr. Rem. Unreal. Amount", -VATEntry."Add.-Curr. Rem. Unreal. Amount");
                Accumulate(TwoVATEntry."Add.-Curr. Rem. Unreal. Base", -VATEntry."Add.-Curr. Rem. Unreal. Base");
            until VATEntry.Next() = 0;
    end;

    local procedure AdjustVATAmount(var AmountLCY: Decimal; var AmountAddCurr: Decimal)
    begin
        case GeneralLedgerSetup."VAT Exchange Rate Adjustment" of
            GeneralLedgerSetup."VAT Exchange Rate Adjustment"::"Adjust Amount":
                AmountLCY :=
                  Round(
                    TwoCurrencyExchangeRate.ExchangeAmtFCYToLCYAdjmt(
                      PostingDate, GeneralLedgerSetup."Additional Reporting Currency",
                      AmountAddCurr, AddCurrCurrencyFactor));
            GeneralLedgerSetup."VAT Exchange Rate Adjustment"::"Adjust Additional-Currency Amount":
                AmountAddCurr :=
                  Round(
                    TwoCurrencyExchangeRate.ExchangeAmtLCYToFCY(
                      PostingDate, GeneralLedgerSetup."Additional Reporting Currency",
                      AmountLCY, AddCurrCurrencyFactor));
        end;
    end;

    local procedure AdjustVATAccount(AccNo: Code[20]; AmountLCY: Decimal; AmountAddCurr: Decimal; BaseLCY: Decimal; BaseAddCurr: Decimal)
    begin
        "G/L Account".Get(AccNo);
        "G/L Account".SetRange("Date Filter", StartDate, EndDate);
        case GeneralLedgerSetup."VAT Exchange Rate Adjustment" of
            GeneralLedgerSetup."VAT Exchange Rate Adjustment"::"Adjust Amount":
                PostGLAccAdjmt(
                  AccNo, GeneralLedgerSetup."VAT Exchange Rate Adjustment"::"Adjust Amount",
                  -AmountLCY, BaseLCY, BaseAddCurr);
            GeneralLedgerSetup."VAT Exchange Rate Adjustment"::"Adjust Additional-Currency Amount":
                PostGLAccAdjmt(
                  AccNo, GeneralLedgerSetup."VAT Exchange Rate Adjustment"::"Adjust Additional-Currency Amount",
                  -AmountAddCurr, BaseLCY, BaseAddCurr);
        end;
    end;

    local procedure AdjustPurchTax(UseTax: Boolean)
    begin
        if (TwoVATEntry.Amount <> 0) or (TwoVATEntry."Additional-Currency Amount" <> 0) then begin
            TaxJurisdiction.TestField("Tax Account (Purchases)");
            AdjustVATAccount(
              TaxJurisdiction."Tax Account (Purchases)",
              TwoVATEntry.Amount, TwoVATEntry."Additional-Currency Amount",
              TotalBaseVATEntry.Amount, TotalBaseVATEntry."Additional-Currency Amount");
            if UseTax then begin
                TaxJurisdiction.TestField("Reverse Charge (Purchases)");
                AdjustVATAccount(
                  TaxJurisdiction."Reverse Charge (Purchases)",
                  -TwoVATEntry.Amount, -TwoVATEntry."Additional-Currency Amount",
                  -TotalBaseVATEntry.Amount, -TotalBaseVATEntry."Additional-Currency Amount");
            end;
        end;
        if (TwoVATEntry."Remaining Unrealized Amount" <> 0) or
           (TwoVATEntry."Add.-Curr. Rem. Unreal. Amount" <> 0)
        then begin
            TaxJurisdiction.TestField("Unrealized VAT Type");
            TaxJurisdiction.TestField("Unreal. Tax Acc. (Purchases)");
            AdjustVATAccount(
              TaxJurisdiction."Unreal. Tax Acc. (Purchases)",
              TwoVATEntry."Remaining Unrealized Amount", TwoVATEntry."Add.-Curr. Rem. Unreal. Amount",
              TotalBaseVATEntry."Remaining Unrealized Amount", TwoVATEntry."Add.-Curr. Rem. Unreal. Amount");

            if UseTax then begin
                TaxJurisdiction.TestField("Unreal. Rev. Charge (Purch.)");
                AdjustVATAccount(
                  TaxJurisdiction."Unreal. Rev. Charge (Purch.)",
                  -TwoVATEntry."Remaining Unrealized Amount",
                  -TwoVATEntry."Add.-Curr. Rem. Unreal. Amount",
                  -TotalBaseVATEntry."Remaining Unrealized Amount",
                  -TotalBaseVATEntry."Add.-Curr. Rem. Unreal. Amount");
            end;
        end;
    end;

    local procedure AdjustSalesTax()
    begin
        TaxJurisdiction.TestField("Tax Account (Sales)");
        AdjustVATAccount(
          TaxJurisdiction."Tax Account (Sales)",
          TwoVATEntry.Amount, TwoVATEntry."Additional-Currency Amount",
          TotalBaseVATEntry.Amount, TotalBaseVATEntry."Additional-Currency Amount");
        if (TwoVATEntry."Remaining Unrealized Amount" <> 0) or
           (TwoVATEntry."Add.-Curr. Rem. Unreal. Amount" <> 0)
        then begin
            TaxJurisdiction.TestField("Unrealized VAT Type");
            TaxJurisdiction.TestField("Unreal. Tax Acc. (Sales)");
            AdjustVATAccount(
              TaxJurisdiction."Unreal. Tax Acc. (Sales)",
              TwoVATEntry."Remaining Unrealized Amount",
              TwoVATEntry."Add.-Curr. Rem. Unreal. Amount",
              TotalBaseVATEntry."Remaining Unrealized Amount",
              TotalBaseVATEntry."Add.-Curr. Rem. Unreal. Amount");
        end;
    end;

    local procedure Accumulate(var TotalAmount: Decimal; AmountToAdd: Decimal)
    begin
        TotalAmount := TotalAmount + AmountToAdd;
    end;

    local procedure PostGLAccAdjmt(PostGLAccNo: Code[20]; ExchRateAdjustmentType: Enum "Exch. Rate Adjustment Type"; Amount: Decimal; NetChange: Decimal; AddCurrNetChange: Decimal)
    begin
        GenJournalLine.Init();
        case ExchRateAdjustmentType of
            "G/L Account"."Exchange Rate Adjustment"::"Adjust Amount":
                begin
                    GenJournalLine."Additional-Currency Posting" := GenJournalLine."Additional-Currency Posting"::"Amount Only";
                    GenJournalLine."Currency Code" := '';
                    GenJournalLine.Amount := Amount;
                    GenJournalLine."Amount (LCY)" := GenJournalLine.Amount;
                    GLAmtTotal := GLAmtTotal + GenJournalLine.Amount;
                    GLAddCurrNetChangeTotal := GLAddCurrNetChangeTotal + AddCurrNetChange;
                    GLNetChangeBase := GLNetChangeBase + NetChange;
                end;
            "G/L Account"."Exchange Rate Adjustment"::"Adjust Additional-Currency Amount":
                begin
                    GenJournalLine."Additional-Currency Posting" := GenJournalLine."Additional-Currency Posting"::"Additional-Currency Amount Only";
                    GenJournalLine."Currency Code" := GeneralLedgerSetup."Additional Reporting Currency";
                    GenJournalLine.Amount := Amount;
                    GenJournalLine."Amount (LCY)" := 0;
                    GLAddCurrAmtTotal := GLAddCurrAmtTotal + GenJournalLine.Amount;
                    GLNetChangeTotal := GLNetChangeTotal + NetChange;
                    GLAddCurrNetChangeBase := GLAddCurrNetChangeBase + AddCurrNetChange;
                end;
        end;
        if GenJournalLine.Amount <> 0 then begin
            GenJournalLine."Document No." := PostingDocNo;
            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
            GenJournalLine."Account No." := PostGLAccNo;
            GenJournalLine."Posting Date" := PostingDate;
            case GenJournalLine."Additional-Currency Posting" of
                GenJournalLine."Additional-Currency Posting"::"Amount Only":
                    GenJournalLine.Description :=
                      StrSubstNo(
                        PostingDescription,
                        GeneralLedgerSetup."Additional Reporting Currency",
                        AddCurrNetChange);
                GenJournalLine."Additional-Currency Posting"::"Additional-Currency Amount Only":
                    GenJournalLine.Description :=
                      StrSubstNo(
                        PostingDescription,
                        '',
                        NetChange);
            end;
            GenJournalLine."System-Created Entry" := true;
            GenJournalLine."Source Code" := SourceCodeSetup."Exchange Rate Adjmt.";
            GetJnlLineDefDim(GenJournalLine, TempDimensionSetEntry);
            PostGenJnlLine(GenJournalLine, TempDimensionSetEntry);
        end;
    end;

    local procedure CheckExchRateAdjustment(AccNo: Code[20]; SetupTableName: Text; SetupFieldName: Text)
    var
        GLAccount: Record "G/L Account";
    begin
        if AccNo = '' then
            exit;
        GLAccount.Get(AccNo);
        if GLAccount."Exchange Rate Adjustment" <> GLAccount."Exchange Rate Adjustment"::"No Adjustment" then begin
            GLAccount."Exchange Rate Adjustment" := GLAccount."Exchange Rate Adjustment"::"No Adjustment";
            Error(
              ExchangeRateAdjustmentErr,
              GLAccount.FieldCaption("Exchange Rate Adjustment"), GLAccount.TableCaption,
              GLAccount."No.", GLAccount."Exchange Rate Adjustment",
              SetupTableName, GeneralLedgerSetup.FieldCaption("VAT Exchange Rate Adjustment"),
              GeneralLedgerSetup.TableCaption, SetupFieldName);
        end;
    end;

    local procedure HandleCustDebitCredit(HandleCorrection: Boolean; HandleAdjAmount: Decimal)
    begin
        if (HandleAdjAmount > 0) and not HandleCorrection or
           (HandleAdjAmount < 0) and HandleCorrection
        then begin
            TempDetailedCustLedgEntry."Debit Amount (LCY)" := HandleAdjAmount;
            TempDetailedCustLedgEntry."Credit Amount (LCY)" := 0;
        end else begin
            TempDetailedCustLedgEntry."Debit Amount (LCY)" := 0;
            TempDetailedCustLedgEntry."Credit Amount (LCY)" := -HandleAdjAmount;
        end;
    end;

    local procedure HandleVendDebitCredit(HandleCorrection: Boolean; HandleAdjAmount: Decimal)
    begin
        if (HandleAdjAmount > 0) and not HandleCorrection or
           (HandleAdjAmount < 0) and HandleCorrection
        then begin
            TempDetailedVendorLedgEntry."Debit Amount (LCY)" := HandleAdjAmount;
            TempDetailedVendorLedgEntry."Credit Amount (LCY)" := 0;
        end else begin
            TempDetailedVendorLedgEntry."Debit Amount (LCY)" := 0;
            TempDetailedVendorLedgEntry."Credit Amount (LCY)" := -HandleAdjAmount;
        end;
    end;

    local procedure HandleEmplDebitCredit(HandleCorrection: Boolean; HandleAdjAmount: Decimal)
    begin
        if (HandleAdjAmount > 0) and not HandleCorrection or
           (HandleAdjAmount < 0) and HandleCorrection
        then begin
            TempDetailedEmployeeLedgerEntry."Debit Amount (LCY)" := HandleAdjAmount;
            TempDetailedEmployeeLedgerEntry."Credit Amount (LCY)" := 0;
        end else begin
            TempDetailedEmployeeLedgerEntry."Debit Amount (LCY)" := 0;
            TempDetailedEmployeeLedgerEntry."Credit Amount (LCY)" := -HandleAdjAmount;
        end;
    end;

    local procedure GetJnlLineDefDim(var VarGenJournalLine: Record "Gen. Journal Line"; var DimensionSetEntry: Record "Dimension Set Entry")
    var
        DimSetID: Integer;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        case VarGenJournalLine."Account Type" of
            VarGenJournalLine."Account Type"::"G/L Account":
                DimensionManagement.AddDimSource(DefaultDimSource, Database::"G/L Account", VarGenJournalLine."Account No.");
            VarGenJournalLine."Account Type"::"Bank Account":
                DimensionManagement.AddDimSource(DefaultDimSource, Database::"Bank Account", VarGenJournalLine."Account No.");
        end;
        DimSetID := DimensionManagement.GetDefaultDimID(DefaultDimSource, VarGenJournalLine."Source Code",
                      VarGenJournalLine."Shortcut Dimension 1 Code", VarGenJournalLine."Shortcut Dimension 2 Code", VarGenJournalLine."Dimension Set ID", 0);
        DimensionManagement.GetDimensionSet(DimensionSetEntry, DimSetID);
    end;

    local procedure CopyDimSetEntryToDimBuf(var DimensionSetEntry: Record "Dimension Set Entry"; var DimensionBuffer: Record "Dimension Buffer")
    begin
        if DimensionSetEntry.FindSet() then
            repeat
                DimensionBuffer."Table ID" := DATABASE::"Dimension Buffer";
                DimensionBuffer."Entry No." := 0;
                DimensionBuffer."Dimension Code" := DimensionSetEntry."Dimension Code";
                DimensionBuffer."Dimension Value Code" := DimensionSetEntry."Dimension Value Code";
                DimensionBuffer.Insert();
            until DimensionSetEntry.Next() = 0;
    end;

    local procedure GetDimCombID(var DimensionBuffer: Record "Dimension Buffer"): Integer
    var
        DimEntryNo: Integer;
    begin
        DimEntryNo := DimensionBufferManagement.FindDimensions(DimensionBuffer);
        if DimEntryNo = 0 then
            DimEntryNo := DimensionBufferManagement.InsertDimensions(DimensionBuffer);
        exit(DimEntryNo);
    end;

    local procedure PostGenJnlLine(var VarGenJournalLine: Record "Gen. Journal Line"; var DimensionSetEntry: Record "Dimension Set Entry"): Integer
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        case DimMoveType of
            DimMoveType::"No move":
                begin
                    // no dimension
                    VarGenJournalLine."Shortcut Dimension 1 Code" := '';
                    VarGenJournalLine."Shortcut Dimension 2 Code" := '';
                    VarGenJournalLine."Dimension Set ID" := 0;
                end;
            DimMoveType::"Source Entry":
                begin
                    // default dim for G/L account, other by source entries
                    VarGenJournalLine."Shortcut Dimension 1 Code" := GetGlobalDimVal(GeneralLedgerSetup."Global Dimension 1 Code", DimensionSetEntry);
                    VarGenJournalLine."Shortcut Dimension 2 Code" := GetGlobalDimVal(GeneralLedgerSetup."Global Dimension 2 Code", DimensionSetEntry);
                    VarGenJournalLine."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
                end;
            DimMoveType::"By G/L Account":
                // source entries dimension -> default dim for G/L account
                if VarGenJournalLine."Account Type" = VarGenJournalLine."Account Type"::"G/L Account" then begin
                    DimensionManagement.AddDimSource(DefaultDimSource, Database::"G/L Account", VarGenJournalLine."Account No.");
                    VarGenJournalLine."Dimension Set ID" := DimensionManagement.GetDefaultDimID(DefaultDimSource, VarGenJournalLine."Source Code",
                                                           VarGenJournalLine."Shortcut Dimension 1 Code", VarGenJournalLine."Shortcut Dimension 2 Code", 0, 0);
                end;
        end;

        if Post then begin
            OnPostGenJnlLineOnBeforeGenJnlPostLineRun(GenJnlPostLine, VarGenJournalLine, DimensionSetEntry);
            GenJnlPostLine.Run(VarGenJournalLine);
            exit(GenJnlPostLine.GetNextTransactionNo());
        end;
    end;

    local procedure GetGlobalDimVal(GlobalDimCode: Code[20]; var DimensionSetEntry: Record "Dimension Set Entry"): Code[20]
    var
        DimVal: Code[20];
    begin
        if GlobalDimCode = '' then
            DimVal := ''
        else begin
            DimensionSetEntry.SetRange("Dimension Code", GlobalDimCode);
            if DimensionSetEntry.FindFirst() then
                DimVal := DimensionSetEntry."Dimension Value Code"
            else
                DimVal := '';
            DimensionSetEntry.SetRange("Dimension Code");
        end;
        exit(DimVal);
    end;

    procedure CheckPostingDate()
    begin
        if PostingDate < StartDate then
            Error(PostingDateEnteredErr);
        if PostingDate > EndDateReq then
            Error(PostingDateEnteredErr);
    end;

    procedure AdjustCustomerLedgerEntry(AdjCustLedgerEntry: Record "Cust. Ledger Entry"; PostingDate2: Date)
    var
        DimensionSetEntry: Record "Dimension Set Entry";
        DimEntryNo: Integer;
        OldAdjAmount: Decimal;
        Adjust: Boolean;
        UpdateBuffer: Boolean;
        AdjExchRateBufIndex: Integer;
    begin
        AdjCustLedgerEntry.SetRange("Date Filter", 0D, PostingDate2);
        TempCurrency.Get(AdjCustLedgerEntry."Currency Code");
        GainsAmount := 0;
        LossesAmount := 0;
        OldAdjAmount := 0;
        Adjust := false;
        UpdateBuffer := true;

        TempDimensionSetEntry.Reset();
        TempDimensionSetEntry.DeleteAll();
        TempDimensionBuffer.Reset();
        TempDimensionBuffer.DeleteAll();
        DimensionSetEntry.SetRange("Dimension Set ID", AdjCustLedgerEntry."Dimension Set ID");
        CopyDimSetEntryToDimBuf(DimensionSetEntry, TempDimensionBuffer);
        DimEntryNo := GetDimCombID(TempDimensionBuffer);

        AdjCustLedgerEntry.CalcFields(
          Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)", "Original Amt. (LCY)",
          "Debit Amount", "Credit Amount", "Debit Amount (LCY)", "Credit Amount (LCY)");

        // Calculate Old Unrealized GainLoss
        SetUnrealizedGainLossFilterCust(DetailedCustLedgEntry, AdjCustLedgerEntry."Entry No.");
        DetailedCustLedgEntry.CalcSums("Amount (LCY)");

        SetUnrealizedGainLossFilterCust(TempSumsDetailedCustLedgEntry, AdjCustLedgerEntry."Entry No.");
        TempSumsDetailedCustLedgEntry.CalcSums("Amount (LCY)");
        OldAdjAmount := DetailedCustLedgEntry."Amount (LCY)" + TempSumsDetailedCustLedgEntry."Amount (LCY)";
        AdjCustLedgerEntry."Remaining Amt. (LCY)" := AdjCustLedgerEntry."Remaining Amt. (LCY)" + TempSumsDetailedCustLedgEntry."Amount (LCY)";
        AdjCustLedgerEntry."Debit Amount (LCY)" := AdjCustLedgerEntry."Debit Amount (LCY)" + TempSumsDetailedCustLedgEntry."Amount (LCY)";
        AdjCustLedgerEntry."Credit Amount (LCY)" := AdjCustLedgerEntry."Credit Amount (LCY)" + TempSumsDetailedCustLedgEntry."Amount (LCY)";
        TempSumsDetailedCustLedgEntry.Reset();

        // Modify Currency factor on Customer Ledger Entry
        if AdjCustLedgerEntry."Adjusted Currency Factor" <> TempCurrency."Currency Factor" then begin
            AdjCustLedgerEntry."Adjusted Currency Factor" := TempCurrency."Currency Factor";
            if Post then
                AdjCustLedgerEntry.Modify();
        end;

        AdjustedFactor := Round(1 / AdjCustLedgerEntry."Adjusted Currency Factor", 0.0001);

        // Calculate New Unrealized GainLoss
        AdjAmount :=
          Round(
            CurrencyExchangeRate.ExchangeAmtFCYToLCYAdjmt(
              PostingDate2, TempCurrency.Code, AdjCustLedgerEntry."Remaining Amount", TempCurrency."Currency Factor")) -
          AdjCustLedgerEntry."Remaining Amt. (LCY)";

        if AdjAmount <> 0 then begin
            OnAdjustCustomerLedgerEntryOnBeforeInitDtldCustLedgEntry(Customer, AdjCustLedgerEntry);
            InitDtldCustLedgEntry(AdjCustLedgerEntry, TempDetailedCustLedgEntry);
            TempDetailedCustLedgEntry."Entry No." := NewEntryNo;
            TempDetailedCustLedgEntry."Posting Date" := PostingDate2;
            TempDetailedCustLedgEntry."Document No." := PostingDocNo;
            TempDetailedCustLedgEntry."Posting Group" := AdjCustLedgerEntry."Customer Posting Group";

            Correction :=
              (AdjCustLedgerEntry."Debit Amount" < 0) or
              (AdjCustLedgerEntry."Credit Amount" < 0) or
              (AdjCustLedgerEntry."Debit Amount (LCY)" < 0) or
              (AdjCustLedgerEntry."Credit Amount (LCY)" < 0);


            if (OldAdjAmount > 0) and (RealGainLossAmt > 0) and (AdjAmount < 0) then
                CreateDtldCustLedgEntryUnrealGain(
                  AdjCustLedgerEntry, TempDetailedCustLedgEntry, DimEntryNo, PostingDate2, UpdateBuffer, Adjust);

            if (OldAdjAmount < 0) and (RealGainLossAmt < 0) and (AdjAmount > 0) then
                CreateDtldCustLedgEntryUnrealLoss(
                  AdjCustLedgerEntry, TempDetailedCustLedgEntry, DimEntryNo, PostingDate2, UpdateBuffer, Adjust);

            if not Adjust then begin
                TempDetailedCustLedgEntry."Amount (LCY)" := AdjAmount;
                HandleCustDebitCredit(Correction, TempDetailedCustLedgEntry."Amount (LCY)");
                TempDetailedCustLedgEntry."Entry No." := NewEntryNo;
                if AdjAmount < 0 then begin
                    TempDetailedCustLedgEntry."Entry Type" := TempDetailedCustLedgEntry."Entry Type"::"Unrealized Loss";
                    GainsAmount := 0;
                    LossesAmount := AdjAmount;
                end else
                    if AdjAmount > 0 then begin
                        TempDetailedCustLedgEntry."Entry Type" := TempDetailedCustLedgEntry."Entry Type"::"Unrealized Gain";
                        GainsAmount := AdjAmount;
                        LossesAmount := 0;
                    end;
                InsertTempDtldCustomerLedgerEntry();
                NewEntryNo := NewEntryNo + 1;
            end;

            if UpdateBuffer then begin
                TotalAdjAmount := TotalAdjAmount + AdjAmount;
                if not HideUI then
                    WindowDialog.Update(4, TotalAdjAmount);
                AdjExchRateBufIndex :=
                  AdjExchRateBufferUpdate(
                    AdjCustLedgerEntry."Currency Code", AdjCustLedgerEntry."Customer Posting Group",
                    AdjCustLedgerEntry."Remaining Amount", AdjCustLedgerEntry."Remaining Amt. (LCY)", TempDetailedCustLedgEntry."Amount (LCY)",
                    GainsAmount, LossesAmount, DimEntryNo, PostingDate2, Customer."IC Partner Code",
                    false,
                    GetInitialGLAccountNo(AdjCustLedgerEntry."Entry No.", 0, AdjCustLedgerEntry."Customer Posting Group"));
                TempDetailedCustLedgEntry."Transaction No." := AdjExchRateBufIndex;
                ModifyTempDtldCustomerLedgerEntry();

                TempAdjExchangeRateBufferCZL."Document Type" := AdjCustLedgerEntry."Document Type";
                TempAdjExchangeRateBufferCZL."Document No." := AdjCustLedgerEntry."Document No.";
                OnAdjustCustomerLedgerEntryOnBeforeModifyBuffer(TempAdjExchangeRateBufferCZL, AdjCustLedgerEntry);
                TempAdjExchangeRateBufferCZL.Modify();
            end;
        end;
    end;

    procedure AdjustVendorLedgerEntry(AdjVendorLedgerEntry: Record "Vendor Ledger Entry"; PostingDate2: Date)
    var
        DimensionSetEntry: Record "Dimension Set Entry";
        DimEntryNo: Integer;
        OldAdjAmount: Decimal;
        Adjust: Boolean;
        UpdateBuffer: Boolean;
        AdjExchRateBufIndex: Integer;
    begin
        AdjVendorLedgerEntry.SetRange("Date Filter", 0D, PostingDate2);
        TempCurrency.Get(AdjVendorLedgerEntry."Currency Code");
        GainsAmount := 0;
        LossesAmount := 0;
        OldAdjAmount := 0;
        Adjust := false;
        UpdateBuffer := true;

        TempDimensionBuffer.Reset();
        TempDimensionBuffer.DeleteAll();
        DimensionSetEntry.SetRange("Dimension Set ID", AdjVendorLedgerEntry."Dimension Set ID");
        CopyDimSetEntryToDimBuf(DimensionSetEntry, TempDimensionBuffer);
        DimEntryNo := GetDimCombID(TempDimensionBuffer);

        AdjVendorLedgerEntry.CalcFields(
          Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)", "Original Amt. (LCY)",
          "Debit Amount", "Credit Amount", "Debit Amount (LCY)", "Credit Amount (LCY)");

        // Calculate Old Unrealized GainLoss
        SetUnrealizedGainLossFilterVend(DetailedVendorLedgEntry, AdjVendorLedgerEntry."Entry No.");
        DetailedVendorLedgEntry.CalcSums("Amount (LCY)");

        SetUnrealizedGainLossFilterVend(TempSumsDetailedVendorLedgEntry, AdjVendorLedgerEntry."Entry No.");
        TempSumsDetailedVendorLedgEntry.CalcSums("Amount (LCY)");
        OldAdjAmount := DetailedVendorLedgEntry."Amount (LCY)" + TempSumsDetailedVendorLedgEntry."Amount (LCY)";
        AdjVendorLedgerEntry."Remaining Amt. (LCY)" := AdjVendorLedgerEntry."Remaining Amt. (LCY)" + TempSumsDetailedVendorLedgEntry."Amount (LCY)";
        AdjVendorLedgerEntry."Debit Amount (LCY)" := AdjVendorLedgerEntry."Debit Amount (LCY)" + TempSumsDetailedVendorLedgEntry."Amount (LCY)";
        AdjVendorLedgerEntry."Credit Amount (LCY)" := AdjVendorLedgerEntry."Credit Amount (LCY)" + TempSumsDetailedVendorLedgEntry."Amount (LCY)";
        TempSumsDetailedVendorLedgEntry.Reset();

        // Modify Currency factor on Vendor Ledger Entry
        if AdjVendorLedgerEntry."Adjusted Currency Factor" <> TempCurrency."Currency Factor" then begin
            AdjVendorLedgerEntry."Adjusted Currency Factor" := TempCurrency."Currency Factor";
            if Post then
                AdjVendorLedgerEntry.Modify();
        end;

        AdjustedFactor := Round(1 / AdjVendorLedgerEntry."Adjusted Currency Factor", 0.0001);

        // Calculate New Unrealized GainLoss
        AdjAmount :=
          Round(
            CurrencyExchangeRate.ExchangeAmtFCYToLCYAdjmt(
              PostingDate2, TempCurrency.Code, AdjVendorLedgerEntry."Remaining Amount", TempCurrency."Currency Factor")) -
          AdjVendorLedgerEntry."Remaining Amt. (LCY)";

        if AdjAmount <> 0 then begin
            OnAdjustVendorLedgerEntryOnBeforeInitDtldVendLedgEntry(Vendor, AdjVendorLedgerEntry);
            InitDtldVendLedgEntry(AdjVendorLedgerEntry, TempDetailedVendorLedgEntry);
            TempDetailedVendorLedgEntry."Entry No." := NewEntryNo;
            TempDetailedVendorLedgEntry."Posting Date" := PostingDate2;
            TempDetailedVendorLedgEntry."Document No." := PostingDocNo;
            TempDetailedVendorLedgEntry."Posting Group" := AdjVendorLedgerEntry."Vendor Posting Group";

            Correction :=
              (AdjVendorLedgerEntry."Debit Amount" < 0) or
              (AdjVendorLedgerEntry."Credit Amount" < 0) or
              (AdjVendorLedgerEntry."Debit Amount (LCY)" < 0) or
              (AdjVendorLedgerEntry."Credit Amount (LCY)" < 0);

            if (OldAdjAmount > 0) and (RealGainLossAmt > 0) and (AdjAmount < 0) then
                CreateDtldVendLedgEntryUnrealGain(
                  AdjVendorLedgerEntry, TempDetailedVendorLedgEntry, DimEntryNo, PostingDate2, UpdateBuffer, Adjust);

            if (OldAdjAmount < 0) and (RealGainLossAmt < 0) and (AdjAmount > 0) then
                CreateDtldVendLedgEntryUnrealLoss(
                  AdjVendorLedgerEntry, TempDetailedVendorLedgEntry, DimEntryNo, PostingDate2, UpdateBuffer, Adjust);

            if not Adjust then begin
                TempDetailedVendorLedgEntry."Amount (LCY)" := AdjAmount;
                HandleVendDebitCredit(Correction, TempDetailedVendorLedgEntry."Amount (LCY)");
                TempDetailedVendorLedgEntry."Entry No." := NewEntryNo;
                if AdjAmount < 0 then begin
                    TempDetailedVendorLedgEntry."Entry Type" := TempDetailedVendorLedgEntry."Entry Type"::"Unrealized Loss";
                    GainsAmount := 0;
                    LossesAmount := AdjAmount;
                end else
                    if AdjAmount > 0 then begin
                        TempDetailedVendorLedgEntry."Entry Type" := TempDetailedVendorLedgEntry."Entry Type"::"Unrealized Gain";
                        GainsAmount := AdjAmount;
                        LossesAmount := 0;
                    end;
                InsertTempDtldVendorLedgerEntry();
                NewEntryNo := NewEntryNo + 1;
            end;

            if UpdateBuffer then begin
                TotalAdjAmount := TotalAdjAmount + AdjAmount;
                if not HideUI then
                    WindowDialog.Update(4, TotalAdjAmount);
                AdjExchRateBufIndex :=
                  AdjExchRateBufferUpdate(
                    AdjVendorLedgerEntry."Currency Code", AdjVendorLedgerEntry."Vendor Posting Group",
                    AdjVendorLedgerEntry."Remaining Amount", AdjVendorLedgerEntry."Remaining Amt. (LCY)",
                    TempDetailedVendorLedgEntry."Amount (LCY)", GainsAmount, LossesAmount, DimEntryNo, PostingDate2, Vendor."IC Partner Code",
                    false,
                    GetInitialGLAccountNo(AdjVendorLedgerEntry."Entry No.", 1, AdjVendorLedgerEntry."Vendor Posting Group"));
                TempDetailedVendorLedgEntry."Transaction No." := AdjExchRateBufIndex;
                ModifyTempDtldVendorLedgerEntry();

                TempAdjExchangeRateBufferCZL."Document Type" := AdjVendorLedgerEntry."Document Type";
                TempAdjExchangeRateBufferCZL."Document No." := AdjVendorLedgerEntry."Document No.";
                OnAdjustVendorLedgerEntryOnBeforeModifyBuffer(TempAdjExchangeRateBufferCZL, AdjVendorLedgerEntry);
                TempAdjExchangeRateBufferCZL.Modify();
            end;
        end;
    end;

    procedure AdjustEmployeeLedgerEntry(EmplLedgerEntry: Record "Employee Ledger Entry"; PostingDate2: Date)
    var
        DimensionSetEntry: Record "Dimension Set Entry";
        DimEntryNo: Integer;
        OldAdjAmount: Decimal;
        Adjust: Boolean;
        UpdateBuffer: Boolean;
        AdjExchRateBufIndex: Integer;
    begin
        EmplLedgerEntry.SetRange("Date Filter", 0D, PostingDate2);
        TempCurrency.Get(EmplLedgerEntry."Currency Code");
        GainsAmount := 0;
        LossesAmount := 0;
        OldAdjAmount := 0;
        Adjust := false;
        UpdateBuffer := true;

        TempDimensionSetEntry.Reset();
        TempDimensionSetEntry.DeleteAll();
        TempDimensionBuffer.Reset();
        TempDimensionBuffer.DeleteAll();
        DimensionSetEntry.SetRange("Dimension Set ID", EmplLedgerEntry."Dimension Set ID");
        CopyDimSetEntryToDimBuf(DimensionSetEntry, TempDimensionBuffer);
        DimEntryNo := GetDimCombID(TempDimensionBuffer);

        EmplLedgerEntry.CalcFields(
            Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)", "Original Amt. (LCY)",
            "Debit Amount", "Credit Amount", "Debit Amount (LCY)", "Credit Amount (LCY)");

        // Calculate Old Unrealized GainLoss
        SetUnrealizedGainLossFilterEmpl(DetailedEmployeeLegerEntry, EmplLedgerEntry."Entry No.");
        DetailedEmployeeLegerEntry.CalcSums("Amount (LCY)");

        SetUnrealizedGainLossFilterEmpl(TempSumsDetailedEmployeeLedgerEntry, EmplLedgerEntry."Entry No.");
        TempSumsDetailedEmployeeLedgerEntry.CalcSums("Amount (LCY)");
        OldAdjAmount := DetailedEmployeeLegerEntry."Amount (LCY)" + TempSumsDetailedEmployeeLedgerEntry."Amount (LCY)";
        EmplLedgerEntry."Remaining Amt. (LCY)" += TempSumsDetailedEmployeeLedgerEntry."Amount (LCY)";
        EmplLedgerEntry."Debit Amount (LCY)" += TempSumsDetailedEmployeeLedgerEntry."Amount (LCY)";
        EmplLedgerEntry."Credit Amount (LCY)" += TempSumsDetailedEmployeeLedgerEntry."Amount (LCY)";
        TempSumsDetailedEmployeeLedgerEntry.Reset();

        // Modify Currency factor on Employee Ledger Entry
        if EmplLedgerEntry."Adjusted Currency Factor" <> TempCurrency."Currency Factor" then begin
            EmplLedgerEntry."Adjusted Currency Factor" := TempCurrency."Currency Factor";
            if Post then
                EmplLedgerEntry.Modify();
        end;

        // Calculate New Unrealized Gains and Losses
        AdjAmount :=
            Round(
                CurrencyExchangeRate.ExchangeAmtFCYToLCYAdjmt(
                    PostingDate2, TempCurrency.Code, EmplLedgerEntry."Remaining Amount", TempCurrency."Currency Factor")) -
                EmplLedgerEntry."Remaining Amt. (LCY)";

        if AdjAmount <> 0 then begin
            OnAdjustEmployeeLedgerEntryOnBeforeInitDtldEmplLedgEntry(Employee, EmplLedgerEntry);
            InitDtldEmplLedgEntry(EmplLedgerEntry, TempDetailedEmployeeLedgerEntry);
            TempDetailedEmployeeLedgerEntry."Entry No." := NewEntryNo;
            TempDetailedEmployeeLedgerEntry."Posting Date" := PostingDate2;
            TempDetailedEmployeeLedgerEntry."Document No." := PostingDocNo;

            Correction :=
                (EmplLedgerEntry."Debit Amount" < 0) or
                (EmplLedgerEntry."Credit Amount" < 0) or
                (EmplLedgerEntry."Debit Amount (LCY)" < 0) or
                (EmplLedgerEntry."Credit Amount (LCY)" < 0);

            if (OldAdjAmount > 0) and (RealGainLossAmt > 0) and (AdjAmount < 0) then
                CreateDtldEmployeeLedgEntryUnrealGain(
                  EmplLedgerEntry, TempDetailedEmployeeLedgerEntry, DimEntryNo, PostingDate2, UpdateBuffer, Adjust);

            if (OldAdjAmount < 0) and (RealGainLossAmt < 0) and (AdjAmount > 0) then
                CreateDtldEmployeeLedgEntryUnrealLoss(
                  EmplLedgerEntry, TempDetailedEmployeeLedgerEntry, DimEntryNo, PostingDate2, UpdateBuffer, Adjust);

            if not Adjust then begin
                TempDetailedEmployeeLedgerEntry."Amount (LCY)" := AdjAmount;
                HandleEmplDebitCredit(Correction, TempDetailedEmployeeLedgerEntry."Amount (LCY)");
                TempDetailedEmployeeLedgerEntry."Entry No." := NewEntryNo;
                if AdjAmount < 0 then begin
                    TempDetailedEmployeeLedgerEntry."Entry Type" := TempDetailedEmployeeLedgerEntry."Entry Type"::"Unrealized Loss";
                    GainsAmount := 0;
                    LossesAmount := AdjAmount;
                end else
                    if AdjAmount > 0 then begin
                        TempDetailedEmployeeLedgerEntry."Entry Type" := TempDetailedEmployeeLedgerEntry."Entry Type"::"Unrealized Gain";
                        GainsAmount := AdjAmount;
                        LossesAmount := 0;
                    end;
                InsertTempDtldEmployeeLedgerEntry();
                NewEntryNo := NewEntryNo + 1;
            end;

            TotalAdjAmount := TotalAdjAmount + AdjAmount;
            if not HideUI then
                WindowDialog.Update(4, TotalAdjAmount);
            AdjExchRateBufIndex :=
                AdjExchRateBufferUpdate(
                    EmplLedgerEntry."Currency Code", EmplLedgerEntry."Employee Posting Group",
                    EmplLedgerEntry."Remaining Amount", EmplLedgerEntry."Remaining Amt. (LCY)",
                    TempDetailedEmployeeLedgerEntry."Amount (LCY)", GainsAmount, LossesAmount, DimEntryNo, PostingDate2, '',
                    false, GetInitialGLAccountNo(EmployeeLedgerEntry."Entry No.", 2, EmployeeLedgerEntry."Employee Posting Group"));
            TempDetailedEmployeeLedgerEntry."Transaction No." := AdjExchRateBufIndex;
            ModifyTempDtldEmployeeLedgerEntry();

            TempAdjExchangeRateBufferCZL."Document Type" := EmployeeLedgerEntry."Document Type";
            TempAdjExchangeRateBufferCZL."Document No." := EmployeeLedgerEntry."Document No.";
            OnAdjustEmployeeLedgerEntryOnBeforeModifyBuffer(TempAdjExchangeRateBufferCZL, EmplLedgerEntry);
            TempAdjExchangeRateBufferCZL.Modify();
        end;
    end;

    procedure AdjustExchRateCust(AdjGenJournalLine: Record "Gen. Journal Line"; var VarTempCustLedgerEntry: Record "Cust. Ledger Entry" temporary)
    var
        CurrentCustLedgerEntry: Record "Cust. Ledger Entry";
        AdjDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        PostingDate2: Date;
    begin
        PostingDate2 := AdjGenJournalLine."Posting Date";
        if VarTempCustLedgerEntry.FindSet() then
            repeat
                CurrentCustLedgerEntry.Get(VarTempCustLedgerEntry."Entry No.");
                CurrentCustLedgerEntry.SetRange("Date Filter", 0D, PostingDate2);
                CurrentCustLedgerEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
                if ShouldAdjustEntry(
                     PostingDate2, CurrentCustLedgerEntry."Currency Code", CurrentCustLedgerEntry."Remaining Amount", CurrentCustLedgerEntry."Remaining Amt. (LCY)", CurrentCustLedgerEntry."Adjusted Currency Factor")
                then begin
                    InitVariablesForSetLedgEntry(AdjGenJournalLine);
                    SetCustLedgEntry(CurrentCustLedgerEntry);
                    AdjustCustomerLedgerEntry(CurrentCustLedgerEntry, PostingDate2);

                    AdjDetailedCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.");
                    AdjDetailedCustLedgEntry.SetRange("Cust. Ledger Entry No.", CurrentCustLedgerEntry."Entry No.");
                    AdjDetailedCustLedgEntry.SetFilter("Posting Date", '%1..', CalcDate('<+1D>', PostingDate2));
                    if AdjDetailedCustLedgEntry.FindSet() then
                        repeat
                            AdjustCustomerLedgerEntry(CurrentCustLedgerEntry, AdjDetailedCustLedgEntry."Posting Date");
                        until AdjDetailedCustLedgEntry.Next() = 0;
                    HandlePostAdjmt(1);
                end;
            until VarTempCustLedgerEntry.Next() = 0;
    end;

    procedure AdjustExchRateVend(AdjGenJournalLine: Record "Gen. Journal Line"; var VarTempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary)
    var
        CurrentVendorLedgerEntry: Record "Vendor Ledger Entry";
        CurrentDetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        PostingDate2: Date;
    begin
        PostingDate2 := AdjGenJournalLine."Posting Date";
        if VarTempVendorLedgerEntry.FindSet() then
            repeat
                CurrentVendorLedgerEntry.Get(VarTempVendorLedgerEntry."Entry No.");
                CurrentVendorLedgerEntry.SetRange("Date Filter", 0D, PostingDate2);
                CurrentVendorLedgerEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
                if ShouldAdjustEntry(
                     PostingDate2, CurrentVendorLedgerEntry."Currency Code", CurrentVendorLedgerEntry."Remaining Amount", CurrentVendorLedgerEntry."Remaining Amt. (LCY)", CurrentVendorLedgerEntry."Adjusted Currency Factor")
                then begin
                    InitVariablesForSetLedgEntry(AdjGenJournalLine);
                    SetVendLedgEntry(CurrentVendorLedgerEntry);
                    AdjustVendorLedgerEntry(CurrentVendorLedgerEntry, PostingDate2);

                    CurrentDetailedVendorLedgEntry.SetCurrentKey("Vendor Ledger Entry No.");
                    CurrentDetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", CurrentVendorLedgerEntry."Entry No.");
                    CurrentDetailedVendorLedgEntry.SetFilter("Posting Date", '%1..', CalcDate('<+1D>', PostingDate2));
                    if CurrentDetailedVendorLedgEntry.FindSet() then
                        repeat
                            AdjustVendorLedgerEntry(CurrentVendorLedgerEntry, CurrentDetailedVendorLedgEntry."Posting Date");
                        until CurrentDetailedVendorLedgEntry.Next() = 0;
                    HandlePostAdjmt(2);
                end;
            until VarTempVendorLedgerEntry.Next() = 0;
    end;

    local procedure SetCustLedgEntry(ToAdjustCustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        Customer.Get(ToAdjustCustLedgerEntry."Customer No.");
        AddCurrency(ToAdjustCustLedgerEntry."Currency Code", ToAdjustCustLedgerEntry."Adjusted Currency Factor");
        DetailedCustLedgEntry.LockTable();
        CustLedgerEntry.LockTable();
        NewEntryNo := DetailedCustLedgEntry.GetLastEntryNo() + 1;
    end;

    local procedure SetVendLedgEntry(ToAdjustVendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        Vendor.Get(ToAdjustVendorLedgerEntry."Vendor No.");
        AddCurrency(ToAdjustVendorLedgerEntry."Currency Code", ToAdjustVendorLedgerEntry."Adjusted Currency Factor");
        DetailedVendorLedgEntry.LockTable();
        VendorLedgerEntry.LockTable();
        NewEntryNo := DetailedVendorLedgEntry.GetLastEntryNo() + 1;
    end;

    local procedure ShouldAdjustEntry(ShouldPostingDate: Date; CurCode: Code[10]; RemainingAmount: Decimal; RemainingAmtLCY: Decimal; AdjCurFactor: Decimal): Boolean
    begin
        exit(Round(CurrencyExchangeRate.ExchangeAmtFCYToLCYAdjmt(ShouldPostingDate, CurCode, RemainingAmount, AdjCurFactor)) - RemainingAmtLCY <> 0);
    end;

    local procedure InitVariablesForSetLedgEntry(InitGenJournalLine: Record "Gen. Journal Line")
    begin
        InitializeRequest(InitGenJournalLine."Posting Date", InitGenJournalLine."Posting Date", ExchRateAdjTxt, InitGenJournalLine."Posting Date");
        PostingDocNo := InitGenJournalLine."Document No.";
        HideUI := true;
        GeneralLedgerSetup.Get();
        SourceCodeSetup.Get();
        if ExchRateAdjmtReg.FindLast() then
            ExchRateAdjmtReg.Init();
    end;

    local procedure AddCurrency(CurrencyCode: Code[10]; CurrencyFactor: Decimal)
    var
        ToAddCurrency: Record Currency;
    begin
        if TempCurrency.Get(CurrencyCode) then begin
            TempCurrency."Currency Factor" := CurrencyFactor;
            TempCurrency.Modify();
        end else begin
            ToAddCurrency.Get(CurrencyCode);
            TempCurrency := ToAddCurrency;
            TempCurrency."Currency Factor" := CurrencyFactor;
            TempCurrency.Insert();
        end;
    end;

    local procedure InitDtldCustLedgEntry(InitCustLedgerEntry: Record "Cust. Ledger Entry"; var VarDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry")
    begin
        VarDetailedCustLedgEntry.Init();
        VarDetailedCustLedgEntry."Cust. Ledger Entry No." := InitCustLedgerEntry."Entry No.";
        VarDetailedCustLedgEntry.Amount := 0;
        VarDetailedCustLedgEntry."Customer No." := InitCustLedgerEntry."Customer No.";
        VarDetailedCustLedgEntry."Currency Code" := InitCustLedgerEntry."Currency Code";
        VarDetailedCustLedgEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(VarDetailedCustLedgEntry."User ID"));
        VarDetailedCustLedgEntry."Source Code" := SourceCodeSetup."Exchange Rate Adjmt.";
        VarDetailedCustLedgEntry."Journal Batch Name" := InitCustLedgerEntry."Journal Batch Name";
        VarDetailedCustLedgEntry."Reason Code" := InitCustLedgerEntry."Reason Code";
        VarDetailedCustLedgEntry."Initial Entry Due Date" := InitCustLedgerEntry."Due Date";
        VarDetailedCustLedgEntry."Initial Entry Global Dim. 1" := InitCustLedgerEntry."Global Dimension 1 Code";
        VarDetailedCustLedgEntry."Initial Entry Global Dim. 2" := InitCustLedgerEntry."Global Dimension 2 Code";
        VarDetailedCustLedgEntry."Initial Document Type" := InitCustLedgerEntry."Document Type";

        OnAfterInitDtldCustLedgerEntry(VarDetailedCustLedgEntry);
    end;

    local procedure InitDtldVendLedgEntry(InitVendorLedgerEntry: Record "Vendor Ledger Entry"; var VarDetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry")
    begin
        VarDetailedVendorLedgEntry.Init();
        VarDetailedVendorLedgEntry."Vendor Ledger Entry No." := InitVendorLedgerEntry."Entry No.";
        VarDetailedVendorLedgEntry.Amount := 0;
        VarDetailedVendorLedgEntry."Vendor No." := InitVendorLedgerEntry."Vendor No.";
        VarDetailedVendorLedgEntry."Currency Code" := InitVendorLedgerEntry."Currency Code";
        VarDetailedVendorLedgEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(VarDetailedVendorLedgEntry."User ID"));
        VarDetailedVendorLedgEntry."Source Code" := SourceCodeSetup."Exchange Rate Adjmt.";
        VarDetailedVendorLedgEntry."Journal Batch Name" := InitVendorLedgerEntry."Journal Batch Name";
        VarDetailedVendorLedgEntry."Reason Code" := InitVendorLedgerEntry."Reason Code";
        VarDetailedVendorLedgEntry."Initial Entry Due Date" := InitVendorLedgerEntry."Due Date";
        VarDetailedVendorLedgEntry."Initial Entry Global Dim. 1" := InitVendorLedgerEntry."Global Dimension 1 Code";
        VarDetailedVendorLedgEntry."Initial Entry Global Dim. 2" := InitVendorLedgerEntry."Global Dimension 2 Code";
        VarDetailedVendorLedgEntry."Initial Document Type" := InitVendorLedgerEntry."Document Type";

        OnAfterInitDtldVendLedgerEntry(VarDetailedVendorLedgEntry);
    end;

    local procedure InitDtldEmplLedgEntry(InitEmployeeLedgerEntry: Record "Employee Ledger Entry"; var VarDetailedEmployeeLedgerEntry: Record "Detailed Employee Ledger Entry")
    begin
        VarDetailedEmployeeLedgerEntry.Init();
        VarDetailedEmployeeLedgerEntry."Employee Ledger Entry No." := InitEmployeeLedgerEntry."Entry No.";
        VarDetailedEmployeeLedgerEntry.Amount := 0;
        VarDetailedEmployeeLedgerEntry."Employee No." := InitEmployeeLedgerEntry."Employee No.";
        VarDetailedEmployeeLedgerEntry."Currency Code" := InitEmployeeLedgerEntry."Currency Code";
        VarDetailedEmployeeLedgerEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(VarDetailedEmployeeLedgerEntry."User ID"));
        VarDetailedEmployeeLedgerEntry."Source Code" := SourceCodeSetup."Exchange Rate Adjmt.";
        VarDetailedEmployeeLedgerEntry."Journal Batch Name" := InitEmployeeLedgerEntry."Journal Batch Name";
        VarDetailedEmployeeLedgerEntry."Reason Code" := InitEmployeeLedgerEntry."Reason Code";
        VarDetailedEmployeeLedgerEntry."Initial Entry Global Dim. 1" := InitEmployeeLedgerEntry."Global Dimension 1 Code";
        VarDetailedEmployeeLedgerEntry."Initial Entry Global Dim. 2" := InitEmployeeLedgerEntry."Global Dimension 2 Code";
        VarDetailedEmployeeLedgerEntry."Initial Document Type" := InitEmployeeLedgerEntry."Document Type";

        OnAfterInitDtldEmplLedgerEntry(VarDetailedEmployeeLedgerEntry);
    end;

    local procedure CreateDtldCustLedgEntryUnrealGain(CreateCustLedgerEntry: Record "Cust. Ledger Entry"; var VarDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; DimEntryNo: Integer; PostingDate2: Date; var UpdateBuffer: Boolean; var Adjust: Boolean)
    begin
        CreateDtldCustLedgEntryUnreal(
          CreateCustLedgerEntry, VarDetailedCustLedgEntry, DimEntryNo, PostingDate2,
          UpdateBuffer, Adjust, VarDetailedCustLedgEntry."Entry Type"::"Unrealized Gain");
    end;

    local procedure CreateDtldCustLedgEntryUnrealLoss(CreateCustLedgerEntry: Record "Cust. Ledger Entry"; var VarDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; DimEntryNo: Integer; PostingDate2: Date; var UpdateBuffer: Boolean; var Adjust: Boolean)
    begin
        CreateDtldCustLedgEntryUnreal(
          CreateCustLedgerEntry, VarDetailedCustLedgEntry, DimEntryNo, PostingDate2,
          UpdateBuffer, Adjust, VarDetailedCustLedgEntry."Entry Type"::"Unrealized Loss");
    end;

    local procedure CreateDtldCustLedgEntryUnreal(CreateCustLedgerEntry: Record "Cust. Ledger Entry"; var VarDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; DimEntryNo: Integer; PostingDate2: Date; var UpdateBuffer: Boolean; var Adjust: Boolean; DtldCustLedgEntryType: Enum "Detailed CV Ledger Entry Type")
    var
        AdjExchRateBufIndex: Integer;
    begin
        if Abs(AdjAmount) > Abs(RealGainLossAmt) then begin
            VarDetailedCustLedgEntry."Amount (LCY)" := AdjAmount;
            VarDetailedCustLedgEntry."Entry Type" := DtldCustLedgEntryType;
            HandleCustDebitCredit(Correction, VarDetailedCustLedgEntry."Amount (LCY)");
            InsertTempDtldCustomerLedgerEntry();
            NewEntryNo := NewEntryNo + 1;

            case DtldCustLedgEntryType of
                VarDetailedCustLedgEntry."Entry Type"::"Unrealized Gain":
                    AdjExchRateBufIndex :=
                      AdjExchRateBufferUpdateUnrealGain(
                        CreateCustLedgerEntry."Currency Code", CreateCustLedgerEntry."Customer Posting Group", CreateCustLedgerEntry."Remaining Amount", CreateCustLedgerEntry."Remaining Amt. (LCY)",
                        VarDetailedCustLedgEntry."Amount (LCY)", DimEntryNo, PostingDate2, Customer."IC Partner Code",
                        false,
                        GetInitialGLAccountNo(CreateCustLedgerEntry."Entry No.", 0, CreateCustLedgerEntry."Customer Posting Group"));
                VarDetailedCustLedgEntry."Entry Type"::"Unrealized Loss":
                    AdjExchRateBufIndex :=
                      AdjExchRateBufferUpdateUnrealLoss(
                        CreateCustLedgerEntry."Currency Code", CreateCustLedgerEntry."Customer Posting Group", CreateCustLedgerEntry."Remaining Amount", CreateCustLedgerEntry."Remaining Amt. (LCY)",
                        VarDetailedCustLedgEntry."Amount (LCY)", DimEntryNo, PostingDate2, Customer."IC Partner Code",
                        false,
                        GetInitialGLAccountNo(CreateCustLedgerEntry."Entry No.", 0, CreateCustLedgerEntry."Customer Posting Group"));
            end;

            TempAdjExchangeRateBufferCZL."Document Type" := CreateCustLedgerEntry."Document Type";
            TempAdjExchangeRateBufferCZL."Document No." := CreateCustLedgerEntry."Document No.";
            OnCreateDtldCustLedgEntryUnrealOnBeforeModifyBuffer(TempAdjExchangeRateBufferCZL, CreateCustLedgerEntry);
            TempAdjExchangeRateBufferCZL.Modify();

            VarDetailedCustLedgEntry."Transaction No." := AdjExchRateBufIndex;
            ModifyTempDtldCustomerLedgerEntry();

            UpdateBuffer := false;
            Adjust := true;
        end else begin
            VarDetailedCustLedgEntry."Amount (LCY)" := AdjAmount;
            VarDetailedCustLedgEntry."Entry Type" := DtldCustLedgEntryType;
            HandleCustDebitCredit(Correction, VarDetailedCustLedgEntry."Amount (LCY)");
            case DtldCustLedgEntryType of
                VarDetailedCustLedgEntry."Entry Type"::"Unrealized Gain":
                    GainsAmount := AdjAmount;
                VarDetailedCustLedgEntry."Entry Type"::"Unrealized Loss":
                    LossesAmount := AdjAmount;
            end;
            InsertTempDtldCustomerLedgerEntry();
            NewEntryNo := NewEntryNo + 1;
            Adjust := true;
        end;
    end;

    local procedure CreateDtldVendLedgEntryUnrealGain(CreateVendorLedgerEntry: Record "Vendor Ledger Entry"; var VarDetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; DimEntryNo: Integer; PostingDate2: Date; var UpdateBuffer: Boolean; var Adjust: Boolean)
    begin
        CreateDtldVendLedgEntryUnreal(
          CreateVendorLedgerEntry, VarDetailedVendorLedgEntry, DimEntryNo, PostingDate2,
          UpdateBuffer, Adjust, VarDetailedVendorLedgEntry."Entry Type"::"Unrealized Gain");
    end;

    local procedure CreateDtldVendLedgEntryUnrealLoss(CreateVendorLedgerEntry: Record "Vendor Ledger Entry"; var VarDetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; DimEntryNo: Integer; PostingDate2: Date; var UpdateBuffer: Boolean; var Adjust: Boolean)
    begin
        CreateDtldVendLedgEntryUnreal(
          CreateVendorLedgerEntry, VarDetailedVendorLedgEntry, DimEntryNo, PostingDate2,
          UpdateBuffer, Adjust, VarDetailedVendorLedgEntry."Entry Type"::"Unrealized Loss");
    end;

    local procedure CreateDtldVendLedgEntryUnreal(CreateVendorLedgerEntry: Record "Vendor Ledger Entry"; var VarDetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; DimEntryNo: Integer; PostingDate2: Date; var UpdateBuffer: Boolean; var Adjust: Boolean; DtldVendLedgEntryType: Enum "Detailed CV Ledger Entry Type")
    var
        AdjExchRateBufIndex: Integer;
    begin
        if Abs(AdjAmount) > Abs(RealGainLossAmt) then begin
            VarDetailedVendorLedgEntry."Amount (LCY)" := AdjAmount;
            VarDetailedVendorLedgEntry."Entry Type" := DtldVendLedgEntryType;
            HandleVendDebitCredit(Correction, VarDetailedVendorLedgEntry."Amount (LCY)");
            InsertTempDtldVendorLedgerEntry();
            NewEntryNo := NewEntryNo + 1;

            case DtldVendLedgEntryType of
                VarDetailedVendorLedgEntry."Entry Type"::"Unrealized Gain":
                    AdjExchRateBufIndex :=
                      AdjExchRateBufferUpdateUnrealGain(
                        CreateVendorLedgerEntry."Currency Code", CreateVendorLedgerEntry."Vendor Posting Group", CreateVendorLedgerEntry."Remaining Amount", CreateVendorLedgerEntry."Remaining Amt. (LCY)",
                        VarDetailedVendorLedgEntry."Amount (LCY)", DimEntryNo, PostingDate2, Vendor."IC Partner Code",
                        false,
                        GetInitialGLAccountNo(CreateVendorLedgerEntry."Entry No.", 1, CreateVendorLedgerEntry."Vendor Posting Group"));
                VarDetailedVendorLedgEntry."Entry Type"::"Unrealized Loss":
                    AdjExchRateBufIndex :=
                      AdjExchRateBufferUpdateUnrealLoss(
                        CreateVendorLedgerEntry."Currency Code", CreateVendorLedgerEntry."Vendor Posting Group", CreateVendorLedgerEntry."Remaining Amount", CreateVendorLedgerEntry."Remaining Amt. (LCY)",
                        VarDetailedVendorLedgEntry."Amount (LCY)", DimEntryNo, PostingDate2, Vendor."IC Partner Code",
                        false,
                        GetInitialGLAccountNo(CreateVendorLedgerEntry."Entry No.", 1, CreateVendorLedgerEntry."Vendor Posting Group"));
            end;

            TempAdjExchangeRateBufferCZL."Document Type" := CreateVendorLedgerEntry."Document Type";
            TempAdjExchangeRateBufferCZL."Document No." := CreateVendorLedgerEntry."Document No.";
            OnCreateDtldVendLedgEntryUnrealOnBeforeModifyBuffer(TempAdjExchangeRateBufferCZL, CreateVendorLedgerEntry);
            TempAdjExchangeRateBufferCZL.Modify();

            VarDetailedVendorLedgEntry."Transaction No." := AdjExchRateBufIndex;
            ModifyTempDtldVendorLedgerEntry();

            UpdateBuffer := false;
            Adjust := true;
        end else begin
            VarDetailedVendorLedgEntry."Amount (LCY)" := AdjAmount;
            VarDetailedVendorLedgEntry."Entry Type" := DtldVendLedgEntryType;
            HandleVendDebitCredit(Correction, VarDetailedVendorLedgEntry."Amount (LCY)");
            case DtldVendLedgEntryType of
                DetailedCustLedgEntry."Entry Type"::"Unrealized Gain":
                    GainsAmount := AdjAmount;
                DetailedCustLedgEntry."Entry Type"::"Unrealized Loss":
                    LossesAmount := AdjAmount;
            end;
            InsertTempDtldVendorLedgerEntry();
            NewEntryNo := NewEntryNo + 1;
            Adjust := true;
        end;
    end;

    local procedure CreateDtldEmployeeLedgEntryUnrealGain(CreateEmployeeLedgerEntry: Record "Employee Ledger Entry"; var VarDetailedEmployeeLedgerEntry: Record "Detailed Employee Ledger Entry"; DimEntryNo: Integer; PostingDate2: Date; var UpdateBuffer: Boolean; var Adjust: Boolean)
    begin
        CreateDtldEmployeeLedgEntryUnreal(
          CreateEmployeeLedgerEntry, VarDetailedEmployeeLedgerEntry, DimEntryNo, PostingDate2,
          UpdateBuffer, Adjust, VarDetailedEmployeeLedgerEntry."Entry Type"::"Unrealized Gain");
    end;

    local procedure CreateDtldEmployeeLedgEntryUnrealLoss(CreateEmployeeLedgerEntry: Record "Employee Ledger Entry"; var VarDetailedEmployeeLedgerEntry: Record "Detailed Employee Ledger Entry"; DimEntryNo: Integer; PostingDate2: Date; var UpdateBuffer: Boolean; var Adjust: Boolean)
    begin
        CreateDtldEmployeeLedgEntryUnreal(
          CreateEmployeeLedgerEntry, VarDetailedEmployeeLedgerEntry, DimEntryNo, PostingDate2,
          UpdateBuffer, Adjust, VarDetailedEmployeeLedgerEntry."Entry Type"::"Unrealized Loss");
    end;

    local procedure CreateDtldEmployeeLedgEntryUnreal(CreateEmployeeLedgerEntry: Record "Employee Ledger Entry"; var VarDetailedEmployeeLedgerEntry: Record "Detailed Employee Ledger Entry"; DimEntryNo: Integer; PostingDate2: Date; var UpdateBuffer: Boolean; var Adjust: Boolean; DtldEmoloyeeLedgEntryType: Enum "Detailed CV Ledger Entry Type")
    var
        AdjExchRateBufIndex: Integer;
    begin
        if Abs(AdjAmount) > Abs(RealGainLossAmt) then begin
            VarDetailedEmployeeLedgerEntry."Amount (LCY)" := AdjAmount;
            VarDetailedEmployeeLedgerEntry."Entry Type" := DtldEmoloyeeLedgEntryType;
            HandleVendDebitCredit(Correction, VarDetailedEmployeeLedgerEntry."Amount (LCY)");
            InsertTempDtldEmployeeLedgerEntry();
            NewEntryNo := NewEntryNo + 1;

            case DtldEmoloyeeLedgEntryType of
                VarDetailedEmployeeLedgerEntry."Entry Type"::"Unrealized Gain":
                    AdjExchRateBufIndex :=
                      AdjExchRateBufferUpdateUnrealGain(
                        CreateEmployeeLedgerEntry."Currency Code", CreateEmployeeLedgerEntry."Employee Posting Group", CreateEmployeeLedgerEntry."Remaining Amount", CreateEmployeeLedgerEntry."Remaining Amt. (LCY)",
                        VarDetailedEmployeeLedgerEntry."Amount (LCY)", DimEntryNo, PostingDate2, '',
                        false,
                        GetInitialGLAccountNo(CreateEmployeeLedgerEntry."Entry No.", 2, CreateEmployeeLedgerEntry."Employee Posting Group"));
                VarDetailedEmployeeLedgerEntry."Entry Type"::"Unrealized Loss":
                    AdjExchRateBufIndex :=
                      AdjExchRateBufferUpdateUnrealLoss(
                        CreateEmployeeLedgerEntry."Currency Code", CreateEmployeeLedgerEntry."Employee Posting Group", CreateEmployeeLedgerEntry."Remaining Amount", CreateEmployeeLedgerEntry."Remaining Amt. (LCY)",
                        VarDetailedEmployeeLedgerEntry."Amount (LCY)", DimEntryNo, PostingDate2, '',
                        false,
                        GetInitialGLAccountNo(CreateEmployeeLedgerEntry."Entry No.", 2, CreateEmployeeLedgerEntry."Employee Posting Group"));
            end;

            TempAdjExchangeRateBufferCZL."Document Type" := CreateEmployeeLedgerEntry."Document Type";
            TempAdjExchangeRateBufferCZL."Document No." := CreateEmployeeLedgerEntry."Document No.";
            OnCreateDtldEmployeeLedgEntryUnrealOnBeforeModifyBuffer(TempAdjExchangeRateBufferCZL, CreateEmployeeLedgerEntry);
            TempAdjExchangeRateBufferCZL.Modify();

            VarDetailedEmployeeLedgerEntry."Transaction No." := AdjExchRateBufIndex;
            ModifyTempDtldEmployeeLedgerEntry();

            UpdateBuffer := false;
            Adjust := true;
        end else begin
            VarDetailedEmployeeLedgerEntry."Amount (LCY)" := AdjAmount;
            VarDetailedEmployeeLedgerEntry."Entry Type" := DtldEmoloyeeLedgEntryType;
            HandleVendDebitCredit(Correction, VarDetailedEmployeeLedgerEntry."Amount (LCY)");
            case DtldEmoloyeeLedgEntryType of
                DetailedCustLedgEntry."Entry Type"::"Unrealized Gain":
                    GainsAmount := AdjAmount;
                DetailedCustLedgEntry."Entry Type"::"Unrealized Loss":
                    LossesAmount := AdjAmount;
            end;
            InsertTempDtldEmployeeLedgerEntry();
            NewEntryNo := NewEntryNo + 1;
            Adjust := true;
        end;
    end;

    local procedure SetUnrealizedGainLossFilterCust(var VarDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; EntryNo: Integer)
    begin
        VarDetailedCustLedgEntry.Reset();
        VarDetailedCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.", "Entry Type");
        VarDetailedCustLedgEntry.SetRange("Cust. Ledger Entry No.", EntryNo);
        VarDetailedCustLedgEntry.SetRange("Entry Type", VarDetailedCustLedgEntry."Entry Type"::"Unrealized Loss", VarDetailedCustLedgEntry."Entry Type"::"Unrealized Gain");
    end;

    local procedure SetUnrealizedGainLossFilterVend(var VarDetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; EntryNo: Integer)
    begin
        VarDetailedVendorLedgEntry.Reset();
        VarDetailedVendorLedgEntry.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type");
        VarDetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", EntryNo);
        VarDetailedVendorLedgEntry.SetRange("Entry Type", VarDetailedVendorLedgEntry."Entry Type"::"Unrealized Loss", VarDetailedVendorLedgEntry."Entry Type"::"Unrealized Gain");
    end;

    local procedure SetUnrealizedGainLossFilterEmpl(var VarDetailedEmployeeLedgerEntry: Record "Detailed Employee Ledger Entry"; EntryNo: Integer)
    begin
        VarDetailedEmployeeLedgerEntry.Reset();
        VarDetailedEmployeeLedgerEntry.SetCurrentKey("Employee Ledger Entry No.", "Entry Type");
        VarDetailedEmployeeLedgerEntry.SetRange("Employee Ledger Entry No.", EntryNo);
        VarDetailedEmployeeLedgerEntry.SetRange("Entry Type", VarDetailedEmployeeLedgerEntry."Entry Type"::"Unrealized Loss", VarDetailedEmployeeLedgerEntry."Entry Type"::"Unrealized Gain");
    end;

    local procedure InsertTempDtldCustomerLedgerEntry()
    begin
        TempDetailedCustLedgEntry.Insert();
        TempSumsDetailedCustLedgEntry := TempDetailedCustLedgEntry;
        TempSumsDetailedCustLedgEntry.Insert();
    end;

    local procedure InsertTempDtldVendorLedgerEntry()
    begin
        TempDetailedVendorLedgEntry.Insert();
        TempSumsDetailedVendorLedgEntry := TempDetailedVendorLedgEntry;
        TempSumsDetailedVendorLedgEntry.Insert();
    end;

    local procedure InsertTempDtldEmployeeLedgerEntry()
    begin
        TempDetailedEmployeeLedgerEntry.Insert();
        TempSumsDetailedEmployeeLedgerEntry := TempDetailedEmployeeLedgerEntry;
        TempSumsDetailedEmployeeLedgerEntry.Insert();
    end;

    local procedure ModifyTempDtldCustomerLedgerEntry()
    begin
        TempDetailedCustLedgEntry.Modify();
        TempSumsDetailedCustLedgEntry := TempDetailedCustLedgEntry;
        TempSumsDetailedCustLedgEntry.Modify();
    end;

    local procedure ModifyTempDtldVendorLedgerEntry()
    begin
        TempDetailedVendorLedgEntry.Modify();
        TempSumsDetailedVendorLedgEntry := TempDetailedVendorLedgEntry;
        TempSumsDetailedVendorLedgEntry.Modify();
    end;

    local procedure ModifyTempDtldEmployeeLedgerEntry()
    begin
        TempDetailedEmployeeLedgerEntry.Modify();
        TempSumsDetailedEmployeeLedgerEntry := TempDetailedEmployeeLedgerEntry;
        TempSumsDetailedEmployeeLedgerEntry.Modify();
    end;

    procedure InitializeRequestExtended(NewStartDate: Date; NewEndDate: Date; NewPostingDescription: Text[100]; NewPostingDate: Date; NewPostingDocNo: Code[20]; NewAdjCust: Boolean; NewAdjVend: Boolean; NewAdjBank: Boolean; NewAdjGLAcc: Boolean; NewSummarizeEntries: Boolean)
    begin
        InitializeRequestExtended(NewStartDate, NewEndDate, NewPostingDescription, NewPostingDate, NewPostingDocNo, NewAdjCust, NewAdjVend, NewAdjBank, NewAdjGLAcc, NewSummarizeEntries, false);
    end;

    procedure InitializeRequestExtended(NewStartDate: Date; NewEndDate: Date; NewPostingDescription: Text[100]; NewPostingDate: Date; NewPostingDocNo: Code[20]; NewAdjCust: Boolean; NewAdjVend: Boolean; NewAdjBank: Boolean; NewAdjGLAcc: Boolean; NewSummarizeEntries: Boolean; NewAdjEmpl: Boolean)
    begin
        InitializeRequest(NewStartDate, NewEndDate, NewPostingDescription, NewPostingDate);
        PostingDocNo := NewPostingDocNo;
        AdjCust := NewAdjCust;
        AdjVend := NewAdjVend;
        AdjBank := NewAdjBank;
        AdjGLAcc := NewAdjGLAcc;
        AdjEmpl := NewAdjEmpl;
        SummarizeEntries := NewSummarizeEntries;
    end;

    procedure SetPostMode(NewPostMode: Boolean)
    begin
        Post := NewPostMode;
    end;

    procedure SetDimMoveType(NewDimMoveType: Option "No move","Source Entry","By G/L Account")
    begin
        DimMoveType := NewDimMoveType;
    end;

    procedure CreateCustRealGainLossEntries(var ThreeDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry")
    var
        FourDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        Temp2DetailedCustLedgEntry.Reset();
        Temp2DetailedCustLedgEntry.DeleteAll();
        FourDetailedCustLedgEntry.Copy(ThreeDetailedCustLedgEntry);
        if FourDetailedCustLedgEntry.FindSet() then
            repeat
                TwoDetailedCustLedgEntry.Reset();
                TwoDetailedCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
                TwoDetailedCustLedgEntry.SetRange("Cust. Ledger Entry No.", FourDetailedCustLedgEntry."Applied Cust. Ledger Entry No.");
                TwoDetailedCustLedgEntry.SetRange(
                  "Entry Type",
                  TwoDetailedCustLedgEntry."Entry Type"::"Realized Loss",
                  TwoDetailedCustLedgEntry."Entry Type"::"Realized Gain");
                if TwoDetailedCustLedgEntry.FindSet() then
                    repeat
                        if TwoDetailedCustLedgEntry."Cust. Ledger Entry No." <> FourDetailedCustLedgEntry."Cust. Ledger Entry No." then begin
                            Temp2DetailedCustLedgEntry.Init();
                            Temp2DetailedCustLedgEntry.TransferFields(TwoDetailedCustLedgEntry);
                            if not Temp2DetailedCustLedgEntry.Insert() then
                                Temp2DetailedCustLedgEntry.Init();
                        end;
                    until TwoDetailedCustLedgEntry.Next() = 0;
            until FourDetailedCustLedgEntry.Next() = 0;
    end;

    procedure CalcCustRealGainLossAmount(CustLedgEntryNo: Integer; EntryPostingDate: Date)
    begin
        if not SummarizeEntries then
            RealGainLossAmt := 0;

        TwoDetailedCustLedgEntry.Reset();
        TwoDetailedCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
        TwoDetailedCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgEntryNo);
        TwoDetailedCustLedgEntry.SetRange("Posting Date", EntryPostingDate);
        TwoDetailedCustLedgEntry.SetRange(
          "Entry Type",
          TwoDetailedCustLedgEntry."Entry Type"::"Realized Loss",
          TwoDetailedCustLedgEntry."Entry Type"::"Realized Gain");
        TwoDetailedCustLedgEntry.CalcSums("Amount (LCY)");

        Temp2DetailedCustLedgEntry.SetRange("Posting Date", EntryPostingDate);
        Temp2DetailedCustLedgEntry.CalcSums("Amount (LCY)");

        RealGainLossAmt := TwoDetailedCustLedgEntry."Amount (LCY)" + Temp2DetailedCustLedgEntry."Amount (LCY)";
    end;

    procedure CreateVendRealGainLossEntries(var ThreeDetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry")
    var
        FourDetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        Temp2DetailedVendorLedgEntry.Reset();
        Temp2DetailedVendorLedgEntry.DeleteAll();
        FourDetailedVendorLedgEntry.Copy(ThreeDetailedVendorLedgEntry);
        if FourDetailedVendorLedgEntry.FindSet() then
            repeat
                TwoDetailedVendorLedgEntry.Reset();
                TwoDetailedVendorLedgEntry.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type", "Posting Date");
                TwoDetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", FourDetailedVendorLedgEntry."Applied Vend. Ledger Entry No.");
                TwoDetailedVendorLedgEntry.SetRange(
                  "Entry Type",
                  TwoDetailedVendorLedgEntry."Entry Type"::"Realized Loss",
                  TwoDetailedVendorLedgEntry."Entry Type"::"Realized Gain");
                if TwoDetailedVendorLedgEntry.FindSet() then
                    repeat
                        if TwoDetailedVendorLedgEntry."Vendor Ledger Entry No." <> FourDetailedVendorLedgEntry."Vendor Ledger Entry No." then begin
                            Temp2DetailedVendorLedgEntry.Init();
                            Temp2DetailedVendorLedgEntry.TransferFields(TwoDetailedVendorLedgEntry);
                            if not Temp2DetailedVendorLedgEntry.Insert() then
                                Temp2DetailedVendorLedgEntry.Init();
                        end;
                    until TwoDetailedVendorLedgEntry.Next() = 0;
            until FourDetailedVendorLedgEntry.Next() = 0;
    end;

    procedure CalcVendRealGainLossAmount(VendLedgEntryNo: Integer; EntryPostingDate: Date)
    begin
        if not SummarizeEntries then
            RealGainLossAmt := 0;

        TwoDetailedVendorLedgEntry.Reset();
        TwoDetailedVendorLedgEntry.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type", "Posting Date");
        TwoDetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", VendLedgEntryNo);
        TwoDetailedVendorLedgEntry.SetRange("Posting Date", EntryPostingDate);
        TwoDetailedVendorLedgEntry.SetRange(
          "Entry Type",
          TwoDetailedVendorLedgEntry."Entry Type"::"Realized Loss",
          TwoDetailedVendorLedgEntry."Entry Type"::"Realized Gain");
        TwoDetailedVendorLedgEntry.CalcSums("Amount (LCY)");

        Temp2DetailedVendorLedgEntry.SetRange("Posting Date", EntryPostingDate);
        Temp2DetailedVendorLedgEntry.CalcSums("Amount (LCY)");

        RealGainLossAmt := TwoDetailedVendorLedgEntry."Amount (LCY)" + Temp2DetailedVendorLedgEntry."Amount (LCY)";
    end;

    local procedure CreateEmployeeRealGainLossEntries(var VarDetailedEmployeeLedgerentry: Record "Detailed Employee Ledger Entry")
    var
        FilterDetailedEmployeeLedgerEntry: Record "Detailed Employee Ledger Entry";
    begin
        Temp2DetailedEmployeeLedgerEntry.Reset();
        Temp2DetailedEmployeeLedgerEntry.DeleteAll();
        FilterDetailedEmployeeLedgerEntry.Copy(VarDetailedEmployeeLedgerentry);
        if FilterDetailedEmployeeLedgerEntry.FindSet() then
            repeat
                TwoDetailedEmployeeLedgerEntry.Reset();
                TwoDetailedEmployeeLedgerEntry.SetCurrentKey("Employee Ledger Entry No.", "Entry Type", "Posting Date");
                TwoDetailedEmployeeLedgerEntry.SetRange("Employee Ledger Entry No.", FilterDetailedEmployeeLedgerEntry."Applied Empl. Ledger Entry No.");
                TwoDetailedEmployeeLedgerEntry.SetRange(
                  "Entry Type",
                  TwoDetailedEmployeeLedgerEntry."Entry Type"::"Realized Loss",
                  TwoDetailedEmployeeLedgerEntry."Entry Type"::"Realized Gain");
                if TwoDetailedEmployeeLedgerEntry.FindSet() then
                    repeat
                        if TwoDetailedEmployeeLedgerEntry."Employee Ledger Entry No." <> FilterDetailedEmployeeLedgerEntry."Employee Ledger Entry No." then begin
                            Temp2DetailedEmployeeLedgerEntry.Init();
                            Temp2DetailedEmployeeLedgerEntry.TransferFields(TwoDetailedEmployeeLedgerEntry);
                            if not Temp2DetailedEmployeeLedgerEntry.Insert() then
                                Temp2DetailedEmployeeLedgerEntry.Init();
                        end;
                    until TwoDetailedEmployeeLedgerEntry.Next() = 0;
            until FilterDetailedEmployeeLedgerEntry.Next() = 0;
    end;

    local procedure CalcEmployeeRealGainLossAmount(EmployeeLedgerEntryNo: Integer; EntryPostingDate: Date)
    begin
        if not SummarizeEntries then
            RealGainLossAmt := 0;

        TwoDetailedEmployeeLedgerEntry.Reset();
        TwoDetailedEmployeeLedgerEntry.SetCurrentKey("Employee Ledger Entry No.", "Entry Type", "Posting Date");
        TwoDetailedEmployeeLedgerEntry.SetRange("Employee Ledger Entry No.", EmployeeLedgerEntryNo);
        TwoDetailedEmployeeLedgerEntry.SetRange("Posting Date", EntryPostingDate);
        TwoDetailedEmployeeLedgerEntry.SetRange(
          "Entry Type",
          TwoDetailedEmployeeLedgerEntry."Entry Type"::"Realized Loss",
          TwoDetailedEmployeeLedgerEntry."Entry Type"::"Realized Gain");
        TwoDetailedEmployeeLedgerEntry.CalcSums("Amount (LCY)");

        Temp2DetailedEmployeeLedgerEntry.SetRange("Posting Date", EntryPostingDate);
        Temp2DetailedEmployeeLedgerEntry.CalcSums("Amount (LCY)");

        RealGainLossAmt := TwoDetailedEmployeeLedgerEntry."Amount (LCY)" + Temp2DetailedEmployeeLedgerEntry."Amount (LCY)";
    end;

    procedure GetInitialGLAccountNo(InitialEntryNo: Integer; SourceType: Option Customer,Vendor,Employee; PostingGroup: Code[20]): Code[20]
    var
        GLEntry: Record "G/L Entry";
    begin
        if GLEntry.Get(InitialEntryNo) then
            exit(GLEntry."G/L Account No.");

        if SourceType = SourceType::Customer then
            exit(CustLedgerEntry.GetReceivablesAccNoCZL());
        if SourceType = SourceType::Vendor then
            exit(VendorLedgerEntry.GetPayablesAccNoCZL());
        if SourceType = SourceType::Employee then
            exit(EmployeeLedgerEntry.GetPayablesAccNoCZL());
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnInitReport(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDtldCustLedgerEntry(var DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDtldVendLedgerEntry(var DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDtldEmplLedgerEntry(var DetailedEmployeeLedgEntry: Record "Detailed Employee Ledger Entry")
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnCustomerAfterGetRecordOnAfterFindCustLedgerEntriesToAdjust(var TempCustLedgerEntry: Record "Cust. Ledger Entry" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnVendorAfterGetRecordOnAfterFindVendLedgerEntriesToAdjust(var TempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAdjustCustomerLedgerEntryOnBeforeInitDtldCustLedgEntry(var Customer: Record Customer; CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAdjustVendorLedgerEntryOnBeforeInitDtldVendLedgEntry(var Vendor: Record Vendor; VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAdjustEmployeeLedgerEntryOnBeforeInitDtldEmplLedgEntry(var Employee: Record Employee; EmplLedgerEntry: Record "Employee Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnEmployeeAfterGetRecordOnAfterFindEmplLedgerEntriesToAdjust(var TempEmployeeLedgerEntry: Record "Employee Ledger Entry" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenPage(var AdjCust: Boolean; var AdjVend: Boolean; var AdjBank: Boolean; var AdjGLAcc: Boolean; var PostingDocNo: Code[20]; var AdjEmpl: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCloseRequestPage()
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnPostGenJnlLineOnBeforeGenJnlPostLineRun(var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line"; var DimensionSetEntry: Record "Dimension Set Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdjmtOnBeforePostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; SummarizeEntries: Boolean; AdjExchangeRateBufferCZL: Record "Adj. Exchange Rate Buffer CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandlePostAdjmtOnAfterUpdateBuffer(var NewAdjExchangeRateBufferCZL: Record "Adj. Exchange Rate Buffer CZL"; AdjExchangeRateBufferCZL: Record "Adj. Exchange Rate Buffer CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAdjustCustomerLedgerEntryOnBeforeModifyBuffer(var AdjExchangeRateBufferCZL: Record "Adj. Exchange Rate Buffer CZL"; CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAdjustVendorLedgerEntryOnBeforeModifyBuffer(var AdjExchangeRateBufferCZL: Record "Adj. Exchange Rate Buffer CZL"; VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAdjustEmployeeLedgerEntryOnBeforeModifyBuffer(var AdjExchangeRateBufferCZL: Record "Adj. Exchange Rate Buffer CZL"; EmployeeLedgerEntry: Record "Employee Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateDtldCustLedgEntryUnrealOnBeforeModifyBuffer(var AdjExchangeRateBufferCZL: Record "Adj. Exchange Rate Buffer CZL"; CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateDtldVendLedgEntryUnrealOnBeforeModifyBuffer(var AdjExchangeRateBufferCZL: Record "Adj. Exchange Rate Buffer CZL"; VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateDtldEmployeeLedgEntryUnrealOnBeforeModifyBuffer(var AdjExchangeRateBufferCZL: Record "Adj. Exchange Rate Buffer CZL"; EmployeeLedgerEntry: Record "Employee Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAdjustBankAccountOnBeforePost(var AdjExchangeRateBufferCZL: Record "Adj. Exchange Rate Buffer CZL"; BankAccount: Record "Bank Account")
    begin
    end;
}
