// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Receivables;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Customer;
using System.Utilities;

report 11715 "Open Cust. Entries to Date CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/OpenCustEntriestoDate.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Open Customer Entries to Date';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Header; "Integer")
        {
            DataItemTableView = sorting(Number);
            MaxIteration = 1;
            column(USERID; UserId)
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(STRSUBSTNO_gtcText000_gteCustDateFilter_; StrSubstNo(PeriodLbl, CustDateFilter))
            {
            }
            column(gteInfoText; InfoText)
            {
            }
            column(Customer_TABLECAPTION__________gteCustFilter; SecondCustomer.TableCaption + ': ' + CustFilter)
            {
            }
            column(Cust__Ledger_Entry__TABLECAPTION__________gteLedgerEntryFilter; "Cust. Ledger Entry".TableCaption + ': ' + LedgerEntryFilter)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Open_Customer_Entries_at_DateCaption; Open_Customer_Entries_at_DateCaptionLbl)
            {
            }
            column(gboSkipBalance; SkipBalance)
            {
            }
            column(gboPrintCurrency; PrintCurrency)
            {
            }
            column(gboSkipDetail; SkipDetail)
            {
            }
            column(gboSkipTotal; SkipTotal)
            {
            }
            column(gboSkipGLAcc; SkipGLAcc)
            {
            }
            column(gteLedgerEntryFilter; LedgerEntryFilter)
            {
            }
            column(gteCustFilter; CustFilter)
            {
            }
            column(Header_Number; Number)
            {
            }
            column(CustomerNoCaption; SecondCustomer.FieldCaption("No."))
            {
            }
            column(CustomerNameCaption; SecondCustomer.FieldCaption(Name))
            {
            }
            column(Original_AmountCaption; "Cust. Ledger Entry".FieldCaption("Original Amount"))
            {
            }
            column(RemainingAmountCaption; "Cust. Ledger Entry".FieldCaption("Remaining Amount"))
            {
            }
            column(CurrencyCodeCaption; "Cust. Ledger Entry".FieldCaption("Currency Code"))
            {
            }
            column(DueDateCaption; "Cust. Ledger Entry".FieldCaption("Due Date"))
            {
            }
            column(DescriptionCaption; "Cust. Ledger Entry".FieldCaption(Description))
            {
            }
            column(DocumentNoCaption; "Cust. Ledger Entry".FieldCaption("Document No."))
            {
            }
            column(DocumentTypeCaption; "Cust. Ledger Entry".FieldCaption("Document Type"))
            {
            }
            column(PostingDateCaption; "Cust. Ledger Entry".FieldCaption("Posting Date"))
            {
            }
            column(ginDaysAfterDueCaption; DaysAfterDueCaptionLbl)
            {
            }
            dataitem(Customer; Customer)
            {
                DataItemTableView = sorting("No.");
                RequestFilterFields = "No.", "Customer Posting Group", "Date Filter";

                trigger OnPreDataItem()
                begin
                    CurrReport.Break();
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                PrintOnlyIfDetail = true;
                column(greCustomer_Name; SecondCustomer.Name)
                {
                }
                column(greCustomer__No__; SecondCustomer."No.")
                {
                }
                column(Integer_Number; Number)
                {
                }
                dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
                {
                    DataItemTableView = sorting("Customer No.", "Posting Date") order(ascending);
                    RequestFilterFields = "Document Type";
                    column(Cust__Ledger_Entry__Original_Amt___LCY__; "Original Amt. (LCY)")
                    {
                    }
                    column(greGLSetup__LCY_Code_; GeneralLedgerSetup."LCY Code")
                    {
                    }
                    column(ginDaysAfterDue; DaysAfterDue)
                    {
                    }
                    column(Cust__Ledger_Entry_Description; Description)
                    {
                    }
                    column(Cust__Ledger_Entry__Document_No__; "Document No.")
                    {
                    }
                    column(Cust__Ledger_Entry__Document_Type_; "Document Type")
                    {
                    }
                    column(Cust__Ledger_Entry__Posting_Date_; Format("Posting Date"))
                    {
                    }
                    column(Cust__Ledger_Entry__Due_Date_; Format("Due Date"))
                    {
                    }
                    column(Cust__Ledger_Entry__Remaining_Amt___LCY__; "Remaining Amt. (LCY)")
                    {
                    }
                    column(gcoCurrency; CurrencyCode)
                    {
                    }
                    column(Cust__Ledger_Entry__Original_Amount_; "Original Amount")
                    {
                    }
                    column(Cust__Ledger_Entry__Remaining_Amount_; "Remaining Amount")
                    {
                    }
                    column(gdeBalance_1_; Balance[1])
                    {
                    }
                    column(gdeBalance_2_; Balance[2])
                    {
                    }
                    column(gdeBalance_3_; Balance[3])
                    {
                    }
                    column(gdeBalance_4_; Balance[4])
                    {
                    }
                    column(gdeBalance_5_; Balance[5])
                    {
                    }
                    column(gdeBalance_6_; Balance[6])
                    {
                    }
                    column(gdeBalance_7_; Balance[7])
                    {
                    }
                    column(BalanceCaption1; InMatureLbl)
                    {
                    }
                    column(BalanceCaption2; StrSubstNo(ToLbl, LimitDate[1]))
                    {
                    }
                    column(BalanceCaption3; StrSubstNo(ToLbl, LimitDate[2]))
                    {
                    }
                    column(BalanceCaption4; StrSubstNo(ToLbl, LimitDate[3]))
                    {
                    }
                    column(BalanceCaption5; StrSubstNo(ToLbl, LimitDate[4]))
                    {
                    }
                    column(BalanceCaption6; StrSubstNo(ToLbl, LimitDate[5]))
                    {
                    }
                    column(BalanceCaption7; StrSubstNo(OverLbl, LimitDate[5]))
                    {
                    }
                    column(TotalCaption; TotalCaptionLbl)
                    {
                    }
                    column(Cust__Ledger_Entry_Entry_No_; "Entry No.")
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        CalcFields("Original Amt. (LCY)", "Remaining Amt. (LCY)");
                        if PrintCurrency then
                            CalcFields("Original Amount", "Remaining Amount");

                        if not (("Remaining Amt. (LCY)" <> 0) or ("Remaining Amount" <> 0)) then
                            CurrReport.Skip();

                        if "Currency Code" = '' then
                            CurrencyCode := GeneralLedgerSetup."LCY Code"
                        else
                            CurrencyCode := "Currency Code";

                        // calculate days after due date
                        if "Due Date" = 0D then
                            "Due Date" := "Posting Date";
                        DaysAfterDue := LastDate - "Due Date";
                        if DaysAfterDue < 0 then
                            DaysAfterDue := 0;

                        if not SkipBalance then
                            case true of
                                DaysAfterDue <= 0:
                                    begin
                                        Balance[1] += "Remaining Amt. (LCY)";
                                        BalanceT[1] += "Remaining Amt. (LCY)";
                                    end;
                                DaysAfterDue <= Days[1]:
                                    begin
                                        Balance[2] += "Remaining Amt. (LCY)";
                                        BalanceT[2] += "Remaining Amt. (LCY)";
                                    end;
                                DaysAfterDue <= Days[2]:
                                    begin
                                        Balance[3] += "Remaining Amt. (LCY)";
                                        BalanceT[3] += "Remaining Amt. (LCY)";
                                    end;
                                DaysAfterDue <= Days[3]:
                                    begin
                                        Balance[4] += "Remaining Amt. (LCY)";
                                        BalanceT[4] += "Remaining Amt. (LCY)";
                                    end;
                                DaysAfterDue <= Days[4]:
                                    begin
                                        Balance[5] += "Remaining Amt. (LCY)";
                                        BalanceT[5] += "Remaining Amt. (LCY)";
                                    end;
                                DaysAfterDue <= Days[5]:
                                    begin
                                        Balance[6] += "Remaining Amt. (LCY)";
                                        BalanceT[6] += "Remaining Amt. (LCY)";
                                    end;
                                else begin
                                    Balance[7] += "Remaining Amt. (LCY)";
                                    BalanceT[7] += "Remaining Amt. (LCY)";
                                end;
                            end;

                        // buffer for total sumary by G/L account;
                        UpdateBuffer(TempGLAccountNetChange, "Cust. Ledger Entry".GetReceivablesAccNoCZL(), "Remaining Amt. (LCY)", 0);
                        UpdateBuffer(TempTotalCurrencyGLAccountNetChange, '', "Original Amt. (LCY)", "Remaining Amt. (LCY)");

                        if PrintCurrency then begin
                            UpdateBuffer(TempCurrencyGLAccountNetChange, CurrencyCode, "Original Amount", "Remaining Amount");
                            UpdateBuffer(TempTotalCurrencyGLAccountNetChange, CurrencyCode, "Original Amount", "Remaining Amount");
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange("Customer No.", SecondCustomer."No.");
                        SetFilter("Posting Date", CustDateFilter);
                        SetFilter("Date Filter", CustDateFilter);
                        Clear(Balance);
                    end;
                }
                dataitem(CustomerByCurrency; "Integer")
                {
                    DataItemTableView = sorting(Number) order(ascending) where(Number = filter(> 0));
                    column(greTCurrencyBuffer__Net_Change_in_Jnl__; TempCurrencyGLAccountNetChange."Net Change in Jnl.")
                    {
                    }
                    column(greTCurrencyBuffer__Balance_after_Posting_; TempCurrencyGLAccountNetChange."Balance after Posting")
                    {
                    }
                    column(greTCurrencyBuffer__No__; TempCurrencyGLAccountNetChange."No.")
                    {
                    }
                    column(of_itCaption; of_itCaptionLbl)
                    {
                    }
                    column(CustomerByCurrency_Number; Number)
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if Number <> 1 then
                            TempCurrencyGLAccountNetChange.Next();
                    end;

                    trigger OnPreDataItem()
                    begin
                        if not TempCurrencyGLAccountNetChange.FindSet() then
                            CurrReport.Break();
                        SetRange(Number, 1, TempCurrencyGLAccountNetChange.Count);
                    end;
                }
                trigger OnAfterGetRecord()
                var
                    lreCustEntry: Record "Cust. Ledger Entry";
                begin
                    CustActual := CustActual + 1;
                    WindowDialog.Update(1, Round(CustActual / CustCount * 10000, 1));
                    if Number <> 1 then
                        SecondCustomer.Next();

                    if CustActual = CustCount then begin
                        SecondCustomer.Reset();
                        SecondCustomer.Init();
                        SecondCustomer."No." := '';
                        lreCustEntry.SetCurrentKey("Customer No.");
                        lreCustEntry.SetRange("Customer No.", '');
                        if lreCustEntry.IsEmpty() then
                            CurrReport.Skip();
                    end;
                    TempCurrencyGLAccountNetChange.DeleteAll();
                end;

                trigger OnPreDataItem()
                begin
                    if not SecondCustomer.FindSet() then
                        CurrReport.Break();

                    CustCount := SecondCustomer.Count + 1;
                    CustActual := 0;
                    WindowDialog.Open(ProcessingCustomersMsg);
                    SetRange(Number, 1, CustCount);
                end;
            }
            dataitem(TotalByCurrency; "Integer")
            {
                DataItemTableView = sorting(Number) order(ascending) where(Number = filter(> 0));
                column(greTTotalCurrencyBuffer__Net_Change_in_Jnl__; TempTotalCurrencyGLAccountNetChange."Net Change in Jnl.")
                {
                }
                column(greTTotalCurrencyBuffer__Balance_after_Posting_; TempTotalCurrencyGLAccountNetChange."Balance after Posting")
                {
                }
                column(greGLSetup__LCY_Code__Control72; GeneralLedgerSetup."LCY Code")
                {
                }
                column(greTTotalCurrencyBuffer__Net_Change_in_Jnl___Control1104000005; TempTotalCurrencyGLAccountNetChange."Net Change in Jnl.")
                {
                }
                column(greTTotalCurrencyBuffer__Balance_after_Posting__Control1104000009; TempTotalCurrencyGLAccountNetChange."Balance after Posting")
                {
                }
                column(greTTotalCurrencyBuffer__No__; TempTotalCurrencyGLAccountNetChange."No.")
                {
                }
                column(gdeBalanceT_1_; BalanceT[1])
                {
                }
                column(gdeBalanceT_2_; BalanceT[2])
                {
                }
                column(gdeBalanceT_3_; BalanceT[3])
                {
                }
                column(gdeBalanceT_4_; BalanceT[4])
                {
                }
                column(gdeBalanceT_5_; BalanceT[5])
                {
                }
                column(gdeBalanceT_6_; BalanceT[6])
                {
                }
                column(gdeBalanceT_7_; BalanceT[7])
                {
                }
                column(BalanceTCaption1; InMatureLbl)
                {
                }
                column(BalanceTCaption2; StrSubstNo(ToLbl, LimitDate[1]))
                {
                }
                column(BalanceTCaption3; StrSubstNo(ToLbl, LimitDate[2]))
                {
                }
                column(BalanceTCaption4; StrSubstNo(ToLbl, LimitDate[3]))
                {
                }
                column(BalanceTCaption5; StrSubstNo(ToLbl, LimitDate[4]))
                {
                }
                column(BalanceTCaption6; StrSubstNo(ToLbl, LimitDate[5]))
                {
                }
                column(BalanceTCaption7; StrSubstNo(OverLbl, LimitDate[5]))
                {
                }
                column(TotalCaption_Control1104000029; TotalCaption_Control1104000029Lbl)
                {
                }
                column(of_itCaption_Control1104000028; of_itCaption_Control1104000028Lbl)
                {
                }
                column(TotalByCurrency_Number; Number)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number <> 1 then
                        TempTotalCurrencyGLAccountNetChange.Next();
                end;

                trigger OnPreDataItem()
                begin
                    if not TempTotalCurrencyGLAccountNetChange.FindSet() then
                        CurrReport.Break();

                    SetRange(Number, 1, TempTotalCurrencyGLAccountNetChange.Count);
                end;
            }
            dataitem(GLAccDetail; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(greGLAcc_FIELDCAPTION__Balance_at_Date__; GLAccount.FieldCaption("Balance at Date"))
                {
                }
                column(greGLAcc_FIELDCAPTION__No___; GLAccount.FieldCaption("No."))
                {
                }
                column(greGLAcc_FIELDCAPTION_Name_; GLAccount.FieldCaption(Name))
                {
                }
                column(greTGLAccBuffer__No__; TempGLAccountNetChange."No.")
                {
                }
                column(greGLAcc_Name; GLAccount.Name)
                {
                }
                column(BalanceToDate_GLAccDetail; TempGLAccountNetChange."Balance after Posting")
                {
                }
                column(Difference_GLAccDetail; TempGLAccountNetChange."Balance after Posting" - GLAccount."Balance at Date")
                {
                }
                column(BalanceToDateByGL_GLAccDetail; GLAccount."Balance at Date")
                {
                }
                column(General_Ledger_SpecificationCaption; General_Ledger_SpecificationCaptionLbl)
                {
                }
                column(greTGLAccBuffer__Balance_after_Posting____greGLAcc__Net_Change_Caption; TGLAccBuffer__Balance_after_Posting____greGLAcc__Net_Change_CaptionLbl)
                {
                }
                column(greGLAcc__Net_Change_Caption; GLAcc__Net_Change_CaptionLbl)
                {
                }
                column(TotalCaption_Control1100170003; TotalCaption_Control1100170003Lbl)
                {
                }
                column(GLAccDetail_Number; Number)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then begin
                        if not TempGLAccountNetChange.FindSet() then
                            CurrReport.Break();
                    end else
                        if TempGLAccountNetChange.Next() = 0 then
                            CurrReport.Break();

                    GLAccount.Get(TempGLAccountNetChange."No.");
                    GLAccount.SetFilter("Date Filter", CustDateFilter);
                    GLAccount.CalcFields("Balance at Date");
                end;

                trigger OnPreDataItem()
                begin
                    if SkipGLAcc then
                        CurrReport.Break();

                    TempGLAccountNetChange.Reset();
                    if TempGLAccountNetChange.IsEmpty() then
                        CurrReport.Break();

                    SetRange(Number, 1, TempGLAccountNetChange.Count);
                end;
            }
            trigger OnPreDataItem()
            var
                lin: Integer;
                LimitDateTok: Label '<CD>+<%1>', Locked = true;
            begin
                if not SkipBalance then
                    for lin := 1 to 5 do
                        Days[lin] := (CalcDate(StrSubstNo(LimitDateTok, Format(LimitDate[lin])), Today()) - Today());
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
                    field(PrintCurrencyField; PrintCurrency)
                    {
                        ApplicationArea = All;
                        Caption = 'Show Currency';
                        ToolTip = 'Specifies when the currency is to be show';
                        Visible = CurrencyAllowed;
                    }
                    field(CustPerPageField; CustPerPage)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Customer Per Page';
                        ToolTip = 'Specifies if each customer has to be printed on new page.';
                        Visible = false;
                    }
                    field(SkipDetailField; SkipDetail)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Skip Entries';
                        ToolTip = 'Specifies when the entries are to be skip';
                    }
                    field(SkipTotalField; SkipTotal)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Skip Customer Total';
                        ToolTip = 'Specifies when the custom balance is to be skip';
                    }
                    field(SkipGLAccField; SkipGLAcc)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Skip General Ledger Specification';
                        ToolTip = 'Specifies when the general ledger specification is to be skip';
                    }
                    field(SkipBalanceField; SkipBalance)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Skip Balance';
                        ToolTip = 'Specifies when the balance is to be skip';
                    }
                    group(Limits)
                    {
                        Caption = 'Limits';
                        Enabled = not SkipBalance;
                        field("LimitDate[1]"; LimitDate[1])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Limit 1.';
                            Enabled = not SkipBalance;
                            ToolTip = 'Specifies the number of due date for customer''s entries calculation. Enter the value in format 30D, 60D or 1M.';
                            ShowMandatory = true;
                        }
                        field("LimitDate[2]"; LimitDate[2])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Limit 2.';
                            Enabled = not SkipBalance;
                            ToolTip = 'Specifies the number of due date for customer''s entries calculation. Enter the value in format 30D, 60D or 1M.';
                            ShowMandatory = true;
                        }
                        field("LimitDate[3]"; LimitDate[3])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Limit 3.';
                            Enabled = not SkipBalance;
                            ToolTip = 'Specifies the number of due date for customer''s entries calculation. Enter the value in format 30D, 60D or 1M.';
                            ShowMandatory = true;
                        }
                        field("LimitDate[4]"; LimitDate[4])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Limit 4.';
                            Enabled = not SkipBalance;
                            ToolTip = 'Specifies the number of due date for customer''s entries calculation. Enter the value in format 30D, 60D or 1M.';
                            ShowMandatory = true;
                        }
                        field("LimitDate[5]"; LimitDate[5])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Limit 5.';
                            Enabled = not SkipBalance;
                            ToolTip = 'Specifies the number of due date for customer''s entries calculation. Enter the value in format 30D, 60D or 1M.';
                            ShowMandatory = true;
                        }
                    }
                }
            }
        }
    }
    trigger OnInitReport()
    var
        Currency: Record Currency;
    begin
        CurrencyAllowed := Currency.ReadPermission;
    end;

    trigger OnPreReport()
    var
        InLocalCurrencyTxt: Label 'In local currency';
        InOriginalCurrencyTxt: Label ' and in original currency.';
    begin
        GeneralLedgerSetup.Get();
        SecondCustomer.CopyFilters(Customer);
        CustFilter := SecondCustomer.GetFilters;
        CustDateFilter := SecondCustomer.GetFilter("Date Filter");
        LedgerEntryFilter := "Cust. Ledger Entry".GetFilters;
        LastDate := SecondCustomer.GetRangeMax("Date Filter");
        InfoText := InLocalCurrencyTxt;
        if PrintCurrency and CurrencyAllowed then
            InfoText := CopyStr(InfoText + InOriginalCurrencyTxt, 1, MaxStrLen(InfoText))
        else
            InfoText := CopyStr(InfoText + '.', 1, MaxStrLen(InfoText));
    end;

    var
        SecondCustomer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
#pragma warning disable AL0432
        TempGLAccountNetChange: Record "G/L Account Net Change" temporary;
        TempCurrencyGLAccountNetChange: Record "G/L Account Net Change" temporary;
        TempTotalCurrencyGLAccountNetChange: Record "G/L Account Net Change" temporary;
#pragma warning restore AL0432        
        GLAccount: Record "G/L Account";
        LimitDate: array[5] of DateFormula;
        CurrencyCode: Code[10];
        WindowDialog: Dialog;
        CustDateFilter: Text;
        CustFilter: Text;
        LedgerEntryFilter: Text;
        InfoText: Text[100];
        LastDate: Date;
        Balance: array[7] of Decimal;
        BalanceT: array[7] of Decimal;
        DaysAfterDue: Integer;
        CustCount: Integer;
        CustActual: Integer;
        Days: array[5] of Integer;
        SkipBalance: Boolean;
        PrintCurrency: Boolean;
        SkipDetail: Boolean;
        SkipTotal: Boolean;
        SkipGLAcc: Boolean;
        CustPerPage: Boolean;
        CurrencyAllowed: Boolean;
        PeriodLbl: Label 'Period: %1', Comment = '%1 = Date Filter';
        ToLbl: Label 'To %1', Comment = '%1 = Date';
        OverLbl: Label 'Over %1', Comment = '%1 = Date';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Open_Customer_Entries_at_DateCaptionLbl: Label 'Open Customer Entries at Date';
        DaysAfterDueCaptionLbl: Label 'Days after Due Date';
        TotalCaptionLbl: Label 'Total';
        InMatureLbl: Label 'In mature';
        of_itCaptionLbl: Label 'of it';
        TotalCaption_Control1104000029Lbl: Label 'Total';
        of_itCaption_Control1104000028Lbl: Label 'of it';
        General_Ledger_SpecificationCaptionLbl: Label 'General Ledger Specification';
        TGLAccBuffer__Balance_after_Posting____greGLAcc__Net_Change_CaptionLbl: Label 'Difference';
        GLAcc__Net_Change_CaptionLbl: Label 'Balance at Date by GL';
        TotalCaption_Control1100170003Lbl: Label 'Total';
        ProcessingCustomersMsg: Label 'Processing Customers @1@@@@@@@@@@@@@@@@@@';

#pragma warning disable AL0432
    local procedure UpdateBuffer(var TempGLAccountNetChange: Record "G/L Account Net Change" temporary; Account: Code[20]; Amount1: Decimal; Amount2: Decimal)
#pragma warning restore AL0432
    begin
        if TempGLAccountNetChange.Get(Account) then begin
            TempGLAccountNetChange."Balance after Posting" := TempGLAccountNetChange."Balance after Posting" + Amount1;
            TempGLAccountNetChange."Net Change in Jnl." := TempGLAccountNetChange."Net Change in Jnl." + Amount2;
            TempGLAccountNetChange.Modify();
        end else begin
            TempGLAccountNetChange.Init();
            TempGLAccountNetChange."No." := Account;
            TempGLAccountNetChange."Balance after Posting" := Amount1;
            TempGLAccountNetChange."Net Change in Jnl." := Amount2;
            TempGLAccountNetChange.Insert();
        end;
    end;
}
