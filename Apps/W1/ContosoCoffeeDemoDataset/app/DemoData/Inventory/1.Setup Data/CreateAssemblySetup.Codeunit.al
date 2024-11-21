codeunit 5301 "Create Assembly Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        ContosoItem.InsertAssemblySetup(true, CreateNoSeries.AssemblyOrders(), CreateNoSeries.AssemblyQuote(), CreateNoSeries.AssemblyBlanketOrders(), CreateNoSeries.PostedAssemblyOrders(), true, true);
    end;
}