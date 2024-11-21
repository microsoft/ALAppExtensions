codeunit 17126 "Create AU Bank Account"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccount(var Rec: Record "Bank Account")
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateBankAccount: Codeunit "Create Bank Account";
        CreateAUBankAccPostingGrp: Codeunit "Create AU Bank Acc Posting Grp";
        CreateBankAccPostingGrp: Codeunit "Create Bank Acc. Posting Grp";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        case Rec."No." of
            CreateBankAccount.Checking():
                ValidateRecordFields(Rec, BowenBridgeLbl, -2724000, '', '4006', CountyLbl, CreateAUBankAccPostingGrp.Lcy());
            CreateBankAccount.Savings():
                ValidateRecordFields(Rec, BowenBridgeLbl, 0, '', '4006', CountyLbl, CreateBankAccPostingGrp.Cash());
        end;
    end;

    local procedure ValidateRecordFields(var BankAccount: Record "Bank Account"; City: Text[30]; MinBalance: Decimal; CountryRegionCode: Code[10]; PostCode: Code[20]; County: Text[30]; BankAccPostingGroup: Code[20])
    begin
        BankAccount.Validate(City, City);
        BankAccount.Validate("Post Code", PostCode);
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount."Country/Region Code" := CountryRegionCode;
        BankAccount.County := County;
        BankAccount.Validate("Bank Acc. Posting Group", BankAccPostingGroup);
    end;

    var
        BowenBridgeLbl: Label 'BOWEN BRIDGE', MaxLength = 30;
        CountyLbl: Label 'QLD', MaxLength = 30;
}