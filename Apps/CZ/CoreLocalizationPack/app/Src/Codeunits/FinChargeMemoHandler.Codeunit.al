codeunit 31014 "Fin. Charge Memo Handler CZL"
{
    var
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure UpdateRegNoOnAfterCustomerNoValidate(var Rec: Record "Finance Charge Memo Header")
    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
    begin
        CompanyInformation.Get();
        Rec.Validate("Bank Account Code CZL", CompanyInformation."Default Bank Account Code CZL");

        if Rec."Customer No." <> '' then begin
            Customer.Get(Rec."Customer No.");
            Rec."Registration No. CZL" := Customer.GetRegistrationNoTrimmedCZL();
            Rec."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FinChrgMemo-Issue", 'OnAfterInitGenJnlLine', '', false, false)]
    local procedure UpdateBankInfoOnAfterInitGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; FinChargeMemoHeader: Record "Finance Charge Memo Header")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJnlLine."VAT Date CZL" := FinChargeMemoHeader."Posting Date";
#pragma warning restore AL0432
#endif
        GenJnlLine."VAT Reporting Date" := FinChargeMemoHeader."Posting Date";
        if GenJnlLine."Account Type" <> GenJnlLine."Account Type"::Customer then
            exit;

        GenJnlLine."Specific Symbol CZL" := FinChargeMemoHeader."Specific Symbol CZL";
        if FinChargeMemoHeader."Variable Symbol CZL" <> '' then
            GenJnlLine."Variable Symbol CZL" := FinChargeMemoHeader."Variable Symbol CZL"
        else
            GenJnlLine."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(FinChargeMemoHeader."No.");
        GenJnlLine."Constant Symbol CZL" := FinChargeMemoHeader."Constant Symbol CZL";
        GenJnlLine."Bank Account Code CZL" := FinChargeMemoHeader."Bank Account Code CZL";
        GenJnlLine."Bank Account No. CZL" := FinChargeMemoHeader."Bank Account No. CZL";
        GenJnlLine."Transit No. CZL" := FinChargeMemoHeader."Transit No. CZL";
        GenJnlLine."IBAN CZL" := FinChargeMemoHeader."IBAN CZL";
        GenJnlLine."SWIFT Code CZL" := FinChargeMemoHeader."SWIFT Code CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Fin. Charge Memo Header", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckDeletionAllowOnBeforeDeleteEvent(var Rec: Record "Issued Fin. Charge Memo Header")
    var
        PostSalesDelete: Codeunit "PostSales-Delete";
    begin
        PostSalesDelete.IsDocumentDeletionAllowed(Rec."Posting Date");
    end;
}
