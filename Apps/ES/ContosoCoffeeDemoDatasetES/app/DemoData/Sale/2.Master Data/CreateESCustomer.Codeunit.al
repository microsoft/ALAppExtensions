codeunit 10823 "Create ES Customer"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomer(var Rec: Record Customer)
    var
        CreateCustomer: Codeunit "Create Customer";
        CreateTerritory: Codeunit "Create Territory";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreateESPaymentTerms: Codeunit "Create ES Payment Terms";
        CreatePaymentMethod: Codeunit "Create Payment Method";
        CreateESPaymentMethod: Codeunit "Create ES Payment Method";
        CreateLanguage: Codeunit "Create Language";
    begin
        case Rec."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateRecordFields(Rec, DomesticAdatumCorporationVATLbl, BarcelonaCityLbl, '08010', CreateTerritory.Foreign(), CreateCountryRegion.ES(), CreatePaymentTerms.PaymentTermsCM(), CreatePaymentMethod.Giro(), CreateLanguage.ESP(), BarcelonaCountyLbl);
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Rec, DomesticTreyResearchVATLbl, ValenciaCityLbl, '46010', CreateTerritory.Foreign(), CreateCountryRegion.ES(), CreatePaymentTerms.PaymentTermsDAYS14(), CreatePaymentMethod.Check(), CreateLanguage.ESP(), ValenciaCountyLbl);
            CreateCustomer.ExportSchoolofArt():
                ValidateRecordFields(Rec, ExportSchoolofArtVATLbl, MiamiCityLbl, 'US-FL 37125', CreateTerritory.Foreign(), CreateCountryRegion.US(), CreatePaymentTerms.PaymentTermsCM(), CreatePaymentMethod.Bank(), CreateLanguage.ENU(), 'FL');
            CreateCustomer.EUAlpineSkiHouse():
                ValidateRecordFields(Rec, EUAlpineSkiHouseVATLbl, MunchenCityLbl, 'DE-80807', CreateTerritory.Foreign(), CreateCountryRegion.DE(), CreateESPaymentTerms.PaymentTermsDays3x30(), CreateESPaymentMethod.Efecto(), CreateLanguage.DEU(), '');
            CreateCustomer.DomesticRelecloud():
                ValidateRecordFields(Rec, DomesticRelecloudVATLbl, BoadillaDelMonteCityLbl, '28660', CreateTerritory.Foreign(), CreateCountryRegion.ES(), CreatePaymentTerms.PaymentTermsDAYS14(), CreatePaymentMethod.Check(), CreateLanguage.ESP(), '');
        end;
    end;

    local procedure ValidateRecordFields(var Customer: Record Customer; VATRegistrationNo: Code[20]; City: Text[30]; PostCode: Code[20]; TerritoryCode: Code[10]; CountryRegionCode: Code[10]; PaymentTermsCode: Code[10]; PaymentMethodCode: Code[10]; LanguageCode: Code[10]; CustomerCounty: Text[30])
    begin
        Customer.Validate(City, City);
        Customer.Validate("Post Code", PostCode);
        Customer.Validate("Territory Code", TerritoryCode);
        Customer.Validate("Payment Terms Code", PaymentTermsCode);
        Customer."VAT Registration No." := VATRegistrationNo;
        if CountryRegionCode <> '' then
            Customer.Validate("Country/Region Code", CountryRegionCode);
        Customer.Validate("Payment Method Code", PaymentMethodCode);
        Customer.Validate("Language Code", LanguageCode);
        Customer.Validate(County, CustomerCounty);
    end;

    var
        ValenciaCityLbl: Label 'Valencia', MaxLength = 30;
        ValenciaCountyLbl: Label 'VALENCIA', MaxLength = 30;
        BarcelonaCityLbl: Label 'Barcelona', MaxLength = 30;
        BarcelonaCountyLbl: Label 'BARCELONA', MaxLength = 30;
        BoadillaDelMonteCityLbl: Label 'Boadilla del Monte', MaxLength = 30;
        MiamiCityLbl: Label 'Miami', MaxLength = 30;
        MunchenCityLbl: Label 'Munchen', MaxLength = 30;
        DomesticAdatumCorporationVATLbl: Label '789456278A', MaxLength = 20;
        DomesticTreyResearchVATLbl: Label '254687456A', MaxLength = 20;
        ExportSchoolofArtVATLbl: Label '733495789', MaxLength = 20;
        EUAlpineSkiHouseVATLbl: Label '533435789', MaxLength = 20;
        DomesticRelecloudVATLbl: Label '582048936A', MaxLength = 20;
}