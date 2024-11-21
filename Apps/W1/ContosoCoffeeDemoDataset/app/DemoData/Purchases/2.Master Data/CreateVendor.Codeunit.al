codeunit 5539 "Create Vendor"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoCustomerVendor: Codeunit "Contoso Customer/Vendor";
        CreateVendorPostingGroup: codeunit "Create Vendor Posting Group";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateVatPostingGroups: Codeunit "Create VAT Posting Groups";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreateCountryRegion: Codeunit "Create Country/Region";
        ContoUtilities: Codeunit "Contoso Utilities";
        CreateTerritory: Codeunit "Create Territory";
        CreateItem: Codeunit "Create Item";
        CreateContJobResponsibility: Codeunit "Create Cont Job Responsibility";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        ContosoCustomerVendor.InsertVendor(ExportFabrikam(), FabrikamIncLbl, CreateCountryRegion.US(), NorthLakeAvenueLbl, '', 'US-GA 31772', '', CreateVendorPostingGroup.Foreign(), CreatePostingGroup.ExportPostingGroup(), CreateVatPostingGroups.Export(), '', '', false, CreatePaymentTerms.PaymentTermsCM(), '', ContoUtilities.EmptyPicture(), KrystalYorkLbl, CreateTerritory.Foreign(), 'krystal.york@contoso.com', Enum::"Application Method"::Manual);
        UpdateVendorNoOnItems(ExportFabrikam(), CreateItem.AmsterdamLamp());

        ContosoCustomerVendor.InsertVendor(DomesticFirstUp(), FirstUpConsultantsLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", AllanTuringRoadLbl, SurreyLbl, 'GU2 7XH', '', CreateVendorPostingGroup.Domestic(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroups.Domestic(), '', '', false, CreatePaymentTerms.PaymentTermsCM(), '', ContoUtilities.EmptyPicture(), EvanMcIntoshLbl, '', 'evan.mcintosh@contoso.com', Enum::"Application Method"::Manual);
        UpdateVendorNoOnItems(DomesticFirstUp(), CreateItem.ParisGuestChairBlack());
        UpdateVendorNoOnItems(DomesticFirstUp(), CreateItem.AntwerpConferenceTable());
        UpdateVendorNoOnItems(DomesticFirstUp(), CreateItem.BerlingGuestChairYellow());
        UpdateVendorNoOnItems(DomesticFirstUp(), CreateItem.RomeGuestChairGreen());
        UpdateVendorNoOnItems(DomesticFirstUp(), CreateItem.TokyoGuestChairBlue());
        UpdateVendorNoOnItems(DomesticFirstUp(), CreateItem.SeoulGuestChairRed());

        ContosoCustomerVendor.InsertVendor(EUGraphicDesign(), GraphicDesignInstituteLbl, CreateCountryRegion.DE(), ArbachtalstrasseLbl, UnterAchalmLbl, 'DE-72800', '', CreateVendorPostingGroup.EU(), CreatePostingGroup.EUPostingGroup(), CreateVatPostingGroups.EU(), '', '', false, CreatePaymentTerms.PaymentTermsCM(), '', ContoUtilities.EmptyPicture(), BryceJassoLbl, CreateTerritory.Foreign(), 'bryce.jasso@contoso.com', Enum::"Application Method"::Manual);
        UpdateVendorNoOnItems(EUGraphicDesign(), CreateItem.AthensDesk());
        UpdateVendorNoOnItems(EUGraphicDesign(), CreateItem.AthensMobilePedestal());
        UpdateVendorNoOnItems(EUGraphicDesign(), CreateItem.LondonSwivelChairBlue());
        UpdateVendorNoOnItems(EUGraphicDesign(), CreateItem.MexicoSwivelChairBlack());
        UpdateVendorNoOnItems(EUGraphicDesign(), CreateItem.MunichSwivelChairYellow());
        UpdateVendorNoOnItems(EUGraphicDesign(), CreateItem.MoscowSwivelChairRed());
        UpdateVendorNoOnItems(EUGraphicDesign(), CreateItem.AtlantaWhiteboardBase());
        UpdateVendorNoOnItems(EUGraphicDesign(), CreateItem.SydneySwivelChairGreen());

        ContosoCustomerVendor.InsertVendor(DomesticWorldImporter(), WideWorldImportersLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", AviatorWayLbl, ManchesterBusParkLbl, 'M22 5TG', '', CreateVendorPostingGroup.Domestic(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroups.Domestic(), '', '', false, CreatePaymentTerms.PaymentTermsCM(), '', ContoUtilities.EmptyPicture(), TobyRhodeLbl, '', 'toby.rhode@contoso.com', Enum::"Application Method"::Manual);
        ContosoCustomerVendor.InsertVendor(DomesticNodPublisher(), NodPublishersLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", WterLooPlaceLbl, WaverlyGateLbl, 'EH1 3EG', '', CreateVendorPostingGroup.Domestic(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroups.Domestic(), '', '', false, CreatePaymentTerms.PaymentTermsCM(), '', ContoUtilities.EmptyPicture(), RaymondHillardLbl, '', 'raymond.hillard@contoso.com', Enum::"Application Method"::Manual);

        CreateContJobResponsibility.UpdateVendorContactJobResposibility();
    end;

    local procedure UpdateVendorNoOnItems(VendorNo: Code[20]; ItemNo: Code[20])
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item.Validate("Vendor No.", VendorNo);
        Item.Modify(true);
    end;


    procedure ExportFabrikam(): Code[20]
    begin
        exit(ExportFabrikamTok);
    end;

    procedure DomesticFirstUp(): Code[20]
    begin
        exit(DomesticFirstUpTok);
    end;

    procedure EUGraphicDesign(): Code[20]
    begin
        exit(EUGraphicDesignTok);
    end;

    procedure DomesticWorldImporter(): Code[20]
    begin
        exit(DomesticWorldImporterTok);
    end;

    procedure DomesticNodPublisher(): Code[20]
    begin
        exit(DomesticNodPublisherTok);
    end;

    var
        ExportFabrikamTok: Label '10000', Locked = true;
        DomesticFirstUpTok: Label '20000', Locked = true;
        EUGraphicDesignTok: Label '30000', Locked = true;
        DomesticWorldImporterTok: Label '40000', Locked = true;
        DomesticNodPublisherTok: Label '50000', Locked = true;
        FabrikamIncLbl: Label 'Fabrikam, Inc.', Maxlength = 100;
        FirstUpConsultantsLbl: Label 'First Up Consultants', Maxlength = 100;
        GraphicDesignInstituteLbl: Label 'Graphic Design Institute', Maxlength = 100;
        WideWorldImportersLbl: Label 'Wide World Importers', Maxlength = 100;
        NodPublishersLbl: Label 'Nod Publishers', Maxlength = 100;
        NorthLakeAvenueLbl: Label '10 North Lake Avenue', MaxLength = 100, Locked = true;
        AllanTuringRoadLbl: Label 'Allan Turing Road, 20', MaxLength = 100, Locked = true;
        ArbachtalstrasseLbl: Label 'Arbachtalstrasse 6', MaxLength = 100, Locked = true;
        AviatorWayLbl: Label 'Aviator Way, 3000', MaxLength = 100, Locked = true;
        WterLooPlaceLbl: Label 'Waterloo Place, 2-4', MaxLength = 100, Locked = true;
        ManchesterBusParkLbl: Label 'Manchester Business Park', MaxLength = 50, Locked = true;
        UnterAchalmLbl: Label 'Unter Achalm', MaxLength = 50, Locked = true;
        SurreyLbl: Label 'Surrey', MaxLength = 50, Locked = true;
        WaverlyGateLbl: Label 'Waverly Gate', MaxLength = 50, Locked = true;
        KrystalYorkLbl: Label 'Krystal York', MaxLength = 100;
        EvanMcIntoshLbl: Label 'Evan McIntosh', MaxLength = 100;
        BryceJassoLbl: Label 'Bryce Jasso', MaxLength = 100;
        TobyRhodeLbl: Label 'Toby Rhode', MaxLength = 100;
        RaymondHillardLbl: Label 'Raymond Hillard', MaxLength = 100;
}