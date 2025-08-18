// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Intrastat;

using Microsoft.Inventory.Intrastat;

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

        IntrastatReportSetup.Validate("Default Trans. - Purchase", CreateTransactionTypeCZ.No11());
        IntrastatReportSetup.Validate("Default Trans. - Return", CreateTransactionTypeCZ.No21());
        IntrastatReportSetup.Modify(true);
    end;
}
