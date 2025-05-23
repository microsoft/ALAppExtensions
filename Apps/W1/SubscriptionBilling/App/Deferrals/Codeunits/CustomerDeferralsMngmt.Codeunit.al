namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.Navigate;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;
using Microsoft.Sales.History;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 8067 "Customer Deferrals Mngmt."
{
    SingleInstance = true;
    Permissions =
        tabledata "Sales Invoice Line" = r;

    var
        TempCustomerContractDeferral: Record "Cust. Sub. Contract Deferral" temporary;
        GLSetup: Record "General Ledger Setup";
        DeferralEntryNo: Integer;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostSalesDoc, '', false, false)]
    local procedure ClearGlobals()
    begin
        TempCustomerContractDeferral.Reset();
        TempCustomerContractDeferral.DeleteAll(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnPrepareLineOnBeforeSetAccount', '', false, false)]
    local procedure OnPrepareLineOnBeforeSetAccount(SalesLine: Record "Sales Line"; var SalesAccount: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if not SalesLine.IsLineAttachedToBillingLine() then
            exit;

        GeneralPostingSetup.Get(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
        if SalesLine.CreateContractDeferrals() then begin
            GeneralPostingSetup.TestField("Cust. Sub. Contr. Def Account");
            SalesAccount := GeneralPostingSetup."Cust. Sub. Contr. Def Account";
        end else begin
            GeneralPostingSetup.TestField("Cust. Sub. Contract Account");
            SalesAccount := GeneralPostingSetup."Cust. Sub. Contract Account";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnPrepareLineOnBeforeSetLineDiscAccount', '', false, false)]
    local procedure OnPrepareLineOnBeforeSetLineDiscAccount(SalesLine: Record "Sales Line"; GenPostingSetup: Record "General Posting Setup"; var InvDiscAccount: Code[20]; var IsHandled: Boolean)
    begin
        if SalesLine.CreateContractDeferrals() then begin
            InvDiscAccount := GenPostingSetup."Cust. Sub. Contr. Def Account";
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnPostSalesLineOnBeforeInsertInvoiceLine, '', false, false)]
    local procedure InsertCustomerDeferralsFromSalesInvoice(SalesHeader: Record "Sales Header"; xSalesLine: Record "Sales Line"; SalesInvHeader: Record "Sales Invoice Header")
    begin
        InsertContractDeferrals(SalesHeader, xSalesLine, SalesInvHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnPostSalesLineOnBeforeInsertCrMemoLine, '', false, false)]
    local procedure InsertCustomerDeferralsFromSalesCrMemoOnPostSalesLineOnBeforeInsertCrMemoLine(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var IsHandled: Boolean; xSalesLine: Record "Sales Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesDocuments: Codeunit "Sales Documents";
    begin
        if (xSalesLine.Quantity >= 0) or (xSalesLine."Unit Price" >= 0) then
            exit;

        if SalesDocuments.GetAppliesToDocNo(SalesHeader) <> '' then
            exit;

        InsertContractDeferrals(SalesHeader, xSalesLine, SalesCrMemoHeader."No.");
    end;

    local procedure InsertContractDeferrals(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; DocumentNo: Code[20])
    var
        CustContractHeader: Record "Customer Subscription Contract";
        CustContractLine: Record "Cust. Sub. Contract Line";
        CustomerContractDeferral: Record "Cust. Sub. Contract Deferral";
        CurrExchRate: Record "Currency Exchange Rate";
        BillingLine: Record "Billing Line";
        Sign: Integer;
    begin
        if DocumentNo = '' then
            exit;
        if SalesLine.Quantity = 0 then
            exit;
        if SalesLine."Recurring Billing from" > SalesLine."Recurring Billing to" then
            exit;
        if not (SalesLine."Document Type" in [Enum::"Sales Document Type"::Invoice, Enum::"Sales Document Type"::"Credit Memo"]) then
            exit;
        if not SalesLine.CreateContractDeferrals() then
            exit;

        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromSalesDocumentType(SalesLine."Document Type"), SalesLine."Document No.", SalesLine."Line No.");
        BillingLine.FindFirst();
        CustContractHeader.Get(BillingLine."Subscription Contract No.");
        GLSetup.Get();

        CustomerContractDeferral.Init();
        CustomerContractDeferral.InitFromSalesLine(SalesLine, Sign);
        CustomerContractDeferral."Document No." := DocumentNo;
        CustomerContractDeferral."Subscription Contract Type" := CustContractHeader."Contract Type";
        CustomerContractDeferral."User ID" := CopyStr(UserId(), 1, MaxStrLen(CustomerContractDeferral."User ID"));
        CustomerContractDeferral."Document Posting Date" := SalesHeader."Posting Date";
        CustContractLine.Get(CustContractHeader."No.", BillingLine."Subscription Contract Line No.");
        CustomerContractDeferral."Subscription Line Description" := CustContractLine."Subscription Line Description";
        CustomerContractDeferral."Subscription Description" := CustContractLine."Subscription Description";
        CustomerContractDeferral."Subscription Contract No." := CustContractLine."Subscription Contract No.";
        CustomerContractDeferral."Subscription Contract Line No." := CustContractLine."Line No.";

        if SalesHeader."Prices Including VAT" then
            if SalesLine."Line Discount Amount" <> 0 then
                SalesLine."Line Discount Amount" := Round(SalesLine."Line Discount Amount" / (1 + SalesLine."VAT %" / 100), GLSetup."Amount Rounding Precision");
        if SalesHeader."Currency Code" <> '' then begin
            SalesLine.Amount := Round(
                CurrExchRate.ExchangeAmtFCYToLCY(
                    SalesHeader."Posting Date",
                    SalesHeader."Currency Code",
                    SalesLine.Amount,
                    SalesHeader."Currency Factor"),
                GLSetup."Amount Rounding Precision");
            if SalesLine."Line Discount Amount" <> 0 then
                SalesLine."Line Discount Amount" := Round(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                        SalesHeader."Posting Date",
                        SalesHeader."Currency Code",
                        SalesLine."Line Discount Amount",
                        SalesHeader."Currency Factor"),
                    GLSetup."Amount Rounding Precision")
        end;
        SalesLine.Amount := Sign * SalesLine.Amount;
        CustomerContractDeferral."Deferral Base Amount" := SalesLine.Amount;
        SalesLine."Line Discount Amount" := Sign * SalesLine."Line Discount Amount";

        if SalesLine."Recurring Billing from" = CalcDate('<-CM>', SalesLine."Recurring Billing from") then
            InsertContractDeferralsWhenStartingOnFirstDayInMonth(CustomerContractDeferral, SalesLine)
        else
            InsertContractDeferralsWhenNotStartingOnFirstDayInMonth(CustomerContractDeferral, SalesLine);
    end;

    local procedure GetDeferralParametersFromSalesLine(SalesLine: Record "Sales Line"; var FirstDayOfBillingPeriod: Date; var LastDayOfBillingPeriod: Date; var TotalLineAmount: Decimal; var TotalLineDiscountAmount: Decimal; var NumberOfPeriods: Integer)
    var
        LoopDate: Date;
    begin
        LoopDate := SalesLine."Recurring Billing from";
        repeat
            NumberOfPeriods += 1;
            LoopDate := CalcDate('<1M>', LoopDate);
        until LoopDate > CalcDate('<CM>', SalesLine."Recurring Billing to");

        FirstDayOfBillingPeriod := SalesLine."Recurring Billing from";
        LastDayOfBillingPeriod := SalesLine."Recurring Billing to";
        TotalLineAmount := SalesLine.Amount;
        TotalLineDiscountAmount := SalesLine."Line Discount Amount";
    end;

    local procedure InsertContractDeferralsWhenStartingOnFirstDayInMonth(var CustomerContractDeferral: Record "Cust. Sub. Contract Deferral"; SalesLine: Record "Sales Line")
    var
        NumberOfPeriods: Integer;
        i: Integer;
        NextPostingDate: Date;
        LastDayOfBillingPeriod: Date;
        TotalLineAmount: Decimal;
        TotalLineDiscountAmount: Decimal;
        LineAmountPerPeriod: Decimal;
        LineDiscountAmountPerPeriod: Decimal;
        RunningLineAmount: Decimal;
        RunningLineDiscountAmount: Decimal;
    begin
        RunningLineAmount := 0;
        RunningLineDiscountAmount := 0;
        GetDeferralParametersFromSalesLine(SalesLine, NextPostingDate, LastDayOfBillingPeriod, TotalLineAmount, TotalLineDiscountAmount, NumberOfPeriods);
        LineAmountPerPeriod := Round(TotalLineAmount / NumberOfPeriods, GLSetup."Amount Rounding Precision");
        LineDiscountAmountPerPeriod := Round(TotalLineDiscountAmount / NumberOfPeriods, GLSetup."Amount Rounding Precision");

        for i := 1 to NumberOfPeriods do begin
            CustomerContractDeferral."Posting Date" := NextPostingDate;
            NextPostingDate := CalcDate('<1M>', NextPostingDate);
            if i = NumberOfPeriods then begin
                LineAmountPerPeriod := TotalLineAmount - RunningLineAmount;
                LineDiscountAmountPerPeriod := TotalLineDiscountAmount - RunningLineDiscountAmount;
            end;
            RunningLineAmount += LineAmountPerPeriod;
            RunningLineDiscountAmount += LineDiscountAmountPerPeriod;

            CustomerContractDeferral."Number of Days" := Date2DMY(CalcDate('<CM>', CustomerContractDeferral."Posting Date"), 1);
            CustomerContractDeferral.Amount := LineAmountPerPeriod;
            CustomerContractDeferral."Discount Amount" := LineDiscountAmountPerPeriod;
            CustomerContractDeferral."Entry No." := 0;
            OnBeforeInsertCustomerContractDeferralWhenStartingOnFirstDayInMonth(CustomerContractDeferral, SalesLine, i, NumberOfPeriods);
            CustomerContractDeferral.Insert(false);
            TempCustomerContractDeferral := CustomerContractDeferral;
            TempCustomerContractDeferral.Insert(false); //Used for Preview Posting
        end;
    end;

    local procedure InsertContractDeferralsWhenNotStartingOnFirstDayInMonth(var CustomerContractDeferral: Record "Cust. Sub. Contract Deferral"; SalesLine: Record "Sales Line")
    var
        NumberOfPeriods: Integer;
        NextPostingDate: Date;
        FirstDayOfBillingPeriod: Date;
        LastDayOfBillingPeriod: Date;
        TotalLineAmount: Decimal;
        TotalLineDiscountAmount: Decimal;
        LineAmountPerPeriod: Decimal;
        LineDiscountAmountPerPeriod: Decimal;
        LineAmountPerDay: Decimal;
        LineDiscountAmountPerDay: Decimal;
        LineAmountPerMonth: Decimal;
        LineDiscountAmountPerMonth: Decimal;
        FirstMonthDays: Integer;
        FirstMonthLineAmount: Decimal;
        FirstMonthLineDiscountAmount: Decimal;
        LastMonthDays: Integer;
        LastMonthLineAmount: Decimal;
        LastMonthLineDiscountAmount: Decimal;
        RunningLineAmount: Decimal;
        RunningLineDiscountTotal: Decimal;
        NumberOfDaysInSchedule: Integer;
        i: Integer;
    begin
        RunningLineAmount := 0;
        RunningLineDiscountTotal := 0;
        GetDeferralParametersFromSalesLine(SalesLine, FirstDayOfBillingPeriod, LastDayOfBillingPeriod, TotalLineAmount, TotalLineDiscountAmount, NumberOfPeriods);
        NextPostingDate := FirstDayOfBillingPeriod;
        NumberOfDaysInSchedule := LastDayOfBillingPeriod - FirstDayOfBillingPeriod + 1;
        LineAmountPerDay := TotalLineAmount / NumberOfDaysInSchedule;
        LineDiscountAmountPerDay := TotalLineDiscountAmount / NumberOfDaysInSchedule;
        FirstMonthDays := CalcDate('<CM>', NextPostingDate) - NextPostingDate + 1;
        FirstMonthLineAmount := Round(FirstMonthDays * LineAmountPerDay, GLSetup."Amount Rounding Precision");
        FirstMonthLineDiscountAmount := Round(FirstMonthDays * LineDiscountAmountPerDay, GLSetup."Amount Rounding Precision");
        LastMonthDays := Date2DMY(LastDayOfBillingPeriod, 1);
        LastMonthLineAmount := Round(LastMonthDays * LineAmountPerDay, GLSetup."Amount Rounding Precision");
        LastMonthLineDiscountAmount := Round(LastMonthDays * LineDiscountAmountPerDay, GLSetup."Amount Rounding Precision");
        if NumberOfPeriods > 2 then begin
            LineAmountPerMonth := Round((TotalLineAmount - FirstMonthLineAmount - LastMonthLineAmount) / (NumberOfPeriods - 2), GLSetup."Amount Rounding Precision");
            LineDiscountAmountPerMonth := Round((TotalLineDiscountAmount - FirstMonthLineDiscountAmount - LastMonthLineDiscountAmount) / (NumberOfPeriods - 2), GLSetup."Amount Rounding Precision");
        end;

        for i := 1 to NumberOfPeriods do begin
            CustomerContractDeferral."Posting Date" := NextPostingDate;
            NextPostingDate := CalcDate('<1M-CM>', NextPostingDate);
            case i of
                1:
                    begin
                        LineAmountPerPeriod := FirstMonthLineAmount;
                        LineDiscountAmountPerPeriod := FirstMonthLineDiscountAmount;
                        CustomerContractDeferral."Number of Days" := FirstMonthDays;
                    end;
                NumberOfPeriods:
                    begin
                        LineAmountPerPeriod := TotalLineAmount - RunningLineAmount;
                        LineDiscountAmountPerPeriod := TotalLineDiscountAmount - RunningLineDiscountTotal;
                        CustomerContractDeferral."Number of Days" := LastMonthDays;
                    end;
                else begin
                    LineAmountPerPeriod := LineAmountPerMonth;
                    LineDiscountAmountPerPeriod := LineDiscountAmountPerMonth;
                    CustomerContractDeferral."Number of Days" := Date2DMY(CalcDate('<CM>', CustomerContractDeferral."Posting Date"), 1);
                end;
            end;
            RunningLineAmount += LineAmountPerPeriod;
            RunningLineDiscountTotal += LineDiscountAmountPerPeriod;

            CustomerContractDeferral.Amount := LineAmountPerPeriod;
            CustomerContractDeferral."Discount Amount" := LineDiscountAmountPerPeriod;
            CustomerContractDeferral."Entry No." := 0;
            OnBeforeInsertCustomerContractDeferralWhenNotStartingOnFirstDayInMonth(CustomerContractDeferral, SalesLine, i, NumberOfPeriods);
            CustomerContractDeferral.Insert(false);
            TempCustomerContractDeferral := CustomerContractDeferral;
            TempCustomerContractDeferral.Insert(false); //Used for Preview Posting
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterSalesCrMemoLineInsert, '', false, false)]
    local procedure InsertCustomerDeferralsFromSalesCrMemo(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesHeader: Record "Sales Header")
    begin
        ReleaseAndCreditCustomerContractDeferrals(SalesHeader, SalesCrMemoLine);
    end;

    local procedure ReleaseAndCreditCustomerContractDeferrals(SalesHeader: Record "Sales Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        InvoiceCustContractDeferral: Record "Cust. Sub. Contract Deferral";
        CreditMemoCustContractDeferral: Record "Cust. Sub. Contract Deferral";
        SalesInvoiceLine: Record "Sales Invoice Line";
        ContractDeferralRelease: Report "Contract Deferrals Release";
        SalesDocuments: Codeunit "Sales Documents";
        AppliesToDocNo: Code[20];
    begin
        AppliesToDocNo := SalesDocuments.GetAppliesToDocNo(SalesHeader);
        if SalesDocuments.IsInvoiceCredited(AppliesToDocNo) then
            exit;
        InvoiceCustContractDeferral.FilterOnDocumentTypeAndDocumentNo(Enum::"Rec. Billing Document Type"::Invoice, AppliesToDocNo);
        InvoiceCustContractDeferral.SetRange("Subscription Contract No.", SalesCrMemoLine."Subscription Contract No.");
        InvoiceCustContractDeferral.SetRange("Subscription Contract Line No.", SalesCrMemoLine."Subscription Contract Line No.");
        if InvoiceCustContractDeferral.FindSet() then begin
            ContractDeferralRelease.GetAndTestSourceCode();
            ContractDeferralRelease.GetGeneralLedgerSetupAndCheckJournalTemplateAndBatch();
            ContractDeferralRelease.SetAllowGUI(false);
            repeat
                CreditMemoCustContractDeferral := InvoiceCustContractDeferral;
                CreditMemoCustContractDeferral."Document Type" := Enum::"Rec. Billing Document Type"::"Credit Memo";
                CreditMemoCustContractDeferral."Document No." := SalesCrMemoLine."Document No.";
                CreditMemoCustContractDeferral."Document Line No." := SalesCrMemoLine."Line No.";
                CreditMemoCustContractDeferral."Posting Date" := InvoiceCustContractDeferral."Posting Date";
                CreditMemoCustContractDeferral."Document Posting Date" := SalesCrMemoLine."Posting Date";
                CreditMemoCustContractDeferral."Deferral Base Amount" := InvoiceCustContractDeferral."Deferral Base Amount" * -1;
                CreditMemoCustContractDeferral.Amount := InvoiceCustContractDeferral.Amount * -1;
                CreditMemoCustContractDeferral."Discount Amount" := InvoiceCustContractDeferral."Discount Amount" * -1;
                CreditMemoCustContractDeferral."Release Posting Date" := 0D;
                CreditMemoCustContractDeferral.Released := false;
                CreditMemoCustContractDeferral."G/L Entry No." := 0;
                CreditMemoCustContractDeferral."Entry No." := 0;
                CreditMemoCustContractDeferral.Insert(false);
                SalesInvoiceLine.Get(InvoiceCustContractDeferral."Document No.", InvoiceCustContractDeferral."Document Line No.");
                if not InvoiceCustContractDeferral.Released then begin
                    ContractDeferralRelease.SetRequestPageParameters(InvoiceCustContractDeferral."Posting Date", SalesCrMemoLine."Posting Date");
                    ContractDeferralRelease.ReleaseCustomerContractDeferralAndInsertTempGenJournalLine(InvoiceCustContractDeferral);
                    ContractDeferralRelease.PostTempGenJnlLineBufferForCustomerDeferrals();
                end;
                ContractDeferralRelease.SetRequestPageParameters(CreditMemoCustContractDeferral."Posting Date", SalesCrMemoLine."Posting Date");
                ContractDeferralRelease.ReleaseCustomerContractDeferralAndInsertTempGenJournalLine(CreditMemoCustContractDeferral);
                ContractDeferralRelease.PostTempGenJnlLineBufferForCustomerDeferrals();

                TempCustomerContractDeferral := CreditMemoCustContractDeferral;
                TempCustomerContractDeferral.Insert(false); //Used for Preview Posting
            until InvoiceCustContractDeferral.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", OnAfterFillDocumentEntry, '', false, false)]
    local procedure OnAfterFillDocumentEntry(var DocumentEntry: Record "Document Entry")
    var
        PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";
    begin
        PostingPreviewEventHandler.InsertDocumentEntry(TempCustomerContractDeferral, DocumentEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", OnAfterShowEntries, '', false, false)]
    local procedure OnAfterShowEntries(TableNo: Integer)
    begin
        if TableNo = Database::"Cust. Sub. Contract Deferral" then
            Page.Run(Page::"Customer Contract Deferrals", TempCustomerContractDeferral);
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, OnAfterNavigateFindRecords, '', false, false)]
    local procedure OnAfterFindEntries(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text)
    var
        CustomerContractDeferral: Record "Cust. Sub. Contract Deferral";
    begin
        CustomerContractDeferral.SetFilter("Document No.", DocNoFilter);
        DocumentEntry.InsertIntoDocEntry(Database::"Cust. Sub. Contract Deferral", CustomerContractDeferral."Document Type", CustomerContractDeferral.TableCaption, CustomerContractDeferral.Count);
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, OnBeforeShowRecords, '', false, false)]
    local procedure OnBeforeShowRecords(var TempDocumentEntry: Record "Document Entry"; DocNoFilter: Text)
    var
        CustomerContractDeferral: Record "Cust. Sub. Contract Deferral";
    begin
        if TempDocumentEntry."Table ID" <> Database::"Cust. Sub. Contract Deferral" then
            exit;
        CustomerContractDeferral.SetFilter("Document No.", DocNoFilter);
        Page.Run(Page::"Customer Contract Deferrals", CustomerContractDeferral);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterGLFinishPosting, '', false, false)]
    local procedure GetEntryNo(GLEntry: Record "G/L Entry"; var GenJnlLine: Record "Gen. Journal Line")
    var
        CustomerContractDeferrals: Record "Cust. Sub. Contract Deferral";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        if SourceCodeSetup."Sub. Contr. Deferrals Release" <> GLEntry."Source Code" then
            exit;
        //Update Contract Deferrals while releasing
        if DeferralEntryNo <> 0 then begin
            CustomerContractDeferrals.Get(DeferralEntryNo);
            CustomerContractDeferrals."G/L Entry No." := GLEntry."Entry No.";
            CustomerContractDeferrals.Modify(false);
        end
        else begin
            //Update related invoice deferrals with GL Entry No.
            CustomerContractDeferrals.FilterOnDocumentTypeAndDocumentNo(Enum::"Rec. Billing Document Type"::Invoice, GenJnlLine."Applies-to Doc. No.");
            CustomerContractDeferrals.SetRange(Released, true);
            CustomerContractDeferrals.SetRange("G/L Entry No.", 0);
            CustomerContractDeferrals.ModifyAll("G/L Entry No.", GLEntry."Entry No.", false);
            //Update Credit memo deferrals with GL Entry No.
            CustomerContractDeferrals.FilterOnDocumentTypeAndDocumentNo(Enum::"Rec. Billing Document Type"::"Credit Memo", GLEntry."Document No.");
            CustomerContractDeferrals.ModifyAll("G/L Entry No.", GLEntry."Entry No.", false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforePostGenJnlLine, '', false, false)]
    local procedure SetContractNo(var GenJournalLine: Record "Gen. Journal Line")
    var
        CustomerContractDeferrals: Record "Cust. Sub. Contract Deferral";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if DeferralEntryNo = 0 then
            exit;
        SourceCodeSetup.Get();
        if SourceCodeSetup."Sub. Contr. Deferrals Release" <> GenJournalLine."Source Code" then
            exit;
        CustomerContractDeferrals.Get(DeferralEntryNo);
        GenJournalLine."Subscription Contract No." := CustomerContractDeferrals."Subscription Contract No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeInsertGlobalGLEntry, '', false, false)]
    local procedure TransferContractNoToGLEntry(var GlobalGLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."Subscription Contract No." = '' then
            exit;
        GlobalGLEntry."Subscription Contract No." := GenJournalLine."Subscription Contract No.";
    end;

    internal procedure SetDeferralNo(NewDeferralNo: Integer)
    begin
        DeferralEntryNo := NewDeferralNo;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertCustomerContractDeferralWhenStartingOnFirstDayInMonth(var CustSubContractDeferral: Record "Cust. Sub. Contract Deferral"; SalesLine: Record "Sales Line"; PeriodNo: Integer; NumberOfPeriods: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertCustomerContractDeferralWhenNotStartingOnFirstDayInMonth(var CustSubContractDeferral: Record "Cust. Sub. Contract Deferral"; SalesLine: Record "Sales Line"; PeriodNo: Integer; NumberOfPeriods: Integer)
    begin
    end;
}