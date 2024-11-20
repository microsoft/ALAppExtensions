codeunit 14618 "Create Customer IS"
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
    begin
        case Rec."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateRecordFields(Rec, ReykjavikCityLbl, DomesticAdatumCorporationVatRegNoLbl, PostCode810Lbl, CreateLanguage.ISL());
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Rec, ReykjavikCityLbl, DomesticTreyResearchVatRgeNoLbl, PostCode640Lbl, CreateLanguage.ISL());
            CreateCustomer.ExportSchoolofArt():
                ValidateRecordFields(Rec, MiamiCityLbl, ExportSchoolofArtVatRegNoLbl, USFL37125PostCodeLbl, CreateLanguage.ENU());
            CreateCustomer.EUAlpineSkiHouse():
                ValidateRecordFields(Rec, MunchenCityLbl, EUAlpineSkiHouseVatRegNoLbl, DE80807PostCodeLbl, CreateLanguage.DEU());
            CreateCustomer.DomesticRelecloud():
                ValidateRecordFields(Rec, HafnafjordurCityLbl, DomesticRelecloudVatRegNoLbl, PostCode220Lbl, CreateLanguage.ISL());
        end;
    end;

    local procedure ValidateRecordFields(var Customer: Record Customer; City: Text[30]; VatRegNo: Text[20]; PostCode: Code[20]; LanguageCode: Code[10])
    begin
        Customer.Validate(City, City);
        Customer.Validate("VAT Registration No.", VatRegNo);
        Customer.Validate("Post Code", PostCode);
        Customer.Validate("Language Code", LanguageCode);
    end;

    var
        ReykjavikCityLbl: Label 'Reykjavik', MaxLength = 30, Locked = true;
        HafnafjordurCityLbl: Label 'Hafnafjordur', MaxLength = 30, Locked = true;
        MiamiCityLbl: Label 'Miami', MaxLength = 30, Locked = true;
        MunchenCityLbl: Label 'Munchen', MaxLength = 30, Locked = true;
        DomesticAdatumCorporationVatRegNoLbl: Label '789456278', MaxLength = 20;
        DomesticTreyResearchVatRgeNoLbl: Label '254687456', MaxLength = 20;
        DomesticRelecloudVatRegNoLbl: Label '582048936', MaxLength = 20;
        ExportSchoolofArtVatRegNoLbl: Label '733495789', MaxLength = 20;
        EUAlpineSkiHouseVatRegNoLbl: Label '533435789', MaxLength = 20;
        PostCode810Lbl: Label '810', MaxLength = 20;
        PostCode640Lbl: Label '640', MaxLength = 20;
        USFL37125PostCodeLbl: Label 'US-FL 37125', MaxLength = 20;
        DE80807PostCodeLbl: Label 'DE-80807', MaxLength = 20;
        PostCode220Lbl: Label '220', MaxLength = 20;
}