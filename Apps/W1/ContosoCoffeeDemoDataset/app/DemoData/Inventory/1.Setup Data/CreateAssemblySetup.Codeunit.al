codeunit 5301 "Create Assembly Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
        CreateNoSeries: Codeunit "Create No. Series";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        ContosoItem.InsertAssemblySetup(true, CreateNoSeries.AssemblyOrders(), CreateNoSeries.AssemblyQuote(), CreateNoSeries.AssemblyBlanketOrders(), CreateNoSeries.PostedAssemblyOrders(), true, true, CreatePostingGroups.DomesticPostingGroup());
    end;
}