codeunit 13710 "Create Bank Account DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateBankAccPostingGrp: Codeunit "Create Bank Acc. Posting Grp";
        CreateSalespersonPurchaser: Codeunit "Create Salesperson/Purchaser";
        ContosoBank: Codeunit "Contoso Bank";
    begin
        ContosoBank.InsertBankAccount(NBL(), NBLBankAccountDescriptionLbl, NBLBankaccountAddressLbl, NBLBankAccountCityLbl, NBLBankAccountContactLbl, NBLBankAccountNoLbl, 0, CreateBankAccPostingGrp.Checking(), CreateSalespersonPurchaser.OtisFalls(), ContosoCoffeeDemoDataSetup."Country/Region Code", NBLLastStateMentNoLbl, '', NBLPostCodeLbl, '', NBLBankBranchNoLbl, '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccount(var Rec: Record "Bank Account")
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        case Rec."No." of
            CreateBankAccount.Checking():
                ValidateRecordFields(Rec, BankAccountCityLbl, -8000000, PostCodeLbl, BankBranchNoLbl);
        end;
    end;

    local procedure ValidateRecordFields(var BankAccount: Record "Bank Account"; City: Text[30]; MinBalance: Decimal; PostCode: Code[20]; BankBranchNo: Text[20])
    begin
        BankAccount.Validate(City, City);
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate("Post Code", PostCode);
        BankAccount.Validate("Bank Branch No.", BankBranchNo);
    end;

    procedure NBL(): Code[20]
    begin
        exit(NBLTok);
    end;

    var
        NBLTok: Label 'NBL', Locked = true;
        NBLBankAccountDescriptionLbl: Label 'New Bank of London', MaxLength = 100, Locked = true;
        NBLBankaccountAddressLbl: Label '4 Baker Street', MaxLength = 100, Locked = true;
        NBLBankAccountCityLbl: Label 'Glostrup', MaxLength = 30, Locked = true;
        NBLBankAccountContactLbl: Label 'Holly Dickson', MaxLength = 100, Locked = true;
        NBLBankAccountNoLbl: Label '078-66-345', MaxLength = 30, Locked = true;
        NBLLastStateMentNoLbl: Label '4', MaxLength = 20, Locked = true;
        NBLPostCodeLbl: Label '2600', MaxLength = 20, Locked = true;
        NBLBankBranchNoLbl: Label '4366', MaxLength = 20, Locked = true;
        BankAccountCityLbl: Label 'Copenhagen K', MaxLength = 30, Locked = true;
        PostCodeLbl: Label '1152', MaxLength = 20, Locked = true;
        BankBranchNoLbl: Label '9999', MaxLength = 20, Locked = true;
}