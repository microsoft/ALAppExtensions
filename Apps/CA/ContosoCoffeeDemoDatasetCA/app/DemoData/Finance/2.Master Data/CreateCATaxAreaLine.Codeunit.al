codeunit 27051 "Create CA Tax Area Line"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCATax: Codeunit "Contoso CA Tax";
        CreateCATaxArea: Codeunit "Create CA Tax Area";
        CreateCATaxJurisdiction: Codeunit "Create CA Tax Jurisdiction";
    begin
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.Alberta(), CreateCATaxJurisdiction.GovernmentofCanadaGST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.BritishColumbia(), CreateCATaxJurisdiction.GovernmentofCanadaGST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.BritishColumbia(), CreateCATaxJurisdiction.ProvinceofBritishColumbiaPST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.Manitoba(), CreateCATaxJurisdiction.GovernmentofCanadaGST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.Manitoba(), CreateCATaxJurisdiction.ProvinceofManitobaPST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.NewBrunswick(), CreateCATaxJurisdiction.ProvinceofNewBrunswickHST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.NewfoundlandandLabrador(), CreateCATaxJurisdiction.ProvinceofNewfoundlandandLabradorHST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.NovaScotia(), CreateCATaxJurisdiction.ProvinceofNovaScotiaHST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.NorthWestTerritories(), CreateCATaxJurisdiction.GovernmentofCanadaGST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.Nunavut(), CreateCATaxJurisdiction.GovernmentofCanadaGST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.Ontario(), CreateCATaxJurisdiction.ProvinceofOntarioHST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.PrinceEdwardIsland(), CreateCATaxJurisdiction.ProvinceofPrinceEdwardIslandHST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.Quebec(), CreateCATaxJurisdiction.GovernmentofCanadaGST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.Quebec(), CreateCATaxJurisdiction.ProvinceofQuebecQST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.Saskatchewan(), CreateCATaxJurisdiction.GovernmentofCanadaGST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.Saskatchewan(), CreateCATaxJurisdiction.ProvinceofSaskatchewanPST());
        ContosoCATax.InsertTaxAreaLine(CreateCATaxArea.Yukon(), CreateCATaxJurisdiction.GovernmentofCanadaGST());
    end;
}