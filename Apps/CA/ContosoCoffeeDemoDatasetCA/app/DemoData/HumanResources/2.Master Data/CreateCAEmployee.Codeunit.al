codeunit 27024 "Create CA Employee"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoEmployee: Codeunit "Contoso Human Resources";
        CreateEmployee: Codeunit "Create Employee";
    begin
        ContosoEmployee.UpdateEmployeeDetails(CreateEmployee.ManagingDirector(), 19731212D, 20010601D, FifthAvenueLbl, '', '6743', '4564-4564-7831', '4465-4899-4643', '', '1212637665', '4151746513235-45646');
        ContosoEmployee.UpdateEmployeeDetails(CreateEmployee.SalesManager(), 19790212D, 20040301D, WestchesterAvenueLbl, '', '1415', '1234-5678-9012', '0678-9012-3456', '', '1202696486', '3462345-235');
        ContosoEmployee.UpdateEmployeeDetails(CreateEmployee.ProductionManager(), 19670705D, 20010601D, WaltWhitmanRoadLbl, '', '4564', '1546-3124-4646', '6549-3216-7415', '', '1003569468', '541236-654');
        ContosoEmployee.UpdateEmployeeDetails(CreateEmployee.Designer(), 19760310D, 20100801D, ColumbusCircleLbl, '', '3545', '1234-6545-5649', '0678-1234-5466', '', '0708624564', '234654-631');
        ContosoEmployee.UpdateEmployeeDetails(CreateEmployee.Secretary(), 19790507D, 20010601D, CommonsWayLbl, '', '6571', '1234-1643-4384', '0678-2534-2013', '', '0712635465', '234654-631');
        ContosoEmployee.UpdateEmployeeDetails(CreateEmployee.ProductionAssistant(), 19820807D, 20010601D, DestinyUSADriveLbl, '', '4456', '1234-5464-5446', '0678-2135-4649', '', '0507473497', '346246546345-24535');
        ContosoEmployee.UpdateEmployeeDetails(CreateEmployee.InventoryManager(), 19831207D, 20061201D, RouteSouthLbl, '', '4653', '1234-6545-8799', '0678-8712-5466', '', '0705491679', '234654-631');
    end;

    var
        FifthAvenueLbl: Label '677 Fifth Avenue', MaxLength = 100, Locked = true;
        WestchesterAvenueLbl: Label '125 Westchester Avenue', MaxLength = 100, Locked = true;
        ColumbusCircleLbl: Label '10 Columbus Circle', MaxLength = 100, Locked = true;
        DestinyUSADriveLbl: Label '10344 Destiny USA Drive', MaxLength = 100, Locked = true;
        WaltWhitmanRoadLbl: Label '160 Walt Whitman Road', MaxLength = 100, Locked = true;
        CommonsWayLbl: Label '400 Commons Way', MaxLength = 100, Locked = true;
        RouteSouthLbl: Label '3710 Route 9 South', MaxLength = 100, Locked = true;
}