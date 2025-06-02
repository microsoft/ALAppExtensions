// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.BankDocuments;

using Microsoft.DemoTool;

codeunit 31428 "Bank. Doc. Contoso Module CZB" implements "Contoso Demo Data Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    begin
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Foundation);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Bank);
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
        Codeunit.Run(Codeunit::"Create Bank Statement CZB");
        Codeunit.Run(Codeunit::"Create Payment Order CZB");
    end;

    procedure CreateHistoricalData()
    var
        CreateBankStatementCZB: Codeunit "Create Bank Statement CZB";
        CreatePaymentOrderCZB: Codeunit "Create Payment Order CZB";
    begin
        CreateBankStatementCZB.IssueBankStatements();
        CreatePaymentOrderCZB.IssueBankStatements();
    end;
}
