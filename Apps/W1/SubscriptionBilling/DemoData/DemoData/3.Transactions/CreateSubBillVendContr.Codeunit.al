namespace Microsoft.SubscriptionBilling;

using Microsoft.DemoData.Purchases;

codeunit 8118 "Create Sub. Bill. Vend. Contr."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateVendorContracts();
    end;

    local procedure CreateVendorContracts()
    var
        CreateVendor: Codeunit "Create Vendor";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
        CreateSubBillContrTypes: Codeunit "Create Sub. Bill. Contr. Types";
        CreateSubBillServObj: Codeunit "Create Sub. Bill. Serv. Obj.";
    begin
        ContosoSubscriptionBilling.InsertVendorContract(VSC100001(), HardwareMaintenanceLbl, CreateVendor.ExportFabrikam(), CreateSubBillContrTypes.MaintenanceCode());
        ContosoSubscriptionBilling.InsertVendorContractLine(VSC100001(), CreateSubBillServObj.SUB100003());

        ContosoSubscriptionBilling.InsertVendorContract(VSC100002(), UsageDataLbl, CreateVendor.DomesticWorldImporter(), CreateSubBillContrTypes.UsageDataCode());
        ContosoSubscriptionBilling.InsertVendorContractLine(VSC100002(), CreateSubBillServObj.SUB100004());
    end;

    var
        HardwareMaintenanceLbl: Label 'Hardware Maintenance', MaxLength = 100;
        UsageDataLbl: Label 'Usage data', MaxLength = 100;

    procedure VSC100001(): Code[20]
    begin
        exit('VSC100001');
    end;

    procedure VSC100002(): Code[20]
    begin
        exit('VSC100002');
    end;
}