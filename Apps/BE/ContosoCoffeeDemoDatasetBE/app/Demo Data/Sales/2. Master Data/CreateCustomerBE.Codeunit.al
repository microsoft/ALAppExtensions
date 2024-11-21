codeunit 11387 "Create Customer BE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsert', '', false, false)]
    local procedure OnBeforeInsertCustomer(var Customer: Record Customer)
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateLanguage: Codeunit "Create Language";
        CreateCustomer: Codeunit "Create Customer";
        CreateVendorPostingGroup: codeunit "Create Vendor Posting Group";
        CreateVATPostingGroupBE: Codeunit "Create VAT Posting Group BE";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        case Customer."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateCustomer(Customer, CreateLanguage.NLB(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreateVendorPostingGroup.Foreign(), PostCode2800Lbl, '', MechelenCityLbl);
            CreateCustomer.DomesticTreyResearch():
                ValidateCustomer(Customer, CreateLanguage.NLB(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreateVendorPostingGroup.Foreign(), PostCode1020Lbl, '', DomesticTreyResearchCityLbl);
            CreateCustomer.DomesticRelecloud():
                ValidateCustomer(Customer, CreateLanguage.NLB(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreateVendorPostingGroup.Foreign(), PostCode6200Lbl, '', DomesticRelecloudCityLbl);

            CreateCustomer.ExportSchoolofArt():
                begin
                    Customer.Validate("VAT Registration No.", ExportSchoolofArtVatRegLbl);
                    Customer.Validate("VAT Bus. Posting Group", CreateVATPostingGroupBE.IMPEXP());
                end;
            CreateCustomer.EUAlpineSkiHouse():
                Customer.Validate("VAT Registration No.", EUAlpineSkiHouseVatRegLbl);
        end;
    end;

    local procedure ValidateCustomer(var Customer: Record Customer; LanguageCode: Code[10]; CountryRegionCode: Code[10]; TerritoryCode: Code[20]; PostCode: Code[20]; VatRegistraionNo: Text[20]; City: Text[30])
    begin
        Customer.Validate("Language Code", LanguageCode);
        Customer."VAT Registration No." := VatRegistraionNo;
        if CountryRegionCode <> '' then
            Customer.Validate("Country/Region Code", CountryRegionCode);
        Customer.Validate(City, City);
        Customer.Validate("Post Code", PostCode);
        Customer.Validate("Territory Code", TerritoryCode);
    end;

    var
        MechelenCityLbl: Label 'MECHELEN', MaxLength = 30;
        DomesticTreyResearchCityLbl: Label 'BRUSSEL', MaxLength = 30;
        DomesticRelecloudCityLbl: Label 'BOUFFIOULX', MaxLength = 30;
        ExportSchoolofArtVatRegLbl: Label '733495789', MaxLength = 20;
        EUAlpineSkiHouseVatRegLbl: Label '533435789', MaxLength = 20;
        PostCode2800Lbl: Label '2800', MaxLength = 20;
        PostCode1020Lbl: Label '1020', MaxLength = 20;
        PostCode6200Lbl: Label '6200', MaxLength = 20;
}