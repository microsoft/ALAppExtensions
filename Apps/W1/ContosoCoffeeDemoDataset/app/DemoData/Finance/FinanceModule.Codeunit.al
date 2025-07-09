// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool;
using Microsoft.Finance.FinancialReports;

codeunit 5415 "Finance Module" implements "Contoso Demo Data Module"
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
    var
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateAccScheduleName: Codeunit "Create Acc. Schedule Name";
        CreateAccScheduleLine: Codeunit "Create Acc. Schedule Line";
        CreateColumnLayoutName: Codeunit "Create Column Layout Name";
        CreateColumnLayout: Codeunit "Create Column Layout";
        CreateFinancialReport: Codeunit "Create Financial Report";
    begin
        Codeunit.Run(Codeunit::"Create VAT Posting Groups");
        Codeunit.Run(Codeunit::"Create Posting Groups");
        Codeunit.Run(Codeunit::"Create G/L Account");
        CreatePostingGroups.UpdateGenPostingSetup();
        CreateVATPostingGroups.UpdateVATPostingSetup();
        Codeunit.Run(Codeunit::"Create KPI Web Srv Setup");
        CreateAccScheduleName.CreateSetupAccScheduleName();
        CreateAccScheduleLine.CreateSetupAccScheduleLine();
        CreateColumnLayoutName.CreateSetupColumnLayoutName();
        CreateColumnLayout.CreateSetupColumnLayout();
        Codeunit.Run(Codeunit::"Create KPI Web Srv Line");
        Codeunit.Run(Codeunit::"Create Acc. Schedule Chart");
        Codeunit.Run(Codeunit::"Create Acc. Sched. Chart Line");
        Codeunit.Run(Codeunit::"Create Chart Definition");
        Codeunit.Run(Codeunit::"Create Currency");
        Codeunit.Run(Codeunit::"Create General Ledger Setup");
        Codeunit.Run(Codeunit::"Create Gen. Journal Template");
        Codeunit.Run(Codeunit::"Create Gen. Journal Batch");
        Codeunit.Run(Codeunit::"Create Resources Setup");
        Codeunit.Run(Codeunit::"Create VAT Reg. No. Format");
        Codeunit.Run(Codeunit::"Create VAT Setup Posting Grp.");
        Codeunit.Run(Codeunit::"Create VAT Report Setup");
        Codeunit.Run(Codeunit::"Create VAT Statement");
        Codeunit.Run(Codeunit::"Create Deferral Template");
        CreateFinancialReport.CreateSetupFinancialReport();
    end;

    procedure CreateMasterData()
    begin
        Codeunit.Run(Codeunit::"Create Dimension");
        Codeunit.Run(Codeunit::"Create Dimension Value");
        Codeunit.Run(Codeunit::"Create Analysis View");
        Codeunit.Run(Codeunit::"Create Acc. Schedule Name");
        Codeunit.Run(Codeunit::"Create Acc. Schedule Line");
        Codeunit.Run(Codeunit::"Create Column Layout Name");
        Codeunit.Run(Codeunit::"Create Column Layout");
        Codeunit.Run(Codeunit::"Create Financial Report");
        Codeunit.Run(Codeunit::"Categ. Generate Acc. Schedules");
        Codeunit.Run(Codeunit::"Create Currency Exchange Rate");
        Codeunit.Run(Codeunit::"Create Resource");
    end;

    procedure CreateTransactionalData()
    begin
        exit;
    end;

    procedure CreateHistoricalData()
    begin
        exit;
    end;
}
