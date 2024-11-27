codeunit 5457 "Create Bank Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoBank: Codeunit "Contoso Bank";
        CreateBankExImportSetup: Codeunit "Create Bank Ex/Import Setup";
        CreateNoSeries: Codeunit "Create No. Series";
        SalespersonPurchaser: Codeunit "Create Salesperson/Purchaser";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        ContosoBank.InsertBankAccount(Checking(), BankAccountDescriptionLbl, BankaccountAddressLbl, BankAccountCityLbl, BankAccountContactLbl, CheckingBankAccountNoLbl, -934400, CheckingTok, SalespersonPurchaser.OtisFalls(), ContosoCoffeeDemoDataSetup."Country/Region Code", '23', CreateNoSeries.PaymentReconciliationJournals(), PostCodeLbl, '199', BankBranchNoLbl, CreateBankExImportSetup.SEPACAMT());
        ContosoBank.InsertBankAccount(Savings(), BankAccountDescriptionLbl, BankaccountAddressLbl, BankAccountCityLbl, BankAccountContactLbl, SavingBankAccountNoLbl, 0, SavingTok, SalespersonPurchaser.OtisFalls(), ContosoCoffeeDemoDataSetup."Country/Region Code", '', '', PostCodeLbl, '', BankBranchNoLbl, '');
    end;

    procedure Checking(): Code[20]
    begin
        exit(CheckingTok);
    end;

    procedure Savings(): Code[20]
    begin
        exit(SavingTok);
    end;

    var
        CheckingTok: Label 'CHECKING', MaxLength = 20;
        SavingTok: Label 'SAVINGS', MaxLength = 20;
        BankAccountDescriptionLbl: Label 'World Wide Bank', MaxLength = 100;
        BankaccountAddressLbl: Label '1 High Holborn', MaxLength = 100;
        BankAccountCityLbl: Label 'London', MaxLength = 30;
        BankAccountContactLbl: Label 'Grant Culbertson', MaxLength = 100;
        CheckingBankAccountNoLbl: Label '99-99-888', Locked = true;
        SavingBankAccountNoLbl: Label '99-44-567', Locked = true;
        PostCodeLbl: Label 'WC1 3DG', Locked = true;
        BankBranchNoLbl: Label 'BG99999', Locked = true;
}