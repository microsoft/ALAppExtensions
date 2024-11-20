codeunit 10874 "Create Bank Account FR"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccount(var Rec: Record "Bank Account")
    var
        ContosoCoffeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        ContosoCoffeDemoDataSetup.Get();
        case Rec."No." of
            CreateBankAccount.Checking():
                ValidateBankAccount(Rec, '98765432105', CityParisLbl, PostcodeParisLbl, CheckingBankBranchNoLbl, -1447200, AgencyCodeLbl, 72, true);
            CreateBankAccount.Savings():
                ValidateBankAccount(Rec, '98765432105', CityParisLbl, PostcodeParisLbl, CheckingBankBranchNoLbl, 0, AgencyCodeLbl, 72, true);
        end;
    end;

    local procedure ValidateBankAccount(var BankAccount: Record "Bank Account"; BankAccountNo: Text[30]; BankAccCity: Text[30]; PostCode: Code[20]; BankBranchNo: Text[30]; MinBalance: Decimal; AgencyCode: Text[5]; RibKey: Integer; RibChecked: Boolean)
    begin
        BankAccount.Validate(City, BankAccCity);
        BankAccount.Validate("Post Code", PostCode);
        BankAccount.Validate("Bank Branch No.", BankBranchNo);
        BankAccount.Validate("Bank Account No.", BankAccountNo);
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate("Agency Code", AgencyCode);
        BankAccount.Validate("RIB Key", RibKey);
        BankAccount.Validate("RIB Checked", RibChecked);
    end;

    var
        CityParisLbl: Label 'Paris', MaxLength = 30;
        PostcodeParisLbl: Label '75015', MaxLength = 20;
        CheckingBankBranchNoLbl: Label '00987', MaxLength = 20;
        AgencyCodeLbl: Label '12356', MaxLength = 5;
}