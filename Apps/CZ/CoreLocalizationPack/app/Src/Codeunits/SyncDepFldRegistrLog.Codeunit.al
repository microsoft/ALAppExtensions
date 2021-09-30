#if not CLEAN17
#pragma warning disable AL0432
codeunit 31153 "Sync.Dep.Fld-RegistrLog CZL"
{
    Permissions = tabledata "Registration Log" = rimd,
                  tabledata "Registration Log CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Registration Log", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertRegistrationLog(var Rec: Record "Registration Log")
    begin
        SyncRegistrationLog(Rec);
    end;

    local procedure SyncRegistrationLog(var Rec: Record "Registration Log")
    var
        RegistrationLogCZL: Record "Registration Log CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Registration Log") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Registration Log CZL");
        RegistrationLogCZL.ChangeCompany(Rec.CurrentCompany);
        RegistrationLogCZL.Init();
        RegistrationLogCZL."Registration No." := Rec."Registration No.";
        RegistrationLogCZL."Account Type" := Enum::"Reg. Log Account Type CZL".FromInteger(Rec."Account Type");
        RegistrationLogCZL."Account No." := Rec."Account No.";
        RegistrationLogCZL."User ID" := Rec."User ID";
        RegistrationLogCZL.Status := Rec.Status;
        RegistrationLogCZL."Verified Name" := Rec."Verified Name";
        RegistrationLogCZL."Verified Address" := Rec."Verified Address";
        RegistrationLogCZL."Verified City" := Rec."Verified City";
        RegistrationLogCZL."Verified Post Code" := Rec."Verified Post Code";
        RegistrationLogCZL."Verified VAT Registration No." := Rec."Verified VAT Registration No.";
        RegistrationLogCZL."Verified Date" := Rec."Verified Date";
        RegistrationLogCZL."Verified Result" := Rec."Verified Result";
        RegistrationLogCZL.SystemId := Rec.SystemId;
        RegistrationLogCZL.Insert(false, true);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Registration Log CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Registration Log CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertRegistrationLogCZL(var Rec: Record "Registration Log CZL")
    begin
        SyncRegistrationLogCZL(Rec);
    end;

    local procedure SyncRegistrationLogCZL(var Rec: Record "Registration Log CZL")
    var
        RegistrationLog: Record "Registration Log";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Registration Log CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Registration Log");
        RegistrationLog.ChangeCompany(Rec.CurrentCompany);
        RegistrationLog.Init();
        RegistrationLog."Registration No." := Rec."Registration No.";
        RegistrationLog."Account Type" := Rec."Account Type".AsInteger();
        RegistrationLog."Account No." := Rec."Account No.";
        RegistrationLog."User ID" := Rec."User ID";
        RegistrationLog.Status := Rec.Status;
        RegistrationLog."Verified Name" := Rec."Verified Name";
        RegistrationLog."Verified Address" := Rec."Verified Address";
        RegistrationLog."Verified City" := Rec."Verified City";
        RegistrationLog."Verified Post Code" := Rec."Verified Post Code";
        RegistrationLog."Verified VAT Registration No." := Rec."Verified VAT Registration No.";
        RegistrationLog."Verified Date" := Rec."Verified Date";
        RegistrationLog."Verified Result" := Rec."Verified Result";
        RegistrationLog.SystemId := Rec.SystemId;
        RegistrationLog.Insert(false, true);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Registration Log");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif