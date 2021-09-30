#if not CLEAN18
#pragma warning disable AL0432
codeunit 31198 "Sync.Dep.Fld-TariffNo CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Tariff Number", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertSalesSetup(var Rec: Record "Tariff Number")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tariff Number", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifySalesSetup(var Rec: Record "Tariff Number")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Tariff Number")
    var
        PreviousRecord: Record "Tariff Number";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

#if not CLEAN17
        DepFieldTxt := Rec."Statement Code";
        NewFieldTxt := Rec."Statement Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Statement Code", PreviousRecord."Statement Code CZL");
        Rec."Statement Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Statement Code"));
        Rec."Statement Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Statement Code CZL"));
        DepFieldTxt := Rec."VAT Stat. Unit of Measure Code";
        NewFieldTxt := Rec."VAT Stat. UoM Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."VAT Stat. Unit of Measure Code", PreviousRecord."VAT Stat. UoM Code CZL");
        Rec."VAT Stat. Unit of Measure Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."VAT Stat. Unit of Measure Code"));
        Rec."VAT Stat. UoM Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."VAT Stat. UoM Code CZL"));
        SyncDepFldUtilities.SyncFields(Rec."Allow Empty Unit of Meas.Code", Rec."Allow Empty UoM Code CZL", PreviousRecord."Allow Empty Unit of Meas.Code", PreviousRecord."Allow Empty UoM Code CZL");
        DepFieldTxt := Rec."Statement Limit Code";
        NewFieldTxt := Rec."Statement Limit Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Statement Limit Code", PreviousRecord."Statement Limit Code CZL");
        Rec."Statement Limit Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Statement Limit Code"));
        Rec."Statement Limit Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Statement Limit Code CZL"));
#endif
        DepFieldTxt := Rec."Supplem. Unit of Measure Code";
        NewFieldTxt := Rec."Suppl. Unit of Meas. Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Supplem. Unit of Measure Code", PreviousRecord."Suppl. Unit of Meas. Code CZL");
        Rec."Supplem. Unit of Measure Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Supplem. Unit of Measure Code"));
        Rec."Suppl. Unit of Meas. Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Suppl. Unit of Meas. Code CZL"));
    end;
}
#endif