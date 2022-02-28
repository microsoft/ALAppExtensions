codeunit 1160 "COHUB Install"
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerDatabase()
    begin
        SetCompanyHubPermissions();
    end;

    trigger OnInstallAppPerCompany();
    begin
        InstallPerCompany();
    end;

    var
        CompanyHubTok: Label 'D365 COMPANY HUB', Locked = true;
        CompanyHubDescriptionTxt: Label 'Dyn. 365 Company Hub';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure OnCompanyInitialize()
    begin
        InstallPerCompany();
    end;

    local procedure SetCompanyHubPermissions()
    begin
        if AddCompanyHubPermissionSet() then
            AddCompanyHubPermissions();
        AddCompanyHubUserGroup();
        AddCompanyHubPermissionSetToGroup();
    end;

    local procedure AddCompanyHubPermissionSet(): Boolean
    var
        PermissionSet: Record "Permission Set";
        ServerSetting: Codeunit "Server Setting";
        CompanyHubCode: Code[20];
    begin
        CompanyHubCode := CopyStr(CompanyHubTok, 1, MaxStrLen(PermissionSet."Role ID"));

        if ServerSetting.GetUsePermissionSetsFromExtensions() then
            exit(false);
        if PermissionSet.Get(CompanyHubCode) then
            exit(false);

        PermissionSet."Role ID" := CompanyHubCode;
        PermissionSet.Name := CopyStr(CompanyHubDescriptionTxt, 1, MaxStrLen(PermissionSet.Name));
        PermissionSet.Insert();
        exit(true);
    end;

    local procedure AddCompanyHubPermissions(): Boolean
    begin
        AddPermission(Database::"COHUB Company Endpoint");
        AddPermission(Database::"COHUB Company KPI");
        AddPermission(Database::"COHUB Enviroment");
        AddPermission(Database::"COHUB Group");
        AddPermission(Database::"COHUB Group Company Summary");
        AddPermission(Database::"COHUB User Task");
    end;

    local procedure AddPermission(ObjectId: Integer)
    var
        Permission: Record Permission;
        CompanyHubCode: Code[20];
    begin
        CompanyHubCode := CopyStr(CompanyHubTok, 1, MaxStrLen(Permission."Role ID"));

        Permission."Role ID" := CompanyHubCode;
        Permission."Object Type" := Permission."Object Type"::"Table Data";
        Permission."Object ID" := ObjectId;
        Permission."Read Permission" := Permission."Read Permission"::Yes;
        Permission."Insert Permission" := Permission."Insert Permission"::Yes;
        Permission."Modify Permission" := Permission."Modify Permission"::Yes;
        Permission."Delete Permission" := Permission."Delete Permission"::Yes;
        Permission.Insert();
    end;

    local procedure AddCompanyHubUserGroup();
    var
        AllProfile: Record "All Profile";
        UserGroup: Record "User Group";
        CompanyHubCode: Code[20];
    begin
        CompanyHubCode := CopyStr(CompanyHubTok, 1, MaxStrLen(UserGroup.Code));
        if UserGroup.Get(CompanyHubCode) then
            exit;

#pragma warning disable AA0210
        AllProfile.SetRange("Role Center ID", Page::"Business Manager Role Center");
#pragma warning restore AA0210
        AllProfile.SetRange(Scope, AllProfile.Scope::Tenant);
        AllProfile.FindFirst();

        UserGroup.Code := CompanyHubCode;
        UserGroup.Name := CopyStr(CompanyHubDescriptionTxt, 1, MaxStrLen(UserGroup.Name));
        UserGroup."Assign to All New Users" := false;
        UserGroup."Default Profile ID" := AllProfile."Profile ID";
        UserGroup."Default Profile App ID" := AllProfile."App ID";
        UserGroup."Default Profile Scope" := AllProfile.Scope;
        UserGroup.Insert();
    end;

    local procedure AddCompanyHubPermissionSetToGroup();
    var
        UserGroupPermissionSet: Record "User Group Permission Set";
        AggregatePermissionSet: Record "Aggregate Permission Set";
        CompanyHubCode: Code[20];
    begin
        CompanyHubCode := CopyStr(CompanyHubTok, 1, MaxStrLen(UserGroupPermissionSet."Role ID"));

        AggregatePermissionSet.SetRange("Role ID", CompanyHubCode);
        if not AggregatePermissionSet.FindFirst() then
            exit;

        if UserGroupPermissionSet.Get(CompanyHubCode, CompanyHubCode, UserGroupPermissionSet.Scope::System, AggregatePermissionSet."App ID") then
            exit;

        // Legacy System
        if UserGroupPermissionSet.Get(CompanyHubCode, CompanyHubCode, UserGroupPermissionSet.Scope::System) then
            exit;

        UserGroupPermissionSet."Role ID" := CompanyHubCode;
        UserGroupPermissionSet."User Group Code" := CompanyHubCode;
        UserGroupPermissionSet.Scope := UserGroupPermissionSet.Scope::System;
        UserGroupPermissionSet."App ID" := AggregatePermissionSet."App ID";
        UserGroupPermissionSet.Insert();

        AggregatePermissionSet.SetRange("Role ID", 'LOCAL');
        if not AggregatePermissionSet.FindFirst() then
            exit;

        UserGroupPermissionSet."Role ID" := 'LOCAL';
        UserGroupPermissionSet."User Group Code" := CompanyHubCode;
        UserGroupPermissionSet.Scope := UserGroupPermissionSet.Scope::System;
        UserGroupPermissionSet."App ID" := AggregatePermissionSet."App ID";
        UserGroupPermissionSet.Insert();
    end;

    local procedure InstallPerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);

        if AppInfo.DataVersion() <> Version.Create('0.0.0.0') then
            exit;

        // Version = 0.0.0.0 on first install.  Only create sample data on initial install.
        ApplyEvaluationClassificationsForPrivacy();
    end;


    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        COHUBCompanyKPI: Record "COHUB Company KPI";
        COHUBCompanyEndpoint: Record "COHUB Company Endpoint";
        COHUBEnviroment: Record "COHUB Enviroment";
        COHUBUserTask: Record "COHUB User Task";
        COHUBGroupCompanySummary: Record "COHUB Group Company Summary";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"COHUB Company KPI");
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB Company KPI", COHUBCompanyKPI.FieldNo("Company Display Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB Company KPI", COHUBCompanyKPI.FieldNo("Company Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB Company KPI", COHUBCompanyKPI.FieldNo("Assigned To"));
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB Company KPI", COHUBCompanyKPI.FieldNo("Contact Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB Company KPI", COHUBCompanyKPI.FieldNo("Environment Name"));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"COHUB Company Endpoint");
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB Company Endpoint", COHUBCompanyEndpoint.FieldNo("Company Display Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB Company Endpoint", COHUBCompanyEndpoint.FieldNo("Company Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB Company Endpoint", COHUBCompanyEndpoint.FieldNo("Assigned To"));
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB Company Endpoint", COHUBCompanyEndpoint.FieldNo("ODATA Company URL"));

        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB Enviroment", COHUBEnviroment.FieldNo(Link));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"COHUB User Task");
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB User Task", COHUBUserTask.FieldNo("Company Display Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB User Task", COHUBUserTask.FieldNo("Assigned To"));
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB User Task", COHUBUserTask.FieldNo("Company Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB User Task", COHUBUserTask.FieldNo("Created By"));
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB User Task", COHUBUserTask.FieldNo("User Task Group Assigned To"));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"COHUB Group");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"COHUB Group Company Summary");
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB Group Company Summary", COHUBGroupCompanySummary.FieldNo("Environment Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB Group Company Summary", COHUBGroupCompanySummary.FieldNo("Company Display Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB Group Company Summary", COHUBGroupCompanySummary.FieldNo("Company Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"COHUB Group Company Summary", COHUBGroupCompanySummary.FieldNo("Assigned To"));
    end;
}