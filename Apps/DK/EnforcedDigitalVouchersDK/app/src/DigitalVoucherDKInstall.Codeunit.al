// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;

codeunit 13645 "Digital Voucher DK Install."
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if (AppInfo.DataVersion() <> Version.Create('0.0.0.0')) then
            exit;

        SetupFeature();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        SetupFeature();
    end;

    local procedure SetupFeature()
    var
        DigitalVouchersEntrySetup: Record "Digital Voucher Entry Setup";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        InsertDigitalVoucherSetup(DigitalVouchersEntrySetup."Entry Type"::"Sales Document", DigitalVouchersEntrySetup."Check Type"::Attachment, true);
        InsertDigitalVoucherSetup(DigitalVouchersEntrySetup."Entry Type"::"Sales Journal", DigitalVouchersEntrySetup."Check Type"::"No Check", false);
        InsertDigitalVoucherSetup(DigitalVouchersEntrySetup."Entry Type"::"Purchase Document", DigitalVouchersEntrySetup."Check Type"::Attachment, false);
        InsertDigitalVoucherSetup(DigitalVouchersEntrySetup."Entry Type"::"Purchase Journal", DigitalVouchersEntrySetup."Check Type"::Attachment, false);
        InsertDigitalVoucherSetup(DigitalVouchersEntrySetup."Entry Type"::"General Journal", DigitalVouchersEntrySetup."Check Type"::"No Check", false);
        if not SourceCodeSetup.Get() then
            exit;
        InsertDigitalVoucherEntrySourceCode(DigitalVouchersEntrySetup."Entry Type"::"Sales Document", SourceCodeSetup.Sales);
        InsertDigitalVoucherEntrySourceCode(DigitalVouchersEntrySetup."Entry Type"::"Sales Document", SourceCodeSetup."Sales Deferral");
        InsertDigitalVoucherEntrySourceCode(DigitalVouchersEntrySetup."Entry Type"::"Sales Journal", SourceCodeSetup."Sales Journal");
        InsertDigitalVoucherEntrySourceCode(DigitalVouchersEntrySetup."Entry Type"::"Purchase Document", SourceCodeSetup.Purchases);
        InsertDigitalVoucherEntrySourceCode(DigitalVouchersEntrySetup."Entry Type"::"Purchase Document", SourceCodeSetup."Purchase Deferral");
        InsertDigitalVoucherEntrySourceCode(DigitalVouchersEntrySetup."Entry Type"::"Purchase Journal", SourceCodeSetup."Purchase Journal");
    end;

    local procedure InsertDigitalVoucherSetup(EntryType: Enum "Digital Voucher Entry Type"; CheckType: Enum "Digital Voucher Check Type"; GenerateAutomatically: Boolean)
    var
        DigitalVouchersEntrySetup: Record "Digital Voucher Entry Setup";
    begin
        DigitalVouchersEntrySetup."Entry Type" := EntryType;
        DigitalVouchersEntrySetup."Check Type" := CheckType;
        DigitalVouchersEntrySetup."Generate Automatically" := GenerateAutomatically;
        DigitalVouchersEntrySetup.Insert();
    end;

    local procedure InsertDigitalVoucherEntrySourceCode(EntryType: Enum "Digital Voucher Entry Type"; SourceCode: Code[10])
    var
        VoucherSourceCode: Record "Voucher Entry Source Code";
    begin
        if SourceCode = '' then
            exit;
        VoucherSourceCode.Validate("Entry Type", EntryType);
        VoucherSourceCode.Validate("Source Code", SourceCode);
        VoucherSourceCode.Insert(true);
    end;
}
