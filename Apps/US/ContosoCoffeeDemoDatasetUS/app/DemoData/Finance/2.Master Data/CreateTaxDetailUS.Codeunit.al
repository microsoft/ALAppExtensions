codeunit 11460 "Create Tax Detail US"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        TaxDetail: Record "Tax Detail";
        ContosoTaxUS: Codeunit "Contoso Tax US";
        CreateTaxGroupUS: Codeunit "Create Tax Group US";
        CreateTaxJurisdictionUS: Codeunit "Create Tax Jurisdiction US";
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.StateofFlorida(), CreateTaxGroupUS.Furniture(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 5);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.StateofFlorida(), CreateTaxGroupUS.Labor(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 1);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.StateofFlorida(), CreateTaxGroupUS.Materials(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 3);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.StateofFlorida(), CreateTaxGroupUS.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 0);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.StateofFlorida(), CreateTaxGroupUS.Supplies(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 2);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.DadeCountyFL(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 1);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.DadeCountyFL(), CreateTaxGroupUS.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 0);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.CityofMiamiFL(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 1);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.CityofMiamiFL(), CreateTaxGroupUS.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 0);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.CityofMiamiFL(), CreateTaxGroupUS.Supplies(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 0);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.StateofGeorgia(), CreateTaxGroupUS.Furniture(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 3);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.StateofGeorgia(), CreateTaxGroupUS.Labor(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 0);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.StateofGeorgia(), CreateTaxGroupUS.Materials(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 2);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.StateofGeorgia(), CreateTaxGroupUS.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 0);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.StateofGeorgia(), CreateTaxGroupUS.Supplies(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 2);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.CityofAtlantaGA(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 1);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.CityofAtlantaGA(), CreateTaxGroupUS.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 0);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.FultonCountyGA(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 2);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.FultonCountyGA(), CreateTaxGroupUS.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 0);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.GwinnettCountyGA(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 2);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.GwinnettCountyGA(), CreateTaxGroupUS.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 0);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.MartaDistrictGA(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 1);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.MartaDistrictGA(), CreateTaxGroupUS.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 0);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.StateofIllinois(), CreateTaxGroupUS.Furniture(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 3);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.StateofIllinois(), CreateTaxGroupUS.Labor(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 1);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.StateofIllinois(), CreateTaxGroupUS.Materials(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 4);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.StateofIllinois(), CreateTaxGroupUS.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 0);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.StateofIllinois(), CreateTaxGroupUS.Supplies(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 2);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.CityofChicagoIL(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 1);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.CityofChicagoIL(), CreateTaxGroupUS.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 0);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.COOKCountyIL(), '', TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 1);
        ContosoTaxUS.InsertTaxDetail(CreateTaxJurisdictionUS.COOKCountyIL(), CreateTaxGroupUS.NonTaxable(), TaxDetail."Tax Type"::"Sales and Use Tax", ContosoUtilities.AdjustDate(19010101D), 0);
    end;
}