// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.DemoTool;

codeunit 4844 "Intrastat Contoso Module" implements "Contoso Demo Data Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    var
        ContosoDemoTool: Codeunit "Contoso Demo Tool";
    begin
        Message(ContosoDemoTool.GetNoConfiguirationMsg());
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Foundation);
    end;

    procedure CreateSetupData()
    begin
        Codeunit.Run(Codeunit::"Create Intrastat No. Series");
        Codeunit.Run(Codeunit::"Create Intrastat Report Setup");
    end;

    procedure CreateMasterData()
    begin
    end;

    procedure CreateTransactionalData()
    begin
    end;

    procedure CreateHistoricalData()
    begin
    end;
}
