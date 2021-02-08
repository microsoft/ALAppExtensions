#pragma warning disable AL0432
codeunit 31159 "Sync.Dep.Fld-PurchHeader CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertPurchaseHeader(var Rec: Record "Purchase Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyPurchaseHeader(var Rec: Record "Purchase Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Purchase Header")
    var
        PreviousRecord: Record "Purchase Header";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
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
        SyncDepFldUtilities.SyncFields(Rec."EU 3-Party Intermediate Role", Rec."EU 3-Party Intermed. Role CZL", PreviousRecord."EU 3-Party Intermediate Role", PreviousRecord."EU 3-Party Intermed. Role CZL");
        SyncDepFldUtilities.SyncFields(Rec."EU 3-Party Trade", Rec."EU 3-Party Trade CZL", PreviousRecord."EU 3-Party Trade", PreviousRecord."EU 3-Party Trade CZL");
        SyncDepFldUtilities.SyncFields(Rec."Original Document VAT Date", Rec."Original Doc. VAT Date CZL", PreviousRecord."Original Document VAT Date", PreviousRecord."Original Doc. VAT Date CZL");
        SyncDepFldUtilities.SyncFields(Rec."VAT Currency Factor", Rec."VAT Currency Factor CZL", PreviousRecord."VAT Currency Factor", PreviousRecord."VAT Currency Factor CZL");
    end;
}
