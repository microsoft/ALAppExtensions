codeunit 10709 "Create Customer NO"
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
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreatePostingGroupsNO: Codeunit "Create Posting Groups NO";
        CreateVatPostingGroupsNO: Codeunit "Create Vat Posting Groups NO";
    begin
        case Rec."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateRecordFields(Rec, OsloCityLbl, PostCode0001Lbl, DomesticAdatumCorporationVatRegNoLbl, CreateLanguage.NOR(), CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroupsNO.CustDom(), CreateVatPostingGroupsNO.CUSTHIGH());
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Rec, SandvikaCityLbl, PostCode1300JWLbl, DomesticTreyResearchVatRgeNoLbl, CreateLanguage.NOR(), CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroupsNO.CustDom(), CreateVatPostingGroupsNO.CUSTHIGH());
            CreateCustomer.ExportSchoolofArt():
                ValidateRecordFields(Rec, MiamiCityLbl, PostCodeUSFL37125Lbl, ExportSchoolofArtVatRegNoLbl, CreateLanguage.ENU(), CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroupsNO.CustDom(), CreateVatPostingGroupsNO.CUSTHIGH());
            CreateCustomer.EUAlpineSkiHouse():
                ValidateRecordFields(Rec, MunchenCityLbl, PostCodeDE80807Lbl, EUAlpineSkiHouseVatRegNoLbl, CreateLanguage.DEU(), CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroupsNO.CustDom(), CreateVatPostingGroupsNO.CUSTHIGH());
            CreateCustomer.DomesticRelecloud():
                ValidateRecordFields(Rec, ALESUNDCityLbl, PostCode6001Lbl, DomesticRelecloudVatRegNoLbl, CreateLanguage.NOR(), CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroupsNO.CustDom(), CreateVatPostingGroupsNO.CUSTHIGH());
        end;
    end;

    local procedure ValidateRecordFields(var Customer: Record Customer; City: Text[30]; PostCode: Code[20]; VatRegNo: Text[20]; LanguageCode: Code[10]; CustomerPostingGroup: Code[20]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20])
    begin
        Customer.Validate(City, City);
        Customer.Validate("Post Code", PostCode);
        Customer."VAT Registration No." := VatRegNo;
        Customer.Validate("Language Code", LanguageCode);
        Customer.Validate("Customer Posting Group", CustomerPostingGroup);
        Customer.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Customer.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
    end;

    var
        OsloCityLbl: Label 'OSLO', MaxLength = 30, Locked = true;
        SandvikaCityLbl: Label 'SANDVIKA', MaxLength = 30, Locked = true;
        MiamiCityLbl: Label 'Miami', MaxLength = 30, Locked = true;
        MunchenCityLbl: Label 'Munchen', MaxLength = 30, Locked = true;
        ALESUNDCityLbl: Label 'ÅLESUND', MaxLength = 30, Locked = true;
        DomesticAdatumCorporationVatRegNoLbl: Label 'NO 789 456 275', MaxLength = 20;
        DomesticTreyResearchVatRgeNoLbl: Label 'NO 254 687 456', MaxLength = 20;
        DomesticRelecloudVatRegNoLbl: Label 'NO 582 048 932', MaxLength = 20;
        ExportSchoolofArtVatRegNoLbl: Label 'NO 733 495 782', MaxLength = 20;
        EUAlpineSkiHouseVatRegNoLbl: Label 'NO 533 435 785', MaxLength = 20;
        PostCode0001Lbl: Label '0001', MaxLength = 20;
        PostCode1300JWLbl: Label '1300', MaxLength = 20;
        PostCode6001Lbl: Label '6001', MaxLength = 20;
        PostCodeUSFL37125Lbl: Label 'US-FL 37125', MaxLength = 20;
        PostCodeDE80807Lbl: Label 'DE-80807', MaxLength = 20;
}