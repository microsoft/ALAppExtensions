codeunit 12210 "Create Customer IT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomer(var Rec: Record Customer)
    var
        CreateCustomer: Codeunit "Create Customer";
        CreateLanguage: Codeunit "Create Language";
        CreateTerritory: Codeunit "Create Territory";
    begin
        case Rec."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateRecordFields(Rec, GenovaCityLbl, DomesticAdatumCorporationVatRegNoLbl, PostCode16100Lbl, CreateTerritory.Foreign(), CreateLanguage.ITA());
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Rec, CremonaCityLbl, DomesticTreyResearchVatRegNoLbl, PostCode26100Lbl, CreateTerritory.Foreign(), CreateLanguage.ITA());
            CreateCustomer.ExportSchoolofArt():
                Rec.Validate("VAT Registration No.", ExportSchoolofArtVatRegNoLbl);
            CreateCustomer.EUAlpineSkiHouse():
                Rec.Validate("VAT Registration No.", EUAlpineSkiHouseVatRegNoLbl);
            CreateCustomer.DomesticRelecloud():
                ValidateRecordFields(Rec, VeronaCityLbl, DomesticRelecloudVatRegNoLbl, PostCode37100Lbl, CreateTerritory.Foreign(), CreateLanguage.ITA());
        end;
    end;

    local procedure ValidateRecordFields(var Customer: Record Customer; City: Text[30]; VatRegNo: Text[20]; PostCode: Code[20]; TerritoryCode: Code[10]; LanguageCode: Code[10])
    begin
        Customer.Validate(City, City);
        Customer.Validate("VAT Registration No.", VatRegNo);
        Customer.Validate("Post Code", PostCode);
        Customer.Validate("Territory Code", TerritoryCode);
        Customer.Validate("Language Code", LanguageCode);
    end;

    var
        GenovaCityLbl: Label 'Genova', MaxLength = 30, Locked = true;
        CremonaCityLbl: Label 'Cremona', MaxLength = 30, Locked = true;
        VeronaCityLbl: Label 'Verona', MaxLength = 30, Locked = true;
        DomesticAdatumCorporationVatRegNoLbl: Label '789456278', MaxLength = 20;
        DomesticTreyResearchVatRegNoLbl: Label '254687456', MaxLength = 20;
        ExportSchoolofArtVatRegNoLbl: Label '733495789', MaxLength = 20;
        EUAlpineSkiHouseVatRegNoLbl: Label '533435789', MaxLength = 20;
        DomesticRelecloudVatRegNoLbl: Label '582048936', MaxLength = 20;
        PostCode16100Lbl: Label '16100', MaxLength = 20;
        PostCode26100Lbl: Label '26100', MaxLength = 20;
        PostCode37100Lbl: Label '37100', MaxLength = 20;
}