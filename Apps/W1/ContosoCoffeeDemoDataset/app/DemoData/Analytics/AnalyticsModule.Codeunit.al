// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Analytics;

using Microsoft.DemoTool;

codeunit 5687 "Analytics Module" implements "Contoso Demo Data Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    begin
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Foundation);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Finance);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::CRM);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Bank);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Inventory);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Sales);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Purchase);
    end;

    procedure CreateSetupData()
    begin
    end;

    procedure CreateMasterData()
    begin
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(Codeunit::"Create Extended Sales Document");
        Codeunit.Run(Codeunit::"Create Extended Purch Document");
    end;

    procedure CreateHistoricalData()
    begin
        Codeunit.Run(Codeunit::"Create Posted Analytics Data");
    end;
}
