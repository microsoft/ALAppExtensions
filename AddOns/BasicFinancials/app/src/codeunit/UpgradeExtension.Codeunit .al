codeunit 57602 "BF Upgrade Extension"
{
    Subtype = Upgrade;
    trigger OnUpgradePerCompany()
    var
        DummyExperienceTierSetup: Record "Experience Tier Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(DummyExperienceTierSetup.FieldCaption(DummyExperienceTierSetup."BF Basic Financials"));

        //DisableRoleCenterProfile();
    end;

    local procedure DisableRoleCenterProfile()
    var
        AllProfile: Record "All Profile";
    begin

        // 8903 MANUFACTURING (Manufacturing)
        Clear(AllProfile);
        AllProfile.Setrange(Scope, AllProfile.Scope::Tenant);
        AllProfile.Setrange("Profile ID", 'MANUFACTURING');
        AllProfile.Setrange("Role Center ID", 8903);
        AllProfile.Setrange(Enabled, true);
        AllProfile.ModifyAll(Enabled, false, false);

        // 8904 PROJECTS (Project)
        Clear(AllProfile);
        AllProfile.Setrange(Scope, AllProfile.Scope::Tenant);
        AllProfile.Setrange("Profile ID", 'PROJECTS');
        AllProfile.Setrange("Role Center ID", 8904);
        AllProfile.Setrange(Enabled, true);
        AllProfile.ModifyAll(Enabled, false, false);

        // 8908 SERVICES (Service)
        Clear(AllProfile);
        AllProfile.Setrange(Scope, AllProfile.Scope::Tenant);
        AllProfile.Setrange("Profile ID", 'SERVICES');
        AllProfile.Setrange("Role Center ID", 8908);
        AllProfile.Setrange(Enabled, true);
        AllProfile.ModifyAll(Enabled, false, false);

        // 8909 WAREHOUSE (Warehouse)
        Clear(AllProfile);
        AllProfile.Setrange(Scope, AllProfile.Scope::Tenant);
        AllProfile.Setrange("Profile ID", 'WAREHOUSE');
        AllProfile.Setrange("Role Center ID", 8909);
        AllProfile.Setrange(Enabled, true);
        AllProfile.ModifyAll(Enabled, false, false);

        // 9000 SHIPPING AND RECEIVING - WMS (Shipping and Receiving - Warehouse Management System)
        Clear(AllProfile);
        AllProfile.Setrange(Scope, AllProfile.Scope::Tenant);
        AllProfile.Setrange("Profile ID", 'SHIPPING AND RECEIVING - WMS');
        AllProfile.Setrange("Role Center ID", 9000);
        AllProfile.Setrange(Enabled, true);
        AllProfile.ModifyAll(Enabled, false, false);

        // 9008 SHIPPING AND RECEIVING (Shipping and Receiving - Order-by-Order)
        Clear(AllProfile);
        AllProfile.Setrange(Scope, AllProfile.Scope::Tenant);
        AllProfile.Setrange("Profile ID", 'SHIPPING AND RECEIVING');
        AllProfile.Setrange("Role Center ID", 9008);
        AllProfile.Setrange(Enabled, true);
        AllProfile.ModifyAll(Enabled, false, false);

        // 9009 WAREHOUSE WORKER - WMS (Warehouse Worker - Warehouse Management System)
        Clear(AllProfile);
        AllProfile.Setrange(Scope, AllProfile.Scope::Tenant);
        AllProfile.Setrange("Profile ID", 'WAREHOUSE WORKER - WMS');
        AllProfile.Setrange("Role Center ID", 9009);
        AllProfile.Setrange(Enabled, true);
        AllProfile.ModifyAll(Enabled, false, false);

        // 9010 PRODUCTION PLANNER (Production Planner)
        Clear(AllProfile);
        AllProfile.Setrange(Scope, AllProfile.Scope::Tenant);
        AllProfile.Setrange("Profile ID", 'PRODUCTION PLANNER');
        AllProfile.Setrange("Role Center ID", 9010);
        AllProfile.Setrange(Enabled, true);
        AllProfile.ModifyAll(Enabled, false, false);

        // 9015 PROJECT MANAGER (Project Manager)
        Clear(AllProfile);
        AllProfile.Setrange(Scope, AllProfile.Scope::Tenant);
        AllProfile.Setrange("Profile ID", 'PROJECT MANAGER');
        AllProfile.Setrange("Role Center ID", 9015);
        AllProfile.Setrange(Enabled, true);
        AllProfile.ModifyAll(Enabled, false, false);

    end;

}