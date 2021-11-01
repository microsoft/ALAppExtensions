codeunit 31400 "SEPA CT Handler CZB"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SEPA CT-Check Line", 'OnBeforeCheckGenJnlLine', '', false, false)]
    local procedure EmptyTypePaymentOrderLineOnBeforeCheckGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        BankAccount: Record "Bank Account";
        MustBeBankAccErr: Label 'The balancing account must be a bank account.';
        MustBePositiveErr: Label 'The amount must be positive.';
        EuroCurrErr: Label 'Only transactions in euro (EUR) are allowed, because the %1 bank account is set up to use the %2 export format.', Comment = '%1= bank account No, %2 export format; Example: Only transactions in euro (EUR) are allowed, because the GIRO bank account is set up to use the SEPACT export format.';
        TransferDateErr: Label 'The earliest possible transfer date is today.';
        EURCurrencyCodeTok: Label 'EUR', Locked = true;
    begin
        if IsHandled then
            exit;

        GeneralLedgerSetup.Get();

        if GenJournalLine."Bal. Account Type" <> GenJournalLine."Bal. Account Type"::"Bank Account" then
            GenJournalLine.InsertPaymentFileError(MustBeBankAccErr);

        if GenJournalLine."Bal. Account No." = '' then
            AddFieldEmptyError(GenJournalLine, GenJournalLine.TableCaption, GenJournalLine.FieldCaption("Bal. Account No."), '');

        if GenJournalLine.Amount <= 0 then
            GenJournalLine.InsertPaymentFileError(MustBePositiveErr);

        if (GenJournalLine."Currency Code" <> GeneralLedgerSetup.GetCurrencyCode(EURCurrencyCodeTok)) and not GeneralLedgerSetup."SEPA Non-Euro Export" then begin
            BankAccount.Get(GenJournalLine."Bal. Account No.");
            GenJournalLine.InsertPaymentFileError(StrSubstNo(EuroCurrErr, GenJournalLine."Bal. Account No.", BankAccount."Payment Export Format"));
        end;

        if GenJournalLine."Posting Date" < Today then
            GenJournalLine.InsertPaymentFileError(TransferDateErr);

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SEPA CT-Check Line", 'OnBeforeCheckCustVendEmpl', '', false, false)]
    local procedure EmptyTypePaymentOrderLineOnBeforeCheckCustVendEmpl(var GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        if GenJournalLine."Account No." = '' then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SEPA CT-Fill Export Buffer", 'OnFillExportBufferOnSetAsRecipient', '', false, false)]
    local procedure EmptyTypePaymentOrderLineOnFillExportBufferOnSetAsRecipient(var GenJnlLine: Record "Gen. Journal Line"; var PaymentExportData: Record "Payment Export Data"; var TempGenJnlLine: Record "Gen. Journal Line" temporary)
    begin
        if GenJnlLine."Account No." = '' then begin
            if TempGenJnlLine."IBAN CZL" <> '' then
                PaymentExportData."Recipient Bank Acc. No." := TempGenJnlLine."IBAN CZL"
            else
                if TempGenJnlLine."Bank Account No. CZL" <> '' then
                    PaymentExportData."Recipient Bank Acc. No." := TempGenJnlLine."Bank Account No. CZL";
            if TempGenJnlLine."SWIFT Code CZL" <> '' then
                PaymentExportData."Recipient Bank BIC" := TempGenJnlLine."SWIFT Code CZL";
        end;
    end;

    local procedure AddFieldEmptyError(var GenJournalLine: Record "Gen. Journal Line"; TableCaption: Text; FieldCaption: Text; KeyValue: Text)
    var
        ErrorText: Text;
        FieldBlankErr: Label 'The %1 field must be filled.', Comment = '%1= field name. Example: The Name field must be filled.';
        FieldKeyBlankErr: Label '%1 %2 must have a value in %3.', Comment = '%1=table name, %2=key field value, %3=field name. Example: Customer 10000 must have a value in Name.';
    begin
        if KeyValue = '' then
            ErrorText := StrSubstNo(FieldBlankErr, FieldCaption)
        else
            ErrorText := StrSubstNo(FieldKeyBlankErr, TableCaption, KeyValue, FieldCaption);
        GenJournalLine.InsertPaymentFileError(ErrorText);
    end;
}