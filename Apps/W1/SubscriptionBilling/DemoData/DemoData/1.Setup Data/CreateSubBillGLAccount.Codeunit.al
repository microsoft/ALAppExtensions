namespace Microsoft.SubscriptionBilling;

using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Jobs;
using Microsoft.Finance.GeneralLedger.Account;

codeunit 8108 "Create Sub. Bill. GL Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        AddGLAccountsForLocalization();
    end;

    local procedure AddGLAccountsForLocalization()
    begin
        OnAfterAddGLAccountsForLocalization();
    end;

    var
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateJobGLAccount: Codeunit "Create Job GL Account";
        CustomerContractsRevenueLbl: Label 'Customer Subscription Contracts Revenue', MaxLength = 100;
        CustomerContractsDeferralsLbl: Label 'Customer Subscription Contract Deferrals', MaxLength = 100;
        VendorContractsCostLbl: Label 'Vendor Subscription Contracts Cost', MaxLength = 100;
        VendorContractsDeferralsLbl: Label 'Vendor Subscription Contract Deferrals', MaxLength = 100;

    procedure FindGLAccountByName(AccountName: Text[100]): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetRange("Name", AccountName);
        if GLAccount.FindFirst() then
            exit(GLAccount."No.")
        else
            exit('');
    end;

    procedure CustomerContractsRevenue(): Code[20]
    begin
        exit(FindGLAccountByName(CreateGLAccount.JobSalesName()));
    end;

    procedure CustomerContractsRevenueName(): Text[100]
    begin
        exit(CustomerContractsRevenueLbl);
    end;

    procedure CustomerContractsDeferrals(): Code[20]
    begin
        exit(FindGLAccountByName(CreateGLAccount.WIPJobSalesName()));
    end;

    procedure CustomerContractsDeferralsName(): Text[100]
    begin
        exit(CustomerContractsDeferralsLbl);
    end;

    procedure VendorContractsCost(): Code[20]
    begin
        exit(FindGLAccountByName(CreateJobGLAccount.RecognizedCostsName()));
    end;

    procedure VendorContractsCostName(): Text[100]
    begin
        exit(VendorContractsCostLbl);
    end;

    procedure VendorContractsDeferrals(): Code[20]
    begin
        exit(FindGLAccountByName(CreateGLAccount.WIPJobCostsName()));
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