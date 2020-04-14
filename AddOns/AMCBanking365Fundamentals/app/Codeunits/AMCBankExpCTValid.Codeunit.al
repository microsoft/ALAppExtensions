codeunit 20107 "AMC Bank Exp. CT Valid."
{
    TableNo = "Gen. Journal Line";

    trigger OnRun()
    var
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: record "Payment Method";
        PaymentExportGenJnlCheck: Codeunit "Payment Export Gen. Jnl Check";
    begin
        DeletePaymentFileBatchErrors();
        DeletePaymentFileErrors();

        GenJnlLine.CopyFilters(Rec);
        if GenJnlLine.FindSet() then
            repeat
                CODEUNIT.Run(CODEUNIT::"Payment Export Gen. Jnl Check", GenJnlLine);
                if "Payment Method Code" <> '' then
                    if (PaymentMethod.Get(GenJnlLine."Payment Method Code")) then
                        if (PaymentMethod."AMC Bank Pmt. Type" = '') then
                            PaymentExportGenJnlCheck.AddFieldEmptyError(GenJnlLine, PaymentMethod.TableCaption, PaymentMethod.FieldCaption("AMC Bank Pmt. Type"), '');

            until GenJnlLine.Next() = 0;

        if GenJnlLine.HasPaymentFileErrorsInBatch() then begin
            Commit();
            Error(HasErrorsErr);
        end;
    end;

    var
        HasErrorsErr: Label 'The file export has one or more errors.\\For each line to be exported, resolve the errors displayed to the right and then try to export again.';
}

