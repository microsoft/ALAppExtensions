codeunit 5164 "Create Employee"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateEmployee();
        UpdateEmployeesDetails();
    end;

    local procedure CreateEmployee()
    var
        HumanResourcesModuleSetup: Record "Human Resources Module Setup";
        ContosoHumanResources: Codeunit "Contoso Human Resources";
        EmployeeMedia: Codeunit "Employee Media";
        EmploymentContract: Codeunit "Create Employment Contract";
        EmployeeStatGrp: Codeunit "Create Employee Stat. Group";
        Union: Codeunit "Create Union";
        PostingGrp: Code[20];
    begin
        HumanResourcesModuleSetup.Get();
        PostingGrp := HumanResourcesModuleSetup."Employee Posting Group";

        ContosoHumanResources.InsertEmployee(ManagingDirector(), EsterLbl, HendersonLbl, ManagingDirectorLbl, PostingGrp, EmploymentContract.Administrators(), EmployeeStatGrp.Monthly(), Union.AdministratorUnion(), Enum::"Employee Gender"::Female, EmployeeMedia.GetManagingDirectorPicture());
        ContosoHumanResources.InsertEmployee(SalesManager(), JimLbl, OliveLbl, SalesManagerLbl, PostingGrp, EmploymentContract.Administrators(), EmployeeStatGrp.Monthly(), Union.AdministratorUnion(), Enum::"Employee Gender"::Male, EmployeeMedia.GetSalesManagerPicture());
        ContosoHumanResources.InsertEmployee(ProductionManager(), OtisLbl, FallsLbl, ProductionManagerLbl, PostingGrp, EmploymentContract.Administrators(), EmployeeStatGrp.Monthly(), Union.AdministratorUnion(), Enum::"Employee Gender"::Male, EmployeeMedia.GetProductionManagerPicture());
        ContosoHumanResources.InsertEmployee(Designer(), LinaLbl, TownsendLbl, DesignerLbl, PostingGrp, EmploymentContract.Developers(), EmployeeStatGrp.Hourly(), Union.DevelopmentEngineerUnion(), Enum::"Employee Gender"::Female, EmployeeMedia.GetDesignerPicture());
        ContosoHumanResources.InsertEmployee(Secretary(), RobinLbl, BettencourtLbl, SecretaryLbl, PostingGrp, EmploymentContract.ProductionStaff(), EmployeeStatGrp.Days14(), Union.ProductionWorkerUnion(), Enum::"Employee Gender"::"Non-binary", EmployeeMedia.GetSecretaryPicture());
        ContosoHumanResources.InsertEmployee(ProductionAssistant(), MartyLbl, HorstLbl, ProductionAssistantLbl, PostingGrp, EmploymentContract.ProductionStaff(), EmployeeStatGrp.Days14(), Union.ProductionWorkerUnion(), Enum::"Employee Gender"::Male, EmployeeMedia.GetProductionAssistantPicture());
        ContosoHumanResources.InsertEmployee(InventoryManager(), TerryLbl, DoddsLbl, InventoryManagerLbl, PostingGrp, EmploymentContract.Administrators(), EmployeeStatGrp.Days14(), Union.AdministratorUnion(), Enum::"Employee Gender"::Male, EmployeeMedia.GetInventoryManagerPicture());
    end;

    procedure UpdateEmployeesDetails()
    var
        ContosoEmployee: Codeunit "Contoso Human Resources";
    begin
        ContosoEmployee.UpdateEmployeeDetails(ManagingDirector(), 19631212D, 19960601D, RusselStreetLbl, '', '6743', '4564-4564-7831', '4465-4899-4643', '', '1212637665', '4151746513235-45646');
        ContosoEmployee.UpdateEmployeeDetails(SalesManager(), 19690212D, 20010101D, MainStreetLbl, '', '1415', '1234-5678-9012', '0678-9012-3456', '', '1202696486', '3462345-235');
        ContosoEmployee.UpdateEmployeeDetails(ProductionManager(), 19470705D, 19910101D, ElmwoodStreetLbl, '', '4564', '1546-3124-4646', '6549-3216-7415', '', '1003569468', '541236-654');
        ContosoEmployee.UpdateEmployeeDetails(Designer(), 19560310D, 19990101D, HighStreetLbl, '', '3545', '1234-6545-5649', '0678-1234-5466', '', '0708624564', '234654-631');
        ContosoEmployee.UpdateEmployeeDetails(Secretary(), 19490507D, 19960301D, MaddistonRoadLbl, '', '6571', '1234-1643-4384', '0678-2534-2013', '', '0712635465', '234654-631');
        ContosoEmployee.UpdateEmployeeDetails(ProductionAssistant(), 19620807D, 19960301D, GrahamsRoadLbl, '', '4456', '1234-5464-5446', '0678-2135-4649', '', '0507473497', '346246546345-24535');
        ContosoEmployee.UpdateEmployeeDetails(InventoryManager(), 19631207D, 19960301D, BJamesRoadLbl, '', '4653', '1234-6545-8799', '0678-8712-5466', '', '0705491679', '234654-631');
    end;

    var
        EsterLbl: Label 'Ester', MaxLength = 30;
        HendersonLbl: Label 'Henderson', MaxLength = 30;
        RusselStreetLbl: Label '5 Russel Street', MaxLength = 30;
        ManagingDirectorLbl: Label 'Managing Director', MaxLength = 30;
        JimLbl: Label 'Jim', MaxLength = 30;
        OtisLbl: Label 'Otis', MaxLength = 30;
        LinaLbl: Label 'Lina', MaxLength = 20;
        RobinLbl: Label 'Robin', MaxLength = 30;
        MartyLbl: Label 'Marty', MaxLength = 20;
        TerryLbl: Label 'Terry', MaxLength = 20;
        OliveLbl: Label 'Olive', MaxLength = 30;
        FallsLbl: Label 'Falls', MaxLength = 30;
        TownsendLbl: Label 'Townsend', MaxLength = 30;
        BettencourtLbl: Label 'Bettencourt', MaxLength = 30;
        HorstLbl: Label 'Horst', MaxLength = 30;
        DoddsLbl: Label 'Dodds', MaxLength = 30;
        SalesManagerLbl: Label 'Sales Manager', MaxLength = 30;
        ProductionManagerLbl: Label 'Production Manager', MaxLength = 30;
        ProductionAssistantLbl: Label 'Production Assistant', MaxLength = 30;
        InventoryManagerLbl: Label 'Inventory Manager', MaxLength = 30;
        DesignerLbl: Label 'Designer', MaxLength = 30;
        SecretaryLbl: Label 'Secretary', MaxLength = 30;
        MainStreetLbl: Label '47 Main Street', MaxLength = 30;
        ElmwoodStreetLbl: Label '327 Elmwood Street', MaxLength = 30;
        HighStreetLbl: Label '10 High Street', MaxLength = 30;
        MaddistonRoadLbl: Label '7 Maddiston Road', MaxLength = 30;
        GrahamsRoadLbl: Label '49 Grahams Road', MaxLength = 30;
        BJamesRoadLbl: Label '66B James Road', MaxLength = 30;

    procedure InventoryManager(): Code[20]
    begin
        exit('TD');
    end;

    procedure ManagingDirector(): Code[20]
    begin
        exit('EH');
    end;

    procedure Designer(): Code[20]
    begin
        exit('LT');
    end;

    procedure SalesManager(): Code[20]
    begin
        exit('JO');
    end;

    procedure ProductionAssistant(): Code[20]
    begin
        exit('MH');
    end;

    procedure ProductionManager(): Code[20]
    begin
        exit('OF');
    end;

    procedure Secretary(): Code[20]
    begin
        exit('RB');
    end;
}