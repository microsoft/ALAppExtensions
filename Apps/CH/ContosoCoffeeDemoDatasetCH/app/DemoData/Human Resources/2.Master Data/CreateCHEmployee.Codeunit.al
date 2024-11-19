codeunit 11599 "Create CH Employee"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoEmployee: Codeunit "Contoso Human Resources";
        CreateEmployee: Codeunit "Create Employee";
    begin
        ContosoEmployee.UpdateEmployeeDetails(CreateEmployee.ManagingDirector(), 19631212D, 19960601D, RusselStreetLbl, '8400', '6743', '4564-4564-7831', '4465-4899-4643', '', '1212637665', '4151746513235-45646');
        ContosoEmployee.UpdateEmployeeDetails(CreateEmployee.SalesManager(), 19690212D, 20010101D, MainStreetLbl, '3000', '1415', '1234-5678-9012', '0678-9012-3456', '', '1202696486', '3462345-235');
        ContosoEmployee.UpdateEmployeeDetails(CreateEmployee.ProductionManager(), 19470705D, 19910101D, ElmwoodStreetLbl, '3000', '4564', '1546-3124-4646', '6549-3216-7415', '', '1003569468', '541236-654');
        ContosoEmployee.UpdateEmployeeDetails(CreateEmployee.Designer(), 19560310D, 19990101D, HighStreetLbl, '6275', '3545', '1234-6545-5649', '0678-1234-5466', '', '0708624564', '234654-631');
        ContosoEmployee.UpdateEmployeeDetails(CreateEmployee.Secretary(), 19490507D, 19960301D, MaddistonRoadLbl, '3000', '6571', '1234-1643-4384', '0678-2534-2013', '', '0712635465', '234654-631');
        ContosoEmployee.UpdateEmployeeDetails(CreateEmployee.ProductionAssistant(), 19620807D, 19960301D, GrahamsRoadLbl, '3000', '4456', '1234-5464-5446', '0678-2135-4649', '', '0507473497', '346246546345-24535');
        ContosoEmployee.UpdateEmployeeDetails(CreateEmployee.InventoryManager(), 19631207D, 19960301D, BJamesRoadLbl, '3000', '4653', '1234-6545-8799', '0678-8712-5466', '', '0705491679', '234654-631');
    end;

    var
        RusselStreetLbl: Label '5 Russel Street', MaxLength = 100;
        MainStreetLbl: Label '47 Main Street', MaxLength = 100;
        ElmwoodStreetLbl: Label '327 Elmwood Street', MaxLength = 100;
        HighStreetLbl: Label '10 High Street', MaxLength = 100;
        MaddistonRoadLbl: Label '7 Maddiston Road', MaxLength = 100;
        GrahamsRoadLbl: Label '49 Grahams Road', MaxLength = 100;
        BJamesRoadLbl: Label '66B James Road', MaxLength = 100;
}