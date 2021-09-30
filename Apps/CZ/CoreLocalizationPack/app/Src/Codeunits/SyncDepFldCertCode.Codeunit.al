#if not CLEAN18
#pragma warning disable AL0432
codeunit 31208 "Sync.Dep.Fld-CertCode CZL"
{
    Permissions = tabledata "Certificate CZ Code" = rimd,
                  tabledata "Certificate Code CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Certificate CZ Code", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCertificateCZCode(var Rec: Record "Certificate CZ Code"; var xRec: Record "Certificate CZ Code")
    var
        CertificateCodeCZL: Record "Certificate Code CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Certificate CZ Code") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Certificate Code CZL");
        CertificateCodeCZL.ChangeCompany(Rec.CurrentCompany);
        if CertificateCodeCZL.Get(xRec.Code) then
            CertificateCodeCZL.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Certificate Code CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Certificate CZ Code", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCertificateCZCode(var Rec: Record "Certificate CZ Code")
    begin
        SyncCertificateCZCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Certificate CZ Code", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCertificateCZCode(var Rec: Record "Certificate CZ Code")
    begin
        SyncCertificateCZCode(Rec);
    end;

    local procedure SyncCertificateCZCode(var Rec: Record "Certificate CZ Code")
    var
        CertificateCodeCZL: Record "Certificate Code CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Certificate CZ Code") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Certificate Code CZL");
        CertificateCodeCZL.ChangeCompany(Rec.CurrentCompany);
        if not CertificateCodeCZL.Get(Rec.Code) then begin
            CertificateCodeCZL.Init();
            CertificateCodeCZL.Code := Rec.Code;
            CertificateCodeCZL.SystemId := Rec.SystemId;
            CertificateCodeCZL.Insert(false, true);
        end;
        CertificateCodeCZL.Description := Rec.Description;
        CertificateCodeCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Certificate Code CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Certificate CZ Code", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCertificateCZCode(var Rec: Record "Certificate CZ Code")
    var
        CertificateCodeCZL: Record "Certificate Code CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Certificate CZ Code") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Certificate Code CZL");
        CertificateCodeCZL.ChangeCompany(Rec.CurrentCompany);
        if CertificateCodeCZL.Get(Rec.Code) then
            CertificateCodeCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Certificate Code CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Certificate Code CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCertificateCodeCZL(var Rec: Record "Certificate Code CZL"; var xRec: Record "Certificate Code CZL")
    var
        CertificateCZCode: Record "Certificate CZ Code";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Certificate Code CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Certificate CZ Code");
        CertificateCZCode.ChangeCompany(Rec.CurrentCompany);
        if CertificateCZCode.Get(xRec.Code) then
            CertificateCZCode.Rename(Rec.Code);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Certificate CZ Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Certificate Code CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCertificateCodeCZL(var Rec: Record "Certificate Code CZL")
    begin
        SyncCertificateCodeCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Certificate Code CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCertificateCodeCZL(var Rec: Record "Certificate Code CZL")
    begin
        SyncCertificateCodeCZL(Rec);
    end;

    local procedure SyncCertificateCodeCZL(var Rec: Record "Certificate Code CZL")
    var
        CertificateCZCode: Record "Certificate CZ Code";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Certificate Code CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Certificate CZ Code");
        CertificateCZCode.ChangeCompany(Rec.CurrentCompany);
        if not CertificateCZCode.Get(Rec.Code) then begin
            CertificateCZCode.Init();
            CertificateCZCode.Code := CopyStr(Rec.Code, 1, MaxStrLen(CertificateCZCode.Code));
            CertificateCZCode.SystemId := Rec.SystemId;
            CertificateCZCode.Insert(false, true);
        end;
        CertificateCZCode.Description := CopyStr(Rec.Description, 1, MaxStrLen(CertificateCZCode.Description));
        CertificateCZCode.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Certificate CZ Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Certificate Code CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCertificateCodeCZL(var Rec: Record "Certificate Code CZL")
    var
        CertificateCZCode: Record "Certificate CZ Code";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Certificate Code CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Certificate CZ Code");
        CertificateCZCode.ChangeCompany(Rec.CurrentCompany);
        if CertificateCZCode.Get(Rec.Code) then
            CertificateCZCode.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Certificate CZ Code");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif