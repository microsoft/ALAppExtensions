codeunit 5648 "Create Marketing Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoCRM: Codeunit "Contoso CRM";
        CreateNoSeries: Codeunit "Create No. Series";
        ContosoLanguage: Codeunit "Contoso Language";
        CreateBusinessRelation: Codeunit "Create Business Relation";
        CreateSalesCycle: Codeunit "Create Sales Cycle";
        CreateSalutations: Codeunit "Create Salutations";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        ContosoCRM.InsertMarketingSetup(ContosoCoffeeDemoDataSetup."Country/Region Code", CreateNoSeries.Contact(), CreateNoSeries.Campaign(), CreateNoSeries.Segment(), CreateNoSeries.Task(), CreateNoSeries.Opportunity(), CreateBusinessRelation.CustBusinessRelation(), CreateBusinessRelation.VendBusinessRelation(), CreateBusinessRelation.BankBusinessRelation(), CreateBusinessRelation.EmpBusinessRelation(), true, true, true, true, true, true, ContosoLanguage.GetLanguageCode(''), CreateSalesCycle.NewSalesCycle(), Enum::"Setup Attachment Storage Type"::Embedded, true, 60, true, 1033, CreateSalutations.Company(), CreateSalutations.Unisex(), Enum::"Correspondence Type"::Email, true);
    end;
}