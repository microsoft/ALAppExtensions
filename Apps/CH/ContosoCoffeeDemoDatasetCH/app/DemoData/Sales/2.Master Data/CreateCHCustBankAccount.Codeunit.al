codeunit 11591 "Create CH Cust. Bank Account"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCHCustomerVendor: Codeunit "Contoso CH Customer Vendor";
        CreateCustomer: Codeunit "Create Customer";
    begin
        ContosoCHCustomerVendor.InsertCustomerBankAccount(CreateCustomer.DomesticAdatumCorporation(), LSV(), RaiffeisenbankAlpnachLbl, '', AlpnachDorfCityLbl, '6055', RaiffeisenbankAlpnachBranchNoLbl, RaiffeisenbankAlpnachAccountNoLbl, RaiffeisenbankAlpnachGiroNoLbl);
        ContosoCHCustomerVendor.InsertCustomerBankAccount(CreateCustomer.DomesticTreyResearch(), LSV(), ObwaldnerKantonalbankLbl, "BrünigstrasseLbl", AlpnachDorfCityLbl, '6055', ObwaldnerKantonalbankBranchNoLbl, ObwaldnerKantonalbankAccountNoLbl, ObwaldnerKantonalbankGiroNoLbl);
        ContosoCHCustomerVendor.InsertCustomerBankAccount(CreateCustomer.ExportSchoolofArt(), LSV(), MigrosbankLuzernLbl, StadthofstrasseLbl, LuzernCityLbl, '6002', MigrosbankLuzernBranchNoLbl, MigrosbankLuzernAccountNoLbl, MigrosbankLuzernGiroNoLbl);
        ContosoCHCustomerVendor.InsertCustomerBankAccount(CreateCustomer.EUAlpineSkiHouse(), LSV(), CoopBankLbl, '', LuzernCityLbl, '6002', CoopBankBranchNoLbl, CoopBankAccountNoLbl, CoopBankGiroNoLbl);
        ContosoCHCustomerVendor.InsertCustomerBankAccount(CreateCustomer.DomesticRelecloud(), LSV(), LuzernerKantonalbankLbl, '', LuzernCityLbl, '6002', LuzernerKantonalbankBranchNoLbl, LuzernerKantonalbankAccountNoLbl, LuzernerKantonalbankGiroNoLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Customer Bank Account")
    begin
        if Rec.Code = LSV() then
            Rec.Validate(County, '');
    end;

    procedure LSV(): Code[20]
    begin
        exit(LSVTok);
    end;

    var
        LSVTok: Label 'LSV', MaxLength = 20;
        RaiffeisenbankAlpnachLbl: Label 'Raiffeisenbank Alpnach', MaxLength = 100, Locked = true;
        ObwaldnerKantonalbankLbl: Label 'Obwaldner Kantonalbank', MaxLength = 100, Locked = true;
        MigrosbankLuzernLbl: Label 'Migrosbank Luzern', MaxLength = 100, Locked = true;
        CoopBankLbl: Label 'Coop Bank', MaxLength = 100, Locked = true;
        LuzernerKantonalbankLbl: Label 'Luzerner Kantonalbank', MaxLength = 100, Locked = true;
        BrünigstrasseLbl: Label 'Brünigstrasse', MaxLength = 100, Locked = true;
        StadthofstrasseLbl: Label 'Stadthofstrasse', MaxLength = 100, Locked = true;
        AlpnachDorfCityLbl: Label 'Alpnach Dorf', MaxLength = 30, Locked = true;
        LuzernCityLbl: Label 'Luzern', MaxLength = 30, Locked = true;
        RaiffeisenbankAlpnachBranchNoLbl: Label '81232', MaxLength = 5, Locked = true;
        ObwaldnerKantonalbankBranchNoLbl: Label '780', MaxLength = 5, Locked = true;
        MigrosbankLuzernBranchNoLbl: Label '8411', MaxLength = 5, Locked = true;
        CoopBankBranchNoLbl: Label '8450', MaxLength = 5, Locked = true;
        LuzernerKantonalbankBranchNoLbl: Label '778', MaxLength = 5, Locked = true;
        RaiffeisenbankAlpnachAccountNoLbl: Label '34124.24', MaxLength = 30, Locked = true;
        ObwaldnerKantonalbankAccountNoLbl: Label '01-30-033237-00', MaxLength = 30, Locked = true;
        MigrosbankLuzernAccountNoLbl: Label '421-740-018.10', MaxLength = 30, Locked = true;
        CoopBankAccountNoLbl: Label '4178933000506', MaxLength = 30, Locked = true;
        LuzernerKantonalbankAccountNoLbl: Label '01-00-036430-00', MaxLength = 30, Locked = true;
        RaiffeisenbankAlpnachGiroNoLbl: Label '01-28302-7', MaxLength = 11, Locked = true;
        ObwaldnerKantonalbankGiroNoLbl: Label '01-17601-2', MaxLength = 11, Locked = true;
        MigrosbankLuzernGiroNoLbl: Label '01-1760-2', MaxLength = 11, Locked = true;
        CoopBankGiroNoLbl: Label '10-1010-6', MaxLength = 11, Locked = true;
        LuzernerKantonalbankGiroNoLbl: Label '80-70-2', MaxLength = 11, Locked = true;
}