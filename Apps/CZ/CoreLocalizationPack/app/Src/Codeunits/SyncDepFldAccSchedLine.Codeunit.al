#if not CLEAN19
#pragma warning disable AL0432,AL0603
codeunit 31189 "Sync.Dep.Fld-AccSchedLine CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '19.0';

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertGLAccount(var Rec: Record "Acc. Schedule Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyGLAccount(var Rec: Record "Acc. Schedule Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Acc. Schedule Line")
    var
        PreviousRecord: Record "Acc. Schedule Line";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldInt, NewFieldInt : Integer;
#if not CLEAN17
        DepFieldTxt, NewFieldTxt : Text;
#endif
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
#if not CLEAN17
        DepFieldInt := Rec.Calc;
        NewFieldInt := Rec."Calc CZL".AsInteger();
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord.Calc, PreviousRecord."Calc CZL".AsInteger());
        Rec.Calc := DepFieldInt;
        Rec."Calc CZL" := NewFieldInt;
        DepFieldTxt := Rec."Row Correction";
        NewFieldTxt := Rec."Row Correction CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Row Correction", PreviousRecord."Row Correction CZL");
        Rec."Row Correction" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Row Correction"));
        Rec."Row Correction CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Row Correction CZL"));
        DepFieldInt := Rec."Assets/Liabilities Type";
        NewFieldInt := Rec."Assets/Liabilities Type CZL".AsInteger();
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."Assets/Liabilities Type", PreviousRecord."Assets/Liabilities Type CZL".AsInteger());
        Rec."Assets/Liabilities Type" := DepFieldInt;
        Rec."Assets/Liabilities Type CZL" := NewFieldInt;
#endif
        DepFieldInt := Rec."Source Table";
        NewFieldInt := Rec."Source Table CZL".AsInteger();
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."Source Table", PreviousRecord."Source Table CZL".AsInteger());
        Rec."Source Table" := DepFieldInt;
        Rec."Source Table CZL" := NewFieldInt;
    end;
}
#endif