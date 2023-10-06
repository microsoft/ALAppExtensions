codeunit 5102 "Create Svc GL Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        GLAccountIndent: Codeunit "G/L Account-Indent";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
    begin
        AddGLAccountsForLocalization();

        ContosoGLAccount.InsertGLAccount(ServiceContractSale(), ServiceContractSaleName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CommonPostingGroup.Domestic(), CommonPostingGroup.Service(), CommonPostingGroup.NonTaxable());

        GLAccountIndent.Indent();
    end;

    local procedure AddGLAccountsForLocalization()
    begin
        ContosoGLAccount.AddAccountForLocalization(ServiceContractSaleName(), '6955');

        OnAfterAddGLAccountsForLocalization();
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        ServiceContractSaleLbl: Label 'Service Contract Sale', MaxLength = 100;

    procedure ServiceContractSale(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServiceContractSaleName()));
    end;

    procedure ServiceContractSaleName(): Text[100]
    begin
        exit(ServiceContractSaleLbl);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddGLAccountsForLocalization()
    begin
    end;
}