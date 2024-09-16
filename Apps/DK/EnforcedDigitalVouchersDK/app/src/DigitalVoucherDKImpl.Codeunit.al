// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Foundation.AuditCodes;

codeunit 13621 "Digital Voucher DK Impl."
{
    Access = Internal;
    Permissions = tabledata "Digital Voucher Entry Setup" = rim,
                  tabledata "Voucher Entry Source Code" = rim,
                  tabledata "Digital Voucher Setup" = rim;

    var
        NotAllowedToChangeWhenEnforcedErr: Label 'You are not allowed to change make this change when the feature is enforced.';

    [EventSubscriber(ObjectType::Table, Database::"Digital Voucher Entry Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure CheckDigitalVoucherEntrySetupOnBeforeModify(var Rec: Record "Digital Voucher Entry Setup")
    begin
        CheckDigitalVoucherEntrySetupOnModification(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Digital Voucher Entry Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure CheckDigitalVoucherEntrySetupOnBeforeInsert(var Rec: Record "Digital Voucher Entry Setup")
    begin
        CheckDigitalVoucherEntrySetupOnModification(Rec);
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

    [EventSubscriber(ObjectType::Table, Database::"Voucher Entry Source Code", 'OnBeforeModifyEvent', '', false, false)]
    local procedure CheckVoucherSourceCodeOnBeforeModify(var Rec: Record "Voucher Entry Source Code"; xRec: Record "Voucher Entry Source Code")
    begin
        CheckVoucherSourceCodeOnModification(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Voucher Entry Source Code", 'OnBeforeRenameEvent', '', false, false)]
    local procedure CheckVoucherSourceCodeOnBeforeRename(var Rec: Record "Voucher Entry Source Code"; xRec: Record "Voucher Entry Source Code")
    begin
        CheckVoucherSourceCodeOnModification(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Voucher Entry Source Code", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckVoucherSourceCodeOnBeforeDelete(var Rec: Record "Voucher Entry Source Code")
    var
        DigitalVoucherFeature: Codeunit "Digital Voucher Feature";
    begin
        if Rec.IsTemporary then
            exit;
        if not DigitalVoucherFeature.EnforceDigitalVoucherFunctionality() then
            exit;
        if Rec."Entry Type" in [Rec."Entry Type"::"Purchase Journal", Rec."Entry Type"::"Sales Journal"] then
            Error(NotAllowedToChangeWhenEnforcedErr);
    end;

    local procedure CheckDigitalVoucherEntrySetupOnModification(Rec: Record "Digital Voucher Entry Setup")
    begin
        if not CheckSetupForEntryTypesForbiddenFromChangeIsRequired(Rec) then
            exit;
        if not IsEntryTypeForbiddenForChange(Rec."Entry Type") then
            exit;
        if Rec."Check Type" <> Rec."Check Type"::Attachment then
            error(NotAllowedToChangeWhenEnforcedErr);
        if (Rec."Entry Type" in [Rec."Entry Type"::"Purchase Document", Rec."Entry Type"::"Purchase Journal"]) and Rec."Generate Automatically" then
            error(NotAllowedToChangeWhenEnforcedErr);
    end;

    local procedure CheckVoucherSourceCodeOnModification(Rec: Record "Voucher Entry Source Code"; xRec: Record "Voucher Entry Source Code")
    var
        SourceCodeSetup: Record "Source Code Setup";
        DigitalVoucherFeature: Codeunit "Digital Voucher Feature";
    begin
        if Rec.IsTemporary then
            exit;
        if not DigitalVoucherFeature.EnforceDigitalVoucherFunctionality() then
            exit;
        if not SourceCodeSetup.Get() then
            exit;
        case Rec."Entry Type" of
            Rec."Entry Type"::"Purchase Journal":
                if (xRec."Source Code" = SourceCodeSetup."Purchase Journal") and (xRec."Source Code" <> Rec."Source Code") then
                    Error(NotAllowedToChangeWhenEnforcedErr);
            Rec."Entry Type"::"Sales Journal":
                if (xRec."Source Code" = SourceCodeSetup."Sales Journal") and (xRec."Source Code" <> Rec."Source Code") then
                    Error(NotAllowedToChangeWhenEnforcedErr);
        end;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Digital Voucher Impl.", 'OnHandleDigitalVoucherEntrySetupWhenEnforced', '', false, false)]
    local procedure DefaultEnforcementSetupOnGetDigitalVoucherEntrySetupWhenEnforced(EntryType: Enum "Digital Voucher Entry Type")
    var
        DigitalVoucherSetup: Record "Digital Voucher Setup";
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        DigitalVoucherFeature: Codeunit "Digital Voucher Feature";
    begin
        if not DigitalVoucherFeature.EnforceDigitalVoucherFunctionality() then
            exit;
        if not DigitalVoucherSetup.WritePermission() then
            exit;
        if not DigitalVoucherSetup.Get() then
            DigitalVoucherSetup.Insert();
        if not DigitalVoucherSetup.Enabled then begin
            DigitalVoucherSetup.Enabled := true;
            DigitalVoucherSetup.Modify();
        end;

        case EntryType of
            EntryType::"General Journal", EntryType::"Sales Journal":
                if not DigitalVoucherEntrySetup.Get(EntryType) then
                    RecreateDigitalVoucherEntrySetup(EntryType, DigitalVoucherEntrySetup."Check Type"::"No Check", false);
            EntryType::"Purchase Journal":
                RecreateDigitalVoucherEntrySetup(EntryType, DigitalVoucherEntrySetup."Check Type"::Attachment, false);
            EntryType::"Sales Document":
                RecreateDigitalVoucherEntrySetup(EntryType, DigitalVoucherEntrySetup."Check Type"::Attachment, true);
            EntryType::"Purchase Document":
                RecreateDigitalVoucherEntrySetup(EntryType, DigitalVoucherEntrySetup."Check Type"::Attachment, false);
        end;
    end;

    local procedure RecreateDigitalVoucherEntrySetup(EntryType: Enum "Digital Voucher Entry Type"; CheckType: Enum "Digital Voucher Check Type"; GenerateAutomatically: Boolean)
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
    begin
        if DigitalVoucherEntrySetup.Get(EntryType) then
            if DigitalVoucherEntrySetup."Check Type" = CheckType then
                exit;
        DigitalVoucherEntrySetup."Entry Type" := EntryType;
        DigitalVoucherEntrySetup."Check Type" := CheckType;
        DigitalVoucherEntrySetup."Generate Automatically" := GenerateAutomatically;
        DigitalVoucherEntrySetup."Skip If Manually Added" := true;
        if not DigitalVoucherEntrySetup.insert() then
            DigitalVoucherEntrySetup.Modify();
        RecreateDigitalVoucherEntrySourceCode(EntryType);
    end;

    local procedure RecreateDigitalVoucherEntrySourceCode(EntryType: Enum "Digital Voucher Entry Type")
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if not SourceCodeSetup.Get() then
            exit;
        case EntryType of
            EntryType::"Sales Document":
                begin
                    InsertDigitalVoucherEntrySourceCode(EntryType, SourceCodeSetup.Sales);
                    InsertDigitalVoucherEntrySourceCode(EntryType, SourceCodeSetup."Sales Deferral");
                end;
            EntryType::"Sales Journal":
                InsertDigitalVoucherEntrySourceCode(EntryType, SourceCodeSetup."Sales Journal");
            EntryType::"Purchase Document":
                begin
                    InsertDigitalVoucherEntrySourceCode(EntryType, SourceCodeSetup.Purchases);
                    InsertDigitalVoucherEntrySourceCode(EntryType, SourceCodeSetup."Purchase Deferral");
                end;
            EntryType::"Purchase Journal":
                InsertDigitalVoucherEntrySourceCode(EntryType, SourceCodeSetup."Purchase Journal");
        end;
    end;

    local procedure InsertDigitalVoucherEntrySourceCode(EntryType: Enum "Digital Voucher Entry Type"; SourceCode: Code[10])
    var
        VoucherSourceCode: Record "Voucher Entry Source Code";
        SourceCodeRec: Record "Source Code";
    begin
        if SourceCode = '' then
            exit;
        if not SourceCodeRec.Get(SourceCode) then
            exit;
        VoucherSourceCode.Validate("Entry Type", EntryType);
        VoucherSourceCode.Validate("Source Code", SourceCode);
        if VoucherSourceCode.Insert(true) then;
    end;
}
