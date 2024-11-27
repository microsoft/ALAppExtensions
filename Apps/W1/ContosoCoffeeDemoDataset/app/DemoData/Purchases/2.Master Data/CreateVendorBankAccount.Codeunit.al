codeunit 5313 "Create Vendor Bank Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoVendorBankAccount: codeunit "Contoso Vendor Bank Account";
        CreateVendor: codeunit "Create Vendor";
        CreateLanguage: Codeunit "Create Language";
    begin
        ContosoVendorBankAccount.InsertVendorBankAccount(CreateVendor.ExportFabrikam(), ECA(), ECABankLbl, AnchorHouseLbl, SheelaWordLbl, '+44 296 196933', BranchLbl, BankAccNum10000Lbl, '+44 296 151727', CreateLanguage.ENG(), 'GB 29 NWBK 60161331926819');
        ContosoVendorBankAccount.InsertVendorBankAccount(CreateVendor.DomesticFirstUp(), ECA(), ECABankLbl, AnchorHouseLbl, SheelaWordLbl, '+44 296 196933', BranchLbl, BankAccNum2000Lbl, '+44 296 151727', CreateLanguage.ENG(), '');
    end;

    procedure ECA(): Code[20]
    begin
        exit(ECATok);
    end;

    var
        ECATok: Label 'ECA', MaxLength = 20;
        ECABankLbl: Label 'ECA Bank', MaxLength = 100;
        AnchorHouseLbl: Label 'Anchor House 43', MaxLength = 100;
        BranchLbl: Label '1200', MaxLength = 20, Locked = true;
        SheelaWordLbl: Label 'Sheela Word', MaxLength = 100;
        BankAccNum10000Lbl: Label '1200 100003', Locked = true;
        BankAccNum2000Lbl: Label '1200 100004', Locked = true;
}