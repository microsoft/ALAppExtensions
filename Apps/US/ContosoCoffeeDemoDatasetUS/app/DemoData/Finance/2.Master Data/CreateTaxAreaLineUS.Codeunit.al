codeunit 10525 "Create Tax Area Line US"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoTaxUS: Codeunit "Contoso Tax US";
        CreateTaxAreaUS: Codeunit "Create Tax Area US";
        CreateTaxJurisdictionUS: Codeunit "Create Tax Jurisdiction US";
    begin
        ContosoTaxUS.InsertTaxAreaLine(CreateTaxAreaUS.AtlantaGa(), CreateTaxJurisdictionUS.StateofGeorgia());
        ContosoTaxUS.InsertTaxAreaLine(CreateTaxAreaUS.AtlantaGa(), CreateTaxJurisdictionUS.CityofAtlantaGA());
        ContosoTaxUS.InsertTaxAreaLine(CreateTaxAreaUS.AtlantaGa(), CreateTaxJurisdictionUS.FultonCountyGA());
        ContosoTaxUS.InsertTaxAreaLine(CreateTaxAreaUS.ChicagoIl(), CreateTaxJurisdictionUS.StateofIllinois());
        ContosoTaxUS.InsertTaxAreaLine(CreateTaxAreaUS.ChicagoIl(), CreateTaxJurisdictionUS.CityofChicagoIL());
        ContosoTaxUS.InsertTaxAreaLine(CreateTaxAreaUS.ChicagoIl(), CreateTaxJurisdictionUS.COOKCountyIL());
        ContosoTaxUS.InsertTaxAreaLine(CreateTaxAreaUS.MiamiFl(), CreateTaxJurisdictionUS.StateofFlorida());
        ContosoTaxUS.InsertTaxAreaLine(CreateTaxAreaUS.MiamiFl(), CreateTaxJurisdictionUS.CityofMiamiFL());
        ContosoTaxUS.InsertTaxAreaLine(CreateTaxAreaUS.MiamiFl(), CreateTaxJurisdictionUS.DadeCountyFL());
        ContosoTaxUS.InsertTaxAreaLine(CreateTaxAreaUS.NAtlGa(), CreateTaxJurisdictionUS.StateofGeorgia());
        ContosoTaxUS.InsertTaxAreaLine(CreateTaxAreaUS.NAtlGa(), CreateTaxJurisdictionUS.CityofAtlantaGA());
        ContosoTaxUS.InsertTaxAreaLine(CreateTaxAreaUS.NAtlGa(), CreateTaxJurisdictionUS.FultonCountyGA());
        ContosoTaxUS.InsertTaxAreaLine(CreateTaxAreaUS.NAtlGa(), CreateTaxJurisdictionUS.MartaDistrictGA());
    end;
}