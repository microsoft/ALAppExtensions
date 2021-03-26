#if not CLEAN18
#pragma warning disable AL0432
codeunit 31224 "Sync.Dep.Fld-InvPostSetup CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Inventory Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertInventoryPostingSetup(var Rec: Record "Inventory Posting Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Posting Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyInventoryPostingSetup(var Rec: Record "Inventory Posting Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Inventory Posting Setup")
    var
        PreviousRecord: Record "Inventory Posting Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Consumption Account";
        NewFieldTxt := Rec."Consumption Account CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Consumption Account", PreviousRecord."Consumption Account CZL");
        Rec."Consumption Account" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Consumption Account"));
        Rec."Consumption Account CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Consumption Account CZL"));
        DepFieldTxt := Rec."Change In Inv.Of WIP Acc.";
        NewFieldTxt := Rec."Change In Inv.Of WIP Acc. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Change In Inv.Of WIP Acc.", PreviousRecord."Change In Inv.Of WIP Acc. CZL");
        Rec."Change In Inv.Of WIP Acc." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Change In Inv.Of WIP Acc."));
        Rec."Change In Inv.Of WIP Acc. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Change In Inv.Of WIP Acc. CZL"));
        DepFieldTxt := Rec."Change In Inv.Of Product Acc.";
        NewFieldTxt := Rec."Change In Inv.OfProd. Acc. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Change In Inv.Of Product Acc.", PreviousRecord."Change In Inv.OfProd. Acc. CZL");
        Rec."Change In Inv.Of Product Acc." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Change In Inv.Of Product Acc."));
        Rec."Change In Inv.OfProd. Acc. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Change In Inv.OfProd. Acc. CZL"));
    end;
}
#endif