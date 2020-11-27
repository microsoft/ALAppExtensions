#pragma warning disable AL0432
codeunit 31160 "Sync.Dep.Fld-ServiceHeader CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertServiceHeader(var Rec: Record "Service Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyServiceHeader(var Rec: Record "Service Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Service Header")
    var
        PreviousRecord: Record "Service Header";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
        DepFieldInt, NewFieldInt : Integer;        
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        SyncDepFldUtilities.SyncFields(Rec."VAT Date", Rec."VAT Date CZL", PreviousRecord."VAT Date", PreviousRecord."VAT Date CZL");
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
        DepFieldInt := Rec."Credit Memo Type";
        NewFieldInt := Rec."Credit Memo Type CZL".AsInteger();
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."Credit Memo Type", PreviousRecord."Credit Memo Type CZL".AsInteger());
        Rec."Credit Memo Type" := DepFieldInt;
        Rec."Credit Memo Type CZL" := "Credit Memo Type CZL".FromInteger(NewFieldInt);
        SyncDepFldUtilities.SyncFields(Rec."EU 3-Party Intermediate Role", Rec."EU 3-Party Intermed. Role CZL", PreviousRecord."EU 3-Party Intermediate Role", PreviousRecord."EU 3-Party Intermed. Role CZL");
        SyncDepFldUtilities.SyncFields(Rec."VAT Currency Factor", Rec."VAT Currency Factor CZL", PreviousRecord."VAT Currency Factor", PreviousRecord."VAT Currency Factor CZL");
    end;
}
