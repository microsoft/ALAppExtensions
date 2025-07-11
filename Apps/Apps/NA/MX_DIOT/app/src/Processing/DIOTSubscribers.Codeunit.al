// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using System.Environment.Configuration;
using System.Globalization;
using System.Media;

codeunit 27022 "DIOT Subscribers"
{
    trigger OnRun()
    begin

    end;

    var
        DIOTDataMgmt: Codeunit "DIOT Data Management";
        LeaseAndRentErr: Label 'Non-MX Vendors cannot have Type of Operation equal to Lease and Rent';
        WHTMoreThanVATErr: Label '%1 can not have higher value than %2', Comment = '%1=Field name;%2=Another field name';
        DIOTSetupTitleTxt: Label 'Set up DIOT reporting';
        DIOTSetupShortTitleTxt: Label 'DIOT Reporting';
        DIOTSetupDescriptionTxt: Label 'Business Central can help you produce the Declaración Informativa de Operaciones con Terceros (DIOT) required for Mexico. Set it up here.';


    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterModifyEvent', '', false, false)]
    local procedure CheckTypeOfOperationAndCountryCodeOnAfterModify(var Rec: Record Vendor)
    begin
        if Rec.IsTemporary() then
            exit;
        CheckCountryCodeDIOTOperationType(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterInsertEvent', '', false, false)]
    local procedure CheckTypeOfOperationAndCountryCodeOnAfterInsert(var Rec: Record Vendor)
    begin
        if Rec.IsTemporary() then
            exit;
        CheckCountryCodeDIOTOperationType(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Posting Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure CheckWHTandVATOnModify(var Rec: Record "VAT Posting Setup")
    begin
        if Rec.IsTemporary() then
            exit;
        CheckWHTIsNotMoreThanVAT(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Posting Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure CheckWHTandVATOnInsert(var Rec: Record "VAT Posting Setup")
    begin
        if Rec.IsTemporary() then
            exit;
        CheckWHTIsNotMoreThanVAT(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertVATEntry', '', false, false)]
    local procedure TransferDIOTTypeOfOperationOnBeforeInsertVATEntry(var VATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VATEntry."DIOT Type of Operation" := GenJournalLine."DIOT Type of Operation";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnPostLinesOnBeforeGenJnlLinePost', '', false, false)]
    local procedure TransferDIOTTypeOfOperationOnPostLinesOnBeforeGenJnlLinePost(var GenJnlLine: Record "Gen. Journal Line"; PurchHeader: Record "Purchase Header");
    begin
        GenJnlLine."DIOT Type of Operation" := PurchHeader."DIOT Type of Operation";
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterInsertEvent', '', false, false)]
    local procedure ModifyDIOTTypeOfOperationOnInsertVendor(var Rec: Record Vendor; RunTrigger: Boolean)
    var
        PurchaseAndPayablesSetup: Record "Purchases & Payables Setup";
    begin
        if Rec.IsTemporary() then
            exit;
        if not PurchaseAndPayablesSetup.Get() then
            exit;
        if PurchaseAndPayablesSetup."Default Vendor DIOT Type" = PurchaseAndPayablesSetup."Default Vendor DIOT Type"::" " then
            exit;
        if (not DIOTDataMgmt.IsCountryCodeMXorBlank(Rec."Country/Region Code")) and (PurchaseAndPayablesSetup."Default Vendor DIOT Type" = PurchaseAndPayablesSetup."Default Vendor DIOT Type"::"Lease and Rent") then
            exit;
        Rec.Validate("DIOT Type of Operation", PurchaseAndPayablesSetup."Default Vendor DIOT Type");
        Rec.Modify(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnValidatePurchaseHeaderPayToVendorNoOnBeforeCheckDocType', '', false, false)]
    local procedure AssignDIOTTypeOnValidatePurchaseHeaderPayToVendorNo(Vendor: Record Vendor; var PurchaseHeader: Record "Purchase Header"; var xPurchaseHeader: Record "Purchase Header")
    begin
        if PurchaseHeader."Pay-to Vendor No." = '' then
            exit;
        PurchaseHeader."DIOT Type of Operation" := Vendor."DIOT Type of Operation";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure InsertIntoAssistedSetupOnRegisterAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        Language: Codeunit Language;
        CurrentGlobalLanguage: Integer;
    begin
        GuidedExperience.InsertAssistedSetup(DIOTSetupTitleTxt, CopyStr(DIOTSetupShortTitleTxt, 1, 50), DIOTSetupDescriptionTxt, 5, ObjectType::Page, Page::"DIOT Setup Wizard", "Assisted Setup Group"::GettingStarted,
                                            '', "Video Category"::GettingStarted, '', true);

        CurrentGlobalLanguage := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());
        GuidedExperience.AddTranslationForSetupObjectTitle("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"DIOT Setup Wizard", Language.GetDefaultApplicationLanguageId(), DIOTSetupTitleTxt);
        GuidedExperience.AddTranslationForSetupObjectDescription("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"DIOT Setup Wizard", Language.GetDefaultApplicationLanguageId(), DIOTSetupDescriptionTxt);
        GlobalLanguage(CurrentGlobalLanguage);
    end;

    local procedure CheckCountryCodeDIOTOperationType(Vendor: Record Vendor)
    begin
        if (not DIOTDataMgmt.IsCountryCodeMXorBlank(Vendor."Country/Region Code")) and (Vendor."DIOT Type of Operation" = Vendor."DIOT Type of Operation"::"Lease and Rent") then
            Error(LeaseAndRentErr);
    end;

    local procedure CheckWHTIsNotMoreThanVAT(VATPostingSetup: Record "VAT Posting Setup")
    begin
        with VATPostingSetup do
            if "DIOT WHT %" > "VAT %" then
                Error(WHTMoreThanVATErr, FieldCaption("DIOT WHT %"), FieldCaption("VAT %"));
    end;
}
