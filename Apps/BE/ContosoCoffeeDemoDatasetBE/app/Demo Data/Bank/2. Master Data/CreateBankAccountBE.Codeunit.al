codeunit 11371 "Create Bank Account BE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoBank: Codeunit "Contoso Bank";
        SalespersonPurchaser: Codeunit "Create Salesperson/Purchaser";
        CreateBankAccPostingGrp: Codeunit "Create Bank Acc. Posting Grp";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        ContosoBank.InsertBankAccount(NBLBank(), NewBankofLondonDescLbl, NBLBankAddressLbl, BruggeCityLbl, HollyDicksonContactLbl, NblBankAccountNoLbl, 0, CreateBankAccPostingGrp.Checking(), SalespersonPurchaser.OtisFalls(), ContosoCoffeeDemoDataSetup."Country/Region Code", LastStateMentNoLbl, '', PostCodeBruggeLbl, '', NblBranchNoLbl, '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccount(var Rec: Record "Bank Account")
    var
        CreateBankAccount: Codeunit "Create Bank Account";
        CreateBankAccountBE: Codeunit "Create Bank Account BE";
    begin
        case Rec."No." of
            CreateBankAccount.Checking():
                ValidateBankAccount(Rec, BankAccountNoLbl, CityAntwerpenLbl, -1447200, PostcodeAntwerpenLbl, CheckingBankBranchNoLbl);
            CreateBankAccountBE.NBLBank():
                begin
                    Rec.Validate(IBAN, 'BE67 2900 0461 4187');
                    Rec.Validate("Protocol No.", NBLProtocolNoLbl);
                    Rec.Validate("Version Code", NBLVersionCodeLbl);
                end;
        end;
    end;

    local procedure ValidateBankAccount(var BankAccount: Record "Bank Account"; BankAccountNo: Text[30]; BankAccCity: Text[30]; MinBalance: Decimal; PostCode: Code[20]; BankBranchNo: Text[30])
    begin
        BankAccount.Validate(City, BankAccCity);
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate("Post Code", PostCode);
        BankAccount.Validate("Bank Branch No.", BankBranchNo);
        BankAccount.Validate("Bank Account No.", BankAccountNo);
    end;

    procedure NBLBank(): Code[20]
    begin
        exit(NBLBankTok);
    end;

    var
        CityAntwerpenLbl: Label 'ANTWERPEN', MaxLength = 30;
        BankAccountNoLbl: Label '431-0065952-59', MaxLength = 30;
        PostcodeAntwerpenLbl: Label '2000', MaxLength = 20;
        CheckingBankBranchNoLbl: Label '431', MaxLength = 20;
        NBLBankTok: Label 'NBL', MaxLength = 20, Locked = true;
        NewBankofLondonDescLbl: Label 'New Bank of London', MaxLength = 100;
        NBLBankAddressLbl: Label '4 Baker Street', MaxLength = 100;
        BruggeCityLbl: Label 'BRUGGE', MaxLength = 30;
        HollyDicksonContactLbl: Label 'Holly Dickson', MaxLength = 100;
        NblBankAccountNoLbl: Label '290-0046141-87', MaxLength = 30;
        LastStateMentNoLbl: Label '4', MaxLength = 20;
        PostCodeBruggeLbl: Label '8000', MaxLength = 20;
        NblBranchNoLbl: Label '290', MaxLength = 20;
        NBLProtocolNoLbl: Label '290', MaxLength = 3;
        NBLVersionCodeLbl: Label '1', MaxLength = 1;
}