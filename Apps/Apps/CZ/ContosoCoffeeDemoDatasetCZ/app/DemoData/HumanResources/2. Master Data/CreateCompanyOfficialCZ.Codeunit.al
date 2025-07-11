// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.HumanResources;

using Microsoft.DemoTool.Helpers;

codeunit 31287 "Create Company Official CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoHumanResourcesCZ: Codeunit "Contoso Human Resources CZ";
    begin
        ContosoHumanResourcesCZ.InsertCompanyOfficial(ManagingDirector(), CreateEmployee.ManagingDirector());
        ContosoHumanResourcesCZ.InsertCompanyOfficial(ProductionManager(), CreateEmployee.ProductionManager());
        ContosoHumanResourcesCZ.InsertCompanyOfficial(Secretary(), CreateEmployee.Secretary());
    end;

    var
        CreateEmployee: Codeunit "Create Employee";

    procedure ManagingDirector(): Code[20]
    begin
        exit(CreateEmployee.ManagingDirector());
    end;

    procedure ProductionManager(): Code[20]
    begin
        exit(CreateEmployee.ProductionManager());
    end;

    procedure Secretary(): Code[20]
    begin
        exit(CreateEmployee.Secretary());
    end;
}
