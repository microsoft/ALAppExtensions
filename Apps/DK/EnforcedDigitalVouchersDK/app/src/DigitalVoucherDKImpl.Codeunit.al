// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

codeunit 13621 "Digital Voucher DK Impl."
{
    Access = Internal;

    var
        NotAllowedToChangeWhenEnforcedErr: Label 'You are not allowed to change make this change when the feature is enforced.';

    [EventSubscriber(ObjectType::Table, Database::"Digital Voucher Entry Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure CheckDigitalVoucherEntrySetupOnBeforeModify(var Rec: Record "Digital Voucher Entry Setup"; var xRec: Record "Digital Voucher Entry Setup"; RunTrigger: Boolean)
    begin
        if not CheckSetupForEntryTypesForbiddenFromChangeIsRequired(Rec) then
            exit;
        if not IsEntryTypeForbiddenForChange(Rec."Entry Type") then
            exit;
        if Rec."Check Type" <> xRec."Check Type" then
            error(NotAllowedToChangeWhenEnforcedErr);
        if Rec."Entry Type" in [Rec."Entry Type"::"Purchase Document", Rec."Entry Type"::"Purchase Journal"] then
            Error(NotAllowedToChangeWhenEnforcedErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Digital Voucher Entry Setup", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckDigitalVoucherEntrySetupOnBeforeDelete(var Rec: Record "Digital Voucher Entry Setup"; RunTrigger: Boolean)
    begin
        if not CheckSetupForEntryTypesForbiddenFromChangeIsRequired(Rec) then
            exit;
        CheckSetupForEntryTypesForbiddenFromChange(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Digital Voucher Entry Setup", 'OnBeforeRenameEvent', '', false, false)]
    local procedure CheckDigitalVoucherEntrySetupOnBeforeRename(var Rec: Record "Digital Voucher Entry Setup"; var xRec: Record "Digital Voucher Entry Setup"; RunTrigger: Boolean)
    begin
        if not CheckSetupForEntryTypesForbiddenFromChangeIsRequired(Rec) then
            exit;
        CheckSetupForEntryTypesForbiddenFromChange(Rec);
    end;

    local procedure CheckSetupForEntryTypesForbiddenFromChange(Rec: Record "Digital Voucher Entry Setup")
    begin
        if IsEntryTypeForbiddenForChange(Rec."Entry Type") then
            error(NotAllowedToChangeWhenEnforcedErr);
    end;

    local procedure IsEntryTypeForbiddenForChange(EntryType: Enum "Digital Voucher Entry Type"): Boolean
    begin
        exit(EntryType in [EntryType::"Sales Document", EntryType::"Purchase Document", EntryType::"Purchase Journal"]);
    end;

    local procedure CheckSetupForEntryTypesForbiddenFromChangeIsRequired(Rec: Record "Digital Voucher Entry Setup"): Boolean
    var
        DigitalVoucherFeature: Codeunit "Digital Voucher Feature";
    begin
        if Rec.IsTemporary then
            exit(false);
        exit(DigitalVoucherFeature.EnforceDigitalVoucherFunctionality());
    end;
}
