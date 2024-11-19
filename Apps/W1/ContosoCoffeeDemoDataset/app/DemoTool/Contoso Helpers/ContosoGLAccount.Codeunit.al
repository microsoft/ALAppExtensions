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
    begin
        InsertGLAccount(AccountNo, Name, IncomeOrBalance, AccountCategory, '', AccountType, GenBusPostingGroup, GenProdPostingGroup, TaxGroup, 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
    end;

    procedure InsertGLAccount(AccountNo: Code[20]; Name: Text[100]; IncomeOrBalance: Enum "G/L Account Income/Balance"; AccountCategory: Enum "G/L Account Category"; AccountType: Enum "G/L Account Type")
    begin
        InsertGLAccount(AccountNo, Name, IncomeOrBalance, AccountCategory, AccountType, '', '', '');
    end;

    procedure InsertGLAccount(AccountNo: Code[20]; Name: Text[100]; IncomeOrBalance: Enum "G/L Account Income/Balance"; AccountCategory: Enum "G/L Account Category"; AccountType: Enum "G/L Account Type"; GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; NoOfBlankLines: Integer; Totaling: Text[250]; GenPostingType: Enum "General Posting Type"; VATGenPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; DirectPosting: Boolean; ReconciliationAccount: Boolean; NewPage: Boolean)
    begin
        InsertGLAccount(AccountNo, Name, IncomeOrBalance, AccountCategory, '', AccountType, GenBusPostingGroup, GenProdPostingGroup, '', NoOfBlankLines, Totaling, GenPostingType, VATGenPostingGroup, VATProdPostingGroup, DirectPosting, ReconciliationAccount, NewPage);
    end;

    procedure InsertGLAccount(AccountNo: Code[20]; Name: Text[100]; IncomeOrBalance: Enum "G/L Account Income/Balance"; AccountCategory: Enum "G/L Account Category"; AccountSubCategory: Text[80]; AccountType: Enum "G/L Account Type"; GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; NoOfBlankLines: Integer; Totaling: Text[250]; GenPostingType: Enum "General Posting Type"; VATGenPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; DirectPosting: Boolean; ReconciliationAccount: Boolean; NewPage: Boolean)
    begin
        InsertGLAccount(AccountNo, Name, IncomeOrBalance, AccountCategory, AccountSubCategory, AccountType, GenBusPostingGroup, GenProdPostingGroup, '', NoOfBlankLines, Totaling, GenPostingType, VATGenPostingGroup, VATProdPostingGroup, DirectPosting, ReconciliationAccount, NewPage);
    end;

    procedure InsertGLAccount(AccountNo: Code[20]; Name: Text[100]; IncomeOrBalance: Enum "G/L Account Income/Balance"; AccountCategory: Enum "G/L Account Category"; AccountSubCategory: Text[80]; AccountType: Enum "G/L Account Type"; GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; TaxGroup: Code[20]; NoOfBlankLines: Integer; Totaling: Text[250]; GenPostingType: Enum "General Posting Type"; VATGenPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; DirectPosting: Boolean; ReconciliationAccount: Boolean; NewPage: Boolean)
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

        if AccountCategory <> Enum::"G/L Account Category"::" " then begin
            GLAccount.Validate("Account Category", AccountCategory);

            if AccountSubCategory = '' then
                GLAccount.Validate("Account Subcategory Entry No.", 0)
            else
                GLAccount.ValidateAccountSubCategory(AccountSubCategory);
        end else
            GLAccount.Validate("Account Category", Enum::"G/L Account Category"::" ");

        GLAccount.Validate("Account Type", AccountType);
        if GLAccount."Account Type" = GLAccount."Account Type"::Posting then
            GLAccount.Validate("Direct Posting", DirectPosting);

        GLAccount.Validate("No. of Blank Lines", NoOfBlankLines);

        if Totaling <> '' then
            GLAccount.Validate(Totaling, Totaling);
        if GenPostingType <> GenPostingType::" " then
            GLAccount.Validate("Gen. Posting Type", GenPostingType);
        if (VATGenPostingGroup <> '') and (ContosoCoffeeDemoDataSetup."Company Type" <> ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax") then
            GLAccount.Validate("VAT Bus. Posting Group", VATGenPostingGroup);
        if (VATProdPostingGroup <> '') and (ContosoCoffeeDemoDataSetup."Company Type" <> ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax") then
            GLAccount.Validate("VAT Prod. Posting Group", VATProdPostingGroup);

        GLAccount.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        GLAccount.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);
        GLAccount.Validate("Reconciliation Account", ReconciliationAccount);
        GLAccount.Validate("New Page", NewPage);

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            if GenProdPostingGroup <> '' then
                GLAccount.Validate("Tax Group Code", TaxGroup);

        if Exists then
            GLAccount.Modify(true)
        else
            GLAccount.Insert(true);
    end;
}
