#if not CLEAN18
#pragma warning disable AL0432
codeunit 31194 "Sync.Dep.Fld-PurchaseLine CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertPurchaseLIne(var Rec: Record "Purchase Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyPurchaseLine(var Rec: Record "Purchase Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Purchase Line")
    var
        PreviousRecord: Record "Purchase Line";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Physical Transfer", Rec."Physical Transfer CZL", PreviousRecord."Physical Transfer", PreviousRecord."Physical Transfer CZL");
        DepFieldTxt := Rec."Country/Region of Origin Code";
        NewFieldTxt := Rec."Country/Reg. of Orig. Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Country/Region of Origin Code", PreviousRecord."Country/Reg. of Orig. Code CZL");
        Rec."Country/Region of Origin Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Country/Region of Origin Code"));
        Rec."Country/Reg. of Orig. Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Country/Reg. of Orig. Code CZL"));
    end;
}
#endif