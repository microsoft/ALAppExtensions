#if not CLEAN17
#pragma warning disable AL0432
codeunit 31166 "Sync.Dep.Fld-InvtSetup CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Inventory Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertInvtSetup(var Rec: Record "Inventory Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyInvtSetup(var Rec: Record "Inventory Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Inventory Setup")
    var
        PreviousRecord: Record "Inventory Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Date Order Inventory Change", Rec."Date Order Invt. Change CZL", PreviousRecord."Date Order Inventory Change", PreviousRecord."Date Order Invt. Change CZL");
        DepFieldTxt := Rec."Def.Template for Phys.Pos.Adj";
        NewFieldTxt := Rec."Def.Tmpl. for Phys.Pos.Adj CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Def.Template for Phys.Pos.Adj", PreviousRecord."Def.Tmpl. for Phys.Pos.Adj CZL");
        Rec."Def.Template for Phys.Pos.Adj" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Def.Template for Phys.Pos.Adj"));
        Rec."Def.Tmpl. for Phys.Pos.Adj CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Def.Tmpl. for Phys.Pos.Adj CZL"));
        DepFieldTxt := Rec."Def.Template for Phys.Neg.Adj";
        NewFieldTxt := Rec."Def.Tmpl. for Phys.Neg.Adj CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Def.Template for Phys.Neg.Adj", PreviousRecord."Def.Tmpl. for Phys.Neg.Adj CZL");
        Rec."Def.Template for Phys.Neg.Adj" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Def.Template for Phys.Neg.Adj"));
        Rec."Def.Tmpl. for Phys.Neg.Adj CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Def.Tmpl. for Phys.Neg.Adj CZL"));
        SyncDepFldUtilities.SyncFields(Rec."Post Exp. Cost Conv. as Corr.", Rec."Post Exp.Cost Conv.As Corr.CZL", PreviousRecord."Post Exp. Cost Conv. as Corr.", PreviousRecord."Post Exp.Cost Conv.As Corr.CZL");
        SyncDepFldUtilities.SyncFields(Rec."Post Neg. Transfers as Corr.", Rec."Post Neg.Transf. As Corr.CZL", PreviousRecord."Post Neg. Transfers as Corr.", PreviousRecord."Post Neg.Transf. As Corr.CZL");
    end;
}
#endif