#if not CLEAN17
#pragma warning disable AL0432
codeunit 31154 "Sync.Dep.Fld-CompOfficials CZL"
{
    Permissions = tabledata "Company Officials" = rimd,
                  tabledata "Company Official CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Company Officials", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCompanyOfficial(var Rec: Record "Company Officials"; var xRec: Record "Company Officials")
    var
        CompanyOfficialCZL: Record "Company Official CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Company Officials") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Company Official CZL");
        CompanyOfficialCZL.ChangeCompany(Rec.CurrentCompany);
        if CompanyOfficialCZL.Get(xRec."No.") then
            CompanyOfficialCZL.Rename(Rec."No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Company Official CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Officials", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCompanyOfficial(var Rec: Record "Company Officials")
    begin
        SyncCompanyOfficial(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Officials", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCompanyOfficial(var Rec: Record "Company Officials")
    begin
        SyncCompanyOfficial(Rec);
    end;

    local procedure SyncCompanyOfficial(var Rec: Record "Company Officials")
    var
        CompanyOfficialCZL: Record "Company Official CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Company Officials") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Company Official CZL");
        CompanyOfficialCZL.ChangeCompany(Rec.CurrentCompany);
        if not CompanyOfficialCZL.Get(Rec."No.") then begin
            CompanyOfficialCZL.Init();
            CompanyOfficialCZL."No." := Rec."No.";
            CompanyOfficialCZL.SystemId := Rec.SystemId;
            CompanyOfficialCZL.Insert(false, true);
        end;
        CompanyOfficialCZL."First Name" := Rec."First Name";
        CompanyOfficialCZL."Middle Name" := Rec."Middle Name";
        CompanyOfficialCZL."Last Name" := Rec."Last Name";
        CompanyOfficialCZL.Initials := Rec.Initials;
        CompanyOfficialCZL."Job Title" := Rec."Job Title";
        CompanyOfficialCZL."Search Name" := Rec."Search Name";
        CompanyOfficialCZL.Address := Rec.Address;
        CompanyOfficialCZL."Address 2" := Rec."Address 2";
        CompanyOfficialCZL.City := Rec.City;
        CompanyOfficialCZL."Post Code" := Rec."Post Code";
        CompanyOfficialCZL.County := Rec.County;
        CompanyOfficialCZL."Phone No." := Rec."Phone No.";
        CompanyOfficialCZL."Mobile Phone No." := Rec."Mobile Phone No.";
        CompanyOfficialCZL."E-Mail" := Rec."E-Mail";
        CompanyOfficialCZL."Country/Region Code" := Rec."Country/Region Code";
        CompanyOfficialCZL."Last Date Modified" := Rec."Last Date Modified";
        CompanyOfficialCZL."Fax No." := Rec."Fax No.";
        CompanyOfficialCZL."No. Series" := Rec."No. Series";
        CompanyOfficialCZL."Employee No." := Rec."Employee No.";
        CompanyOfficialCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Company Official CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Officials", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCompanyOfficial(var Rec: Record "Company Officials")
    var
        CompanyOfficialCZL: Record "Company Official CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Company Officials") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Company Official CZL");
        CompanyOfficialCZL.ChangeCompany(Rec.CurrentCompany);
        if CompanyOfficialCZL.Get(Rec."No.") then
            CompanyOfficialCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Company Official CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Official CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameCompanyOfficialCZL(var Rec: Record "Company Official CZL"; var xRec: Record "Company Official CZL")
    var
        CompanyOfficials: Record "Company Officials";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Company Official CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Company Officials");
        CompanyOfficials.ChangeCompany(Rec.CurrentCompany);
        if CompanyOfficials.Get(xRec."No.") then
            CompanyOfficials.Rename(Rec."No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Company Officials");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Official CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCompanyOfficialCZL(var Rec: Record "Company Official CZL")
    begin
        SyncCompanyOfficialCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Official CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCompanyOfficialCZL(var Rec: Record "Company Official CZL")
    begin
        SyncCompanyOfficialCZL(Rec);
    end;

    local procedure SyncCompanyOfficialCZL(var Rec: Record "Company Official CZL")
    var
        CompanyOfficials: Record "Company Officials";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Company Official CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Company Officials");
        CompanyOfficials.ChangeCompany(Rec.CurrentCompany);
        if not CompanyOfficials.Get(Rec."No.") then begin
            CompanyOfficials.Init();
            CompanyOfficials."No." := Rec."No.";
            CompanyOfficials.SystemId := Rec.SystemId;
            CompanyOfficials.Insert(false, true);
        end;
        CompanyOfficials."First Name" := Rec."First Name";
        CompanyOfficials."Middle Name" := Rec."Middle Name";
        CompanyOfficials."Last Name" := Rec."Last Name";
        CompanyOfficials.Initials := Rec.Initials;
        CompanyOfficials."Job Title" := Rec."Job Title";
        CompanyOfficials."Search Name" := CopyStr(Rec."Search Name", 1, MaxStrLen(CompanyOfficials."Search Name"));
        CompanyOfficials.Address := CopyStr(Rec.Address, 1, MaxStrLen(CompanyOfficials.Address));
        CompanyOfficials."Address 2" := Rec."Address 2";
        CompanyOfficials.City := Rec.City;
        CompanyOfficials."Post Code" := Rec."Post Code";
        CompanyOfficials.County := Rec.County;
        CompanyOfficials."Phone No." := Rec."Phone No.";
        CompanyOfficials."Mobile Phone No." := Rec."Mobile Phone No.";
        CompanyOfficials."E-Mail" := Rec."E-Mail";
        CompanyOfficials."Country/Region Code" := Rec."Country/Region Code";
        CompanyOfficials."Last Date Modified" := Rec."Last Date Modified";
        CompanyOfficials."Fax No." := Rec."Fax No.";
        CompanyOfficials."No. Series" := Rec."No. Series";
        CompanyOfficials."Employee No." := Rec."Employee No.";
        CompanyOfficials.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Company Officials");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Official CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteCompanyOfficialCZL(var Rec: Record "Company Official CZL")
    var
        CompanyOfficials: Record "Company Officials";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Company Official CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Company Officials");
        CompanyOfficials.ChangeCompany(Rec.CurrentCompany);
        if CompanyOfficials.Get(Rec."No.") then
            CompanyOfficials.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Company Officials");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif