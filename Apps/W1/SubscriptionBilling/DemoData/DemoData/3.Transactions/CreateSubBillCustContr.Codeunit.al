namespace Microsoft.SubscriptionBilling;

using Microsoft.DemoData.Sales;

codeunit 8117 "Create Sub. Bill. Cust. Contr."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateCustomerContracts();
    end;

    local procedure CreateCustomerContracts()
    var
        CreateCustomer: Codeunit "Create Customer";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
        CreateSubBillContrTypes: Codeunit "Create Sub. Bill. Contr. Types";
        CreateSubBillServObj: Codeunit "Create Sub. Bill. Serv. Obj.";
    begin
        ContosoSubscriptionBilling.InsertCustomerContract(CSC100001(), NewspaperLbl, CreateCustomer.DomesticAdatumCorporation(), CreateSubBillContrTypes.MiscellaneousCode());
        ContosoSubscriptionBilling.InsertCustomerContractLine(CSC100001(), CreateSubBillServObj.SUB100001());

        ContosoSubscriptionBilling.InsertCustomerContract(CSC100002(), SupportLbl, CreateCustomer.DomesticTreyResearch(), CreateSubBillContrTypes.SupportCode());
        ContosoSubscriptionBilling.InsertCustomerContractLine(CSC100002(), CreateSubBillServObj.SUB100002());

        ContosoSubscriptionBilling.InsertCustomerContract(CSC100003(), HardwareMaintenanceLbl, CreateCustomer.ExportSchoolofArt(), CreateSubBillContrTypes.MaintenanceCode());
        ContosoSubscriptionBilling.InsertCustomerContractLine(CSC100003(), CreateSubBillServObj.SUB100003());

        ContosoSubscriptionBilling.InsertCustomerContract(CSC100004(), UsageDataLbl, CreateCustomer.DomesticRelecloud(), CreateSubBillContrTypes.UsageDataCode());
        ContosoSubscriptionBilling.InsertCustomerContractLine(CSC100004(), CreateSubBillServObj.SUB100004());
    end;

    var
        NewspaperLbl: Label 'Newspaper', MaxLength = 100;
        SupportLbl: Label 'Support', MaxLength = 100;
        HardwareMaintenanceLbl: Label 'Hardware Maintenance', MaxLength = 100;
        UsageDataLbl: Label 'Usage data', MaxLength = 100;

    procedure CSC100001(): Code[20]
    begin
        exit('CSC100001');
    end;

    procedure CSC100002(): Code[20]
    begin
        exit('CSC100002');
    end;

    procedure CSC100003(): Code[20]
    begin
        exit('CSC100003');
    end;

    procedure CSC100004(): Code[20]
    begin
        exit('CSC100004');
    end;
}