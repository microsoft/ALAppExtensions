#if not CLEAN19
#pragma warning disable AL0432, AL0603
codeunit 31164 "Sync.Dep.Fld-PurchSetup CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Purchases & Payables Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertPurchSetup(var Rec: Record "Purchases & Payables Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchases & Payables Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyPurchSetup(var Rec: Record "Purchases & Payables Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Purchases & Payables Setup")
    var
        PreviousRecord: Record "Purchases & Payables Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldInt, NewFieldInt : Integer;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldInt := Rec."Default VAT Date";
        NewFieldInt := Rec."Default VAT Date CZL".AsInteger();
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."Default VAT Date", PreviousRecord."Default VAT Date CZL".AsInteger());
        Rec."Default VAT Date" := DepFieldInt;
        Rec."Default VAT Date CZL" := NewFieldInt;
        DepFieldInt := Rec."Default Orig. Doc. VAT Date";
        NewFieldInt := Rec."Def. Orig. Doc. VAT Date CZL";
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."Default Orig. Doc. VAT Date", PreviousRecord."Def. Orig. Doc. VAT Date CZL");
        Rec."Default Orig. Doc. VAT Date" := DepFieldInt;
        Rec."Def. Orig. Doc. VAT Date CZL" := NewFieldInt;
#if not CLEAN18
        SyncDepFldUtilities.SyncFields(Rec."Allow Alter Posting Groups", Rec."Allow Alter Posting Groups CZL", PreviousRecord."Allow Alter Posting Groups", PreviousRecord."Allow Alter Posting Groups CZL");
#endif
    end;
}
#endif