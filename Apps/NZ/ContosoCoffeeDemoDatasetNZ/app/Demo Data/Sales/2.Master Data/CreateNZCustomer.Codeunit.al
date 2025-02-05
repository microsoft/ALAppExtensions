codeunit 17138 "Create NZ Customer"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record Customer; RunTrigger: Boolean)
    var
        CreateCustomer: Codeunit "Create Customer";
        CreateTerritory: Codeunit "Create Territory";
        CreateCustomerPostingGroup: Codeunit "Create Customer Posting Group";
        CreateLanguage: Codeunit "Create Language";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        case Rec."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateRecordFields(Rec, DomesticAdatumCorporationVATLbl, ArrowJunctionCityLbl, '9197', CreateTerritory.Foreign(), CreateCustomerPostingGroup.Domestic(), CreateLanguage.ENZ(), CreatePaymentTerms.PaymentTermsDAYS30(), CreatePostingGroups.DomesticPostingGroup(), CreateVATPostingGroups.Domestic(), '', CreateCountryRegion.NZ());
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Rec, DomesticTreyResearchVATLbl, ChristchurchCityLbl, '8001', CreateTerritory.Foreign(), CreateCustomerPostingGroup.Domestic(), CreateLanguage.ENZ(), CreatePaymentTerms.PaymentTermsDAYS30(), CreatePostingGroups.DomesticPostingGroup(), CreateVATPostingGroups.Domestic(), '', CreateCountryRegion.NZ());
            CreateCustomer.ExportSchoolofArt():
                ValidateRecordFields(Rec, SchoolOfFineArtVATLbl, MiamiCityLbl, 'US-FL 37125', CreateTerritory.Foreign(), CreateCustomerPostingGroup.Foreign(), CreateLanguage.ENU(), CreatePaymentTerms.PaymentTermsDAYS30(), CreatePostingGroups.ExportPostingGroup(), CreateVATPostingGroups.Export(), '', CreateCountryRegion.US());
            CreateCustomer.EUAlpineSkiHouse():
                ValidateRecordFields(Rec, EUAlpineSkiHouseVATLbl, MunchenCityLbl, 'DE-80807', CreateTerritory.Foreign(), CreateCustomerPostingGroup.Foreign(), CreateLanguage.DEU(), CreatePaymentTerms.PaymentTermsDAYS30(), CreatePostingGroups.ExportPostingGroup(), CreateVATPostingGroups.Export(), '', CreateCountryRegion.DE());
            CreateCustomer.DomesticRelecloud():
                ValidateRecordFields(Rec, DomesticRelecloudVATLbl, CentreHillCityLbl, '9681', CreateTerritory.Foreign(), CreateCustomerPostingGroup.Domestic(), CreateLanguage.ENZ(), CreatePaymentTerms.PaymentTermsDAYS30(), CreatePostingGroups.DomesticPostingGroup(), CreateVATPostingGroups.Domestic(), '', CreateCountryRegion.NZ());
        end;
    end;

    local procedure ValidateRecordFields(var Customer: Record Customer; VATRegistrationNo: Code[20]; City: Text[30]; PostCode: Code[20]; TerritoryCode: Code[10]; CustomerPostingGroup: Code[20]; LanguageCode: Code[10]; PaymentTermsCode: Code[10]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; County: Text[30]; CountryRegionCode: Code[10])
    begin
        Customer.Validate(City, City);
        Customer.Validate("Post Code", PostCode);
        Customer.Validate("Territory Code", TerritoryCode);
        Customer.Validate("Customer Posting Group", CustomerPostingGroup);
        Customer.Validate("Language Code", LanguageCode);
        Customer.Validate("Payment Terms Code", PaymentTermsCode);
        Customer.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Customer.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Customer.Validate("VAT Registration No.", VATRegistrationNo);
        Customer.Validate(County, County);
        Customer.Validate("Country/Region Code", CountryRegionCode);
    end;

    var
        ArrowJunctionCityLbl: Label 'Arrow Junction', MaxLength = 30;
        ChristchurchCityLbl: Label 'Christchurch', MaxLength = 30;
        CentreHillCityLbl: Label 'Centre Hill', MaxLength = 30;
        MiamiCityLbl: Label 'Miami', MaxLength = 30;
        MunchenCityLbl: Label 'Munchen', MaxLength = 30;
        DomesticAdatumCorporationVATLbl: Label '789456278', MaxLength = 20;
        DomesticTreyResearchVATLbl: Label '254687456', MaxLength = 20;
        EUAlpineSkiHouseVATLbl: Label '533435789', MaxLength = 20;
        DomesticRelecloudVATLbl: Label '582048936', MaxLength = 20;
        SchoolOfFineArtVATLbl: Label '733495789', MaxLength = 20;
}