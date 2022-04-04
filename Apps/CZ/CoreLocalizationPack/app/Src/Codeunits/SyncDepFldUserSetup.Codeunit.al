#if not CLEAN18
#pragma warning disable AL0432
codeunit 31161 "Sync.Dep.Fld-UserSetup CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

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
        SyncDepFldUtilities.SyncFields(Rec."Check Document Date(work date)", Rec."Check Doc. Date(work date) CZL", PreviousRecord."Check Document Date(work date)", PreviousRecord."Check Doc. Date(work date) CZL");
        SyncDepFldUtilities.SyncFields(Rec."Check Document Date(sys. date)", Rec."Check Doc. Date(sys. date) CZL", PreviousRecord."Check Document Date(sys. date)", PreviousRecord."Check Doc. Date(sys. date) CZL");
        SyncDepFldUtilities.SyncFields(Rec."Check Posting Date (work date)", Rec."Check Post.Date(work date) CZL", PreviousRecord."Check Posting Date (work date)", PreviousRecord."Check Post.Date(work date) CZL");
        SyncDepFldUtilities.SyncFields(Rec."Check Posting Date (sys. date)", Rec."Check Post.Date(sys. date) CZL", PreviousRecord."Check Posting Date (sys. date)", PreviousRecord."Check Post.Date(sys. date) CZL");
        SyncDepFldUtilities.SyncFields(Rec."Check Bank Accounts", Rec."Check Bank Accounts CZL", PreviousRecord."Check Bank Accounts", PreviousRecord."Check Bank Accounts CZL");
        SyncDepFldUtilities.SyncFields(Rec."Check Journal Templates", Rec."Check Journal Templates CZL", PreviousRecord."Check Journal Templates", PreviousRecord."Check Journal Templates CZL");
        SyncDepFldUtilities.SyncFields(Rec."Check Dimension Values", Rec."Check Dimension Values CZL", PreviousRecord."Check Dimension Values", PreviousRecord."Check Dimension Values CZL");
        SyncDepFldUtilities.SyncFields(Rec."Allow Posting to Closed Period", Rec."Allow Post.toClosed Period CZL", PreviousRecord."Allow Posting to Closed Period", PreviousRecord."Allow Post.toClosed Period CZL");
        SyncDepFldUtilities.SyncFields(Rec."Allow Complete Job", Rec."Allow Complete Job CZL", PreviousRecord."Allow Complete Job", PreviousRecord."Allow Complete Job CZL");
        SyncDepFldUtilities.SyncFields(Rec."Allow Item Unapply", Rec."Allow Item Unapply CZL", PreviousRecord."Allow Item Unapply", PreviousRecord."Allow Item Unapply CZL");
        SyncDepFldUtilities.SyncFields(Rec."Check Location Code", Rec."Check Location Code CZL", PreviousRecord."Check Location Code", PreviousRecord."Check Location Code CZL");
        SyncDepFldUtilities.SyncFields(Rec."Check Release Location Code", Rec."Check Release LocationCode CZL", PreviousRecord."Check Release Location Code", PreviousRecord."Check Release LocationCode CZL");
        SyncDepFldUtilities.SyncFields(Rec."Check Whse. Net Change Temp.", Rec."Check Invt. Movement Temp. CZL", PreviousRecord."Check Whse. Net Change Temp.", PreviousRecord."Check Invt. Movement Temp. CZL");
        DepFieldTxt := Rec."Employee No.";
        NewFieldTxt := Rec."Employee No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Employee No.", PreviousRecord."Employee No. CZL");
        Rec."Employee No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Employee No."));
        Rec."Employee No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Employee No. CZL"));
        DepFieldTxt := Rec."User Name";
        NewFieldTxt := Rec."User Name CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."User Name", PreviousRecord."User Name CZL");
        Rec."User Name" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."User Name"));
        Rec."User Name CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."User Name CZL"));
    end;
}
#endif