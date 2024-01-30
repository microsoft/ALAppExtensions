codeunit 4773 "Create FA GL Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        GLAccountIndent: Codeunit "G/L Account-Indent";
    begin
        AddGLAccountsForLocalization();

        ContosoGLAccount.InsertGLAccount(IncreasesDuringTheYear(), IncreasesDuringTheYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(DecreasesDuringTheYear(), DecreasesDuringTheYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(AccumDepreciationBuildings(), AccumDepreciationBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);

        ContosoGLAccount.InsertGLAccount(Miscellaneous(), MiscellaneousName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting);

        ContosoGLAccount.InsertGLAccount(DepreciationEquipment(), DepreciationEquipmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(GainsAndLosses(), GainsAndLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting);

        GLAccountIndent.Indent();
    end;

    local procedure AddGLAccountsForLocalization()
    begin
        ContosoGLAccount.AddAccountForLocalization(IncreasesDuringTheYearName(), '1220');
        ContosoGLAccount.AddAccountForLocalization(DecreasesDuringTheYearName(), '1230');
        ContosoGLAccount.AddAccountForLocalization(AccumDepreciationBuildingsName(), '1240');

        ContosoGLAccount.AddAccountForLocalization(MiscellaneousName(), '8640');

        ContosoGLAccount.AddAccountForLocalization(DepreciationEquipmentName(), '8820');
        ContosoGLAccount.AddAccountForLocalization(GainsAndLossesName(), '8840');

        OnAfterAddGLAccountsForLocalization();
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        DepreciationEquipmentLbl: Label 'Depreciation, Equipment', MaxLength = 100;
        GainsAndLossesLbl: Label 'Gains and Losses', MaxLength = 100;
        IncreasesDuringTheYearLbl: Label 'Increases during the Year', MaxLength = 100;
        DecreasesDuringTheYearLbl: Label 'Decreases during the Year', MaxLength = 100;
        AccumDepreciationBuildingsLbl: Label 'Accum. Depreciation, Buildings', MaxLength = 100;
        MiscellaneousLbl: Label 'Miscellaneous', MaxLength = 100;

    procedure DepreciationEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationEquipmentName()));
    end;

    procedure DepreciationEquipmentName(): Text[100]
    begin
        exit(DepreciationEquipmentLbl);
    end;

    procedure GainsAndLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainsAndLossesName()));
    end;

    procedure GainsAndLossesName(): Text[100]
    begin
        exit(GainsAndLossesLbl);
    end;

    procedure IncreasesDuringTheYear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncreasesDuringTheYearName()));
    end;

    procedure IncreasesDuringTheYearName(): Text[100]
    begin
        exit(IncreasesDuringTheYearLbl);
    end;

    procedure DecreasesDuringTheYear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesDuringTheYearName()));
    end;

    procedure DecreasesDuringTheYearName(): Text[100]
    begin
        exit(DecreasesDuringTheYearLbl);
    end;

    procedure AccumDepreciationBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepreciationBuildingsName()));
    end;

    procedure AccumDepreciationBuildingsName(): Text[100]
    begin
        exit(AccumDepreciationBuildingsLbl);
    end;

    procedure Miscellaneous(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscellaneousName()));
    end;

    procedure MiscellaneousName(): Text[100]
    begin
        exit(MiscellaneousLbl);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddGLAccountsForLocalization()
    begin
    end;
}