#if not CLEAN19
#pragma warning disable AL0432
codeunit 31336 "Sync.Dep.Fld-PaymentExData CZB"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Payment Export Data", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertPaymentExportData(var Rec: Record "Payment Export Data")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Export Data", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyPaymentExportData(var Rec: Record "Payment Export Data")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var PaymentExportData: Record "Payment Export Data")
    var
        PreviousPaymentExportData: Record "Payment Export Data";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(PaymentExportData, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousPaymentExportData);

        DepFieldTxt := PaymentExportData."Specific Symbol";
        NewFieldTxt := PaymentExportData."Specific Symbol CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousPaymentExportData."Specific Symbol", PreviousPaymentExportData."Specific Symbol CZB");
        PaymentExportData."Specific Symbol" := CopyStr(DepFieldTxt, 1, MaxStrLen(PaymentExportData."Specific Symbol"));
        PaymentExportData."Specific Symbol CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(PaymentExportData."Specific Symbol CZB"));
        DepFieldTxt := PaymentExportData."Variable Symbol";
        NewFieldTxt := PaymentExportData."Variable Symbol CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousPaymentExportData."Variable Symbol", PreviousPaymentExportData."Variable Symbol CZB");
        PaymentExportData."Variable Symbol" := CopyStr(DepFieldTxt, 1, MaxStrLen(PaymentExportData."Variable Symbol"));
        PaymentExportData."Variable Symbol CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(PaymentExportData."Variable Symbol CZB"));
        DepFieldTxt := PaymentExportData."Constant Symbol";
        NewFieldTxt := PaymentExportData."Constant Symbol CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousPaymentExportData."Constant Symbol", PreviousPaymentExportData."Constant Symbol CZB");
        PaymentExportData."Constant Symbol" := CopyStr(DepFieldTxt, 1, MaxStrLen(PaymentExportData."Constant Symbol"));
        PaymentExportData."Constant Symbol CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(PaymentExportData."Constant Symbol CZB"));
    end;
}
#endif
