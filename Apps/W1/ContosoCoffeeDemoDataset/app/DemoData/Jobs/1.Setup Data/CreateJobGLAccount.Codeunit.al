codeunit 5199 "Create Job GL Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        GLAccountIndent: Codeunit "G/L Account-Indent";
    begin
        AddGLAccountsForLocalization();

        ContosoGLAccount.InsertGLAccount(WIPInvoicedSales(), WIPInvoicedSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(WIPJobCosts(), WIPJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);

        ContosoGLAccount.InsertGLAccount(JobSalesApplied(), JobSalesAppliedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(RecognizedSales(), RecognizedSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting);

        ContosoGLAccount.InsertGLAccount(JobCostsApplied(), JobCostsAppliedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(RecognizedCosts(), RecognizedCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);

        GLAccountIndent.Indent();
    end;

    local procedure AddGLAccountsForLocalization()
    begin
        ContosoGLAccount.AddAccountForLocalization(WIPInvoicedSalesName(), '2212');
        ContosoGLAccount.AddAccountForLocalization(WIPJobCostsName(), '2231');

        ContosoGLAccount.AddAccountForLocalization(JobSalesAppliedName(), '6190');
        ContosoGLAccount.AddAccountForLocalization(RecognizedSalesName(), '6620');

        ContosoGLAccount.AddAccountForLocalization(JobCostsAppliedName(), '7180');
        ContosoGLAccount.AddAccountForLocalization(RecognizedCostsName(), '7620');

        OnAfterAddGLAccountsForLocalization();
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        WIPJobCostsTok: Label 'WIP Project Costs', MaxLength = 100;
        JobCostsAppliedTok: Label 'Project Cost Applied', MaxLength = 100;
        WIPInvoicedSalesTok: Label 'Invoiced Project Sales', MaxLength = 100;
        JobSalesAppliedTok: Label 'Project Sales Applied', MaxLength = 100;
        RecognizedCostsTok: Label 'Project Costs', MaxLength = 100;
        RecognizedSalesTok: Label 'Project Sales', MaxLength = 100;


    procedure WIPInvoicedSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPInvoicedSalesName()));
    end;

    procedure WIPInvoicedSalesName(): Text[100]
    begin
        exit(WIPInvoicedSalesTok);
    end;

    procedure WIPJobCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPJobCostsName()));
    end;

    procedure WIPJobCostsName(): Text[100]
    begin
        exit(WIPJobCostsTok);
    end;

    procedure JobSalesApplied(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesAppliedName()));
    end;

    procedure JobSalesAppliedName(): Text[100]
    begin
        exit(JobSalesAppliedTok);
    end;

    procedure RecognizedSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RecognizedSalesName()));
    end;

    procedure RecognizedSalesName(): Text[100]
    begin
        exit(RecognizedSalesTok);
    end;

    procedure JobCostsApplied(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostsAppliedName()));
    end;

    procedure JobCostsAppliedName(): Text[100]
    begin
        exit(JobCostsAppliedTok);
    end;

    procedure RecognizedCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RecognizedCostsName()));
    end;

    procedure RecognizedCostsName(): Text[100]
    begin
        exit(RecognizedCostsTok);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddGLAccountsForLocalization()
    begin
    end;
}