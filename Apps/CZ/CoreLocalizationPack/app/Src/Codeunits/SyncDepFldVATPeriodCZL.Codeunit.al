#if not CLEAN28
#pragma warning disable AL0432
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Utilities;

using Microsoft.Finance.VAT.Reporting;

codeunit 11719 "Sync.Dep.Fld-VATPeriod CZL"
{
    Access = Internal;
    Permissions = tabledata "VAT Period CZL" = rimd,
                  tabledata "VAT Return Period" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"VAT Period CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATPeriodCZL(var Rec: Record "VAT Period CZL")
    begin
        SyncVATReturnPeriod(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Period CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATPeriodCZL(var Rec: Record "VAT Period CZL")
    begin
        SyncVATReturnPeriod(Rec);
    end;

    local procedure SyncVATReturnPeriod(var VATPeriodCZL: Record "VAT Period CZL")
    var
        VATReturnPeriod: Record "VAT Return Period";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if VATPeriodCZL.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Period CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Return Period");
        VATReturnPeriod.ChangeCompany(VATPeriodCZL.CurrentCompany);
        VATReturnPeriod.SetCurrentKey("Start Date");
        VATReturnPeriod.SetRange("Start Date", VATPeriodCZL."Starting Date");
        if not VATReturnPeriod.FindLast() then begin
            VATReturnPeriod.Init();
            VATReturnPeriod."Start Date" := VATPeriodCZL."Starting Date";
            VATReturnPeriod."End Date" := CalcEndDate(VATPeriodCZL);
            VATReturnPeriod."Due Date" := CalcDueDate(VATReturnPeriod."End Date");
            VATReturnPeriod.Insert(true);
        end;
        VATReturnPeriod.Status := VATPeriodCZL.Closed ? VATReturnPeriod.Status::Closed : VATReturnPeriod.Status::Open;
        VATReturnPeriod.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Return Period");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Period CZL", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVATPeriodCZL(var Rec: Record "VAT Period CZL")
    var
        VATReturnPeriod: Record "VAT Return Period";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Period CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Return Period");
        VATReturnPeriod.ChangeCompany(Rec.CurrentCompany);
        VATReturnPeriod.SetCurrentKey("Start Date");
        VATReturnPeriod.SetRange("Start Date", Rec."Starting Date");
        if VATReturnPeriod.FindLast() then
            VATReturnPeriod.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Return Period");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Return Period", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertVATReturnPeriod(var Rec: Record "VAT Return Period")
    begin
        SyncVATReturnPeriod(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Return Period", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyVATReturnPeriod(var Rec: Record "VAT Return Period")
    begin
        SyncVATReturnPeriod(Rec);
    end;

    local procedure SyncVATReturnPeriod(var VATReturnPeriod: Record "VAT Return Period")
    var
        VATPeriodCZL: Record "VAT Period CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if VATReturnPeriod.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Return Period") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Period CZL");
        VATPeriodCZL.ChangeCompany(VATReturnPeriod.CurrentCompany);
        if not VATPeriodCZL.Get(VATReturnPeriod."Start Date") then begin
            VATPeriodCZL.Init();
            VATPeriodCZL.Validate("Starting Date", VATReturnPeriod."Start Date");
            VATPeriodCZL.Insert(false);
        end;
        VATPeriodCZL.Closed := VATReturnPeriod.Status = VATReturnPeriod.Status::Closed;
        VATPeriodCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Period CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Return Period", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SyncOnBeforeDeleteVATReturnPeriod(var Rec: Record "VAT Return Period")
    var
        VATPeriodCZL: Record "VAT Period CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"VAT Return Period") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"VAT Period CZL");
        VATPeriodCZL.ChangeCompany(Rec.CurrentCompany);
        if VATPeriodCZL.Get(Rec."Start Date") then
            VATPeriodCZL.Delete(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"VAT Period CZL");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;

    local procedure CalcEndDate(VATPeriodCZL: Record "VAT Period CZL"): Date
    var
        StartingDate: Date;
    begin
        if VATPeriodCZL.Next() > 0 then
            exit(VATPeriodCZL."Starting Date" - 1);
        StartingDate := VATPeriodCZL."Starting Date";
        if VATPeriodCZL.Next(-1) < 0 then
            case StartingDate of
                CalcDate('<+1M>', VATPeriodCZL."Starting Date"):
                    exit(CalcDate('<CM>', StartingDate));
                CalcDate('<+1Q>', VATPeriodCZL."Starting Date"):
                    exit(CalcDate('<CQ>', StartingDate));
                else
                    exit(StartingDate + (StartingDate - VATPeriodCZL."Starting Date") - 1);
            end;
        exit(0D);
    end;

    local procedure CalcDueDate(EndDate: Date): Date
    begin
        if EndDate = 0D then
            exit(0D);
        exit(CalcDate('<+25D>', EndDate));
    end;
}
#endif