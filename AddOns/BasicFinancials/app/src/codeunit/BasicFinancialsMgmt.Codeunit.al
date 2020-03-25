codeunit 20601 "Basic Financials Mgmt BF"
{
    Access = Internal;
    internal procedure TestSupportedLocales()
    var
        TempApplicationAreaSetup: Record "Application Area Setup";
        AppAreaMgmt: Codeunit "App Area Mgmt BF";
        ErrLbl: Label 'The Basic Financials Extension can only be deployed for the follovwing Countries: Denmark, Iceland';
    begin
        Clear(TempApplicationAreaSetup);
        AppAreaMgmt.GetEssentialExperienceAppAreas(TempApplicationAreaSetup);
        if TempApplicationAreaSetup."Basic DK" or TempApplicationAreaSetup."Basic IS" then
            exit;

        Error(ErrLbl);
    end;

    internal procedure TestSupportedLicenses()
    var
        AzureADLic: codeunit "Azure AD Licensing";
        ErrLbl: Label 'The Basic Financials Extension can only be deployed, when at least one user has been assigned to a Basic Financials license';
    begin
        while AzureADLic.NextSubscribedSKU() do
            case UpperCase(AzureADLic.SubscribedSKUId()) of
                '{66CAD104-64F9-476E-9682-3C3518B9B6ED}': // Dynamics 365 Business Central Basic Financials:
                    exit;
                '{4dce07fd-7b07-4fb5-8fb7-d49653f7bf30}': // Dynamics 365 Business Central Basic Financials from C5 SPLA (Qualified Offer)
                    exit;
            end;
        Error(ErrLbl);
    end;

    internal procedure TestSupportedUser()
    var
        UserPermissions: Codeunit "User Permissions";
        ErrLbl: Label 'The Basic Financials Extension can only be deployed with Super User Permissions';
    begin
        if UserPermissions.IsSuper(UserSecurityId()) then
            exit;
        Error(ErrLbl);
    end;

    internal procedure TestSupportedCompanies()
    var
        Company: Record Company;
        ErrLbl: Label 'The Basic Financials Extension, can only be deployed, when exactly one Company is present in the Environment';
    begin
        Clear(Company);
        if Company.count() = 1 then
            exit;
        Error(ErrLbl);
    end;

    internal procedure TryDisableRoleCenter()
    var
        AllProfile: Record "All Profile";
    begin
        Clear(AllProfile);
        AllProfile.SetRange(Enabled, true);
        AllProfile.SetFilter("Profile ID", '%1|%2|%3|%4|%5|%6|%7|%8|%9|%10|%11',
            'MANUFACTURING',                    // 8903 MANUFACTURING (Manufacturing)
            'PROJECTS',                         // 8904 PROJECTS (Project)
            'SERVICES',                         // 8908 SERVICES (Service)
            'WAREHOUSE',                        // 8909 WAREHOUSE (Warehouse)
            'SHIPPING AND RECEIVING - WMS',     // 9000 SHIPPING AND RECEIVING - WMS (Shipping and Receiving - Warehouse Management System)
            'SHIPPING AND RECEIVING',           // 9008 SHIPPING AND RECEIVING (Shipping and Receiving - Order-by-Order)
            'WAREHOUSE WORKER - WMS',           // 9009 WAREHOUSE WORKER - WMS (Warehouse Worker - Warehouse Management System)
            'PRODUCTION PLANNER',               // 9010 PRODUCTION PLANNER (Production Planner)
            'PROJECT MANAGER',                  // 9015 PROJECT MANAGER (Project Manager)
            'DISPATCHER',	                    // 9016 Dispatcher - Customer Service
            'SALES AND RELATIONSHIP MANAGER');  // 9026 Sales and Relationship Manager

        if AllProfile.FindSet() then
            repeat
                if not IsAssignedToGroupsOrUsers(AllProfile) then begin
                    AllProfile.Enabled := false;
                    AllProfile.Promoted := false;
                    AllProfile.Modify();
                end;
            until AllProfile.Next() = 0;
    end;

    internal procedure IsAssignedToGroupsOrUsers(AllProfile: Record "All Profile"): Boolean
    var
        UserPersonalization: Record "User Personalization";
        UserGroup: Record "User Group";
    begin
        if AllProfile."Default Role Center" then
            exit(true);

        UserGroup.SetRange("Default Profile ID", AllProfile."Profile ID");
        UserGroup.SetRange("Default Profile App ID", AllProfile."App ID");
        if not UserGroup.IsEmpty() then
            exit(true);

        UserPersonalization.SetRange("Profile ID", AllProfile."Profile ID");
        UserPersonalization.SetRange("App ID", AllProfile."App ID");
        if not UserPersonalization.IsEmpty() then
            exit(true);

        exit(false);
    end;
}