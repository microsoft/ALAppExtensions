namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.Navigate;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.History;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 8068 "Vendor Deferrals Mngmt."
{
    SingleInstance = true;
    Access = Internal;
    Permissions =
        tabledata "Purch. Inv. Line" = r;

    var
        TempVendorContractDeferral: Record "Vend. Sub. Contract Deferral" temporary;
        GLSetup: Record "General Ledger Setup";
        TempPurchaseLine: Record "Purchase Line" temporary;
        DeferralEntryNo: Integer;
        VendorContractDeferralLinePosting: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnBeforePostPurchaseDoc, '', false, false)]
    local procedure ClearGlobals()
    begin
        TempVendorContractDeferral.Reset();
        TempVendorContractDeferral.DeleteAll(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnPrepareLineOnBeforeSetAccount', '', false, false)]
    local procedure OnPrepareLineOnBeforeSetAccount(PurchLine: Record "Purchase Line"; var SalesAccount: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if not PurchLine.IsLineAttachedToBillingLine() then
            exit;

        GeneralPostingSetup.Get(PurchLine."Gen. Bus. Posting Group", PurchLine."Gen. Prod. Posting Group");
        if PurchLine.CreateContractDeferrals() then begin
            GeneralPostingSetup.TestField("Vend. Sub. Contr. Def. Account");
            SalesAccount := GeneralPostingSetup."Vend. Sub. Contr. Def. Account";
        end else begin
            GeneralPostingSetup.TestField("Vend. Sub. Contract Account");
            SalesAccount := GeneralPostingSetup."Vend. Sub. Contract Account";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnAfterInitTotalAmounts', '', false, false)]
    local procedure SetVendorContractDeferralLinePosting(PurchLine: Record "Purchase Line")
    begin
        VendorContractDeferralLinePosting := false;
        Clear(TempPurchaseLine);
        if PurchLine.CreateContractDeferrals() then begin
            VendorContractDeferralLinePosting := true;
            TempPurchaseLine := PurchLine;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"General Posting Setup", OnBeforeGetPurchLineDiscAccount, '', false, false)]
    local procedure SetLineDiscAccountForVendorContractDeferrals(var AccountNo: Code[20]; var IsHandled: Boolean)
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if VendorContractDeferralLinePosting then begin
            GeneralPostingSetup.Get(TempPurchaseLine."Gen. Bus. Posting Group", TempPurchaseLine."Gen. Prod. Posting Group");
            AccountNo := GeneralPostingSetup."Vend. Sub. Contr. Def. Account";
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnPostPurchLineOnBeforeInsertCrMemoLine, '', false, false)]
    local procedure InsertVendorDeferralsFromPurchaseInvoiceOnPostPurchLineOnBeforeInsertCrMemoLine(PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean; var PurchCrMemoLine: Record "Purch. Cr. Memo Line"; xPurchaseLine: Record "Purchase Line");
    begin
        if (PurchaseLine.Quantity >= 0) or (PurchaseLine."Direct Unit Cost" >= 0) then
            exit;

        if GetAppliesToDocNo(PurchaseHeader) <> '' then
            exit;

        InsertContractDeferrals(PurchaseHeader, PurchaseLine, PurchaseHeader."Posting No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnPostPurchLineOnBeforeInsertInvoiceLine, '', false, false)]
    local procedure InsertVendorDeferralsFromPurchaseInvoiceOnPostPurchLineOnBeforeInsertInvoiceLine(PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line")
    begin
        InsertContractDeferrals(PurchaseHeader, PurchaseLine, PurchaseHeader."Posting No.");
    end;

    local procedure InsertContractDeferrals(PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"; DocumentNo: Code[20])
    var
        VendContractHeader: Record "Vendor Subscription Contract";
        VendContractLine: Record "Vend. Sub. Contract Line";
        VendorContractDeferral: Record "Vend. Sub. Contract Deferral";
        BillingLine: Record "Billing Line";
        Sign: Integer;
    begin
        if DocumentNo = '' then
            exit;
        if PurchaseLine.Quantity = 0 then
            exit;
        if PurchaseLine."Recurring Billing from" > PurchaseLine."Recurring Billing to" then
            exit;
        if not (PurchaseLine."Document Type" in [Enum::"Purchase Document Type"::Invoice, Enum::"Purchase Document Type"::"Credit Memo"]) then
            exit;
        if not PurchaseLine.CreateContractDeferrals() then
            exit;

        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(PurchaseLine."Document Type"), PurchaseLine."Document No.", PurchaseLine."Line No.");
        BillingLine.FindFirst();
        VendContractHeader.Get(BillingLine."Subscription Contract No.");
        GLSetup.Get();

        VendorContractDeferral.Init();
        VendorContractDeferral.InitFromPurchaseLine(PurchaseLine, Sign);
        VendorContractDeferral."Document No." := DocumentNo;
        VendorContractDeferral."Subscription Contract Type" := VendContractHeader."Contract Type";
        VendorContractDeferral."User ID" := CopyStr(UserId(), 1, MaxStrLen(VendorContractDeferral."User ID"));
        VendorContractDeferral."Document Posting Date" := PurchaseHeader."Posting Date";
        VendContractLine.Get(VendContractHeader."No.", BillingLine."Subscription Contract Line No.");
        VendorContractDeferral."Subscription Line Description" := VendContractLine."Subscription Line Description";
        VendorContractDeferral."Subscription Description" := VendContractLine."Subscription Description";
        VendorContractDeferral."Subscription Contract No." := VendContractLine."Subscription Contract No.";
        VendorContractDeferral."Subscription Contract Line No." := VendContractLine."Line No.";

        if PurchaseHeader."Prices Including VAT" then
            if PurchaseLine."Line Discount Amount" <> 0 then
                PurchaseLine."Line Discount Amount" := Round(PurchaseLine."Line Discount Amount" / (1 + PurchaseLine."VAT %" / 100), GLSetup."Amount Rounding Precision");

        //Amount in LCY is calculated inside PostPurchLine function in CU Purch.-Post; PurchLine.RoundAmount
        PurchaseLine.Amount := Sign * PurchaseLine.Amount;
        VendorContractDeferral."Deferral Base Amount" := PurchaseLine.Amount;
        PurchaseLine."Line Discount Amount" := Sign * PurchaseLine."Line Discount Amount";

        if PurchaseLine."Recurring Billing from" = CalcDate('<-CM>', PurchaseLine."Recurring Billing from") then
            InsertContractDeferralsWhenStartingOnFirstDayInMonth(VendorContractDeferral, PurchaseLine)
        else
            InsertContractDeferralsWhenNotStartingOnFirstDayInMonth(VendorContractDeferral, PurchaseLine);
    end;

    local procedure GetDeferralParametersFromPurchaseLine(PurchaseLine: Record "Purchase Line"; var FirstDayOfBillingPeriod: Date; var LastDayOfBillingPeriod: Date; var TotalLineAmount: Decimal; var TotalLineDiscountAmount: Decimal; var NumberOfPeriods: Integer)
    var
        LoopDate: Date;
    begin
        LoopDate := PurchaseLine."Recurring Billing from";
        repeat
            NumberOfPeriods += 1;
            LoopDate := CalcDate('<1M>', LoopDate);
        until LoopDate > CalcDate('<CM>', PurchaseLine."Recurring Billing to");

        FirstDayOfBillingPeriod := PurchaseLine."Recurring Billing from";
        LastDayOfBillingPeriod := PurchaseLine."Recurring Billing to";
        TotalLineAmount := PurchaseLine.Amount;
        TotalLineDiscountAmount := PurchaseLine."Line Discount Amount";
    end;

    local procedure InsertContractDeferralsWhenStartingOnFirstDayInMonth(var VendorContractDeferral: Record "Vend. Sub. Contract Deferral"; PurchaseLine: Record "Purchase Line")
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
        GetDeferralParametersFromPurchaseLine(PurchaseLine, NextPostingDate, LastDayOfBillingPeriod, TotalLineAmount, TotalLineDiscountAmount, NumberOfPeriods);
        LineAmountPerPeriod := Round(TotalLineAmount / NumberOfPeriods, GLSetup."Amount Rounding Precision");
        LineDiscountAmountPerPeriod := Round(TotalLineDiscountAmount / NumberOfPeriods, GLSetup."Amount Rounding Precision");

        for i := 1 to NumberOfPeriods do begin
            VendorContractDeferral."Posting Date" := NextPostingDate;
            NextPostingDate := CalcDate('<1M>', NextPostingDate);
            if i = NumberOfPeriods then begin
                LineAmountPerPeriod := TotalLineAmount - RunningLineAmount;
                LineDiscountAmountPerPeriod := TotalLineDiscountAmount - RunningLineDiscountAmount;
            end;
            RunningLineAmount += LineAmountPerPeriod;
            RunningLineDiscountAmount += LineDiscountAmountPerPeriod;

            VendorContractDeferral."Number of Days" := Date2DMY(CalcDate('<CM>', VendorContractDeferral."Posting Date"), 1);
            VendorContractDeferral.Amount := LineAmountPerPeriod;
            VendorContractDeferral."Discount Amount" := LineDiscountAmountPerPeriod;
            VendorContractDeferral."Entry No." := 0;
            VendorContractDeferral.Insert(false);
            TempVendorContractDeferral := VendorContractDeferral;
            TempVendorContractDeferral.Insert(false); //Used for Preview Posting
        end;
    end;

    local procedure InsertContractDeferralsWhenNotStartingOnFirstDayInMonth(var VendorContractDeferral: Record "Vend. Sub. Contract Deferral"; PurchaseLine: Record "Purchase Line")
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
        GetDeferralParametersFromPurchaseLine(PurchaseLine, FirstDayOfBillingPeriod, LastDayOfBillingPeriod, TotalLineAmount, TotalLineDiscountAmount, NumberOfPeriods);
        NextPostingDate := FirstDayOfBillingPeriod;
        NumberOfDaysInSchedule := (LastDayOfBillingPeriod - FirstDayOfBillingPeriod + 1);
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
            VendorContractDeferral."Posting Date" := NextPostingDate;
            NextPostingDate := CalcDate('<1M-CM>', NextPostingDate);
            case i of
                1:
                    begin
                        LineAmountPerPeriod := FirstMonthLineAmount;
                        LineDiscountAmountPerPeriod := FirstMonthLineDiscountAmount;
                        VendorContractDeferral."Number of Days" := FirstMonthDays;
                    end;
                NumberOfPeriods:
                    begin
                        LineAmountPerPeriod := TotalLineAmount - RunningLineAmount;
                        LineDiscountAmountPerPeriod := TotalLineDiscountAmount - RunningLineDiscountTotal;
                        VendorContractDeferral."Number of Days" := LastMonthDays;
                    end;
                else begin
                    LineAmountPerPeriod := LineAmountPerMonth;
                    LineDiscountAmountPerPeriod := LineDiscountAmountPerMonth;
                    VendorContractDeferral."Number of Days" := Date2DMY(CalcDate('<CM>', VendorContractDeferral."Posting Date"), 1);
                end;
            end;
            RunningLineAmount += LineAmountPerPeriod;
            RunningLineDiscountTotal += LineDiscountAmountPerPeriod;

            VendorContractDeferral.Amount := LineAmountPerPeriod;
            VendorContractDeferral."Discount Amount" := LineDiscountAmountPerPeriod;
            VendorContractDeferral."Entry No." := 0;
            VendorContractDeferral.Insert(false);
            TempVendorContractDeferral := VendorContractDeferral;
            TempVendorContractDeferral.Insert(false); //Used for Preview Posting
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPurchCrMemoLineInsert, '', false, false)]
    local procedure InsertVendorDeferralsFromPurchaseCrMemo(var PurchCrMemoLine: Record "Purch. Cr. Memo Line"; var PurchaseHeader: Record "Purchase Header")
    begin
        ReleaseAndCreditVendorContractDeferrals(PurchaseHeader, PurchCrMemoLine);
    end;

    local procedure ReleaseAndCreditVendorContractDeferrals(PurchaseHeader: Record "Purchase Header"; var PurchCrMemoLine: Record "Purch. Cr. Memo Line")
    var
        InvoiceVendorContractDeferral: Record "Vend. Sub. Contract Deferral";
        CreditMemoVendorContractDeferral: Record "Vend. Sub. Contract Deferral";
        PurchInvLine: Record "Purch. Inv. Line";
        ContractDeferralRelease: Report "Contract Deferrals Release";
        PurchaseDocuments: Codeunit "Purchase Documents";
        AppliesToDocNo: Code[20];
    begin
        AppliesToDocNo := GetAppliesToDocNo(PurchaseHeader);
        if PurchaseDocuments.IsInvoiceCredited(AppliesToDocNo) then
            exit;
        InvoiceVendorContractDeferral.FilterOnDocumentTypeAndDocumentNo(Enum::"Rec. Billing Document Type"::Invoice, AppliesToDocNo);
        InvoiceVendorContractDeferral.SetRange("Subscription Contract No.", PurchCrMemoLine."Subscription Contract No.");
        InvoiceVendorContractDeferral.SetRange("Subscription Contract Line No.", PurchCrMemoLine."Subscription Contract Line No.");
        if InvoiceVendorContractDeferral.FindSet() then begin
            ContractDeferralRelease.GetAndTestSourceCode();
            ContractDeferralRelease.GetGeneralLedgerSetupAndCheckJournalTemplateAndBatch();
            ContractDeferralRelease.SetAllowGUI(false);
            repeat
                CreditMemoVendorContractDeferral := InvoiceVendorContractDeferral;
                CreditMemoVendorContractDeferral."Document Type" := Enum::"Rec. Billing Document Type"::"Credit Memo";
                CreditMemoVendorContractDeferral."Document No." := PurchCrMemoLine."Document No.";
                CreditMemoVendorContractDeferral."Document Line No." := PurchCrMemoLine."Line No.";
                CreditMemoVendorContractDeferral."Posting Date" := InvoiceVendorContractDeferral."Posting Date";
                CreditMemoVendorContractDeferral."Document Posting Date" := PurchCrMemoLine."Posting Date";
                CreditMemoVendorContractDeferral."Deferral Base Amount" := InvoiceVendorContractDeferral."Deferral Base Amount" * -1;
                CreditMemoVendorContractDeferral.Amount := InvoiceVendorContractDeferral.Amount * -1;
                CreditMemoVendorContractDeferral."Discount Amount" := InvoiceVendorContractDeferral."Discount Amount" * -1;
                CreditMemoVendorContractDeferral."Release Posting Date" := 0D;
                CreditMemoVendorContractDeferral.Released := false;
                CreditMemoVendorContractDeferral."G/L Entry No." := 0;
                CreditMemoVendorContractDeferral."Entry No." := 0;
                CreditMemoVendorContractDeferral.Insert(false);

                PurchInvLine.Get(InvoiceVendorContractDeferral."Document No.", InvoiceVendorContractDeferral."Document Line No.");
                if not InvoiceVendorContractDeferral.Released then begin
                    ContractDeferralRelease.SetRequestPageParameters(InvoiceVendorContractDeferral."Posting Date", PurchCrMemoLine."Posting Date");
                    ContractDeferralRelease.ReleaseVendorContractDeferralsAndInsertTempGenJournalLines(InvoiceVendorContractDeferral);
                    ContractDeferralRelease.PostTempGenJnlLineBufferForVendorDeferrals();
                end;
                ContractDeferralRelease.SetRequestPageParameters(CreditMemoVendorContractDeferral."Posting Date", PurchCrMemoLine."Posting Date");
                ContractDeferralRelease.ReleaseVendorContractDeferralsAndInsertTempGenJournalLines(CreditMemoVendorContractDeferral);
                ContractDeferralRelease.PostTempGenJnlLineBufferForVendorDeferrals();

                TempVendorContractDeferral := CreditMemoVendorContractDeferral;
                TempVendorContractDeferral.Insert(false); //Used for Preview Posting
            until InvoiceVendorContractDeferral.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", OnAfterFillDocumentEntry, '', false, false)]
    local procedure OnAfterFillDocumentEntry(var DocumentEntry: Record "Document Entry")
    var
        PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";
    begin
        PostingPreviewEventHandler.InsertDocumentEntry(TempVendorContractDeferral, DocumentEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", OnAfterShowEntries, '', false, false)]
    local procedure OnAfterShowEntries(TableNo: Integer)
    begin
        if TableNo = Database::"Vend. Sub. Contract Deferral" then
            Page.Run(Page::"Vendor Contract Deferrals", TempVendorContractDeferral);
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, OnAfterNavigateFindRecords, '', false, false)]
    local procedure OnAfterFindEntries(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text)
    var
        VendorContractDeferral: Record "Vend. Sub. Contract Deferral";
    begin
        VendorContractDeferral.SetFilter("Document No.", DocNoFilter);
        DocumentEntry.InsertIntoDocEntry(Database::"Vend. Sub. Contract Deferral", VendorContractDeferral."Document Type", VendorContractDeferral.TableCaption, VendorContractDeferral.Count);
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, OnBeforeShowRecords, '', false, false)]
    local procedure OnBeforeShowRecords(var TempDocumentEntry: Record "Document Entry"; DocNoFilter: Text)
    var
        VendorContractDeferral: Record "Vend. Sub. Contract Deferral";
    begin
        if TempDocumentEntry."Table ID" <> Database::"Vend. Sub. Contract Deferral" then
            exit;

        VendorContractDeferral.SetFilter("Document No.", DocNoFilter);
        Page.Run(Page::"Vendor Contract Deferrals", VendorContractDeferral);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforePostGenJnlLine, '', false, false)]
    local procedure SetContractNo(var GenJournalLine: Record "Gen. Journal Line"; Balancing: Boolean)
    var
        VendorContractDeferrals: Record "Vend. Sub. Contract Deferral";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if DeferralEntryNo = 0 then
            exit;
        SourceCodeSetup.Get();
        if SourceCodeSetup."Sub. Contr. Deferrals Release" <> GenJournalLine."Source Code" then
            exit;
        VendorContractDeferrals.Get(DeferralEntryNo);
        GenJournalLine."Subscription Contract No." := VendorContractDeferrals."Subscription Contract No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterGLFinishPosting, '', false, false)]
    local procedure GetEntryNo(GLEntry: Record "G/L Entry"; var GenJnlLine: Record "Gen. Journal Line")
    var
        VendorContractDeferrals: Record "Vend. Sub. Contract Deferral";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        if SourceCodeSetup."Sub. Contr. Deferrals Release" <> GLEntry."Source Code" then
            exit;   //Update Contract Deferrals while releasing
        if DeferralEntryNo <> 0 then begin
            VendorContractDeferrals.Get(DeferralEntryNo);
            VendorContractDeferrals."G/L Entry No." := GLEntry."Entry No.";
            VendorContractDeferrals.Modify(false);
        end else begin
            //Update related invoice deferrals with GL Entry No.
            VendorContractDeferrals.FilterOnDocumentTypeAndDocumentNo(Enum::"Rec. Billing Document Type"::Invoice, GenJnlLine."Applies-to Doc. No.");
            VendorContractDeferrals.SetRange(Released, true);
            VendorContractDeferrals.SetRange("G/L Entry No.", 0);
            VendorContractDeferrals.ModifyAll("G/L Entry No.", GLEntry."Entry No.", false);
            //Update Credit memo deferrals with GL Entry No.
            VendorContractDeferrals.FilterOnDocumentTypeAndDocumentNo(Enum::"Rec. Billing Document Type"::"Credit Memo", GLEntry."Document No.");
            VendorContractDeferrals.ModifyAll("G/L Entry No.", GLEntry."Entry No.", false);
        end;
    end;

    internal procedure SetDeferralNo(NewDeferralNo: Integer)
    begin
        DeferralEntryNo := NewDeferralNo;
    end;

    local procedure GetAppliesToDocNo(PurchHeader: Record "Purchase Header"): Code[20]
    var
        BillingLine: Record "Billing Line";
    begin
        if PurchHeader."Applies-to Doc. No." <> '' then
            exit(PurchHeader."Applies-to Doc. No.");
        exit(BillingLine.GetCorrectionDocumentNo("Service Partner"::Vendor, PurchHeader."No."));
    end;
}