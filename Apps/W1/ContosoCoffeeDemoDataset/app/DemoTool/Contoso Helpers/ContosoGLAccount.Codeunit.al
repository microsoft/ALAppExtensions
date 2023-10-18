codeunit 5133 "Contoso GL Account"
{
    SingleInstance = true;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "G/L Account" = rim;

    var
        TempContosoGLAccount: Record "Contoso GL Account" temporary;
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure AddAccountForLocalization(AccountName: Text[100]; AccountNo: Code[20])
    begin
        if TempContosoGLAccount.Get(AccountName) then begin
            TempContosoGLAccount.Validate("Account No.", AccountNo);
            TempContosoGLAccount.Modify();
        end else begin
            TempContosoGLAccount.Init();
            TempContosoGLAccount.Validate("Account Name", AccountName);
            TempContosoGLAccount.Validate("Account No.", AccountNo);
            TempContosoGLAccount.Insert();
        end;
    end;

    procedure GetAccountNo(AccountName: Text[100]): Code[20]
    begin
        TempContosoGLAccount.Get(AccountName);
        exit(TempContosoGLAccount."Account No.");
    end;

    procedure InsertGLAccount(AccountNo: Code[20]; Name: Text[100]; IncomeOrBalance: Enum "G/L Account Income/Balance"; AccountCategory: Enum "G/L Account Category"; AccountType: Enum "G/L Account Type"; GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; TaxGroup: Code[20])
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        GLAccount: Record "G/L Account";
        Exists: Boolean;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if AccountNo = '' then
            exit;

        if GLAccount.Get(AccountNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GLAccount.Validate("No.", AccountNo);
        GLAccount.Validate(Name, Name);

        case IncomeOrBalance of
            IncomeOrBalance::"Income Statement":
                GLAccount.Validate("Income/Balance", GLAccount."Income/Balance"::"Income Statement");
            IncomeOrBalance::"Balance Sheet":
                GLAccount.Validate("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        end;

        GLAccount.Validate("Account Category", AccountCategory);
        GLAccount.Validate("Account Type", AccountType);

        GLAccount.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        GLAccount.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            if GenProdPostingGroup <> '' then
                GLAccount.Validate("Tax Group Code", TaxGroup);

        if Exists then
            GLAccount.Modify(true)
        else
            GLAccount.Insert(true);
    end;

    procedure InsertGLAccount(AccountNo: Code[20]; Name: Text[100]; IncomeOrBalance: Enum "G/L Account Income/Balance"; AccountCategory: Enum "G/L Account Category"; AccountType: Enum "G/L Account Type")
    begin
        InsertGLAccount(AccountNo, Name, IncomeOrBalance, AccountCategory, AccountType, '', '', '');
    end;
}
