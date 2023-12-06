// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

codeunit 13621 "Digital Voucher DK Impl."
{
    Access = Internal;

    var
        NotAllowedToChangeDigitalVoucherEntrySetupErr: Label 'You are not allowed to change the Digital Voucher Entry Setup for this entry type.';

    [EventSubscriber(ObjectType::Table, Database::"Digital Voucher Entry Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure CheckDigitalVoucherEntrySetupOnBeforeModify(var Rec: Record "Digital Voucher Entry Setup"; var xRec: Record "Digital Voucher Entry Setup"; RunTrigger: Boolean)
    begin
        if not CheckSetupForEntryTypesForbiddenFromChangeIsRequired(Rec) then
            exit;
        CheckSetupForEntryTypesForbiddenFromChange(Rec);
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
        if Rec."Entry Type" in [Rec."Entry Type"::"Sales Document", Rec."Entry Type"::"Purchase Document", Rec."Entry Type"::"Purchase Journal"] then
            error(NotAllowedToChangeDigitalVoucherEntrySetupErr);
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
