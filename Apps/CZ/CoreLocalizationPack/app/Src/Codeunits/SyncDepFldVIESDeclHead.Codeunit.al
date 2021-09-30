#if not CLEAN17
#pragma warning disable AL0432
codeunit 31140 "Sync.Dep.Fld-VIESDeclHead CZL"
{
    Permissions = tabledata "VIES Declaration Header" = rimd,
                  tabledata "VIES Declaration Header CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Header", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVIESDeclarationHeader(var Rec: Record "VIES Declaration Header"; var xRec: Record "VIES Declaration Header")
    var
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VIES Declaration Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VIES Declaration Header CZL");
        VIESDeclarationHeaderCZL.ChangeCompany(Rec.CurrentCompany);
        if VIESDeclarationHeaderCZL.Get(xRec."No.") then
            VIESDeclarationHeaderCZL.Rename(Rec."No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VIES Declaration Header CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVIESDeclarationHeader(var Rec: Record "VIES Declaration Header")
    begin
        SyncVIESDeclarationHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Header", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVIESDeclarationHeader(var Rec: Record "VIES Declaration Header")
    begin
        SyncVIESDeclarationHeader(Rec);
    end;

    local procedure SyncVIESDeclarationHeader(var Rec: Record "VIES Declaration Header")
    var
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VIES Declaration Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VIES Declaration Header CZL");
        VIESDeclarationHeaderCZL.ChangeCompany(Rec.CurrentCompany);
        if not VIESDeclarationHeaderCZL.Get(Rec."No.") then begin
            VIESDeclarationHeaderCZL.Init();
            VIESDeclarationHeaderCZL."No." := Rec."No.";
            VIESDeclarationHeaderCZL.SystemId := Rec.SystemId;
            VIESDeclarationHeaderCZL.Insert(false, true);
        end;
        VIESDeclarationHeaderCZL."VAT Registration No." := Rec."VAT Registration No.";
        VIESDeclarationHeaderCZL."Trade Type" := Rec."Trade Type";
        VIESDeclarationHeaderCZL."Period No." := Rec."Period No.";
        VIESDeclarationHeaderCZL.Year := Rec.Year;
        VIESDeclarationHeaderCZL."Start Date" := Rec."Start Date";
        VIESDeclarationHeaderCZL."End Date" := Rec."End Date";
        VIESDeclarationHeaderCZL.Name := Rec.Name;
        VIESDeclarationHeaderCZL."Name 2" := Rec."Name 2";
        VIESDeclarationHeaderCZL."Country/Region Name" := Rec."Country/Region Name";
        VIESDeclarationHeaderCZL.County := Rec.County;
        VIESDeclarationHeaderCZL."Municipality No." := Rec."Municipality No.";
        VIESDeclarationHeaderCZL.Street := Rec.Street;
        VIESDeclarationHeaderCZL."House No." := Rec."House No.";
        VIESDeclarationHeaderCZL."Apartment No." := Rec."Apartment No.";
        VIESDeclarationHeaderCZL.City := Rec.City;
        VIESDeclarationHeaderCZL."Post Code" := Rec."Post Code";
        VIESDeclarationHeaderCZL."Tax Office Number" := Rec."Tax Office Number";
        VIESDeclarationHeaderCZL."Declaration Period" := Rec."Declaration Period";
        VIESDeclarationHeaderCZL."Declaration Type" := Rec."Declaration Type";
        VIESDeclarationHeaderCZL."Corrected Declaration No." := Rec."Corrected Declaration No.";
        VIESDeclarationHeaderCZL."Document Date" := Rec."Document Date";
        VIESDeclarationHeaderCZL."Sign-off Date" := Rec."Sign-off Date";
        VIESDeclarationHeaderCZL."Sign-off Place" := Rec."Sign-off Place";
        VIESDeclarationHeaderCZL."EU Goods/Services" := Rec."EU Goods/Services";
        VIESDeclarationHeaderCZL.Status := Rec.Status;
        VIESDeclarationHeaderCZL."No. Series" := Rec."No. Series";
        VIESDeclarationHeaderCZL."Authorized Employee No." := Rec."Authorized Employee No.";
        VIESDeclarationHeaderCZL."Filled by Employee No." := Rec."Filled by Employee No.";
        VIESDeclarationHeaderCZL."Individual First Name" := Rec."Natural Person First Name";
        VIESDeclarationHeaderCZL."Individual Surname" := Rec."Natural Person Surname";
        VIESDeclarationHeaderCZL."Individual Title" := Rec."Natural Person Title";
        VIESDeclarationHeaderCZL."Company Type" := Rec."Taxpayer Type";
        VIESDeclarationHeaderCZL."Individual Employee No." := Rec."Natural Employee No.";
        VIESDeclarationHeaderCZL."Company Trade Name Appendix" := Rec."Company Trade Name Appendix";
        VIESDeclarationHeaderCZL."Tax Office Region Number" := Rec."Tax Office Region Number";
        VIESDeclarationHeaderCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VIES Declaration Header CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Header", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVIESDeclarationHeader(var Rec: Record "VIES Declaration Header")
    var
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VIES Declaration Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VIES Declaration Header CZL");
        VIESDeclarationHeaderCZL.ChangeCompany(Rec.CurrentCompany);
        if VIESDeclarationHeaderCZL.Get(Rec."No.") then
            VIESDeclarationHeaderCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VIES Declaration Header CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Header CZL", 'OnBeforeRenameEvent', '', false, false)]
    local procedure SyncOnBeforeRenameVIESDeclarationHeaderCZL(var Rec: Record "VIES Declaration Header CZL"; var xRec: Record "VIES Declaration Header CZL")
    var
        VIESDeclarationHeader: Record "VIES Declaration Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VIES Declaration Header CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VIES Declaration Header");
        VIESDeclarationHeader.ChangeCompany(Rec.CurrentCompany);
        if VIESDeclarationHeader.Get(xRec."No.") then
            VIESDeclarationHeader.Rename(Rec."No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VIES Declaration Header");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Header CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVIESDeclarationHeaderCZL(var Rec: Record "VIES Declaration Header CZL")
    begin
        SyncVIESDeclarationHeaderCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Header CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVIESDeclarationHeaderCZL(var Rec: Record "VIES Declaration Header CZL")
    begin
        SyncVIESDeclarationHeaderCZL(Rec);
    end;

    local procedure SyncVIESDeclarationHeaderCZL(var Rec: Record "VIES Declaration Header CZL")
    var
        VIESDeclarationHeader: Record "VIES Declaration Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VIES Declaration Header CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VIES Declaration Header");
        VIESDeclarationHeader.ChangeCompany(Rec.CurrentCompany);
        if not VIESDeclarationHeader.Get(Rec."No.") then begin
            VIESDeclarationHeader.Init();
            VIESDeclarationHeader."No." := Rec."No.";
            VIESDeclarationHeader.SystemId := Rec.SystemId;
            VIESDeclarationHeader.Insert(false, true);
        end;
        VIESDeclarationHeader."VAT Registration No." := Rec."VAT Registration No.";
        VIESDeclarationHeader."Trade Type" := Rec."Trade Type";
        VIESDeclarationHeader."Period No." := Rec."Period No.";
        VIESDeclarationHeader.Year := Rec.Year;
        VIESDeclarationHeader."Start Date" := Rec."Start Date";
        VIESDeclarationHeader."End Date" := Rec."End Date";
        VIESDeclarationHeader.Name := Rec.Name;
        VIESDeclarationHeader."Name 2" := Rec."Name 2";
        VIESDeclarationHeader."Country/Region Name" := Rec."Country/Region Name";
        VIESDeclarationHeader.County := Rec.County;
        VIESDeclarationHeader."Municipality No." := Rec."Municipality No.";
        VIESDeclarationHeader.Street := Rec.Street;
        VIESDeclarationHeader."House No." := Rec."House No.";
        VIESDeclarationHeader."Apartment No." := Rec."Apartment No.";
        VIESDeclarationHeader.City := Rec.City;
        VIESDeclarationHeader."Post Code" := Rec."Post Code";
        VIESDeclarationHeader."Tax Office Number" := Rec."Tax Office Number";
        VIESDeclarationHeader."Declaration Period" := Rec."Declaration Period";
        VIESDeclarationHeader."Declaration Type" := Rec."Declaration Type";
        VIESDeclarationHeader."Corrected Declaration No." := Rec."Corrected Declaration No.";
        VIESDeclarationHeader."Document Date" := Rec."Document Date";
        VIESDeclarationHeader."Sign-off Date" := Rec."Sign-off Date";
        VIESDeclarationHeader."Sign-off Place" := Rec."Sign-off Place";
        VIESDeclarationHeader."EU Goods/Services" := Rec."EU Goods/Services";
        VIESDeclarationHeader.Status := Rec.Status;
        VIESDeclarationHeader."No. Series" := Rec."No. Series";
        VIESDeclarationHeader."Authorized Employee No." := Rec."Authorized Employee No.";
        VIESDeclarationHeader."Filled by Employee No." := Rec."Filled by Employee No.";
        VIESDeclarationHeader."Natural Person First Name" := Rec."Individual First Name";
        VIESDeclarationHeader."Natural Person Surname" := Rec."Individual Surname";
        VIESDeclarationHeader."Natural Person Title" := Rec."Individual Title";
        VIESDeclarationHeader."Taxpayer Type" := Rec."Company Type";
        VIESDeclarationHeader."Natural Employee No." := Rec."Individual Employee No.";
        VIESDeclarationHeader."Company Trade Name Appendix" := Rec."Company Trade Name Appendix";
        VIESDeclarationHeader."Tax Office Region Number" := Rec."Tax Office Region Number";
        VIESDeclarationHeader.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VIES Declaration Header");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Header CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVIESDeclarationHeaderCZL(var Rec: Record "VIES Declaration Header CZL")
    var
        VIESDeclarationHeader: Record "VIES Declaration Header";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VIES Declaration Header CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VIES Declaration Header");
        VIESDeclarationHeader.ChangeCompany(Rec.CurrentCompany);
        if VIESDeclarationHeader.Get(Rec."No.") then
            VIESDeclarationHeader.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VIES Declaration Header");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif