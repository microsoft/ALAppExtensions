namespace Microsoft.SubscriptionBilling;

using Microsoft.DemoData.Sales;
using Microsoft.DemoTool.Helpers;

codeunit 8116 "Create Sub. Bill. Serv. Obj."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateServiceObjects();
    end;

    local procedure CreateServiceObjects()
    var
        CreateCustomer: Codeunit "Create Customer";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateSubBillItem: Codeunit "Create Sub. Bill. Item";
        CreateSubBillPackages: Codeunit "Create Sub. Bill. Packages";
    begin
        ContosoSubscriptionBilling.InsertServiceObject(SUB100001(), CreateCustomer.DomesticAdatumCorporation(), CreateSubBillItem.SB1100(), ContosoUtilities.AdjustDate(19020101D), 1);
        ContosoSubscriptionBilling.InsertServiceCommitments(SUB100001(), ContosoUtilities.AdjustDate(19020101D), CreateSubBillPackages.MonthlySubscription());

        ContosoSubscriptionBilling.InsertServiceObject(SUB100002(), CreateCustomer.DomesticTreyResearch(), CreateSubBillItem.SB1102(), ContosoUtilities.AdjustDate(19020101D), 5);
        ContosoSubscriptionBilling.InsertServiceCommitments(SUB100002(), ContosoUtilities.AdjustDate(19020101D), CreateSubBillPackages.MonthlySubscription());

        ContosoSubscriptionBilling.InsertServiceObject(SUB100003(), CreateCustomer.ExportSchoolofArt(), CreateSubBillItem.SB1103(), ContosoUtilities.AdjustDate(19020101D), 1);
        ContosoSubscriptionBilling.InsertServiceCommitments(SUB100003(), ContosoUtilities.AdjustDate(19020101D), CreateSubBillPackages.MaintenanceSilver());
        ContosoSubscriptionBilling.InsertServiceCommitments(SUB100003(), ContosoUtilities.AdjustDate(19020101D), CreateSubBillPackages.Warranty());

        ContosoSubscriptionBilling.InsertServiceObject(SUB100004(), CreateCustomer.DomesticRelecloud(), CreateSubBillItem.SB1105(), ContosoUtilities.AdjustDate(19020101D), 3);
        ContosoSubscriptionBilling.InsertServiceCommitments(SUB100004(), ContosoUtilities.AdjustDate(19020101D), CreateSubBillPackages.UDUsage());
    end;


    procedure SUB100001(): Code[20]
    begin
        exit('SUB100001');
    end;

    procedure SUB100002(): Code[20]
    begin
        exit('SUB100002');
    end;

    procedure SUB100003(): Code[20]
    begin
        exit('SUB100003');
    end;

    procedure SUB100004(): Code[20]
    begin
        exit('SUB100004');
    end;
}