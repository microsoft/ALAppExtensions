#if not CLEAN18
#pragma warning disable AL0432
codeunit 31223 "Sync.Dep.Fld-IntrastJnlLn CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Jnl. Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertIntrastatJnlLine(var Rec: Record "Intrastat Jnl. Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Jnl. Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyIntrastatJnlLine(var Rec: Record "Intrastat Jnl. Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Intrastat Jnl. Line")
    var
        PreviousRecord: Record "Intrastat Jnl. Line";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldInt, NewFieldInt : Integer;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Additional Costs", Rec."Additional Costs CZL", PreviousRecord."Additional Costs", PreviousRecord."Additional Costs CZL");
        SyncDepFldUtilities.SyncFields(Rec."Source Entry Date", Rec."Source Entry Date CZL", PreviousRecord."Source Entry Date", PreviousRecord."Source Entry Date CZL");
        DepFieldTxt := Rec."Statistic Indication";
        NewFieldTxt := Rec."Statistic Indication CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Statistic Indication", PreviousRecord."Statistic Indication CZL");
        Rec."Statistic Indication" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Statistic Indication"));
        Rec."Statistic Indication CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Statistic Indication CZL"));
        DepFieldTxt := Rec."Statistics Period";
        NewFieldTxt := Rec."Statistics Period CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Statistics Period", PreviousRecord."Statistics Period CZL");
        Rec."Statistics Period" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Statistics Period"));
        Rec."Statistics Period CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Statistics Period CZL"));
        DepFieldTxt := Rec."Declaration No.";
        NewFieldTxt := Rec."Declaration No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Declaration No.", PreviousRecord."Declaration No. CZL");
        Rec."Declaration No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Declaration No."));
        Rec."Declaration No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Declaration No. CZL"));
        DepFieldInt := Rec."Statement Type";
        NewFieldInt := Rec."Statement Type CZL".AsInteger();
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."Statement Type", PreviousRecord."Statement Type CZL".AsInteger());
        Rec."Statement Type" := DepFieldInt;
        Rec."Statement Type CZL" := "Intrastat Statement Type CZL".FromInteger(NewFieldInt);
        DepFieldTxt := Rec."Prev. Declaration No.";
        NewFieldTxt := Rec."Prev. Declaration No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Prev. Declaration No.", PreviousRecord."Prev. Declaration No. CZL");
        Rec."Prev. Declaration No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Prev. Declaration No."));
        Rec."Prev. Declaration No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Prev. Declaration No. CZL"));
        SyncDepFldUtilities.SyncFields(Rec."Prev. Declaration Line No.", Rec."Prev. Declaration Line No. CZL", PreviousRecord."Prev. Declaration Line No.", PreviousRecord."Prev. Declaration Line No. CZL");
        DepFieldTxt := Rec."Specific Movement";
        NewFieldTxt := Rec."Specific Movement CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Specific Movement", PreviousRecord."Specific Movement CZL");
        Rec."Specific Movement" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Specific Movement"));
        Rec."Specific Movement CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Specific Movement CZL"));
        DepFieldTxt := Rec."Supplem. UoM Code";
        NewFieldTxt := Rec."Supplem. UoM Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Supplem. UoM Code", PreviousRecord."Supplem. UoM Code CZL");
        Rec."Supplem. UoM Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Supplem. UoM Code"));
        Rec."Supplem. UoM Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Supplem. UoM Code CZL"));
        SyncDepFldUtilities.SyncFields(Rec."Supplem. UoM Quantity", Rec."Supplem. UoM Quantity CZL", PreviousRecord."Supplem. UoM Quantity", PreviousRecord."Supplem. UoM Quantity CZL");
        SyncDepFldUtilities.SyncFields(Rec."Supplem. UoM Net Weight", Rec."Supplem. UoM Net Weight CZL", PreviousRecord."Supplem. UoM Net Weight", PreviousRecord."Supplem. UoM Net Weight CZL");
        DepFieldTxt := Rec."Base Unit of Measure";
        NewFieldTxt := Rec."Base Unit of Measure CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Base Unit of Measure", PreviousRecord."Base Unit of Measure CZL");
        Rec."Base Unit of Measure" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Base Unit of Measure"));
        Rec."Base Unit of Measure CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Base Unit of Measure CZL"));
    end;
}
#endif