// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Vendor;

codeunit 31413 "Calculate Vendor Stats. CZZ"
{
    trigger OnRun()
    var
        Vendor: record Vendor;
        Params: Dictionary of [Text, Text];
        Results: Dictionary of [Text, Text];
        VendorNo: Code[20];
    begin
        Params := Page.GetBackgroundParameters();
        VendorNo := CopyStr(Params.Get(GetVendorNoLabel()), 1, MaxStrLen(VendorNo));
        if not Vendor.Get(VendorNo) then
            exit;

        Results.Add(GetAdvancesLabel(), Format(Vendor.GetPurchaseAdvancesCountCZZ()));

        Page.SetBackgroundTaskResult(Results);
    end;

    var
        VendorNoLbl: label 'Vendor No.', Locked = true;
        LastAdvancesLbl: label 'Advances', Locked = true;

    internal procedure GetVendorNoLabel(): Text
    begin
        exit(VendorNoLbl);
    end;

    internal procedure GetAdvancesLabel(): Text
    begin
        exit(LastAdvancesLbl);
    end;
}
