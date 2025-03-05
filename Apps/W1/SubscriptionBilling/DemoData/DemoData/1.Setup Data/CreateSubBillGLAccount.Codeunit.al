namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Account;

codeunit 8108 "Create Sub. Bill. GL Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        GLAccountIndent: Codeunit "G/L Account-Indent";
    begin
        AddGLAccountsForLocalization();

        ContosoGLAccount.InsertGLAccount(CustomerContractsRevenue(), CustomerContractsRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(CustomerContractsDeferrals(), CustomerContractsDeferralsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);

        ContosoGLAccount.InsertGLAccount(VendorContractsCost(), VendorContractsCostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(VendorContractsDeferrals(), VendorContractsDeferralsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);

        GLAccountIndent.Indent();
    end;

    local procedure AddGLAccountsForLocalization()
    begin
        ContosoGLAccount.AddAccountForLocalization(CustomerContractsRevenueName(), '6160');
        ContosoGLAccount.AddAccountForLocalization(CustomerContractsDeferralsName(), '2360');

        ContosoGLAccount.AddAccountForLocalization(VendorContractsCostName(), '7160');
        ContosoGLAccount.AddAccountForLocalization(VendorContractsDeferralsName(), '5460');

        OnAfterAddGLAccountsForLocalization();
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        CustomerContractsRevenueLbl: Label 'Customer Subscription Contracts Revenue', MaxLength = 100;
        CustomerContractsDeferralsLbl: Label 'Customer Subscription Contract Deferrals', MaxLength = 100;
        VendorContractsCostLbl: Label 'Vendor Subscription Contracts Cost', MaxLength = 100;
        VendorContractsDeferralsLbl: Label 'Vendor Subscription Contract Deferrals', MaxLength = 100;

    procedure CustomerContractsRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerContractsRevenueName()));
    end;

    procedure CustomerContractsRevenueName(): Text[100]
    begin
        exit(CustomerContractsRevenueLbl);
    end;

    procedure CustomerContractsDeferrals(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerContractsDeferralsName()));
    end;

    procedure CustomerContractsDeferralsName(): Text[100]
    begin
        exit(CustomerContractsDeferralsLbl);
    end;

    procedure VendorContractsCost(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorContractsCostName()));
    end;

    procedure VendorContractsCostName(): Text[100]
    begin
        exit(VendorContractsCostLbl);
    end;

    procedure VendorContractsDeferrals(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorContractsDeferralsName()));
    end;

    procedure VendorContractsDeferralsName(): Text[100]
    begin
        exit(VendorContractsDeferralsLbl);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddGLAccountsForLocalization()
    begin
    end;
}