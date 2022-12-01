codeunit 4795 "Whse Demo User Event"
{
    SingleInstance = true;
    Permissions = tabledata "Warehouse Employee" = rim, tabledata Location = r;

    local procedure AddUserAsEmployee(Company: Record Company; User: Record User; Location: Record Location; SetAsDefault: Boolean)
    var
        WarehouseEmployee: Record "Warehouse Employee";
    begin
        WarehouseEmployee.ChangeCompany(Company.Name);
        if WarehouseEmployee.Get(User."User Name", Location.Code) then
            exit;
        WarehouseEmployee.Init();
        WarehouseEmployee."User ID" := User."User Name";
        WarehouseEmployee."Location Code" := Location.Code;
        WarehouseEmployee.Default := SetAsDefault;
        WarehouseEmployee.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::User, 'OnAfterInsertEvent', '', false, false)]
    local procedure AddDemoLocationsToNewUsers(var Rec: Record User; RunTrigger: Boolean)
    var
        Company: Record Company;
        WhseDemoDataSetup: Record "Whse Demo Data Setup";
        Location: Record Location;
    begin
        if not RunTrigger then
            exit;

        if Company.FindSet() then
            repeat
                WhseDemoDataSetup.ChangeCompany(Company.Name);
                Location.ChangeCompany(Company.Name);
                if WhseDemoDataSetup.Get() then
                    if WhseDemoDataSetup."Is DemoData Populated" and WhseDemoDataSetup."Auto Create Whse. Employees" then begin
                        if (WhseDemoDataSetup."Location Basic" <> '') and Location.Get(WhseDemoDataSetup."Location Basic") then
                            AddUserAsEmployee(Company, Rec, Location, true);
                        if (WhseDemoDataSetup."Location Simple Logistics" <> '') and Location.Get(WhseDemoDataSetup."Location Simple Logistics") then
                            AddUserAsEmployee(Company, Rec, Location, false);
                        if (WhseDemoDataSetup."Location Advanced Logistics" <> '') and Location.Get(WhseDemoDataSetup."Location Advanced Logistics") then
                            AddUserAsEmployee(Company, Rec, Location, false);
                    end;
            until Company.Next() < 1;

    end;
}
