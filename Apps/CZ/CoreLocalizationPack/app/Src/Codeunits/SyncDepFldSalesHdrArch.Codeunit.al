// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Utilities;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Sales.Archive;

#pragma warning disable AL0432
codeunit 31468 "Sync.Dep.Fld-SalesHdrArch CZL"
{
    Access = Internal;
    Permissions = tabledata "Sales Header Archive" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header Archive", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertSalesHeaderArchive(var Rec: Record "Sales Header Archive")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header Archive", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifySalesHeaderArchive(var Rec: Record "Sales Header Archive")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Sales Header Archive")
    var
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Sales Header Archive") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Sales Header Archive");
        if not IsReplaceVATDateEnabled() then
            Rec."VAT Reporting Date" := Rec."VAT Date CZL"
        else
            Rec."VAT Date CZL" := Rec."VAT Reporting Date";
        Rec.Modify();
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Sales Header Archive");
    end;

    local procedure IsReplaceVATDateEnabled(): Boolean
    var
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
    begin
        exit(ReplaceVATDateMgtCZL.IsEnabled());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header Archive", 'OnAfterValidateEvent', 'VAT Date CZL', false, false)]
    local procedure SyncOnAfterValidateVatDate(var Rec: Record "Sales Header Archive")
    begin
        if not IsReplaceVATDateEnabled() then
            Rec."VAT Reporting Date" := Rec."VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header Archive", 'OnAfterValidateEvent', 'VAT Reporting Date', false, false)]
    local procedure SyncOnAfterValidateVatReportingDate(var Rec: Record "Sales Header Archive")
    begin
        if IsReplaceVATDateEnabled() then
            Rec."VAT Date CZL" := Rec."VAT Reporting Date";
    end;
}
#endif
