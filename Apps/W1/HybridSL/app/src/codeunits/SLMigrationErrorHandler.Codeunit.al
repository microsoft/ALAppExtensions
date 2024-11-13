// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Integration;

codeunit 47024 "SL Migration Error Handler"
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::"Data Migration Error", OnAfterInsertEvent, '', false, false)]
    local procedure UpdateErrorOverviewOnInsert(RunTrigger: Boolean; var Rec: Record "Data Migration Error")
    begin
        UpdateErrorOverview(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Data Migration Error", OnAfterModifyEvent, '', false, false)]
    local procedure UpdateErrorOverviewOnModify(RunTrigger: Boolean; var Rec: Record "Data Migration Error")
    begin
        UpdateErrorOverview(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Data Migration Error", OnAfterDeleteEvent, '', false, false)]
    local procedure UpdateErrorOverviewOnDelete(RunTrigger: Boolean; var Rec: Record "Data Migration Error")
    var
        SLMigrationErrorOverview: Record "SL Migration Error Overview";
    begin
        ErrorOccurred := true;
        if SLMigrationErrorOverview.Get(Rec.Id, CompanyName()) then begin
            SLMigrationErrorOverview."Error Dismissed" := true;
            SLMigrationErrorOverview.Modify();
        end;
    end;

    internal procedure UpdateErrorOverview(var DataMigrationError: Record "Data Migration Error")
    var
        SLMigrationErrorOverview: Record "SL Migration Error Overview";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        HybridSLWizard: Codeunit "SL Hybrid Wizard";
        Exists: Boolean;
        ErrorMessageSnippet: Text;
        MigrationType: Text;
    begin
        if not (HybridSLWizard.GetSLMigrationEnabled()) then
            exit;

        ErrorMessageSnippet := CopyStr(DataMigrationError."Error Message", 1, 13);
        if ErrorMessageSnippet.ToUpper() = 'POSTING ERROR' then
            exit;

        ErrorOccurred := true;
        SLMigrationErrorOverview.ReadIsolation := IsolationLevel::ReadUncommitted;
        Exists := SLMigrationErrorOverview.Get(DataMigrationError.Id, CompanyName());
        if not Exists then begin
            SLMigrationErrorOverview.Id := DataMigrationError.Id;
            SLMigrationErrorOverview."Migration Type" := SLHelperFunctions.GetMigrationTypeTxt();
            SLMigrationErrorOverview."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(SLMigrationErrorOverview."Company Name"));
            SLMigrationErrorOverview.Insert();
        end;

        SLMigrationErrorOverview.TransferFields(DataMigrationError);
        SLMigrationErrorOverview.SetFullExceptionMessage(DataMigrationError.GetFullExceptionMessage());
        SLMigrationErrorOverview.SetLastRecordUnderProcessingLog(DataMigrationError.GetLastRecordsUnderProcessingLog());
        SLMigrationErrorOverview.SetExceptionCallStack(DataMigrationError.GetExceptionCallStack());
        MigrationType := SLMigrationErrorOverview."Migration Type";
        if MigrationType.Trim() <> SLHelperFunctions.GetMigrationTypeTxt().Trim() then
            SLMigrationErrorOverview."Migration Type" := SLHelperFunctions.GetMigrationTypeTxt();
        SLMigrationErrorOverview.Modify();
    end;

    internal procedure ClearErrorOccurred()
    begin
        Clear(ErrorOccurred);
    end;

    internal procedure GetErrorOccurred(): Boolean
    begin
        exit(ErrorOccurred);
    end;

    internal procedure ErrorOccurredDuringLastUpgrade(): Boolean
    var
        SLMigrationErrorOverview: Record "SL Migration Error Overview";
        SLUpgradeSettings: Record "SL Upgrade Settings";
    begin
        SLUpgradeSettings.GetonInsertSLUpgradeSettings(SLUpgradeSettings);
        SLMigrationErrorOverview.SetRange("Company Name", CompanyName());
        SLMigrationErrorOverview.SetFilter(SystemModifiedAt, '>%1', SLUpgradeSettings."Data Upgrade Started");
        exit(not SLMigrationErrorOverview.IsEmpty());
    end;

    var
        ErrorOccurred: Boolean;
}
