namespace Microsoft.Bank.StatementImport.Yodlee;

using System.Upgrade;
using Microsoft.Bank.BankAccount;

codeunit 1452 "MS - Yodlee Service Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerDatabase();
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if AppInfo.DataVersion().Major() = 1 then
            NAVAPP.LOADPACKAGEDATA(DATABASE::"MS - Yodlee Data Exchange Def");
    end;

    trigger OnUpgradePerCompany();
    begin
        CleanupYodleeBankAccountLink();
        UpdateDataExchangeDefinition();
        UpdateYodleeBankSession();
    end;

    procedure UpdateDataExchangeDefinition();
    var
        MSYodleeDataExchangeDef: Record "MS - Yodlee Data Exchange Def";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetYodleeUpdateDataExchangeDefinitionTag()) then
            exit;

        MSYodleeDataExchangeDef.ResetDataExchToDefault();

        if MSYodleeBankServiceSetup.GET() then
            if MSYodleeBankServiceSetup."Bank Feed Import Format" = '' then
                MSYodleeDataExchangeDef.UpdateMSYodleeBankServiceSetupBankStmtImportFormat();

        UpgradeTag.SetUpgradeTag(GetYodleeUpdateDataExchangeDefinitionTag());
    end;

    local procedure CleanupYodleeBankAccountLink();
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        BankAccount: Record "Bank Account";
    begin
        if MSYodleeBankAccLink.FIND('-') then
            repeat
                if not BankAccount.GET(MSYodleeBankAccLink."No.") then
                    MSYodleeBankAccLink.DELETE()
                else
                    if (BankAccount."Currency Code" <> '') and (MSYodleeBankAccLink."Currency Code" <> '') and (BankAccount."Currency Code" <> MSYodleeBankAccLink."Currency Code") then
                        MSYodleeBankAccLink.DELETE();
            until MSYodleeBankAccLink.NEXT() = 0;
    end;

    procedure UpdateYodleeBankSession();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeBankSession: Record "MS - Yodlee Bank Session";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetYodleeUpdateBankSessionTableTag()) then
            exit;

        if MSYodleeBankSession.GET() then
            exit;

        if not MSYodleeBankServiceSetup.GET() then
            exit;

        MSYodleeBankSession.INIT();
        MSYodleeBankSession.TRANSFERFIELDS(MSYodleeBankServiceSetup);
        MSYodleeBankSession.INSERT();

        UpgradeTag.SetUpgradeTag(GetYodleeUpdateBankSessionTableTag());
    end;

    internal procedure GetYodleeUpdateBankSessionTableTag(): Code[250]
    begin
        exit('YodleeUpdateBankSession-20200221');
    end;

    internal procedure GetYodleeUpdateDataExchangeDefinitionTag(): Code[250]
    begin
        exit('YodleeUpdateDataExchangeDefinition-20200221');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyags(var PerCompanyUpgradeTags: List of [Code[250]])
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTag.HasUpgradeTag(GetYodleeUpdateBankSessionTableTag()) then
            PerCompanyUpgradeTags.Add(GetYodleeUpdateBankSessionTableTag());

        if not UpgradeTag.HasUpgradeTag(GetYodleeUpdateDataExchangeDefinitionTag()) then
            PerCompanyUpgradeTags.Add(GetYodleeUpdateDataExchangeDefinitionTag());
    end;
}

