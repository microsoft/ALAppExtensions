// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Reports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Foundation.Period;
using System.Utilities;

report 11712 "General Ledger CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/GeneralLedger.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'General Ledger';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(GLAccount; "G/L Account")
        {
            DataItemTableView = sorting("No.") where("Account Type" = filter(Posting));
            RequestFilterFields = "No.", "Date Filter";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(GLAccount_Filters; GLAccountFilters)
            {
            }
            column(GLAccountNo; GLAccountNo)
            {
            }
            column(GLAccountName; GLAccountName)
            {
            }
            column(StartDate; StartDate)
            {
            }
            column(EndDate; EndDate)
            {
            }
            column(StartDebit; StartDebit)
            {
            }
            column(StartCredit; StartCredit)
            {
            }
            column(Sums; Sums)
            {
            }
            column(Entries; Entries)
            {
            }
            dataitem(AccountingPeriod; "Accounting Period")
            {
                DataItemTableView = sorting("Starting Date");
                column(StartPeriod; StartPeriod)
                {
                }
                column(EndPeriod; EndPeriod)
                {
                }
                dataitem(GLEntry; "G/L Entry")
                {
                    DataItemTableView = sorting("G/L Account No.", "Posting Date");
                    column(GLEntry_GLAccountNo; "G/L Account No.")
                    {
                    }
                    column(GLEntry_PostingDate; "Posting Date")
                    {
                        IncludeCaption = true;
                    }
                    column(GLEntry_DocumentNo; "Document No.")
                    {
                        IncludeCaption = true;
                    }
                    column(GLEntry_Description; Description)
                    {
                        IncludeCaption = true;
                    }
                    column(GLEntry_DebitAmount; "Debit Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(GLEntry_CreditAmount; "Credit Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(GLEntry_Amount; Amount)
                    {
                    }
                    column(GLEntry_EntryNo; "Entry No.")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Sums then begin
                            NetChangePeriodDebit += GLEntry."Debit Amount";
                            NetChangePeriodCredit += GLEntry."Credit Amount";
                            EndPeriodDebit += GLEntry."Debit Amount";
                            EndPeriodCredit += GLEntry."Credit Amount";
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetFilter("G/L Account No.", GetGLAccountNoFilter());
                        SetRange("Posting Date", StartPeriod, EndPeriod);
                        SetFilter("Global Dimension 1 Code", GLAccount.GetFilter("Global Dimension 1 Filter"));
                        SetFilter("Global Dimension 2 Code", GLAccount.GetFilter("Global Dimension 2 Filter"));
                        SetFilter("Business Unit Code", GLAccount.GetFilter("Business Unit Filter"));
                        SetRange("Entry No.", 1, LastEntryNo);
                    end;
                }
                dataitem(TotalPeriod; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(TotalPeriod_NetChangePeriodDebit; NetChangePeriodDebit)
                    {
                    }
                    column(TotalPeriod_NetChangePeriodCredit; NetChangePeriodCredit)
                    {
                    }
                    column(TotalPeriod_EndPeriodDebit; EndPeriodDebit)
                    {
                    }
                    column(TotalPeriod_EndPeriodCredit; EndPeriodCredit)
                    {
                    }
                    column(TotalPeriod_Number; Number)
                    {
                    }
                }
                trigger OnAfterGetRecord()
                begin
                    StartPeriod := GetAccountingStartPeriod("Starting Date");
                    EndPeriod := GetAccountingEndPeriod("Starting Date");

                    if not Sums then
                        FindLast();

                    NetChangePeriodDebit := 0;
                    NetChangePeriodCredit := 0;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Starting Date", GetAccountingStartDate(), EndDate);
                    EndPeriodDebit := StartDebit;
                    EndPeriodCredit := StartCredit;
                end;
            }
            dataitem(TotalAccount; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(TotalAccount_EndDebit; EndDebit)
                {
                }
                column(TotalAccount_EndCredit; EndCredit)
                {
                }
                column(TotalAccount_NetChangeDebit; NetChangeDebit)
                {
                }
                column(TotalAccount_NetChangeCredit; NetChangeCredit)
                {
                }
                column(TotalAccount_Number; Number)
                {
                }
            }

            trigger OnAfterGetRecord()
            var
                GLAccount2: Record "G/L Account";
                Balance: Decimal;
            begin
                if CreateGLAccountNoByLevel(GLAccount."No.") = GLAccountNo then
                    CurrReport.Skip();

                InitAmounts();
                GLAccountNo := CreateGLAccountNoByLevel(GLAccount."No.");

                if Level = 0 then begin
                    GLAccountName := Name;

                    Balance := CalcBalance(GLAccount);
                    if Balance > 0 then
                        StartDebit := Balance
                    else
                        StartCredit := Abs(Balance);

                    NetChangeDebit := CalcDebit(GLAccount);
                    NetChangeCredit := CalcCredit(GLAccount);
                end else begin
                    GLAccount2.SetFilter("No.", GetGLAccountNoFilter());
                    GLAccount2.SetFilter("Account Type", '<>%1', GLAccount2."Account Type"::Posting);
                    if GLAccount2.FindFirst() then
                        GLAccountName := GLAccount2.Name
                    else
                        GLAccountName := GetGLAccountNoFilter();
                    GLAccount2.SetRange("Account Type", GLAccount2."Account Type"::Posting);
                    if GLAccount2.FindSet() then
                        repeat
                            Balance := CalcBalance(GLAccount2);
                            if Balance > 0 then
                                StartDebit += Balance
                            else
                                StartCredit += Abs(Balance);

                            NetChangeDebit += CalcDebit(GLAccount2);
                            NetChangeCredit += CalcCredit(GLAccount2);
                        until GLAccount2.Next() = 0;
                end;

                EndDebit := StartDebit + NetChangeDebit;
                EndCredit := StartCredit + NetChangeCredit;

                if (StartDebit = 0) and (StartCredit = 0) and (EndDebit = 0) and (EndCredit = 0) then
                    CurrReport.Skip();
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
                    field(LevelField; Level)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Level';
                        ToolTip = 'Specifies the level on G/L account number';
                    }
                    field(SumsField; Sums)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sums per Period';
                        ToolTip = 'Specifies if the sums will be per period';
                    }
                    field(EntriesField; Entries)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print entries';
                        ToolTip = 'Specifies to indicate that detailed documents will print.';
                    }
                    field(IncomeInFYField; IncomeInFY)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Income Only In Current Year';
                        MultiLine = true;
                        ToolTip = 'Specifies if the income only has to be printed only in current year.';
                    }
                }
            }
        }
    }

    labels
    {
        ReportNameLbl = 'General Ledger';
        PageLbl = 'Page';
        AccountNoLbl = 'Account No.';
        AccountNameLbl = 'Account Name';
        BalanceLbl = 'Balance';
        StartBalanceLbl = 'Starting balance to';
        EndBalanceLbl = 'Final balance to';
        NetChangePeriodLbl = 'Net Change period';
        PeriodLbl = 'Period';
    }

    trigger OnPreReport()
    var
        GLAccountFiltersTok: Label '%1: %2', Locked = true;
    begin
        if GLAccount.GetFilters() <> '' then
            GLAccountFilters := StrSubstNo(GLAccountFiltersTok, GLAccount.TableCaption(), GLAccount.GetFilters());
        StartDate := GLAccount.GetRangeMin("Date Filter");
        EndDate := GLAccount.GetRangeMax("Date Filter");
        LastEntryNo := GLEntry.GetLastEntryNo();
    end;

    var
        GLAccountFilters: Text;
        GLAccountName: Text[100];
        GLAccountNo: Code[20];
        StartDebit: Decimal;
        StartCredit: Decimal;
        NetChangeDebit: Decimal;
        NetChangeCredit: Decimal;
        EndDebit: Decimal;
        EndCredit: Decimal;
        NetChangePeriodDebit: Decimal;
        NetChangePeriodCredit: Decimal;
        EndPeriodDebit: Decimal;
        EndPeriodCredit: Decimal;
        StartPeriod: Date;
        EndPeriod: Date;
        StartDate: Date;
        EndDate: Date;
        Level: Integer;
        LastEntryNo: Integer;
        Sums: Boolean;
        Entries: Boolean;
        IncomeInFY: Boolean;

    local procedure CalcBalance(GLAccount: Record "G/L Account"): Decimal
    var
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
    begin
        if IncomeInFY and (GLAccount."Income/Balance" = GLAccount."Income/Balance"::"Income Statement") then begin
            GLAccount.SetFilter("Date Filter", '%1..%2', AccountingPeriodMgt.FindFiscalYear(StartDate), ClosingDate(StartDate - 1));
            GLAccount.CalcFields("Net Change");
            exit(GLAccount."Net Change");
        end;

        GLAccount.SetFilter("Date Filter", '..%1', ClosingDate(StartDate - 1));
        GLAccount.CalcFields("Balance at Date");
        exit(GLAccount."Balance at Date");
    end;

    local procedure CalcCredit(GLAccount: Record "G/L Account"): Decimal
    begin
        GLAccount.SetFilter("Date Filter", '%1..%2', StartDate, EndDate);
        GLAccount.CalcFields("Credit Amount");
        exit(GLAccount."Credit Amount");
    end;

    local procedure CalcDebit(GLAccount: Record "G/L Account"): Decimal
    begin
        GLAccount.SetFilter("Date Filter", '%1..%2', StartDate, EndDate);
        GLAccount.CalcFields("Debit Amount");
        exit(GLAccount."Debit Amount");
    end;

    local procedure GetAccountingStartDate(): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        if AccountingPeriod.Get(StartDate) then
            exit(StartDate);

        AccountingPeriod.SetFilter("Starting Date", '..%1', StartDate);
        if AccountingPeriod.FindLast() then
            exit(AccountingPeriod."Starting Date");
    end;

    local procedure GetAccountingStartPeriod(StartingDate: Date): Date
    begin
        if not Sums then
            exit(StartDate);
        if StartingDate < StartDate then
            exit(StartDate);
        exit(StartingDate);
    end;

    local procedure GetAccountingEndPeriod(StartingDate: Date): Date
    var
        AccountingPeriod: Record "Accounting Period";
        TempEndPeriod: Date;
    begin
        if not Sums then
            exit(EndDate);
        AccountingPeriod.SetFilter("Starting Date", '%1..', CalcDate('<+1D>', StartingDate));
        if not AccountingPeriod.FindFirst() then
            exit(EndDate);
        TempEndPeriod := CalcDate('<-1D>', AccountingPeriod."Starting Date");
        if TempEndPeriod > EndDate then
            exit(EndDate);
        exit(TempEndPeriod);
    end;

    local procedure CreateGLAccountNoByLevel(GLAccountNo: Code[20]): Code[20]
    begin
        if Level = 0 then
            exit(GLAccountNo);
        exit(CopyStr(CopyStr(GLAccountNo, 1, Level), 1, MaxStrLen(GLAccountNo)));
    end;

    local procedure GetGLAccountNoFilter(): Code[20]
    var
        GLAccountNoFilterTok: Label '%1*', Locked = true;
    begin
        if Level = 0 then
            exit(GLAccountNo);
        exit(StrSubstNo(GLAccountNoFilterTok, GLAccountNo));
    end;

    local procedure InitAmounts()
    begin
        StartDebit := 0;
        StartCredit := 0;
        NetChangeDebit := 0;
        NetChangeCredit := 0;
        EndDebit := 0;
        EndCredit := 0;
    end;
}
