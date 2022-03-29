codeunit 11749 "Reminder Handler CZL"
{
    var
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";

    [EventSubscriber(ObjectType::Table, Database::"Reminder Header", 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure UpdateRegNoOnAfterCustomerNoValidate(var Rec: Record "Reminder Header")
    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
    begin
        CompanyInformation.Get();
        Rec.Validate("Bank Account Code CZL", CompanyInformation."Default Bank Account Code CZL");

        if Rec."Customer No." <> '' then begin
            Customer.Get(Rec."Customer No.");
            Rec."Registration No. CZL" := Customer."Registration No. CZL";
            Rec."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reminder-Issue", 'OnAfterInitGenJnlLine', '', false, false)]
    local procedure UpdateBankInfoOnAfterInitGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; ReminderHeader: Record "Reminder Header")
    begin
        GenJournalLine."VAT Date CZL" := ReminderHeader."Posting Date";
        if GenJournalLine."Account Type" <> GenJournalLine."Account Type"::Customer then
            exit;

        GenJournalLine."Specific Symbol CZL" := ReminderHeader."Specific Symbol CZL";
        if ReminderHeader."Variable Symbol CZL" <> '' then
            GenJournalLine."Variable Symbol CZL" := ReminderHeader."Variable Symbol CZL"
        else
            GenJournalLine."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(ReminderHeader."No.");
        GenJournalLine."Constant Symbol CZL" := ReminderHeader."Constant Symbol CZL";
        GenJournalLine."Bank Account Code CZL" := ReminderHeader."Bank Account Code CZL";
        GenJournalLine."Bank Account No. CZL" := ReminderHeader."Bank Account No. CZL";
        GenJournalLine."Transit No. CZL" := ReminderHeader."Transit No. CZL";
        GenJournalLine."IBAN CZL" := ReminderHeader."IBAN CZL";
        GenJournalLine."SWIFT Code CZL" := ReminderHeader."SWIFT Code CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Reminder Header", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckDeletionAllowOnBeforeDeleteEvent(var Rec: Record "Issued Reminder Header")
    var
        PostSalesDelete: Codeunit "PostSales-Delete";
    begin
        PostSalesDelete.IsDocumentDeletionAllowed(Rec."Posting Date");
    end;
}