// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoTool;
using Microsoft.Inventory.Intrastat;

codeunit 31488 "Contoso Demo Tool Handler CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure GenerateDemoDataCZOnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                FoundationModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::"Intrastat Contoso Module":
                IntrastatModule(ContosoDemoDataLevel);
        end;
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Shipping Data CZ");
        end;
    end;

    local procedure IntrastatModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
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
