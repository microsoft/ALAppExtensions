#if not CLEAN17
#pragma warning disable AL0432
codeunit 31130 "Sync.Dep.Fld-UserSetup CZP"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertUserSetup(var Rec: Record "User Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyUserSetup(var Rec: Record "User Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "User Setup")
    var
        PreviousRecord: Record "User Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Cash Resp. Ctr. Filter";
        NewFieldTxt := Rec."Cash Resp. Ctr. Filter CZP";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Cash Resp. Ctr. Filter", PreviousRecord."Cash Resp. Ctr. Filter CZP");
        Rec."Cash Resp. Ctr. Filter" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Cash Resp. Ctr. Filter"));
        Rec."Cash Resp. Ctr. Filter CZP" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Cash Resp. Ctr. Filter CZP"));
        SyncDepFldUtilities.SyncFields(Rec."Cash Desk Amt. Approval Limit", Rec."Cash Desk Amt. Appr. Limit CZP", PreviousRecord."Cash Desk Amt. Approval Limit", PreviousRecord."Cash Desk Amt. Appr. Limit CZP");
        SyncDepFldUtilities.SyncFields(Rec."Unlimited Cash Desk Approval", Rec."Unlimited Cash Desk Appr. CZP", PreviousRecord."Unlimited Cash Desk Approval", PreviousRecord."Unlimited Cash Desk Appr. CZP");
    end;
}
#endif