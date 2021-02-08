#pragma warning disable AL0432
codeunit 31150 "Sync.Dep.Fld-Customer CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

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
    end;
}
