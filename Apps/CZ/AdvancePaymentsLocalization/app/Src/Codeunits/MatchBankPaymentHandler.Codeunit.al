codeunit 31390 "Match Bank Payment Handler CZZ"
{
    var
        BankAccount: Record "Bank Account";
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
        MatchBankPaymentCZB: Codeunit "Match Bank Payment CZB";
        MinAmount, MaxAmount : Decimal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Match Bank Payment CZB", 'OnAfterFillMatchBankPaymentBuffer', '', false, false)]
    local procedure MatchAdvancesOnAfterFillMatchBankPaymentBuffer(SearchRuleLineCZB: Record "Search Rule Line CZB"; var TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        if not AdvancePaymentsMgtCZZ.IsEnabled() then
            exit;
        if SearchRuleLineCZB."Search Scope" <> SearchRuleLineCZB."Search Scope"::"Advance CZZ" then
            exit;

        BankAccount.Get(GenJournalLine."Bal. Account No.");
        if GenJournalLine.IsLocalCurrencyCZB() then
            MatchBankPaymentCZB.GetAmountRangeForTolerance(BankAccount, -GenJournalLine."Amount (LCY)", MinAmount, MaxAmount)
        else
            MatchBankPaymentCZB.GetAmountRangeForTolerance(BankAccount, -GenJournalLine.Amount, MinAmount, MaxAmount);
        case
            SearchRuleLineCZB."Banking Transaction Type" of
            SearchRuleLineCZB."Banking Transaction Type"::Both:
                begin
                    FillMatchBankPaymentBufferSalesAdvance(SearchRuleLineCZB, TempMatchBankPaymentBufferCZB, GenJournalLine);
                    FillMatchBankPaymentBufferPurchaseAdvance(SearchRuleLineCZB, TempMatchBankPaymentBufferCZB, GenJournalLine);
                end;
            SearchRuleLineCZB."Banking Transaction Type"::Credit:
                FillMatchBankPaymentBufferSalesAdvance(SearchRuleLineCZB, TempMatchBankPaymentBufferCZB, GenJournalLine);
            SearchRuleLineCZB."Banking Transaction Type"::Debit:
                FillMatchBankPaymentBufferPurchaseAdvance(SearchRuleLineCZB, TempMatchBankPaymentBufferCZB, GenJournalLine);
        end;
    end;

    local procedure FillMatchBankPaymentBufferSalesAdvance(var SearchRuleLineCZB: Record "Search Rule Line CZB"; var TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; var GenJournalLine: Record "Gen. Journal Line")
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        CustomerBankAccount: Record "Customer Bank Account";
        InsertToBuffer: Boolean;
    begin
        SalesAdvLetterHeaderCZZ.SetRange(Status, SalesAdvLetterHeaderCZZ.Status::"To Pay");
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) and
            (GenJournalLine."Account No." <> '')
        then
            SalesAdvLetterHeaderCZZ.SetRange("Bill-to Customer No.", GenJournalLine."Account No.");
        if SearchRuleLineCZB."Bank Account No." then begin
            if (GenJournalLine."Bank Account No. CZL" = '') and
               (GenJournalLine."Bank Account Code CZL" = '') and
               (GenJournalLine."IBAN CZL" = '')
            then
                exit;
            if SalesAdvLetterHeaderCZZ.GetFilter("Bill-to Customer No.") <> '' then
                SalesAdvLetterHeaderCZZ.CopyFilter("Bill-to Customer No.", CustomerBankAccount."Customer No.");
            if GenJournalLine."Bank Account Code CZL" <> '' then
                CustomerBankAccount.SetRange(Code, GenJournalLine."Bank Account Code CZL");
            if GenJournalLine."Bank Account No. CZL" <> '' then
                CustomerBankAccount.SetRange("Bank Account No.", GenJournalLine."Bank Account No. CZL");
            if GenJournalLine."IBAN CZL" <> '' then
                CustomerBankAccount.SetRange(IBAN, GenJournalLine."IBAN CZL");
            if CustomerBankAccount.Count() <> 1 then
                exit;
            CustomerBankAccount.FindFirst();
            SalesAdvLetterHeaderCZZ.SetRange("Bill-to Customer No.", CustomerBankAccount."Customer No.");
        end;
        if SearchRuleLineCZB."Variable Symbol" then begin
            if GenJournalLine."Variable Symbol CZL" = '' then
                exit;
            SalesAdvLetterHeaderCZZ.SetRange("Variable Symbol", GenJournalLine."Variable Symbol CZL");
        end;
        if SearchRuleLineCZB."Specific Symbol" then begin
            if GenJournalLine."Specific Symbol CZL" = '' then
                exit;
            SalesAdvLetterHeaderCZZ.SetRange("Specific Symbol", GenJournalLine."Specific Symbol CZL");
        end;
        if SearchRuleLineCZB."Constant Symbol" then begin
            if GenJournalLine."Constant Symbol CZL" = '' then
                exit;
            SalesAdvLetterHeaderCZZ.SetRange("Constant Symbol", GenJournalLine."Constant Symbol CZL");
        end;
        if SalesAdvLetterHeaderCZZ.FindSet() then
            repeat
                InsertToBuffer := true;
                if SearchRuleLineCZB.Amount then
                    InsertToBuffer := IsToPayAmountInRange(SalesAdvLetterHeaderCZZ, GenJournalLine.IsLocalCurrencyCZB());
                if InsertToBuffer then
                    TempMatchBankPaymentBufferCZB.InsertFromSalesAdvanceCZZ(SalesAdvLetterHeaderCZZ, GenJournalLine.IsLocalCurrencyCZB())
            until SalesAdvLetterHeaderCZZ.Next() = 0;
    end;

    local procedure IsToPayAmountInRange(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; UseLCYAmounts: Boolean): Boolean
    begin
        SalesAdvLetterHeaderCZZ.CalcFields("To Pay", "To Pay (LCY)");
        if UseLCYAmounts then
            exit((SalesAdvLetterHeaderCZZ."To Pay (LCY)" >= MinAmount) and (SalesAdvLetterHeaderCZZ."To Pay (LCY)" <= MaxAmount));
        exit((SalesAdvLetterHeaderCZZ."To Pay" >= MinAmount) and (SalesAdvLetterHeaderCZZ."To Pay" <= MaxAmount));
    end;

    local procedure FillMatchBankPaymentBufferPurchaseAdvance(var SearchRuleLineCZB: Record "Search Rule Line CZB"; var TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; var GenJournalLine: Record "Gen. Journal Line")
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        VendorBankAccount: Record "Vendor Bank Account";
        InsertToBuffer: Boolean;
    begin
        PurchAdvLetterHeaderCZZ.SetRange(Status, PurchAdvLetterHeaderCZZ.Status::"To Pay");
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) and
            (GenJournalLine."Account No." <> '')
        then
            PurchAdvLetterHeaderCZZ.SetRange("Pay-to Vendor No.", GenJournalLine."Account No.");
        if SearchRuleLineCZB."Bank Account No." then begin
            if (GenJournalLine."Bank Account No. CZL" = '') and
               (GenJournalLine."Bank Account Code CZL" = '') and
               (GenJournalLine."IBAN CZL" = '')
            then
                exit;
            if PurchAdvLetterHeaderCZZ.GetFilter("Pay-to Vendor No.") <> '' then
                PurchAdvLetterHeaderCZZ.CopyFilter("Pay-to Vendor No.", VendorBankAccount."Vendor No.");
            if GenJournalLine."Bank Account Code CZL" <> '' then
                VendorBankAccount.SetRange(Code, GenJournalLine."Bank Account Code CZL");
            if GenJournalLine."Bank Account No. CZL" <> '' then
                VendorBankAccount.SetRange("Bank Account No.", GenJournalLine."Bank Account No. CZL");
            if GenJournalLine."IBAN CZL" <> '' then
                VendorBankAccount.SetRange(IBAN, GenJournalLine."IBAN CZL");
            if VendorBankAccount.Count() <> 1 then
                exit;
            VendorBankAccount.FindFirst();
            PurchAdvLetterHeaderCZZ.SetRange("Pay-to Vendor No.", VendorBankAccount."Vendor No.");
        end;
        if SearchRuleLineCZB."Variable Symbol" then begin
            if GenJournalLine."Variable Symbol CZL" = '' then
                exit;
            PurchAdvLetterHeaderCZZ.SetRange("Variable Symbol", GenJournalLine."Variable Symbol CZL");
        end;
        if SearchRuleLineCZB."Specific Symbol" then begin
            if GenJournalLine."Specific Symbol CZL" = '' then
                exit;
            PurchAdvLetterHeaderCZZ.SetRange("Specific Symbol", GenJournalLine."Specific Symbol CZL");
        end;
        if SearchRuleLineCZB."Constant Symbol" then begin
            if GenJournalLine."Constant Symbol CZL" = '' then
                exit;
            PurchAdvLetterHeaderCZZ.SetRange("Constant Symbol", GenJournalLine."Constant Symbol CZL");
        end;
        if PurchAdvLetterHeaderCZZ.FindSet() then
            repeat
                InsertToBuffer := true;
                if SearchRuleLineCZB.Amount then
                    InsertToBuffer := IsToPayAmountInRange(PurchAdvLetterHeaderCZZ, GenJournalLine.IsLocalCurrencyCZB());
                if InsertToBuffer then
                    TempMatchBankPaymentBufferCZB.InsertFromPurchAdvanceCZZ(PurchAdvLetterHeaderCZZ, GenJournalLine.IsLocalCurrencyCZB())
            until PurchAdvLetterHeaderCZZ.Next() = 0;
    end;

    local procedure IsToPayAmountInRange(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; UseLCYAmounts: Boolean): Boolean
    begin
        PurchAdvLetterHeaderCZZ.CalcFields("To Pay", "To Pay (LCY)");
        if UseLCYAmounts then
            exit((PurchAdvLetterHeaderCZZ."To Pay (LCY)" >= MinAmount) and (PurchAdvLetterHeaderCZZ."To Pay (LCY)" <= MaxAmount));
        exit((PurchAdvLetterHeaderCZZ."To Pay" >= MinAmount) and (PurchAdvLetterHeaderCZZ."To Pay" <= MaxAmount));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Match Bank Payment CZB", 'OnAfterValidateGenJournalLine', '', false, false)]
    local procedure ValidateAdvanceNoOnAfterValidateGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; var TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB")
    var
        OriginalGenJournalLine: Record "Gen. Journal Line";
    begin
        if not AdvancePaymentsMgtCZZ.IsEnabled() then
            exit;
        if TempMatchBankPaymentBufferCZB."Advance Letter No. CZZ" = '' then
            exit;

        OriginalGenJournalLine := GenJournalLine;
        GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Payment);
        GenJournalLine.Validate("Advance Letter No. CZZ", TempMatchBankPaymentBufferCZB."Advance Letter No. CZZ");
        GenJournalLine.Validate(Amount, OriginalGenJournalLine.Amount);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Search Rule CZB", 'OnAfterInsertRuleLine', '', false, false)]
    local procedure AddAdvanceRuleLineOnAfterInsertRuleLine(SearchRuleLineCZB: Record "Search Rule Line CZB"; var LineNo: Integer; Description: Text)
    var
        AdvanceSearchRuleLineCZB: Record "Search Rule Line CZB";
        DescriptionTxt: Label 'Both, Advance, %1', Comment = '%1 = Line Description';
    begin
        if not AdvancePaymentsMgtCZZ.IsEnabled() then
            exit;
        if SearchRuleLineCZB."Banking Transaction Type" <> SearchRuleLineCZB."Banking Transaction Type"::Both then
            exit;
        if SearchRuleLineCZB."Search Scope" <> SearchRuleLineCZB."Search Scope"::Balance then
            exit;

        LineNo += 10000;
        AdvanceSearchRuleLineCZB := SearchRuleLineCZB;
        AdvanceSearchRuleLineCZB."Line No." := LineNo;
        AdvanceSearchRuleLineCZB.Validate(Description, CopyStr(StrSubstNo(DescriptionTxt, Description), 1, MaxStrLen(SearchRuleLineCZB.Description)));
        AdvanceSearchRuleLineCZB.Validate("Banking Transaction Type", AdvanceSearchRuleLineCZB."Banking Transaction Type"::Both);
        AdvanceSearchRuleLineCZB.Validate("Search Scope", AdvanceSearchRuleLineCZB."Search Scope"::"Advance CZZ");
        AdvanceSearchRuleLineCZB.Insert(true);
    end;
#if not CLEAN19
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Match Bank Payment CZB", 'OnBeforeFillMatchBankPaymentBufferSalesAdvance', '', false, false)]
    local procedure SkipMatchingSalesAdvanceOnBeforeFillMatchBankPaymentBufferSalesAdvance(var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        IsHandled := AdvancePaymentsMgtCZZ.IsEnabled();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Match Bank Payment CZB", 'OnBeforeFillMatchBankPaymentBufferPurchaseAdvance', '', false, false)]
    local procedure SkipMatchingPurchAdvanceOnBeforeFillMatchBankPaymentBufferSalesAdvance(var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        IsHandled := AdvancePaymentsMgtCZZ.IsEnabled();
    end;
#pragma warning restore AL0432
#endif
}
