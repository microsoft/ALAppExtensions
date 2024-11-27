codeunit 13442 "Create Customer FI"
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
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        case Rec."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateRecordFields(Rec, HelsinkiCityLbl, DomesticAdatumCorporationVatRegNoLbl, PostCode40530Lbl, CreatePaymentTerms.PaymentTermsM8D(), CreateLanguage.FIN());
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Rec, HelsinkiCityLbl, DomesticTreyResearchVatRegNoLbl, PostCode33200Lbl, CreatePaymentTerms.PaymentTermsDAYS30(), CreateLanguage.FIN());
            CreateCustomer.ExportSchoolofArt():
                ValidateRecordFields(Rec, MiamiCityLbl, ExportSchoolofArtVatRegNoLbl, USFL37125PostCodeLbl, CreatePaymentTerms.PaymentTermsCM(), CreateLanguage.ENU());
            CreateCustomer.EUAlpineSkiHouse():
                ValidateRecordFields(Rec, MunchenCityLbl, EUAlpineSkiHouseVatRegNoLbl, DE80807PostCodeLbl, CreatePaymentTerms.PaymentTermsM8D(), CreateLanguage.DEU());
            CreateCustomer.DomesticRelecloud():
                ValidateRecordFields(Rec, HelsinkiCityLbl, DomesticRelecloudVatRegNoLbl, PostCode2170Lbl, CreatePaymentTerms.PaymentTermsDAYS14(), CreateLanguage.FIN());
        end;
    end;

    local procedure ValidateRecordFields(var Customer: Record Customer; City: Text[30]; VatRegNo: Text[20]; PostCode: Code[20]; PaymentTermsCode: Code[10]; LanguageCode: Code[10])
    begin
        Customer.Validate(City, City);
        Customer.Validate("VAT Registration No.", VatRegNo);
        Customer.Validate("Post Code", PostCode);
        Customer.Validate("Payment Terms Code", PaymentTermsCode);
        Customer.Validate("Language Code", LanguageCode);
    end;

    var
        HelsinkiCityLbl: Label 'Helsinki', MaxLength = 30, Locked = true;
        MiamiCityLbl: Label 'Miami', MaxLength = 30, Locked = true;
        MunchenCityLbl: Label 'Munchen', MaxLength = 30, Locked = true;
        DomesticAdatumCorporationVatRegNoLbl: Label '789456278', MaxLength = 20;
        DomesticTreyResearchVatRegNoLbl: Label '254687456', MaxLength = 20;
        ExportSchoolofArtVatRegNoLbl: Label '733495789', MaxLength = 20;
        EUAlpineSkiHouseVatRegNoLbl: Label '533435789', MaxLength = 20;
        DomesticRelecloudVatRegNoLbl: Label '582048936', MaxLength = 20;
        PostCode40530Lbl: Label '40530', MaxLength = 20;
        PostCode33200Lbl: Label '33200', MaxLength = 20;
        PostCode2170Lbl: Label '02170', MaxLength = 20;
        USFL37125PostCodeLbl: Label 'US-FL 37125', MaxLength = 20;
        DE80807PostCodeLbl: Label 'DE-80807', MaxLength = 20;
}