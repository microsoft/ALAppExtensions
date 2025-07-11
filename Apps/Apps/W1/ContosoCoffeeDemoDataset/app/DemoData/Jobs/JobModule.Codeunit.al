// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Jobs;

using Microsoft.DemoTool;

codeunit 5187 "Job Module" implements "Contoso Demo Data Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage();
    begin
        Page.Run(Page::"Jobs Module Setup");
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Common Module");
    end;

    procedure CreateSetupData();
    var
        JobModuleSetup: Record "Jobs Module Setup";
    begin
        JobModuleSetup.InitJobModuleDemoDataSetup();
        Codeunit.Run(Codeunit::"Create Job GL Account");
        Codeunit.Run(Codeunit::"Create Job No Series");
        Codeunit.Run(Codeunit::"Create Job Posting Group");
        Codeunit.Run(Codeunit::"Create Job Setup");
        Codeunit.Run(Codeunit::"Create Job Journal Setup");
        Codeunit.Run(Codeunit::"Create Job Item Journal");
    end;

    procedure CreateMasterData();
    begin
        Codeunit.Run(Codeunit::"Create Job Location");
        Codeunit.Run(Codeunit::"Create Job Item");
        Codeunit.Run(Codeunit::"Create Job Resource");
    end;

    procedure CreateTransactionalData();
    begin
        Codeunit.Run(Codeunit::"Create Job");
        Codeunit.Run(Codeunit::"Create Job Item Jnl Lines");
    end;

    procedure CreateHistoricalData();
    begin
        exit;
    end;
}
