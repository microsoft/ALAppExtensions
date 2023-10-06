codeunit 5107 "Create Svc Sales Orders"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        ServiceModuleSetup: Record "Service Module Setup";
        ContosoUtilities: Codeunit "Contoso Utilities";

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        ContosoSales: Codeunit "Contoso Sales";
    begin
        ServiceModuleSetup.Get();

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Order, ServiceModuleSetup."Customer No.", 'SVC-1', ContosoUtilities.AdjustDate(19020601D), ServiceModuleSetup."Service Location");
        ContosoSales.InsertSalesLineWithItem(SalesHeader, ServiceModuleSetup."Item 1 No.", 1);
    end;
}