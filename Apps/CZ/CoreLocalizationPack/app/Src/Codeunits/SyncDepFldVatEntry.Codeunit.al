#if not CLEAN17
#pragma warning disable AL0432
codeunit 31175 "Sync.Dep.Fld-VATEntry CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertVATEntry(var Rec: Record "VAT Entry")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyVATEntry(var Rec: Record "VAT Entry")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "VAT Entry")
    var
        PreviousRecord: Record "VAT Entry";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."VAT Settlement No.";
        NewFieldTxt := Rec."VAT Settlement No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."VAT Settlement No.", PreviousRecord."VAT Settlement No. CZL");
        Rec."VAT Settlement No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."VAT Settlement No."));
        Rec."VAT Settlement No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."VAT Settlement No. CZL"));
    end;
}
#endif