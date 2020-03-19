codeunit 20601 "BF Install Extension"
{
    Subtype = Install;
    trigger OnInstallAppPerCompany()
    var
        DummyExperienceTierSetup: Record "Experience Tier Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(DummyExperienceTierSetup.FieldCaption(DummyExperienceTierSetup."BF Basic Financials"));
        TryDisableRoleCenter();
    end;

    local procedure TryDisableRoleCenter()
    var
        AllProfile: Record "All Profile";
    begin
        Clear(AllProfile);
        AllProfile.SetRange(Enabled, true);
        AllProfile.SetFilter("Profile ID", '%1|%2|%3|%4|%5|%6|%7|%8|%9',
            'MANUFACTURING',                // 8903 MANUFACTURING (Manufacturing)
            'PROJECTS',                     // 8904 PROJECTS (Project)
            'SERVICES',                     // 8908 SERVICES (Service)
            'WAREHOUSE',                    // 8909 WAREHOUSE (Warehouse)
            'SHIPPING AND RECEIVING - WMS', // 9000 SHIPPING AND RECEIVING - WMS (Shipping and Receiving - Warehouse Management System)
            'SHIPPING AND RECEIVING',       // 9008 SHIPPING AND RECEIVING (Shipping and Receiving - Order-by-Order)
            'WAREHOUSE WORKER - WMS',       // 9009 WAREHOUSE WORKER - WMS (Warehouse Worker - Warehouse Management System)
            'PRODUCTION PLANNER',           // 9010 PRODUCTION PLANNER (Production Planner)
            'PROJECT MANAGER');             // 9015 PROJECT MANAGER (Project Manager)

        if AllProfile.FindSet() then
            repeat
                if not IsAssignedToGroupsOrUsers(AllProfile) then begin
                    AllProfile.Enabled := false;
                    AllProfile.Promoted := false;
                    AllProfile.Modify();
                end;
            until AllProfile.Next() = 0;
    end;

    local procedure IsAssignedToGroupsOrUsers(AllProfile: Record "All Profile"): Boolean
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