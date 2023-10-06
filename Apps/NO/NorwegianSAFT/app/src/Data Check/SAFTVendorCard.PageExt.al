// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

using Microsoft.Finance.AuditFileExport;

pageextension 10692 "SAF-T Vendor Card" extends "Vendor Card"
{
    layout
    {
        modify(City)
        {
            ShowMandatory = FieldIsMandatory;
        }
        modify("Post Code")
        {
            ShowMandatory = FieldIsMandatory;
        }
    }

    var
        FieldIsMandatory: Boolean;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        SAFTDataCheck: Codeunit "SAF-T Data Check";
    begin
        if FieldIsMandatory then
            exit(SAFTDataCheck.ThrowNotificationIfVendorDataMissed(Rec));
        exit(true);
    end;

    trigger OnOpenPage()
    var
        SAFTSetup: Record "SAF-T Setup";
    begin
        if SAFTSetup.Get() then;
        FieldIsMandatory := SAFTSetup."Check Vendor";
    end;
}
