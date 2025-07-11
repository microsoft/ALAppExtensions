// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

codeunit 4846 "Create Intrastat Report Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateIntrastatNoSeries: Codeunit "Create Intrastat No. Series";
    begin
        InsertData(CreateIntrastatNoSeries.Intrastat());
    end;

    procedure InsertData(IntrastatNo: Code[20])
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        if not IntrastatReportSetup.Get() then
            IntrastatReportSetup.Insert();

        IntrastatReportSetup.Validate("Intrastat Nos.", IntrastatNo);
        IntrastatReportSetup.Modify(true);
    end;
}
