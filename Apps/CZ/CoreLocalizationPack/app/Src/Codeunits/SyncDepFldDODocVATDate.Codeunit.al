// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Utilities;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Setup;
using Microsoft.Finance.VAT.Setup;

#pragma warning disable AL0432
codeunit 31473 "Sync.Dep.Fld-DODocVATDate CZL"
{
    Access = Internal;
    Permissions = tabledata "Purchases & Payables Setup" = rimd,
                  tabledata "General Ledger Setup" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Purchases & Payables Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertPurchasesPayablesSetup(var Rec: Record "Purchases & Payables Setup")
    begin
        SyncPurchasesPayablesSetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchases & Payables Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyPurchasesPayablesSetup(var Rec: Record "Purchases & Payables Setup")
    begin
        SyncPurchasesPayablesSetup(Rec);
    end;

    local procedure SyncPurchasesPayablesSetup(var PurchasesPayablesSetup: Record "Purchases & Payables Setup")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if PurchasesPayablesSetup.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Purchases & Payables Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"General Ledger Setup");
        GeneralLedgerSetup.ChangeCompany(PurchasesPayablesSetup.CurrentCompany);
        if not GeneralLedgerSetup.Get() then begin
            GeneralLedgerSetup.Init();
            GeneralLedgerSetup.Insert(false);
        end;
        case PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL" of
            PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::Blank:
                GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := Enum::"Default Orig.Doc. VAT Date CZL"::Blank;
            PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::"Posting Date":
                GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := Enum::"Default Orig.Doc. VAT Date CZL"::"Posting Date";
            PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::"VAT Date":
                GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := Enum::"Default Orig.Doc. VAT Date CZL"::"VAT Date";
            PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::"Document Date":
                GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := Enum::"Default Orig.Doc. VAT Date CZL"::"Document Date";
        end;
        GeneralLedgerSetup.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"General Ledger Setup");
    end;

    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertEETEntryCZL(var Rec: Record "General Ledger Setup")
    begin
        SyncGeneralLedgerSetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyEETEntryCZL(var Rec: Record "General Ledger Setup")
    begin
        SyncGeneralLedgerSetup(Rec);
    end;

    local procedure SyncGeneralLedgerSetup(var GeneralLedgerSetup: Record "General Ledger Setup")
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if GeneralLedgerSetup.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"General Ledger Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Purchases & Payables Setup");
        PurchasesPayablesSetup.ChangeCompany(GeneralLedgerSetup.CurrentCompany);
        if not PurchasesPayablesSetup.Get() then begin
            PurchasesPayablesSetup.Init();
            PurchasesPayablesSetup.Insert(false);
        end;
        case GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" of
            Enum::"Default Orig.Doc. VAT Date CZL"::Blank:
                PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL" := PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::Blank;
            Enum::"Default Orig.Doc. VAT Date CZL"::"Posting Date":
                PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL" := PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::"Posting Date";
            Enum::"Default Orig.Doc. VAT Date CZL"::"VAT Date":
                PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL" := PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::"VAT Date";
            Enum::"Default Orig.Doc. VAT Date CZL"::"Document Date":
                PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL" := PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::"Document Date";
        end;
        PurchasesPayablesSetup.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Purchases & Payables Setup");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif
