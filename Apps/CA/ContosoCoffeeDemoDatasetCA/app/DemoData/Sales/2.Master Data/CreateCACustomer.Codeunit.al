codeunit 27081 "Create CA Customer"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsert', '', false, false)]
    local procedure OnInsertRecord(var Customer: Record Customer)
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateCustomer: Codeunit "Create Customer";
        CreateReminderTerms: Codeunit "Create Reminder Terms";
        CreateCustomerPostinGroup: Codeunit "Create Customer Posting Group";
        CreateLanguage: Codeunit "Create Language";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateCATaxArea: Codeunit "Create CA Tax Area";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        case Customer."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateRecordFields(Customer, AdatumCorporationAddressLbl, WinnipegLbl, '', CreateLanguage.ENC(), '', '', 'R3C 3Z3', MBLbl, '', CreateCATaxArea.Manitoba(), true, '', '');
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Customer, TreyResearchAddressLbl, MissisaugaLbl, '', CreateLanguage.ENC(), '', '', 'L5N 8L9', ONLbl, '', CreateCATaxArea.Ontario(), true, '', '');
            CreateCustomer.ExportSchoolofArt():
                ValidateRecordFields(Customer, SchoolofArtAddressLbl, OttawaLbl, CreateCustomerPostinGroup.Domestic(), CreateLanguage.ENC(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreatePostingGroups.DomesticPostingGroup(), 'K1P 1J9', ONLbl, CreateReminderTerms.Domestic(), CreateCATaxArea.Ontario(), true, '', '');
            CreateCustomer.EUAlpineSkiHouse():
                ValidateRecordFields(Customer, AlpineSkiHouseAddressLbl, CalgaryLbl, CreateCustomerPostinGroup.Domestic(), CreateLanguage.ENC(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreatePostingGroups.DomesticPostingGroup(), 'T2P 0T1', ABLbl, CreateReminderTerms.Domestic(), CreateCATaxArea.Alberta(), true, '', '');
            CreateCustomer.DomesticRelecloud():
                ValidateRecordFields(Customer, RelecloudAddressLbl, VancouverLbl, '', CreateLanguage.ENC(), '', '', 'V6B 1C1', BCLbl, '', CreateCATaxArea.BritishColumbia(), true, '', '');
        end;
    end;

    local procedure ValidateRecordFields(var Customer: Record Customer; Address: Text[100]; City: Text[30]; CustomerPostingGroup: Code[20]; LanguageCode: Code[10]; CountryOrRegionCode: Code[10]; GenBusPostingGroup: Code[20]; PostCode: Code[20]; County: Code[20]; ReminderTermsCode: Code[10]; TaxAreaCode: Code[20]; TaxLiable: Boolean; TerritoryCode: Code[10]; DocumentSendingProfile: Code[20])
    begin
        Customer.Validate(Address, Address);
        Customer.Validate("Address 2", '');
        Customer.Validate(City, City);
        if CustomerPostingGroup <> '' then
            Customer.Validate("Customer Posting Group", CustomerPostingGroup);
        if GenBusPostingGroup <> '' then
            Customer.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Customer.Validate("Tax Area Code", TaxAreaCode);
        Customer.Validate("Tax Liable", TaxLiable);
        Customer.Validate("Document Sending Profile", DocumentSendingProfile);
        Customer.Validate("Territory Code", TerritoryCode);
        Customer.Validate("Language Code", LanguageCode);
        if ReminderTermsCode <> '' then
            Customer.Validate("Reminder Terms Code", ReminderTermsCode);
        if CountryOrRegionCode <> '' then
            Customer.Validate("Country/Region Code", CountryOrRegionCode);
        Customer.Validate("Post Code", PostCode);
        Customer.Validate(County, County);
    end;

    var
        AdatumCorporationAddressLbl: Label '360 Main Street, Suite 1150', MaxLength = 100, Locked = true;
        TreyResearchAddressLbl: Label '1950 Meadowvale Blvd.', MaxLength = 100, Locked = true;
        SchoolofArtAddressLbl: Label '100 Queen Street, Suite 500', MaxLength = 100, Locked = true;
        AlpineSkiHouseAddressLbl: Label '110 - 9th Avenue SW, 8th Floor', MaxLength = 100, Locked = true;
        RelecloudAddressLbl: Label '858 Beatty Street, 6th Floor', MaxLength = 100, Locked = true;
        WinnipegLbl: Label 'Winnipeg', MaxLength = 30;
        MissisaugaLbl: Label 'Missisauga', MaxLength = 30;
        OttawaLbl: Label 'Ottawa', MaxLength = 30;
        CalgaryLbl: Label 'Calgary', MaxLength = 30;
        VancouverLbl: Label 'Vancouver', MaxLength = 30;
        MBLbl: Label 'MB', MaxLength = 20;
        ONLbl: Label 'ON', MaxLength = 20;
        ABLbl: Label 'AB', MaxLength = 20;
        BCLbl: Label ' BC', MaxLength = 20;
}