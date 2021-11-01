#if not CLEAN18
#pragma warning disable AL0432
codeunit 31209 "Sync.Dep.Fld-IsolCert CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Isolated Certificate", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertIsolatedCertificate(var Rec: Record "Isolated Certificate")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Isolated Certificate", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyIsolatedCertificate(var Rec: Record "Isolated Certificate")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Isolated Certificate")
    var
        PreviousRecord: Record "Isolated Certificate";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Certificate Code";
        NewFieldTxt := Rec."Certificate Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Certificate Code", PreviousRecord."Certificate Code CZL");
        Rec."Certificate Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Certificate Code"));
        Rec."Certificate Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Certificate Code CZL"));
    end;
}
#endif