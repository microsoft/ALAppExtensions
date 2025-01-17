codeunit 27050 "Create CA Tax Detail"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        TaxDetail: Record "Tax Detail";
        ContosoCATax: Codeunit "Contoso CA Tax";
        CreateCATaxGroup: Codeunit "Create CA Tax Group";
        CreateCATaxJurisdiction: Codeunit "Create CA Tax Jurisdiction";
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.GovernmentofCanadaGST(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 5);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.GovernmentofCanadaGST(), CreateCATaxGroup.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 0);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.GovernmentofCanadaGST(), CreateCATaxGroup.Taxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 5);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofBritishColumbiaPST(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 7);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofBritishColumbiaPST(), CreateCATaxGroup.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 0);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofBritishColumbiaPST(), CreateCATaxGroup.Taxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 7);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofManitobaPST(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 7);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofManitobaPST(), CreateCATaxGroup.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 0);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofManitobaPST(), CreateCATaxGroup.Taxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 7);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofNewBrunswickHST(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 15);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofNewBrunswickHST(), CreateCATaxGroup.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 0);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofNewBrunswickHST(), CreateCATaxGroup.Taxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 15);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofNewfoundlandandLabradorHST(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 15);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofNewfoundlandandLabradorHST(), CreateCATaxGroup.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 0);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofNewfoundlandandLabradorHST(), CreateCATaxGroup.Taxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 15);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofNovaScotiaHST(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 15);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofNovaScotiaHST(), CreateCATaxGroup.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 0);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofNovaScotiaHST(), CreateCATaxGroup.Taxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 15);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofOntarioHST(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 13);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofOntarioHST(), CreateCATaxGroup.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 0);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofOntarioHST(), CreateCATaxGroup.Taxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 13);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofPrinceEdwardIslandHST(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 15);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofPrinceEdwardIslandHST(), CreateCATaxGroup.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 0);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofPrinceEdwardIslandHST(), CreateCATaxGroup.Taxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 15);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofQuebecQST(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 9.975);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofQuebecQST(), CreateCATaxGroup.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 0);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofQuebecQST(), CreateCATaxGroup.Taxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 9.975);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofSaskatchewanPST(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 6);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofSaskatchewanPST(), CreateCATaxGroup.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 0);
        ContosoCATax.InsertTaxDetail(CreateCATaxJurisdiction.ProvinceofSaskatchewanPST(), CreateCATaxGroup.Taxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(18920101D), 6);
    end;
}