codeunit 11470 "Create Customer US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateCustomer: Codeunit "Create Customer";
        CreateDimensionValue: Codeunit "Create Dimension Value";
    begin
        UpdateCustomerDimension(CreateCustomer.DomesticAdatumCorporation(), CreateDimensionValue.SalesDepartment(), CreateDimensionValue.SmallBusinessCustomerGroup());
        UpdateCustomerDimension(CreateCustomer.DomesticTreyResearch(), CreateDimensionValue.SalesDepartment(), CreateDimensionValue.MediumBusinessCustomerGroup());
        UpdateCustomerDimension(CreateCustomer.ExportSchoolofArt(), CreateDimensionValue.SalesDepartment(), CreateDimensionValue.LargeBusinessCustomerGroup());
        UpdateCustomerDimension(CreateCustomer.EUAlpineSkiHouse(), CreateDimensionValue.SalesDepartment(), CreateDimensionValue.SmallBusinessCustomerGroup());
        UpdateCustomerDimension(CreateCustomer.DomesticRelecloud(), CreateDimensionValue.SalesDepartment(), CreateDimensionValue.MediumBusinessCustomerGroup());
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsert', '', false, false)]
    local procedure OnInsertRecord(var Customer: Record Customer; var IsHandled: Boolean)
    var
        CreateCustomer: Codeunit "Create Customer";
        CreateCustomerPostinGroup: Codeunit "Create Customer Posting Group";
        CreateLanguage: Codeunit "Create Language";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateTaxAreaUS: Codeunit "Create Tax Area US";
    begin
        case Customer."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateRecordFields(Customer, AdatumCorporationAddressLbl, AtlantaCityLbl, CreateCustomerPostinGroup.Domestic(), CreateLanguage.ENU(), CreateCountryRegion.US(), CreatePostingGroups.DomesticPostingGroup(), '31772', GaLbl, '', CreateTaxAreaUS.AtlantaGa(), true, '', '', '', '');
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Customer, TreyResearchAddressLbl, ChicagoCityLbl, CreateCustomerPostinGroup.Domestic(), CreateLanguage.ENU(), CreateCountryRegion.US(), CreatePostingGroups.DomesticPostingGroup(), '61236', IlLbl, '', CreateTaxAreaUS.ChicagoIl(), true, '', '', '', '');
            CreateCustomer.ExportSchoolofArt():
                ValidateRecordFields(Customer, SchoolofArtAddressLbl, MiamiCityLbl, CreateCustomerPostinGroup.Domestic(), CreateLanguage.ENU(), CreateCountryRegion.US(), CreatePostingGroups.DomesticPostingGroup(), '37125', FlLbl, '', CreateTaxAreaUS.MiamiFl(), true, '', '', '', '');
            CreateCustomer.EUAlpineSkiHouse():
                ValidateRecordFields(Customer, AlpineSkiHouseAddressLbl, AtlantaCityLbl, CreateCustomerPostinGroup.Domestic(), CreateLanguage.ENU(), CreateCountryRegion.US(), CreatePostingGroups.DomesticPostingGroup(), '31772', GaLbl, '', CreateTaxAreaUS.NAtlGa(), true, '', '', '', '');
            CreateCustomer.DomesticRelecloud():
                ValidateRecordFields(Customer, RelecloudAddressLbl, AtlantaCityLbl, CreateCustomerPostinGroup.Domestic(), CreateLanguage.ENU(), CreateCountryRegion.US(), CreatePostingGroups.DomesticPostingGroup(), '31772', GaLbl, '', CreateTaxAreaUS.AtlantaGa(), true, '', '', '', '');
        end;
    end;

    local procedure ValidateRecordFields(var Customer: Record Customer; Address: Text[100]; City: Text[30]; CustomerPostingGroup: Code[20]; LanguageCode: Code[10]; CountryOrRegionCode: Code[10]; GenBusPostingGroup: Code[20]; PostCode: Code[20]; County: Code[20]; ReminderTermsCode: Code[10]; TaxAreaCode: Code[20]; TaxLiable: Boolean; Address2: Text[50]; VATBusPostingGroup: Code[20]; TerritoryCode: Code[10]; DocumentSendingProfile: Code[20])
    begin
        Customer.Validate(Address, Address);
        Customer.Validate("Address 2", Address2);
        Customer.Validate(City, City);
        Customer.Validate("Customer Posting Group", CustomerPostingGroup);
        Customer.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Customer.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Customer.Validate("Tax Area Code", TaxAreaCode);
        Customer.Validate("Tax Liable", TaxLiable);
        Customer.Validate("Document Sending Profile", DocumentSendingProfile);
        Customer.Validate("Territory Code", TerritoryCode);
        Customer.Validate("Language Code", LanguageCode);
        Customer.Validate("Reminder Terms Code", ReminderTermsCode);
        Customer.Validate("Country/Region Code", CountryOrRegionCode);
        Customer.Validate("Post Code", PostCode);
        Customer.Validate(County, County);
    end;

    local procedure UpdateCustomerDimension(CustomerNo: Code[20]; GlobalDimension1Code: Code[20]; GlobalDimension2Code: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);

        Customer.Validate("Global Dimension 1 Code", GlobalDimension1Code);
        Customer.Validate("Global Dimension 2 Code", GlobalDimension2Code);
        Customer.Modify(true);
    end;

    var
        AdatumCorporationAddressLbl: Label '192 Market Square', MaxLength = 100, Locked = true;
        TreyResearchAddressLbl: Label '153 Thomas Drive', MaxLength = 100, Locked = true;
        SchoolofArtAddressLbl: Label '10 High Tower Green', MaxLength = 100, Locked = true;
        AlpineSkiHouseAddressLbl: Label '10 Deerfield Road', MaxLength = 100, Locked = true;
        RelecloudAddressLbl: Label '25 Water Way', MaxLength = 100, Locked = true;
        AtlantaCityLbl: Label 'Atlanta', MaxLength = 30;
        ChicagoCityLbl: Label 'Chicago', MaxLength = 30;
        MiamiCityLbl: Label 'Miami', MaxLength = 30;
        GaLbl: Label 'GA', MaxLength = 20;
        IlLbl: Label 'IL', MaxLength = 20;
        FlLbl: Label 'FL', MaxLength = 20;
}