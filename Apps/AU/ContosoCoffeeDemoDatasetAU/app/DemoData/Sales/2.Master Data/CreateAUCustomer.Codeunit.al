codeunit 17132 "Create AU Customer"
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
    begin
        case Rec."No." of
            CreateCustomer.DomesticAdatumCorporation():
                begin
                    ValidateRecordFields(Rec, DomesticAdatumCorporationVATLbl, AdelaideCityLbl, '5000', SouthAustraliaCountyLbl, CreateTerritory.Foreign(), CreateCustomerPostingGroup.Domestic(), CreateLanguage.ENA(), CreatePaymentTerms.PaymentTermsDAYS30(), CreatePostingGroups.DomesticPostingGroup(), '');
                    InsertAddressID(Rec, DomesticAdatumCorporationAddressIDLbl)
                end;
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Rec, DomesticTreyResearchVATLbl, PerthCityLbl, '6800', WesternAustraliaCountyLbl, CreateTerritory.Foreign(), CreateCustomerPostingGroup.Domestic(), CreateLanguage.ENA(), CreatePaymentTerms.PaymentTermsDAYS30(), CreatePostingGroups.DomesticPostingGroup(), '');
            CreateCustomer.ExportSchoolofArt():
                ValidateRecordFields(Rec, SchoolOfFineArtVATLbl, MiamiCityLbl, 'US-FL 37125', '', CreateTerritory.Foreign(), CreateCustomerPostingGroup.Foreign(), CreateLanguage.ENU(), CreatePaymentTerms.PaymentTermsDAYS30(), CreatePostingGroups.ExportPostingGroup(), '');
            CreateCustomer.EUAlpineSkiHouse():
                ValidateRecordFields(Rec, EUAlpineSkiHouseVATLbl, MunchenCityLbl, 'DE-80807', '', CreateTerritory.Foreign(), CreateCustomerPostingGroup.Foreign(), CreateLanguage.DEU(), CreatePaymentTerms.PaymentTermsDAYS30(), CreatePostingGroups.ExportPostingGroup(), '');
            CreateCustomer.DomesticRelecloud():
                begin
                    ValidateRecordFields(Rec, DomesticRelecloudVATLbl, MurdunnaCityLbl, '7178', TasmaniaCountyLbl, CreateTerritory.Foreign(), CreateCustomerPostingGroup.Domestic(), CreateLanguage.ENA(), CreatePaymentTerms.PaymentTermsDAYS30(), CreatePostingGroups.DomesticPostingGroup(), '');
                    InsertAddressID(Rec, DomesticRelecloudAddressIDLbl)
                end;
        end;
    end;

    local procedure ValidateRecordFields(var Customer: Record Customer; VATRegistrationNo: Code[20]; City: Text[30]; PostCode: Code[20]; County: Code[10]; TerritoryCode: Code[10]; CustomerPostingGroup: Code[20]; LanguageCode: Code[10]; PaymentTermsCode: Code[10]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20])
    begin
        Customer.Validate(City, City);
        Customer.Validate("Post Code", PostCode);
        Customer.Validate(County, County);
        Customer.Validate("Territory Code", TerritoryCode);
        Customer.Validate("Customer Posting Group", CustomerPostingGroup);
        Customer.Validate("Language Code", LanguageCode);
        Customer.Validate("Payment Terms Code", PaymentTermsCode);
        Customer.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Customer.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Customer."VAT Registration No." := VATRegistrationNo;
    end;

    local procedure InsertAddressID(Customer: Record Customer; AddressIDField: Text[10])
    var
        AddressID: Record "Address ID";
    begin
        AddressID.Init();
        AddressID.Validate("Table No.", Database::Customer);
        AddressID.Validate("Table Key", Customer.GetPosition());
        AddressID.Validate("Address Type", AddressID."Address Type"::Main);
        AddressID.Validate("Address ID", AddressIDField);
        AddressID.Validate("Bar Code System", AddressID."Bar Code System"::"4-State Bar Code");
        AddressID.Insert();
    end;

    var
        AdelaideCityLbl: Label 'ADELAIDE', MaxLength = 30;
        PerthCityLbl: Label 'Perth', MaxLength = 30;
        MurdunnaCityLbl: Label 'Murdunna', MaxLength = 30;
        MiamiCityLbl: Label 'Miami', MaxLength = 30;
        MunchenCityLbl: Label 'Munchen', MaxLength = 30;
        DomesticAdatumCorporationVATLbl: Label '789456278', MaxLength = 20;
        DomesticTreyResearchVATLbl: Label '254687456', MaxLength = 20;
        EUAlpineSkiHouseVATLbl: Label '533435789', MaxLength = 20;
        DomesticRelecloudVATLbl: Label '582048936', MaxLength = 20;
        SchoolOfFineArtVATLbl: Label '733495789', MaxLength = 20;
        SouthAustraliaCountyLbl: Label 'SA', MaxLength = 10;
        WesternAustraliaCountyLbl: Label 'WA', MaxLength = 10;
        TasmaniaCountyLbl: Label 'TAS', MaxLength = 10;
        DomesticAdatumCorporationAddressIDLbl: Label '20028478', MaxLength = 10;
        DomesticRelecloudAddressIDLbl: Label '20104226', MaxLength = 10;
}