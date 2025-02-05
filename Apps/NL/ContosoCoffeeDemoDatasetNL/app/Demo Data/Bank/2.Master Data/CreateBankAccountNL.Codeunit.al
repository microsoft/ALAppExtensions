codeunit 11517 "Create Bank Account NL"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CompanyInformation: Record "Company Information";
        ContosoBankNL: Codeunit "Contoso Bank NL";
        SalespersonPurchaser: Codeunit "Create Salesperson/Purchaser";
        CreateCurrency: Codeunit "Create Currency";
    begin
        CompanyInformation.Get();
        ContosoBankNL.InsertBankAccount(ABN(), ABNLbl, Raadhuisplein10AddressLbl, RotterdamCityLbl, DikBijlmersContactLbl, BankAccountABNLbl, ABNTok, SalespersonPurchaser.OtisFalls(), PostCode2131HDLbl, BankBranch1Lbl, '', IBANABNLbl, CompanyInformation.Name, CompanyInformation.Address, CompanyInformation.City, CompanyInformation."Post Code", '');
        ContosoBankNL.InsertBankAccount(ABNUSD(), ABNUsdTok, Damrak1AddressLbl, ArnhemCityLbl, GerardZalmContactLbl, BankAccountABNUsdLbl, ABNUsdTok, SalespersonPurchaser.OtisFalls(), PostCode1012LXLbl, CompanyInformation."Bank Branch No.", CreateCurrency.USD(), IBANABNUsdLbl, CompanyInformation.Name, CompanyInformation.Address, CompanyInformation.City, CompanyInformation."Post Code", '');
        ContosoBankNL.InsertBankAccount(PostBank(), PostbankTok, DeBrug12AddressLbl, RotterdamCityLbl, MargrietKantersContactLbl, BankAccountPostBankLbl, PostbankTok, SalespersonPurchaser.OtisFalls(), PostCode2131HDLbl, BankBranch2Lbl, '', IBANPostBankLbl, CompanyInformation.Name, CompanyInformation.Address, CompanyInformation.City, CompanyInformation."Post Code", '');
        ContosoBankNL.InsertBankAccount(RaboLeen(), RaboLeenTok, Damrak1AddressLbl, ArnhemCityLbl, GerardZalmContactLbl, BankAccountRaboLeenLbl, RaboLeenTok, SalespersonPurchaser.OtisFalls(), PostCode1012LXLbl, CompanyInformation."Bank Branch No.", '', IBANRaboLeenLbl, CompanyInformation.Name, CompanyInformation.Address, CompanyInformation.City, CompanyInformation."Post Code", '');
        ContosoBankNL.InsertBankAccount(RaboUSD(), RaboUsdTok, Damrak1AddressLbl, ArnhemCityLbl, GerardZalmContactLbl, BankAccountRaboUsdLbl, RaboUsdTok, SalespersonPurchaser.OtisFalls(), PostCode1012LXLbl, CompanyInformation."Bank Branch No.", CreateCurrency.USD(), IBANRaboUsdLbl, '', '', '', '', '');
    end;

    procedure ABN(): Code[20]
    begin
        exit(ABNTok);
    end;

    procedure ABNUSD(): Code[20]
    begin
        exit(ABNUsdTok);
    end;

    procedure PostBank(): Code[20]
    begin
        exit(PostbankTok);
    end;

    procedure RaboLeen(): Code[20]
    begin
        exit(RaboLeenTok);
    end;

    procedure RaboUSD(): Code[20]
    begin
        exit(RaboUsdTok);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccount(var Rec: Record "Bank Account")
    var
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        case Rec."No." of
            CreateBankAccount.Checking():
                ValidateRecordFields(Rec, -1447200, ArnhemCityLbl, PostCode1012LXLbl);
            CreateBankAccount.Savings():
                ValidateRecordFields(Rec, 0, ArnhemCityLbl, PostCode1012LXLbl);
        end;
    end;

    local procedure ValidateRecordFields(var BankAccount: Record "Bank Account"; MinBalance: Decimal; City: Text[30]; PostCode: Code[20])
    begin
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate(City, City);
        BankAccount.Validate("Post Code", PostCode);
    end;

    var
        ABNTok: Label 'ABN', MaxLength = 20, Locked = true;
        ABNLbl: Label 'ABN-AMRO', MaxLength = 100;
        ABNUsdTok: Label 'ABN-USD', MaxLength = 20, Locked = true;
        PostbankTok: Label 'POSTBANK', MaxLength = 20, Locked = true;
        RaboLeenTok: Label 'RABO-LEEN', MaxLength = 20, Locked = true;
        RaboUsdTok: Label 'RABO-USD', MaxLength = 20, Locked = true;
        Raadhuisplein10AddressLbl: Label 'Raadhuisplein 10', MaxLength = 100;
        Damrak1AddressLbl: Label 'Damrak 1', MaxLength = 100;
        DeBrug12AddressLbl: Label 'De Brug 12', MaxLength = 100;
        ArnhemCityLbl: Label 'Arnhem', MaxLength = 30;
        RotterdamCityLbl: Label 'Rotterdam', MaxLength = 30;
        DikBijlmersContactLbl: Label 'Dik Bijlmers', MaxLength = 50;
        GerardZalmContactLbl: Label 'Gerard Zalm', MaxLength = 50;
        MargrietKantersContactLbl: Label 'Margriet Kanters', MaxLength = 50;
        PostCode1012LXLbl: Label '1012 LX', MaxLength = 20;
        PostCode2131HDLbl: Label '2131 HD', MaxLength = 20;
        BankBranch1Lbl: Label '43.12.90.456', MaxLength = 20;
        BankBranch2Lbl: Label 'GO284033', MaxLength = 20;
        BankAccountABNLbl: Label '306001241', MaxLength = 30;
        BankAccountABNUsdLbl: Label '306001244', MaxLength = 30;
        BankAccountPostBankLbl: Label 'P9876543', MaxLength = 30;
        BankAccountRaboLeenLbl: Label '303355328', MaxLength = 30;
        BankAccountRaboUsdLbl: Label '0000111120', MaxLength = 30;
        IBANABNLbl: Label 'NL69 ABNA 0306 0012 41', MaxLength = 50;
        IBANABNUsdLbl: Label 'NL28 ABNA 0112 2233 33', MaxLength = 50;
        IBANPostBankLbl: Label 'NL69 PSTB 0001 2345 67', MaxLength = 50;
        IBANRaboLeenLbl: Label 'NL38 RABO 0303 3553 28', MaxLength = 50;
        IBANRaboUsdLbl: Label 'NL00 RABO 0000 1111 20', MaxLength = 50;
}