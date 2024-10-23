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
    Access = Internal;

    var
        TempCustomerContractDeferral: Record "Customer Contract Deferral" temporary;
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
        CustContractHeader: Record "Customer Contract";
        GeneralPostingSetup: Record "General Posting Setup";
        BillingLine: Record "Billing Line";
    begin
        if not SalesLine.IsLineAttachedToBillingLine() then
            exit;
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromSalesDocumentType(SalesLine."Document Type"), SalesLine."Document No.", SalesLine."Line No.");
        BillingLine.FindFirst();
        CustContractHeader.Get(BillingLine."Contract No.");

        GeneralPostingSetup.Get(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
        if CustContractHeader."Without Contract Deferrals" then begin
            GeneralPostingSetup.TestField("Customer Contract Account");
            SalesAccount := GeneralPostingSetup."Customer Contract Account";
        end else begin
            GeneralPostingSetup.TestField("Cust. Contr. Deferral Account");
            SalesAccount := GeneralPostingSetup."Cust. Contr. Deferral Account";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnPrepareLineOnBeforeSetLineDiscAccount', '', false, false)]
    local procedure OnPrepareLineOnBeforeSetLineDiscAccount(SalesLine: Record "Sales Line"; GenPostingSetup: Record "General Posting Setup"; var InvDiscAccount: Code[20]; var IsHandled: Boolean)
    begin
        if IsCustomerContractWithDeferrals(SalesLine) then begin
            InvDiscAccount := GenPostingSetup."Cust. Contr. Deferral Account";
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnPostSalesLineOnBeforeInsertInvoiceLine, '', false, false)]
    local procedure InsertCustomerDeferralsFromSalesInvoice(SalesHeader: Record "Sales Header"; xSalesLine: Record "Sales Line"; SalesInvHeader: Record "Sales Invoice Header")
    begin
        InsertContractDeferrals(SalesHeader, xSalesLine, SalesInvHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterSalesCrMemoHeaderInsert, '', false, false)]
    local procedure InsertCustomerDeferralsFromSalesCrMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesHeader: Record "Sales Header")
    begin
        ReleaseAndCreditCustomerContractDeferrals(SalesHeader, SalesCrMemoHeader);
    end;

    local procedure InsertContractDeferrals(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; DocumentNo: Code[20])
    var
        CustContractHeader: Record "Customer Contract";
        CustContractLine: Record "Customer Contract Line";
        CustomerContractDeferral: Record "Customer Contract Deferral";
        CurrExchRate: Record "Currency Exchange Rate";
        BillingLine: Record "Billing Line";
        Sign: Integer;
    begin
        if DocumentNo = '' then
            exit;
        if SalesLine.Quantity = 0 then
            exit;
        if not SalesLine.IsLineAttachedToBillingLine() then
            exit;
        if SalesLine."Recurring Billing from" > SalesLine."Recurring Billing to" then
            exit;
        if not (SalesLine."Document Type" in [Enum::"Sales Document Type"::Invoice, Enum::"Sales Document Type"::"Credit Memo"]) then
            exit;

        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromSalesDocumentType(SalesLine."Document Type"), SalesLine."Document No.", SalesLine."Line No.");
        BillingLine.FindFirst();
        CustContractHeader.Get(BillingLine."Contract No.");
        if CustContractHeader."Without Contract Deferrals" then
            exit;

        GLSetup.Get();

        CustomerContractDeferral.Init();
        CustomerContractDeferral.InitFromSalesLine(SalesLine, Sign);
        CustomerContractDeferral."Document No." := DocumentNo;
        CustomerContractDeferral."Contract Type" := CustContractHeader."Contract Type";
        CustomerContractDeferral."User ID" := CopyStr(UserId(), 1, MaxStrLen(CustomerContractDeferral."User ID"));
        CustomerContractDeferral."Document Posting Date" := SalesHeader."Posting Date";
        CustContractLine.Get(CustContractHeader."No.", BillingLine."Contract Line No.");
        CustomerContractDeferral."Service Commitment Description" := CustContractLine."Service Commitment Description";
        CustomerContractDeferral."Service Object Description" := CustContractLine."Service Object Description";
        CustomerContractDeferral."Contract No." := CustContractLine."Contract No.";
        CustomerContractDeferral."Contract Line No." := CustContractLine."Line No.";

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

    local procedure InsertContractDeferralsWhenStartingOnFirstDayInMonth(var CustomerContractDeferral: Record "Customer Contract Deferral"; SalesLine: Record "Sales Line")
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

    local procedure InsertContractDeferralsWhenNotStartingOnFirstDayInMonth(var CustomerContractDeferral: Record "Customer Contract Deferral"; SalesLine: Record "Sales Line")
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

    local procedure ReleaseAndCreditCustomerContractDeferrals(SalesHeader: Record "Sales Header"; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        InvoiceCustContractDeferral: Record "Customer Contract Deferral";
        CreditMemoCustContractDeferral: Record "Customer Contract Deferral";
        SalesInvoiceLine: Record "Sales Invoice Line";
        ContractDeferralRelease: Report "Contract Deferrals Release";
        SalesDocuments: Codeunit "Sales Documents";
        AppliesToDocNo: Code[20];
    begin
        AppliesToDocNo := SalesDocuments.GetAppliesToDocNo(SalesHeader);
        if SalesDocuments.IsInvoiceCredited(AppliesToDocNo) then
            exit;
        InvoiceCustContractDeferral.FilterOnDocumentTypeAndDocumentNo(Enum::"Rec. Billing Document Type"::Invoice, AppliesToDocNo);
        if InvoiceCustContractDeferral.FindSet() then begin
            ContractDeferralRelease.GetAndTestSourceCode();
            ContractDeferralRelease.SetAllowGUI(false);
            repeat
                CreditMemoCustContractDeferral := InvoiceCustContractDeferral;
                CreditMemoCustContractDeferral."Document Type" := Enum::"Rec. Billing Document Type"::"Credit Memo";
                CreditMemoCustContractDeferral."Document No." := SalesCrMemoHeader."No.";
                CreditMemoCustContractDeferral."Posting Date" := InvoiceCustContractDeferral."Posting Date";
                CreditMemoCustContractDeferral."Document Posting Date" := SalesCrMemoHeader."Posting Date";
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
                    ContractDeferralRelease.SetRequestPageParameters(InvoiceCustContractDeferral."Posting Date", SalesCrMemoHeader."Posting Date");
                    ContractDeferralRelease.ReleaseCustomerContractDeferralAndInsertTempGenJournalLine(InvoiceCustContractDeferral, SalesInvoiceLine."Gen. Bus. Posting Group", SalesInvoiceLine."Gen. Prod. Posting Group");
                    ContractDeferralRelease.PostTempGenJnlLineBufferForCustomerDeferrals();
                end;
                ContractDeferralRelease.SetRequestPageParameters(CreditMemoCustContractDeferral."Posting Date", SalesCrMemoHeader."Posting Date");
                ContractDeferralRelease.ReleaseCustomerContractDeferralAndInsertTempGenJournalLine(CreditMemoCustContractDeferral, SalesInvoiceLine."Gen. Bus. Posting Group", SalesInvoiceLine."Gen. Prod. Posting Group");
                ContractDeferralRelease.PostTempGenJnlLineBufferForCustomerDeferrals();

                TempCustomerContractDeferral := CreditMemoCustContractDeferral;
                TempCustomerContractDeferral.Insert(false); //Used for Preview Posting
            until InvoiceCustContractDeferral.Next() = 0;
        end;
    end;

    local procedure IsCustomerContractWithDeferrals(SalesLine: Record "Sales Line"): Boolean
    var
        CustomerContractHeader: Record "Customer Contract";
        BillingLine: Record "Billing Line";
    begin
        if not SalesLine.IsLineAttachedToBillingLine() then
            exit;
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromSalesDocumentType(SalesLine."Document Type"), SalesLine."Document No.", SalesLine."Line No.");
        BillingLine.FindFirst();

        CustomerContractHeader.Get(BillingLine."Contract No.");
        exit(not CustomerContractHeader."Without Contract Deferrals");
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
        if TableNo = Database::"Customer Contract Deferral" then
            Page.Run(Page::"Customer Contract Deferrals", TempCustomerContractDeferral);
    end;

#if not CLEAN25
    [EventSubscriber(ObjectType::Page, Page::Navigate, OnAfterNavigateFindRecords, '', false, false)]
    local procedure OnAfterFindEntries(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text)
    var
        CustomerContractDeferral: Record "Customer Contract Deferral";
        Navigate: Page Navigate;
    begin
        CustomerContractDeferral.SetRange("Document No.", DocNoFilter);
        Navigate.InsertIntoDocEntry(DocumentEntry, Database::"Customer Contract Deferral", CustomerContractDeferral."Document Type", CustomerContractDeferral.TableCaption, CustomerContractDeferral.Count);
    end;
#endif
#if not CLEAN25
    [EventSubscriber(ObjectType::Page, Page::Navigate, OnBeforeNavigateShowRecords, '', false, false)]
    local procedure OnBeforeShowRecords(var TempDocumentEntry: Record "Document Entry"; DocNoFilter: Text)
    var
        CustomerContractDeferral: Record "Customer Contract Deferral";
    begin
        if TempDocumentEntry."Table ID" <> Database::"Customer Contract Deferral" then
            exit;
        CustomerContractDeferral.SetRange("Document No.", DocNoFilter);
        Page.Run(Page::"Customer Contract Deferrals", CustomerContractDeferral);
    end;
#endif
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterGLFinishPosting, '', false, false)]
    local procedure GetEntryNo(GLEntry: Record "G/L Entry"; var GenJnlLine: Record "Gen. Journal Line")
    var
        CustomerContractDeferrals: Record "Customer Contract Deferral";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        if SourceCodeSetup."Contract Deferrals Release" <> GLEntry."Source Code" then
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
        CustomerContractDeferrals: Record "Customer Contract Deferral";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if DeferralEntryNo = 0 then
            exit;
        SourceCodeSetup.Get();
        if SourceCodeSetup."Contract Deferrals Release" <> GenJournalLine."Source Code" then
            exit;
        CustomerContractDeferrals.Get(DeferralEntryNo);
        GenJournalLine."Sub. Contract No." := CustomerContractDeferrals."Contract No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeInsertGlobalGLEntry, '', false, false)]
    local procedure TransferContractNoToGLEntry(var GlobalGLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."Sub. Contract No." = '' then
            exit;
        GlobalGLEntry."Sub. Contract No." := GenJournalLine."Sub. Contract No.";
    end;

    procedure SetDeferralNo(NewDeferralNo: Integer)
    begin
        DeferralEntryNo := NewDeferralNo;
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeInsertCustomerContractDeferralWhenStartingOnFirstDayInMonth(var CustomerContractDeferral: Record "Customer Contract Deferral"; SalesLine: Record "Sales Line"; PeriodNo: Integer; NumberOfPeriods: Integer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeInsertCustomerContractDeferralWhenNotStartingOnFirstDayInMonth(var CustomerContractDeferral: Record "Customer Contract Deferral"; SalesLine: Record "Sales Line"; PeriodNo: Integer; NumberOfPeriods: Integer)
    begin
    end;
}