codeunit 5209 "Create Customer"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    //To do -Hard coded values pending to replace - Post Code

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoCustomerVendor: Codeunit "Contoso Customer/Vendor";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateVatPostingGroups: Codeunit "Create VAT Posting Groups";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateCustomerPostinGroup: Codeunit "Create Customer Posting Group";
        CreateReminderTerms: Codeunit "Create Reminder Terms";
        CreateLanguage: Codeunit "Create Language";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateDocSendingProfile: Codeunit "Create Doc Sending Profile";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreateTerritory: Codeunit "Create Territory";
        CreateSalespersonPurchaser: Codeunit "Create Salesperson/Purchaser";
        CreateContJobResponsibility: Codeunit "Create Cont Job Responsibility";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        ContosoCustomerVendor.InsertCustomer(DomesticAdatumCorporation(), AdatumCorporationLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", AdatumCorporationAddressLbl, '', 'CB1 2FB', '', CreateCustomerPostinGroup.Domestic(), CreatePostingGroups.DomesticPostingGroup(), CreateVatPostingGroups.Domestic(), '', '', false, CreatePaymentTerms.PaymentTermsM8D(), ContosoUtilities.EmptyPicture(), CreateDocSendingProfile.DefaultDocumentSendingProfile(), RobertTownesLbl, '', CreateLanguage.ENG(), CreateSalespersonPurchaser.JimOlive(), 'robert.townes@contoso.com', CreateReminderTerms.Domestic());
        ContosoCustomerVendor.InsertCustomer(DomesticTreyResearch(), TreyResearchLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", TreyResearchAddressLbl, '', 'SE1 0AX', '', CreateCustomerPostinGroup.Domestic(), CreatePostingGroups.DomesticPostingGroup(), CreateVatPostingGroups.Domestic(), '', '', false, CreatePaymentTerms.PaymentTermsDAYS14(), ContosoUtilities.EmptyPicture(), '', HelenRayLbl, '', CreateLanguage.ENG(), CreateSalespersonPurchaser.JimOlive(), 'helen.ray@contoso.com', CreateReminderTerms.Domestic());
        ContosoCustomerVendor.InsertCustomer(ExportSchoolofArt(), SchoolofArtLbl, CreateCountryRegion.US(), SchoolofArtAddressLbl, '', 'US-FL 37125', '', CreateCustomerPostinGroup.Foreign(), CreatePostingGroups.ExportPostingGroup(), CreateVatPostingGroups.Export(), '', '', false, CreatePaymentTerms.PaymentTermsCM(), ContosoUtilities.EmptyPicture(), '', MeaganBondLbl, CreateTerritory.Foreign(), CreateLanguage.ENU(), CreateSalespersonPurchaser.JimOlive(), 'meagan.bond@contoso.com', CreateReminderTerms.Foreign());
        ContosoCustomerVendor.InsertCustomer(EUAlpineSkiHouse(), AlpineSkiHouseLbl, CreateCountryRegion.DE(), AlpineSkiHouseAddressLbl, AlpineSkiHouseAddress2Lbl, 'DE-80807', '', CreateCustomerPostinGroup.EU(), CreatePostingGroups.EUPostingGroup(), CreateVatPostingGroups.EU(), '', '', false, CreatePaymentTerms.PaymentTermsM8D(), ContosoUtilities.EmptyPicture(), '', IanDeberryLbl, CreateTerritory.Foreign(), CreateLanguage.DEU(), CreateSalespersonPurchaser.JimOlive(), 'ian.deberry@contoso.com', CreateReminderTerms.Foreign());
        ContosoCustomerVendor.InsertCustomer(DomesticRelecloud(), RelecloudLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", RelecloudAddressLbl, RelecloudAddresss2Lbl, 'GU2 7YQ', '', CreateCustomerPostinGroup.Domestic(), CreatePostingGroups.DomesticPostingGroup(), CreateVatPostingGroups.Domestic(), '', '', false, CreatePaymentTerms.PaymentTermsDAYS14(), ContosoUtilities.EmptyPicture(), '', JesseHomerLbl, '', CreateLanguage.ENG(), CreateSalespersonPurchaser.JimOlive(), 'jesse.homer@contoso.com', CreateReminderTerms.Domestic());
        CreateContJobResponsibility.UpdateCustomerContactJobResposibility();
    end;

    procedure DomesticAdatumCorporation(): Code[20]
    begin
        exit(DomesticAdatumCorporationTok);
    end;

    procedure DomesticTreyResearch(): Code[20]
    begin
        exit(DomesticTreyResearchTok);
    end;

    procedure ExportSchoolofArt(): Code[20]
    begin
        exit(ExportSchoolofArtTok);
    end;

    procedure EUAlpineSkiHouse(): Code[20]
    begin
        exit(EUAlpineSkiHouseTok);
    end;

    procedure DomesticRelecloud(): Code[20]
    begin
        exit(DomesticRelecloudTok);
    end;

    var
        DomesticAdatumCorporationTok: Label '10000', MaxLength = 20, Locked = true;
        DomesticTreyResearchTok: Label '20000', MaxLength = 20, Locked = true;
        ExportSchoolofArtTok: Label '30000', MaxLength = 20, Locked = true;
        EUAlpineSkiHouseTok: Label '40000', MaxLength = 20, Locked = true;
        DomesticRelecloudTok: Label '50000', MaxLength = 20, Locked = true;
        AdatumCorporationLbl: Label 'Adatum Corporation', MaxLength = 100;
        TreyResearchLbl: Label 'Trey Research', MaxLength = 100;
        SchoolofArtLbl: Label 'School of Fine Art', MaxLength = 100;
        AlpineSkiHouseLbl: Label 'Alpine Ski House', MaxLength = 100;
        RelecloudLbl: Label 'Relecloud', MaxLength = 100;
        AdatumCorporationAddressLbl: Label 'Station Road, 21', MaxLength = 100, Locked = true;
        TreyResearchAddressLbl: Label 'Southwark Bridge Rd, 91-95', MaxLength = 100, Locked = true;
        SchoolofArtAddressLbl: Label '10 High Tower Green', MaxLength = 100, Locked = true;
        AlpineSkiHouseAddressLbl: Label 'Walter-Gropius-Strasse 5', MaxLength = 100, Locked = true;
        RelecloudAddressLbl: Label 'Occam Court, 1', MaxLength = 100, Locked = true;
        AlpineSkiHouseAddress2Lbl: Label 'Park Stadt Schwabing', MaxLength = 50, Locked = true;
        RelecloudAddresss2Lbl: Label 'Surrey', MaxLength = 50, Locked = true;
        RobertTownesLbl: Label 'Robert Townes', MaxLength = 100;
        HelenRayLbl: Label 'Helen Ray', MaxLength = 100;
        MeaganBondLbl: Label 'Meagan Bond', MaxLength = 100;
        IanDeberryLbl: Label 'Ian Deberry', MaxLength = 100;
        JesseHomerLbl: Label 'Jesse Homer', MaxLength = 100;
}