// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.Intrastat;
using Microsoft.DemoData.Inventory;
using Microsoft.DemoData.Purchases;
using Microsoft.DemoData.Sales;
using Microsoft.DemoTool;

codeunit 31488 "Contoso Demo Tool Handler CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure GenerateDemoDataCZOnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Sales:
                SalesModuleBefore(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Purchase:
                PurchaseModuleBefore(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Inventory:
                InventoryModuleBefore(ContosoDemoDataLevel);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure GenerateDemoDataCZOnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                FoundationModuleAfter(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Sales:
                SalesModuleAfter(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Purchase:
                PurchaseModuleAfter(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Inventory:
                InventoryModuleAfter(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::"Intrastat Contoso Module":
                IntrastatModuleAfter(ContosoDemoDataLevel);
        end;
    end;

    local procedure FoundationModuleAfter(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Shipping Data CZ");
        end;
    end;

    local procedure SalesModuleBefore(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateIntrastatCustomerCZ: Codeunit "Create Intrastat Customer CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                BindSubscription(CreateIntrastatCustomerCZ);
        end;
    end;

    local procedure SalesModuleAfter(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateIntrastatCustomerCZ: Codeunit "Create Intrastat Customer CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                UnbindSubscription(CreateIntrastatCustomerCZ);
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create Sales Document CZ");
        end;
    end;

    local procedure PurchaseModuleBefore(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateIntrastatVendorCZ: Codeunit "Create Intrastat Vendor CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                BindSubscription(CreateIntrastatVendorCZ);
        end;
    end;

    local procedure PurchaseModuleAfter(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateIntrastatVendorCZ: Codeunit "Create Intrastat Vendor CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                UnbindSubscription(CreateIntrastatVendorCZ);
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create Purch. Document CZ");
        end;
    end;

    local procedure InventoryModuleBefore(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateIntrastatItemCZ: Codeunit "Create Intrastat Item CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                BindSubscription(CreateIntrastatItemCZ);
        end;
    end;

    local procedure InventoryModuleAfter(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateIntrastatItemCZ: Codeunit "Create Intrastat Item CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                UnbindSubscription(CreateIntrastatItemCZ);
        end;
    end;

    local procedure IntrastatModuleAfter(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateShippingDataCZ: Codeunit "Create Shipping Data CZ";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Intrastat Del. Group CZ");
                    Codeunit.Run(Codeunit::"Create Tariff Number CZ");
                    Codeunit.Run(Codeunit::"Create Transaction Type CZ");
                    Codeunit.Run(Codeunit::"Create Transport Method CZ");
                    Codeunit.Run(Codeunit::"Create Specific Movement CZ");
                    Codeunit.Run(Codeunit::"Create Statistic Indication CZ");
                    Codeunit.Run(Codeunit::"Create Intrastat Rep. Setup CZ");
                    CreateShippingDataCZ.UpdateShipmentMethod();
                end;
        end;
    end;
}
