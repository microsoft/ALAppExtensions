// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoTool;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Inventory;
using Microsoft.DemoData.Bank;
using Microsoft.DemoData.HumanResources;
using Microsoft.DemoData.Sales;
using Microsoft.DemoData.Purchases;
using Microsoft.DemoData.FixedAsset;
using Microsoft.DemoData.Foundation;

codeunit 13414 "FI Contoso Localization"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGenerateDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreatePurchaseOrderFI: Codeunit "Create Purchase Order FI";
    begin
        if ContosoDemoDataLevel = Enum::"Contoso Demo Data Level"::"Historical Data" then
            CreatePurchaseOrderFI.UpdateInvoiceMessage();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        if Module = Enum::"Contoso Demo Data Module"::Foundation then
            FoundationModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Sales then
            SalesModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Purchase then
            PurchaseModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::"Human Resources Module" then
            HumanResourceModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Finance then
            FinanceModule(ContosoDemoDataLevel);

        UnBindSubscriptionDemoData(Module);
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create No. Series FI");
                    Codeunit.Run(Codeunit::"Create Post Code FI");
                    Codeunit.Run(Codeunit::"Create Job Queue Category FI");
                    Codeunit.Run(Codeunit::"Create Vat Posting Groups FI");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Company Information FI");
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVatPostingGroupFI: Codeunit "Create VAT Posting Groups FI";
        CreateFIGLAccounts: Codeunit "Create FI GL Accounts";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    CreateVatPostingGroupFI.UpdateVATPostingSetup();
                    Codeunit.Run(Codeunit::"Create Posting Groups FI");
                    Codeunit.Run(Codeunit::"Create General Ledger Setup FI");
                    Codeunit.Run(Codeunit::"Create VATSetupPostingGrp. FI");
                    CreateFIGLAccounts.AddCategoriesToGLAccounts();
                end;

            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Currency Ex. Rate FI");
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Sales Recv. Setup FI");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create Sales Document FI");
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Purch. Payable Setup FI");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create Purchase Order FI");
        end;
    end;

    local procedure HumanResourceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Employee FI");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateCountryRegionFI: Codeunit "Create Country Region FI";
        CreateLocationFI: Codeunit "Create Location FI";
        CreateInvPostingSetupFI: Codeunit "Create Inv. Posting Setup FI";
        CreateItemFI: Codeunit "Create Item FI";
        CreateBankAccountFI: Codeunit "Create Bank Account FI";
        CreatePaymentMethodFI: Codeunit "Create Payment Method FI";
        CreateBankAccPostingGrpFI: Codeunit "Create Bank Acc Posting Grp FI";
        CreateEmployeeFI: Codeunit "Create Employee FI";
        CreateCustPostingGroupFI: Codeunit "Create Cust. Posting Group FI";
        CreateReminderLevelFI: Codeunit "Create Reminder Level FI";
        CreateCustomerFI: Codeunit "Create Customer FI";
        CreateSalesDimValueFI: Codeunit "Create Sales Dim Value FI";
        CreateShiptoAddressFI: Codeunit "Create Ship-to Address FI";
        CreateVendorFI: Codeunit "Create Vendor FI";
        CreateVendorPostingGroupFI: Codeunit "Create Vendor Posting Group FI";
        CreatePurchDimValueFI: Codeunit "Create Purch. Dim. Value FI";
        CreateResourceFI: Codeunit "Create Resource FI";
        CreateCurrencyFI: Codeunit "Create Currency FI";
        CreateCurrencyExchRateFI: Codeunit "Create Currency Ex. Rate FI";
        CreateFADepreciationBookFI: Codeunit "Create FA Depreciation Book FI";
        CreateFAPostingGrpFI: Codeunit "Create FA Posting Grp. FI";
        CreatePaymentTermsFI: Codeunit "Create Payment Terms FI";
        CreateAccScheduleLineFI: Codeunit "Create Acc. Schedule Line FI";
        CreateVatPostingGroupsFI: Codeunit "Create Vat Posting Groups FI";
        CreateVATSetupPostingGrpFI: Codeunit "Create VATSetupPostingGrp. FI";
        CreateVATStatementFI: Codeunit "Create VAT Statement FI";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                begin
                    BindSubscription(CreateCountryRegionFI);
                    BindSubscription(CreatePaymentTermsFI);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreatePaymentMethodFI);
                    BindSubscription(CreateBankAccountFI);
                    BindSubscription(CreateBankAccPostingGrpFI);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateInvPostingSetupFI);
                    BindSubscription(CreateItemFI);
                    BindSubscription(CreateLocationFI);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateCustomerFI);
                    BindSubscription(CreateShiptoAddressFI);
                    BindSubscription(CreateSalesDimValueFI);
                    BindSubscription(CreateReminderLevelFI);
                    BindSubscription(CreateCustPostingGroupFI);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateVendorFI);
                    BindSubscription(CreatePurchDimValueFI);
                    BindSubscription(CreateVendorPostingGroupFI);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateCurrencyFI);
                    BindSubscription(CreateCurrencyExchRateFI);
                    BindSubscription(CreateResourceFI);
                    BindSubscription(CreateAccScheduleLineFI);
                    BindSubscription(CreateVatPostingGroupsFI);
                    BindSubscription(CreateVATSetupPostingGrpFI);
                    BindSubscription(CreateVATStatementFI);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    BindSubscription(CreateFADepreciationBookFI);
                    BindSubscription(CreateFAPostingGrpFI);
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                BindSubscription(CreateEmployeeFI);
        end;
    end;

    local procedure UnBindSubscriptionDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateCountryRegionFI: Codeunit "Create Country Region FI";
        CreateLocationFI: Codeunit "Create Location FI";
        CreateInvPostingSetupFI: Codeunit "Create Inv. Posting Setup FI";
        CreateItemFI: Codeunit "Create Item FI";
        CreateBankAccountFI: Codeunit "Create Bank Account FI";
        CreatePaymentMethodFI: Codeunit "Create Payment Method FI";
        CreateBankAccPostingGrpFI: Codeunit "Create Bank Acc Posting Grp FI";
        CreateEmployeeFI: Codeunit "Create Employee FI";
        CreateCustPostingGroupFI: Codeunit "Create Cust. Posting Group FI";
        CreateReminderLevelFI: Codeunit "Create Reminder Level FI";
        CreateCustomerFI: Codeunit "Create Customer FI";
        CreateSalesDimValueFI: Codeunit "Create Sales Dim Value FI";
        CreateShiptoAddressFI: Codeunit "Create Ship-to Address FI";
        CreateVendorFI: Codeunit "Create Vendor FI";
        CreateVendorPostingGroupFI: Codeunit "Create Vendor Posting Group FI";
        CreatePurchDimValueFI: Codeunit "Create Purch. Dim. Value FI";
        CreateResourceFI: Codeunit "Create Resource FI";
        CreateCurrencyFI: Codeunit "Create Currency FI";
        CreateCurrencyExchRateFI: Codeunit "Create Currency Ex. Rate FI";
        CreateFADepreciationBookFI: Codeunit "Create FA Depreciation Book FI";
        CreateFAPostingGrpFI: Codeunit "Create FA Posting Grp. FI";
        CreatePaymentTermsFI: Codeunit "Create Payment Terms FI";
        CreateAccScheduleLineFI: Codeunit "Create Acc. Schedule Line FI";
        CreateVatPostingGroupsFI: Codeunit "Create Vat Posting Groups FI";
        CreateVATSetupPostingGrpFI: Codeunit "Create VATSetupPostingGrp. FI";
        CreateVATStatementFI: Codeunit "Create VAT Statement FI";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                begin
                    UnBindSubscription(CreateCountryRegionFI);
                    UnbindSubscription(CreatePaymentTermsFI);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnBindSubscription(CreatePaymentMethodFI);
                    UnBindSubscription(CreateBankAccountFI);
                    UnBindSubscription(CreateBankAccPostingGrpFI);
                end;

            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnBindSubscription(CreateInvPostingSetupFI);
                    UnBindSubscription(CreateItemFI);
                    UnBindSubscription(CreateLocationFI);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnBindSubscription(CreateCustomerFI);
                    UnBindSubscription(CreateShiptoAddressFI);
                    UnBindSubscription(CreateSalesDimValueFI);
                    UnBindSubscription(CreateReminderLevelFI);
                    UnBindSubscription(CreateCustPostingGroupFI);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnBindSubscription(CreateVendorFI);
                    UnBindSubscription(CreatePurchDimValueFI);
                    UnBindSubscription(CreateVendorPostingGroupFI);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnBindSubscription(CreateCurrencyFI);
                    UnBindSubscription(CreateCurrencyExchRateFI);
                    UnBindSubscription(CreateResourceFI);
                    UnBindSubscription(CreateAccScheduleLineFI);
                    UnBindSubscription(CreateVatPostingGroupsFI);
                    UnBindSubscription(CreateVATSetupPostingGrpFI);
                    UnbindSubscription(CreateVATStatementFI);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    UnBindSubscription(CreateFADepreciationBookFI);
                    UnBindSubscription(CreateFAPostingGrpFI);
                end;

            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                UnBindSubscription(CreateEmployeeFI);
        end;
    end;
}
