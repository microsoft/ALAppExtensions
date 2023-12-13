// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

using Microsoft.Finance.AuditFileExport;

pageextension 10695 "SAF-T Vend. Bank Account Card" extends "Vendor Bank Account Card"
{
    var
        FieldIsMandatory: Boolean;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        SAFTDataCheck: Codeunit "SAF-T Data Check";
    begin
        if FieldIsMandatory then
            exit(SAFTDataCheck.ThrowNotificationIfVendorBankAccountDataMissed(Rec));
        exit(true);
    end;

    trigger OnOpenPage()
    var
        SAFTSetup: Record "SAF-T Setup";
    begin
        if SAFTSetup.Get() then;
        FieldIsMandatory := SAFTSetup."Check Bank Account";
    end;
}
