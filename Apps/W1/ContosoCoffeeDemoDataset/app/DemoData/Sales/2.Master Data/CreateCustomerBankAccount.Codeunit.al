codeunit 5325 "Create Customer Bank Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCustomerVendor: Codeunit "Contoso Customer/Vendor";
        CreateLanguage: Codeunit "Create Language";
        CreateCustomer: Codeunit "Create Customer";
    begin
        ContosoCustomerVendor.InsertCustomerBankAccount(CreateCustomer.DomesticAdatumCorporation(), ECA(), NameLbl, AnchorHouseLbl, SheelaWordLbl, '+44 296 196933', BranchLbl, AdatumAccountNoLbl, '+44 296 151727', CreateLanguage.ENG(), 'GB 54 BARC 20992012345678');
        ContosoCustomerVendor.InsertCustomerBankAccount(CreateCustomer.DomesticTreyResearch(), ECA(), NameLbl, AnchorHouseLbl, SheelaWordLbl, '+44 296 196933', BranchLbl, TreyAccountNoLbl, '+44 296 151727', CreateLanguage.ENG(), '');
    end;

    procedure ECA(): Code[20]
    begin
        exit(ECATok);
    end;

    var
        ECATok: Label 'ECA', MaxLength = 20;
        NameLbl: Label 'ECA Bank', MaxLength = 100;
        AnchorHouseLbl: Label 'Anchor House 43', MaxLength = 100, Locked = true;
        SheelaWordLbl: Label 'Sheela Word', MaxLength = 100, Locked = true;
        BranchLbl: Label '1200', MaxLength = 20, Locked = true;
        AdatumAccountNoLbl: Label '1200 100001', MaxLength = 30, Locked = true;
        TreyAccountNoLbl: Label '1200 100002', MaxLength = 30, Locked = true;
}