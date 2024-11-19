codeunit 13736 "Create Customer DK"
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
        CreateCustomerPostingGroup: Codeunit "Create Customer Posting Group";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateVatPostingGroups: Codeunit "Create Vat Posting Groups";
        CreateLanguage: Codeunit "Create Language";
        CreateReminderTerms: Codeunit "Create Reminder Terms";
    begin
        case Rec."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateRecordFields(Rec, CannonGroupLbl, CannonGroupAddressLbl, '', NyborgCityLbl, '', CreateCustomerPostingGroup.Domestic(), CreateCountryRegion.DK(), '', CreatePostingGroups.DomesticPostingGroup(), '', PostCode5800Lbl, CreateVatPostingGroups.Domestic(), CreateLanguage.DAN(), CreateReminderTerms.Domestic());
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Rec, SelangorianLtdLbl, SelangorianLtdAddressLbl, '', HolbækCityLbl, '', CreateCustomerPostingGroup.Domestic(), CreateCountryRegion.DK(), '', CreatePostingGroups.DomesticPostingGroup(), '', PostCode4300Lbl, CreateVatPostingGroups.Domestic(), CreateLanguage.DAN(), CreateReminderTerms.Domestic());
            CreateCustomer.ExportSchoolofArt():
                ValidateRecordFields(Rec, JohnHaddockLbl, SchoolofArtAddressLbl, '', KogeCityLbl, '', CreateCustomerPostingGroup.Domestic(), CreateCountryRegion.DK(), '', CreatePostingGroups.DomesticPostingGroup(), '', PostCode4600Lbl, CreateVatPostingGroups.Domestic(), CreateLanguage.DAN(), CreateReminderTerms.Domestic());
            CreateCustomer.EUAlpineSkiHouse():
                ValidateRecordFields(Rec, DeerfieldGraphicsLbl, DeerfieldGraphicsAddressLbl, '', HilliardCityLbl, CreateTerritory.Foreign(), CreateCustomerPostingGroup.Foreign(), CreateCountryRegion.US(), '', CreatePostingGroups.ExportPostingGroup(), '', USFL37125PostCodeLbl, CreateVatPostingGroups.Export(), CreateLanguage.ENU(), CreateReminderTerms.Foreign());
            CreateCustomer.DomesticRelecloud():
                ValidateRecordFields(Rec, GuildfordWaterLbl, GuildfordWaterAddressLbl, '', GuildfordCityLbl, CreateTerritory.Foreign(), CreateCustomerPostingGroup.EU(), CreateCountryRegion.GB(), GBVatRegNoLbl, CreatePostingGroups.EUPostingGroup(), '', GBGU27YQPostCodeLbl, CreateVatPostingGroups.EU(), CreateLanguage.ENG(), CreateReminderTerms.Foreign());
        end;
    end;

    local procedure ValidateRecordFields(var Customer: Record Customer; Name: Text[100]; Address: Text[100]; Address2: Text[50]; City: Text[30]; TerritoryCode: Code[10]; CustomerPostingGroupCode: Code[20]; CountryRegionCode: Code[10]; VatRegNo: Text[20]; GenBusPostingGroupCode: Code[20]; County: Text[30]; PostCode: Code[20]; VATBusPostingGroup: Code[20]; LanguageCode: Code[10]; ReminderTermsCode: Code[10])
    begin
        Customer.Validate(Name, Name);
        Customer.Validate(Address, Address);
        Customer.Validate("Address 2", Address2);
        Customer.Validate(City, City);
        Customer.Validate("Territory Code", TerritoryCode);
        Customer.Validate("Customer Posting Group", CustomerPostingGroupCode);
        Customer.Validate("Country/Region Code", CountryRegionCode);
        Customer.Validate("VAT Registration No.", VatRegNo);
        Customer.Validate("Gen. Bus. Posting Group", GenBusPostingGroupCode);
        Customer.Validate(County, County);
        Customer.Validate("Post Code", PostCode);
        Customer.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Customer.Validate("Language Code", LanguageCode);
        Customer.Validate("Reminder Terms Code", ReminderTermsCode);
    end;

    var
        CannonGroupLbl: Label 'The Cannon Group PLC', Maxlength = 100;
        SelangorianLtdLbl: Label 'Selangorian Ltd.', Maxlength = 100;
        JohnHaddockLbl: Label 'John Haddock Insurance Co.', Maxlength = 100;
        DeerfieldGraphicsLbl: Label 'Deerfield Graphics Company', Maxlength = 100;
        GuildfordWaterLbl: Label 'Guildford Water Department', Maxlength = 100;
        CannonGroupAddressLbl: Label '192 Market Square', MaxLength = 100, Locked = true;
        SelangorianLtdAddressLbl: Label '153 Thomas Drive', MaxLength = 100, Locked = true;
        SchoolofArtAddressLbl: Label '10 High Tower Green', MaxLength = 100, Locked = true;
        DeerfieldGraphicsAddressLbl: Label '10 Deerfield Road', MaxLength = 100, Locked = true;
        GuildfordWaterAddressLbl: Label '25 Water Way', MaxLength = 100, Locked = true;
        NyborgCityLbl: Label 'Nyborg', MaxLength = 30, Locked = true;
        KogeCityLbl: Label 'Koge', MaxLength = 30, Locked = true;
        HolbækCityLbl: Label 'Holbæk', MaxLength = 30, Locked = true;
        HilliardCityLbl: Label 'Hilliard', MaxLength = 30, Locked = true;
        GuildfordCityLbl: Label 'Guildford', MaxLength = 30, Locked = true;
        GBVatRegNoLbl: Label 'GB333333333', MaxLength = 20;
        PostCode5800Lbl: Label '5800', MaxLength = 20;
        PostCode4300Lbl: Label '4300', MaxLength = 20;
        PostCode4600Lbl: Label '4600', MaxLength = 20;
        USFL37125PostCodeLbl: Label 'US-FL 37125', MaxLength = 20;
        GBGU27YQPostCodeLbl: Label 'GB-GU2 7YQ', MaxLength = 20;
}