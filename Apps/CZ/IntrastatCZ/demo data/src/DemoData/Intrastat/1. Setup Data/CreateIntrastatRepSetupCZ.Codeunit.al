// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.DemoData.Localization;

codeunit 31497 "Create Intrastat Rep. Setup CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateIntrastatReportSetup();
    end;

    procedure UpdateIntrastatReportSetup()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        IntrastatReportManagement: Codeunit IntrastatReportManagement;
        CreateTransactionTypeCZ: Codeunit "Create Transaction Type CZ";
    begin
        IntrastatReportManagement.InitSetup(IntrastatReportSetup);

        IntrastatReportSetup.Validate("Default Trans. - Purchase", CreateTransactionTypeCZ.Type11());
        IntrastatReportSetup.Validate("Default Trans. - Return", CreateTransactionTypeCZ.Type21());
        IntrastatReportSetup.Modify(true);
    end;
}
