codeunit 14136 "Create Customer MX"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomer(var Rec: Record Customer)
    var
        CreateCustomer: Codeunit "Create Customer";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateLanguage: Codeunit "Create Language";
    begin
        case Rec."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateRecordFields(Rec, TheCannonGroupPLCLbl, AdatumCorporationAddressLbl, MexicoCityLbl, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), PostCode01030Lbl, CreateLanguage.ESM(), CreatePostingGroups.DomesticPostingGroup());
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Rec, SelangorianLtdLbl, TreyResearchAddressLbl, MexicoCityLbl, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), PostCode6000Lbl, CreateLanguage.ESM(), CreatePostingGroups.DomesticPostingGroup());
            CreateCustomer.ExportSchoolofArt():
                ValidateRecordFields(Rec, JohnHaddockInsuranceCoLbl, SchoolofArtAddressLbl, LeonCityLbl, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), PostCode37500Lbl, CreateLanguage.ESM(), CreatePostingGroups.DomesticPostingGroup());
            CreateCustomer.EUAlpineSkiHouse():
                ValidateRecordFields(Rec, DeerfieldGraphicsCompanyLbl, AlpineSkiHouseAddressLbl, MonterreyCityLbl, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), PostCode64640Lbl, CreateLanguage.ESM(), CreatePostingGroups.DomesticPostingGroup());
            CreateCustomer.DomesticRelecloud():
                ValidateRecordFields(Rec, GuildfordWaterDepartmentLbl, RelecloudAddressLbl, MazatlanCityLbl, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), PostCode82100Lbl, CreateLanguage.ESM(), CreatePostingGroups.DomesticPostingGroup());
        end;
    end;

    local procedure ValidateRecordFields(var Customer: Record Customer; Name: Text[100]; Address: Text[100]; City: Text[30]; CustomerPostingGroup: Code[20]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; PostCode: Code[20]; LanguageCode: Code[10]; ReminderTermsCode: Code[20])
    begin
        Customer.Validate(Name, Name);
        Customer.Validate(Address, Address);
        Customer.Validate("Address 2", '');
        Customer.Validate(City, City);
        Customer.Validate("Territory Code", '');
        Customer.Validate("Customer Posting Group", CustomerPostingGroup);
        Customer.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Customer.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Customer.Validate("Post Code", PostCode);
        Customer.Validate(County, '');
        Customer.Validate("Language Code", LanguageCode);
        Customer.Validate("Reminder Terms Code", ReminderTermsCode);
    end;

    var
        TheCannonGroupPLCLbl: Label 'The Cannon Group PLC', Maxlength = 100;
        SelangorianLtdLbl: Label 'Selangorian Ltd.', Maxlength = 100;
        JohnHaddockInsuranceCoLbl: Label 'John Haddock Insurance Co.', Maxlength = 100;
        DeerfieldGraphicsCompanyLbl: Label 'Deerfield Graphics Company', Maxlength = 100;
        GuildfordWaterDepartmentLbl: Label 'Guildford Water Department', Maxlength = 100;
        AdatumCorporationAddressLbl: Label '192 Market Square', MaxLength = 100, Locked = true;
        TreyResearchAddressLbl: Label '153 Thomas Drive', MaxLength = 100, Locked = true;
        SchoolofArtAddressLbl: Label '10 High Tower Green', MaxLength = 100, Locked = true;
        AlpineSkiHouseAddressLbl: Label '10 Deerfield Road', MaxLength = 100, Locked = true;
        RelecloudAddressLbl: Label '25 Water Way', MaxLength = 100, Locked = true;
        MexicoCityLbl: Label 'Mexico City', MaxLength = 30;
        LeonCityLbl: Label 'Leon', MaxLength = 30;
        MonterreyCityLbl: Label 'Monterrey', MaxLength = 30;
        MazatlanCityLbl: Label 'Mazatlan', MaxLength = 30;
        PostCode01030Lbl: Label '01030', MaxLength = 20;
        PostCode6000Lbl: Label '06000', MaxLength = 20;
        PostCode37500Lbl: Label '37500', MaxLength = 20;
        PostCode64640Lbl: Label '64640', MaxLength = 20;
        PostCode82100Lbl: Label '82100', MaxLength = 20;
}