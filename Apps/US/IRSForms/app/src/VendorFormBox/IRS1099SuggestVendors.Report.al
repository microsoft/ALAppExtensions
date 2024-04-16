// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;

report 10036 "IRS 1099 Suggest Vendors"
{
    ProcessingOnly = true;
    ApplicationArea = BasicUS;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            trigger OnAfterGetRecord()
            var
                IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
            begin
                IRS1099VendorFormBoxSetup.SetRange("Period No.", PeriodNo);
                IRS1099VendorFormBoxSetup.SetRange("Vendor No.", Vendor."No.");
                if not IRS1099VendorFormBoxSetup.FindFirst() then begin
                    IRS1099VendorFormBoxSetup.Init();
                    IRS1099VendorFormBoxSetup.Validate("Period No.", PeriodNo);
                    IRS1099VendorFormBoxSetup.Validate("Vendor No.", Vendor."No.");
                    IRS1099VendorFormBoxSetup.Insert(true);
                end;
            end;
        }
    }

    var
        PeriodNo: Code[20];

    procedure InitializeRequest(NewPeriodNo: Code[20])
    begin
        PeriodNo := NewPeriodNo;
    end;
}
