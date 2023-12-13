// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Utilities;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Sales.History;

#pragma warning disable AL0432
codeunit 31469 "Sync.Dep.Fld-SCrMemoHdr CZL"
{
    Access = Internal;
    Permissions = tabledata "Sales Cr.Memo Header" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertSalesCrMemoHeader(var Rec: Record "Sales Cr.Memo Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Header", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifySalesCrMemoHeader(var Rec: Record "Sales Cr.Memo Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Sales Cr.Memo Header")
    var
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Sales Cr.Memo Header") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Sales Cr.Memo Header");
        if not IsReplaceVATDateEnabled() then
            Rec."VAT Reporting Date" := Rec."VAT Date CZL"
        else
            Rec."VAT Date CZL" := Rec."VAT Reporting Date";
        Rec.Modify();
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Sales Cr.Memo Header");
    end;

    local procedure IsReplaceVATDateEnabled(): Boolean
    var
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
    begin
        exit(ReplaceVATDateMgtCZL.IsEnabled());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Header", 'OnAfterValidateEvent', 'VAT Date CZL', false, false)]
    local procedure SyncOnAfterValidateVatDate(var Rec: Record "Sales Cr.Memo Header")
    begin
        if not IsReplaceVATDateEnabled() then
            Rec."VAT Reporting Date" := Rec."VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Header", 'OnAfterValidateEvent', 'VAT Reporting Date', false, false)]
    local procedure SyncOnAfterValidateVatReportingDate(var Rec: Record "Sales Cr.Memo Header")
    begin
        if IsReplaceVATDateEnabled() then
            Rec."VAT Date CZL" := Rec."VAT Reporting Date";
    end;
}
#endif
