// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoTool;
using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Bank;
using Microsoft.DemoData.Sales;
using Microsoft.DemoData.FixedAsset;
using Microsoft.DemoData.Inventory;
using Microsoft.DemoData.Purchases;
using Microsoft.DemoData.HumanResources;

codeunit 31215 "Contoso CZ Localization"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure GenerateDemoDataCZOnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        BindSubscriptions(Module, ContosoDemoDataLevel);

        case Module of
            Enum::"Contoso Demo Data Module"::Finance:
                FinanceModuleBefore(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Inventory:
                InventoryModuleBefore(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::"Common Module":
                CommonModuleBefore(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Bank:
                BankModuleBefore(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::"Manufacturing Module":
                ManufacturingModuleBefore(ContosoDemoDataLevel);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure GenerateDemoDataCZOnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                FoundationModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Finance:
                FinanceModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Inventory:
                InventoryModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Bank:
                BankModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Purchase:
                PurchaseModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Sales:
                SalesModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                FixedAssetModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::"Common Module":
                CommonModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                HumanResourcesModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::"Manufacturing Module":
                ManufacturingModule(ContosoDemoDataLevel);
        end;

        UnbindSubscriptions(Module, ContosoDemoDataLevel);
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateStatRepSetupCZ: Codeunit "Create Stat. Rep. Setup CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Reason Code CZ");
                    Codeunit.Run(Codeunit::"Create No. Series CZ");
                    Codeunit.Run(Codeunit::"Create Post Code CZ");
                    Codeunit.Run(Codeunit::"Create Custom Report Layout CZ");
                    CreateStatRepSetupCZ.CreateSetupStatutoryReportingSetup();
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Company Information CZ");
                    Codeunit.Run(Codeunit::"Create Stat. Rep. Setup CZ");
                    Codeunit.Run(Codeunit::"Create Document Footer CZ");
                end;
        end;
    end;

    local procedure FinanceModuleBefore(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateCZGLAccounts: Codeunit "Create CZ GL Accounts";
        CreateNoSeriesCZ: Codeunit "Create No. Series CZ";
        CreateVatPostingGroupsCZ: Codeunit "Create Vat Posting Groups CZ";
    begin
        BindSubscription(CreateCZGLAccounts); // due to g/l account categories

        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create VAT Posting Groups CZ");
                    Codeunit.Run(Codeunit::"Create Posting Groups CZ");
                    CreateNoSeriesCZ.CreateDummyNoSeries();
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                CreateVatPostingGroupsCZ.CreateDummyVATProductPostingGroup();
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateCurrencyExRateCZ: Codeunit "Create Currency Ex. Rate CZ";
        CreateCZGLAccounts: Codeunit "Create CZ GL Accounts";
        CreateNoSeriesCZ: Codeunit "Create No. Series CZ";
        CreatePostingGroupsCZ: Codeunit "Create Posting Groups CZ";
        CreateVatPostingGroupsCZ: Codeunit "Create Vat Posting Groups CZ";
        CreateStatRepSetupCZ: Codeunit "Create Stat. Rep. Setup CZ";
    begin
        UnbindSubscription(CreateCZGLAccounts);

        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create General Ledger Setup CZ");
                    CreateVatPostingGroupsCZ.InsertVATPostingSetupWithoutGLAccounts();
                    CreatePostingGroupsCZ.InsertGenPostingSetupWithoutGLAccounts();
                    Codeunit.Run(Codeunit::"Create G/L Account CZ");
                    CreateVatPostingGroupsCZ.UpdateVATPostingSetup();
                    CreateVatPostingGroupsCZ.DeleteVATProductPostingGroups();
                    CreateVatPostingGroupsCZ.DeleteVATClauses();
                    CreatePostingGroupsCZ.UpdateGenPostingSetup();
                    CreatePostingGroupsCZ.DeleteGenProductPostingGroups();
                    Codeunit.Run(Codeunit::"Create Currency CZ");
                    Codeunit.Run(Codeunit::"Create Gen. Jnl. Template CZ");
                    Codeunit.Run(Codeunit::"Create Gen. Jnl. Batch CZ");
                    Codeunit.Run(Codeunit::"Create Commodity CZ");
                    Codeunit.Run(Codeunit::"Create VAT Report Setup CZ");
                    Codeunit.Run(Codeunit::"Create VAT Statement CZ");
                    Codeunit.Run(Codeunit::"Create Acc. Schedule Name CZ");
                    Codeunit.Run(Codeunit::"Create Acc. Schedule Line CZ");
                    Codeunit.Run(Codeunit::"Create Column Layout Name CZ");
                    Codeunit.Run(Codeunit::"Create Column Layout CZ");
                    Codeunit.Run(Codeunit::"Create Financial Report CZ");
                    CreateNoSeriesCZ.DeleteNoSeries();
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create VAT Period CZ");
                    Codeunit.Run(Codeunit::"Create VAT Return Period CZ");
                    CreateStatRepSetupCZ.CreateFinanceStatutoryReportingSetup();
                    CreateVatPostingGroupsCZ.DeleteVATProductPostingGroups();
                    Codeunit.Run(Codeunit::"Create Currency Ex. Rate CZ");
                    CreateCurrencyExRateCZ.DeleteLocalCurrencyExchangeRate();
                end;
        end;
    end;

    local procedure InventoryModuleBefore(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVatPostingGroupsCZ: Codeunit "Create Vat Posting Groups CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                CreateVatPostingGroupsCZ.CreateDummyVATProductPostingGroup();
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVatPostingGroupsCZ: Codeunit "Create Vat Posting Groups CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Invt. Mvmt. Templ. CZ");
                    Codeunit.Run(Codeunit::"Create Inventory Setup CZ");
                    Codeunit.Run(Codeunit::"Create Assembly Setup CZ");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Item Template CZ");
                    CreateVatPostingGroupsCZ.DeleteVATProductPostingGroups();
                end;
        end;
    end;

    local procedure BankModuleBefore(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateBankAccountCZ: Codeunit "Create Bank Account CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Transactional Data",
            Enum::"Contoso Demo Data Level"::"Historical Data":
                CreateBankAccountCZ.CreateDummyBankAccount();
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateBankAccountCZ: Codeunit "Create Bank Account CZ";
        CreateBankAccPostGrpCZ: Codeunit "Create Bank Acc. Post. Grp CZ";
        CreateCompanyInformationCZ: Codeunit "Create Company Information CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    CreateBankAccPostGrpCZ.DeleteBankAccountPostingGroups();
                    Codeunit.Run(Codeunit::"Create Bank Acc. Post. Grp CZ");
                    Codeunit.Run(Codeunit::"Create Payment Method CZ");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Bank Account CZ");
                    CreateCompanyInformationCZ.UpdateDefaultBankAccountCode();
                end;
            Enum::"Contoso Demo Data Level"::"Transactional Data",
            Enum::"Contoso Demo Data Level"::"Historical Data":
                CreateBankAccountCZ.DeleteBankAccounts();
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Purch. Payable Setup CZ");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Vendor CZ");
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Customer CZ");
        end;
    end;

    local procedure FixedAssetModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create FA Posting Group CZ");
                    Codeunit.Run(Codeunit::"Create Depreciation Book CZ");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create FA Depreciation Book CZ");
        end;
    end;

    local procedure CommonModuleBefore(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVatPostingGroupsCZ: Codeunit "Create Vat Posting Groups CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                CreateVatPostingGroupsCZ.CreateDummyVATProductPostingGroup();
        end;
    end;

    local procedure CommonModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVatPostingGroupsCZ: Codeunit "Create Vat Posting Groups CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                CreateVatPostingGroupsCZ.DeleteVATProductPostingGroups();
        end;
    end;

    local procedure HumanResourcesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateStatRepSetupCZ: Codeunit "Create Stat. Rep. Setup CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Company Official CZ");
                    CreateStatRepSetupCZ.CreateHRStatutoryReportingSetup();
                end;
        end;
    end;

    local procedure ManufacturingModuleBefore(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVatPostingGroupsCZ: Codeunit "Create Vat Posting Groups CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                CreateVatPostingGroupsCZ.CreateDummyVATProductPostingGroup();
        end;
    end;

    local procedure ManufacturingModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVatPostingGroupsCZ: Codeunit "Create Vat Posting Groups CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                CreateVatPostingGroupsCZ.DeleteVATProductPostingGroups();
        end;
    end;

    local procedure BindSubscriptions(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateBankAccRecCZ: Codeunit "Create Bank Acc. Rec. CZ";
        CreateCurrencyExRateCZ: Codeunit "Create Currency Ex. Rate CZ";
        CreateCustomerCZ: Codeunit "Create Customer CZ";
        CreateCustPostingGroupCZ: Codeunit "Create Cust. Posting Group CZ";
        CreateCZGLAccounts: Codeunit "Create CZ GL Accounts";
        CreateFAPostingGroupCZ: Codeunit "Create FA Posting Group CZ";
        CreateGenJnlTemplateCZ: Codeunit "Create Gen. Jnl. Template CZ";
        CreateGenJournalLineCZ: Codeunit "Create Gen. Journal Line CZ";
        CreateInvtPostingSetupCZ: Codeunit "Create Invt. Posting Setup CZ";
        CreateItemCZ: Codeunit "Create Item CZ";
        CreateItemChargeCZ: Codeunit "Create Item Charge CZ";
        CreatePostingGroupsCZ: Codeunit "Create Posting Groups CZ";
        CreatePurchaseDocumentCZ: Codeunit "Create Purchase Document CZ";
        CreateResourceCZ: Codeunit "Create Resource CZ";
        CreateVATPostingGroupsCZ: Codeunit "Create VAT Posting Groups CZ";
        CreateVATStatementCZ: Codeunit "Create VAT Statement CZ";
        CreateVendorCZ: Codeunit "Create Vendor CZ";
        CreateVendorPostingGroupCZ: Codeunit "Create Vendor Posting Group CZ";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateGenJnlTemplateCZ);
                    BindSubscription(CreateVATPostingGroupsCZ);
                    BindSubscription(CreatePostingGroupsCZ);
                    BindSubscription(CreateResourceCZ);
                    BindSubscription(CreateCurrencyExRateCZ);
                    BindSubscription(CreateVATStatementCZ);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateItemCZ);
                    BindSubscription(CreateInvtPostingSetupCZ);
                    BindSubscription(CreateItemChargeCZ);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreateBankAccRecCZ);
                    BindSubscription(CreateGenJournalLineCZ);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateVendorPostingGroupCZ);
                    BindSubscription(CreateVendorCZ);
                    if ContosoDemoDataLevel = Enum::"Contoso Demo Data Level"::"Transactional Data" then
                        BindSubscription(CreatePurchaseDocumentCZ);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateCustPostingGroupCZ);
                    BindSubscription(CreateCustomerCZ);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    BindSubscription(CreateFAPostingGroupCZ);
                    BindSubscription(CreateCZGLAccounts);
                end;
            Enum::"Contoso Demo Data Module"::"Common Module":
                begin
                    BindSubscription(CreateVATPostingGroupsCZ);
                    BindSubscription(CreateCZGLAccounts);
                end;
            Enum::"Contoso Demo Data Module"::"Service Module":
                BindSubscription(CreateCZGLAccounts);
            Enum::"Contoso Demo Data Module"::"Manufacturing Module":
                begin
                    BindSubscription(CreateCZGLAccounts);
                    BindSubscription(CreateInvtPostingSetupCZ);
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                BindSubscription(CreateCZGLAccounts);
            Enum::"Contoso Demo Data Module"::"Job Module":
                BindSubscription(CreateCZGLAccounts);
        end;
    end;

    local procedure UnbindSubscriptions(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateBankAccRecCZ: Codeunit "Create Bank Acc. Rec. CZ";
        CreateCurrencyExRateCZ: Codeunit "Create Currency Ex. Rate CZ";
        CreateCustomerCZ: Codeunit "Create Customer CZ";
        CreateCustPostingGroupCZ: Codeunit "Create Cust. Posting Group CZ";
        CreateCZGLAccounts: Codeunit "Create CZ GL Accounts";
        CreateFAPostingGroupCZ: Codeunit "Create FA Posting Group CZ";
        CreateGenJnlTemplateCZ: Codeunit "Create Gen. Jnl. Template CZ";
        CreateGenJournalLineCZ: Codeunit "Create Gen. Journal Line CZ";
        CreateInvtPostingSetupCZ: Codeunit "Create Invt. Posting Setup CZ";
        CreateItemCZ: Codeunit "Create Item CZ";
        CreateItemChargeCZ: Codeunit "Create Item Charge CZ";
        CreatePostingGroupsCZ: Codeunit "Create Posting Groups CZ";
        CreatePurchaseDocumentCZ: Codeunit "Create Purchase Document CZ";
        CreateResourceCZ: Codeunit "Create Resource CZ";
        CreateVATPostingGroupsCZ: Codeunit "Create VAT Posting Groups CZ";
        CreateVATStatementCZ: Codeunit "Create VAT Statement CZ";
        CreateVendorCZ: Codeunit "Create Vendor CZ";
        CreateVendorPostingGroupCZ: Codeunit "Create Vendor Posting Group CZ";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnbindSubscription(CreateGenJnlTemplateCZ);
                    UnbindSubscription(CreateVATPostingGroupsCZ);
                    UnbindSubscription(CreatePostingGroupsCZ);
                    UnbindSubscription(CreateResourceCZ);
                    UnbindSubscription(CreateCurrencyExRateCZ);
                    UnbindSubscription(CreateVATStatementCZ);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateItemCZ);
                    UnbindSubscription(CreateInvtPostingSetupCZ);
                    UnbindSubscription(CreateItemChargeCZ);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnbindSubscription(CreateBankAccRecCZ);
                    UnbindSubscription(CreateGenJournalLineCZ);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreateVendorPostingGroupCZ);
                    UnbindSubscription(CreateVendorCZ);
                    if ContosoDemoDataLevel = Enum::"Contoso Demo Data Level"::"Transactional Data" then
                        UnbindSubscription(CreatePurchaseDocumentCZ);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateCustPostingGroupCZ);
                    UnbindSubscription(CreateCustomerCZ);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    UnbindSubscription(CreateFAPostingGroupCZ);
                    UnbindSubscription(CreateCZGLAccounts);
                end;
            Enum::"Contoso Demo Data Module"::"Common Module":
                begin
                    UnbindSubscription(CreateVATPostingGroupsCZ);
                    UnbindSubscription(CreateCZGLAccounts);
                end;
            Enum::"Contoso Demo Data Module"::"Service Module":
                UnbindSubscription(CreateCZGLAccounts);
            Enum::"Contoso Demo Data Module"::"Manufacturing Module":
                begin
                    UnbindSubscription(CreateCZGLAccounts);
                    UnbindSubscription(CreateInvtPostingSetupCZ);
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                UnbindSubscription(CreateCZGLAccounts);
            Enum::"Contoso Demo Data Module"::"Job Module":
                UnbindSubscription(CreateCZGLAccounts);
        end;
    end;
}
