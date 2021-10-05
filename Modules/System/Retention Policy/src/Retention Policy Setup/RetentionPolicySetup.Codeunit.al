// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This codeunit contains helper methods for retention policy setups.
/// </summary>
codeunit 3902 "Retention Policy Setup"
{
    Access = Public;

    var
        RetenPolSetupRenameErr: Label 'You cannot rename retention policy setup records. Table ID %1. Renamed to %2.', Comment = '%1, %2 = table number';
        RetenPolSetupLineRenameErr: Label 'You cannot rename retention policy setup line records. Table ID %1. Renamed to %2.', Comment = '%1, %2 = table number';

    /// <summary>
    /// Use this procedure to open a Filter Page Builder page and store the resulting filter in view format on the retention policy setup line.
    /// </summary>
    /// <param name="RetentionPolicySetupLine">The record where the filter is stored.</param>
    /// <returns>The filter in Text format.</returns>
    procedure SetTableFilterView(var RetentionPolicySetupLine: record "Retention Policy Setup Line"): Text[2048]
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        exit(CopyStr(RetentionPolicySetupImpl.SetTableFilterView(RetentionPolicySetupLine), 1, 2048));
    end;

    /// <summary>
    /// Use this procedure to get the filter that is stored in a view format on the retention policy setup line.
    /// </summary>
    /// <param name="RetentionPolicySetupLine">The record where the filter is stored.</param>
    /// <returns>The filter in View format.</returns>
    procedure GetTableFilterView(RetentionPolicySetupLine: record "Retention Policy Setup Line"): Text
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        exit(RetentionPolicySetupImpl.GetTableFilterView(RetentionPolicySetupLine));
    end;

    /// <summary>
    /// Use this procedure to get the filter that is stored in a text format on the retention policy setup line.
    /// </summary>
    /// <param name="RetentionPolicySetupLine">The record where the filter is stored.</param>
    /// <returns>The Filter in text format.</returns>
    procedure GetTableFilterText(RetentionPolicySetupLine: Record "Retention Policy Setup Line"): Text[2048]
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        exit(CopyStr(RetentionPolicySetupImpl.GetTableFilterText(RetentionPolicySetupLine), 1, 2048));
    end;

    /// <summary>
    /// Use this procedure to open a lookup page to select one of the allowed Table Id's.
    /// </summary>
    /// <param name="TableId">The currently stored Table ID. This value will be selected when you open the lookup.</param>
    /// <returns>The new selected table id.</returns>
    procedure TableIdLookup(TableId: Integer): Integer
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        exit(RetentionPolicySetupImpl.TableIdLookup(TableId))
    end;

    /// <summary>
    /// Use this procedure to open a lookup page to select one of the date or datetime fields for the given table.
    /// </summary>
    /// <param name="TableId">The table ID for which you want to select a field number.</param>
    /// <param name="FieldNo">The currently selected field number.</param>
    /// <returns>The new selected field number.</returns>
    procedure DateFieldNoLookup(TableId: Integer; FieldNo: Integer): Integer
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        exit(RetentionPolicySetupImpl.DateFieldNoLookup(TableId, FieldNo))
    end;

    /// <summary>
    /// This procedure checks whether any retention policies are enabled.
    /// </summary>
    /// <returns>True if a retention policy is enabled. False if no retention policies are enabled.</returns>
    procedure IsRetentionPolicyEnabled(): Boolean
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        exit(RetentionPolicySetupImpl.IsRetentionPolicyEnabled())
    end;

    /// <summary>
    /// This procedure checks whether a retention policy is enabled for the given table ID.
    /// </summary>
    /// <param name="TableId">The ID of the table that will be checked for an enabled retention policy.</param>
    /// <returns>True if a retention policy is enabled for the table ID. False if no retention policy is enabled for the table ID.</returns>
    procedure IsRetentionPolicyEnabled(TableId: Integer): Boolean
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        exit(RetentionPolicySetupImpl.IsRetentionPolicyEnabled(TableId))
    end;

    // these event subscribers are here because the Impl. codeunit has a manual subscriber

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', true, true)]
    local procedure AddRetentionPolicyOnRegisterManualSetup(sender: Codeunit "Guided Experience")
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        RetentionPolicySetupImpl.AddRetentionPolicyOnRegisterManualSetup(Sender)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Period", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure VerifyRetentionPolicySetupOnbeforeDeleteRetentionPeriod(var Rec: Record "Retention Period")
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        RetentionPolicySetupImpl.VerifyRetentionPolicySetupOnBeforeDeleteRetentionPeriod(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Period", 'OnBeforeModifyEvent', '', true, true)]
    local procedure VerifyRetentionPolicySetupOnbeforeModifyRetentionPeriod(var Rec: Record "Retention Period")
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        RetentionPolicySetupImpl.VerifyRetentionPolicySetupOnBeforeModifyRetentionPeriod(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure VerifyRetentionPolicyAllowedTablesOnBeforeInsertRetenPolSetup(var Rec: Record "Retention Policy Setup")
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        RetentionPolicySetupImpl.VerifyRetentionPolicyAllowedTablesOnBeforeInsertRetenPolSetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure InsertDefaultTableFiltersOnAfterInsertRetenPolSetup(var Rec: Record "Retention Policy Setup")
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        RetentionPolicySetupImpl.InsertDefaultTableFiltersOnAfterInsertRetenPolSetup(Rec)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Setup", 'OnBeforeRenameEvent', '', false, false)]
    local procedure ErrorOnBeforeRenameRetentionPolicySetup(var Rec: Record "Retention Policy Setup"; var xRec: Record "Retention Policy Setup")
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        if Rec.IsTemporary() then
            exit;

        RetentionPolicyLog.LogError(RetentionPolicySetupImpl.LogCategory(), StrSubstNo(RetenPolSetupRenameErr, xRec."Table Id", Rec."Table Id"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Setup Line", 'OnBeforeRenameEvent', '', false, false)]
    local procedure ErrorOnBeforeRenameRetentionPolicySetupLine(var Rec: Record "Retention Policy Setup Line"; var xRec: Record "Retention Policy Setup Line")
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        if Rec.IsTemporary() then
            exit;

        RetentionPolicyLog.LogError(RetentionPolicySetupImpl.LogCategory(), StrSubstNo(RetenPolSetupLineRenameErr, xRec."Table Id", Rec."Table Id"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Setup Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure CheckRecordLockedOnRetentionPolicySetupLineOnAfterModify(var Rec: Record "Retention Policy Setup Line"; var xRec: Record "Retention Policy Setup Line")
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        if not Rec.IsTemporary then
            xRec.Get(Rec."Table ID", Rec."Line No.");

        RetentionPolicySetupImpl.CheckRecordLockedOnRetentionPolicySetupLine(xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Setup Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckRecordLockedOnRetentionPolicySetupLineOnAfterDelete(var Rec: Record "Retention Policy Setup Line")
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        RetentionPolicySetupImpl.CheckRecordLockedOnRetentionPolicySetupLine(Rec);
    end;
}