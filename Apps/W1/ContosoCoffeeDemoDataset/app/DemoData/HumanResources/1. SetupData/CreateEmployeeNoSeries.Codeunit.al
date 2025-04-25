// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.HumanResources;

using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.NoSeries;

codeunit 5177 "Create Employee No Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: Codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(Employee(), EmployeeNoSeriesDescriptionLbl, 'E0010', 'E9990', '', '', 10, Enum::"No. Series Implementation"::Sequence, true);
    end;

    procedure Employee(): Code[20]
    begin
        exit(EmployeeNoSeriesTok);
    end;

    var
        EmployeeNoSeriesTok: Label 'EMP', MaxLength = 20;
        EmployeeNoSeriesDescriptionLbl: Label 'Employee', MaxLength = 100;
}
