// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 10037 "IRS 1099 Vendor Form Box"
{
    Access = Internal;

    procedure SuggestVendorsForFormBoxSetup(PeriodNo: Code[20])
    var
        IRS1099SuggestVendorsReport: Report "IRS 1099 Suggest Vendors";
    begin
        IRS1099SuggestVendorsReport.InitializeRequest(PeriodNo);
        IRS1099SuggestVendorsReport.Run();
    end;

    procedure PropagateVendorFormBoxSetupToExistingEntries(IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup")
    var
        IRS1099PropagateVendorSetup: Report "IRS 1099 Propagate Vend. Setup";
    begin
        IRS1099VendorFormBoxSetup.SetRecFilter();
        IRS1099PropagateVendorSetup.SetTableView(IRS1099VendorFormBoxSetup);
        IRS1099PropagateVendorSetup.Run();
    end;

    procedure PropagateVendorsFormBoxSetupToExistingEntries(var IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup")
    var
        IRS1099PropagateVendorSetup: Report "IRS 1099 Propagate Vend. Setup";
    begin
        IRS1099PropagateVendorSetup.SetTableView(IRS1099VendorFormBoxSetup);
        IRS1099PropagateVendorSetup.Run();
    end;
}
