#if not CLEAN18
#pragma warning disable AL0432
codeunit 31150 "Sync.Dep.Fld-Customer CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertCustomer(var Rec: Record Customer)
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyCustomer(var Rec: Record Customer)
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record Customer)
    var
        PreviousRecord: Record Customer;
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

#if not CLEAN17
        DepFieldTxt := Rec."Registration No.";
        NewFieldTxt := Rec."Registration No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Registration No.", PreviousRecord."Registration No. CZL");
        Rec."Registration No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Registration No."));
        Rec."Registration No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Registration No. CZL"));
        DepFieldTxt := Rec."Tax Registration No.";
        NewFieldTxt := Rec."Tax Registration No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Tax Registration No.", PreviousRecord."Tax Registration No. CZL");
        Rec."Tax Registration No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Tax Registration No."));
        Rec."Tax Registration No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Tax Registration No. CZL"));
#endif
        DepFieldTxt := Rec."Transaction Type";
        NewFieldTxt := Rec."Transaction Type CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Transaction Type", PreviousRecord."Transaction Type CZL");
        Rec."Transaction Type" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Transaction Type"));
        Rec."Transaction Type CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Transaction Type CZL"));
        DepFieldTxt := Rec."Transaction Specification";
        NewFieldTxt := Rec."Transaction Specification CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Transaction Specification", PreviousRecord."Transaction Specification CZL");
        Rec."Transaction Specification" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Transaction Specification"));
        Rec."Transaction Specification CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Transaction Specification CZL"));
        DepFieldTxt := Rec."Transport Method";
        NewFieldTxt := Rec."Transport Method CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Transport Method", PreviousRecord."Transport Method CZL");
        Rec."Transport Method" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Transport Method"));
        Rec."Transport Method CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Transport Method CZL"));
    end;
}
#endif