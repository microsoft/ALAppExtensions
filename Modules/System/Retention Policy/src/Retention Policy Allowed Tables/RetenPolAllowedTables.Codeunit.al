// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This codeunit is used to manage the list of allowed tables for which retention policies can be set up. 
/// Extensions can only approve the tables they create. Extensions cannot approve tables from other extensions.
/// </summary>
codeunit 3905 "Reten. Pol. Allowed Tables"
{
    Access = Public;
    Permissions = tabledata Field = r,
                  tabledata "Retention Policy Allowed Table" = r;

    var
        RetenPolAllowedTblRenameErr: Label 'Reten. Pol. Allowed Tables cannot be renamed. (From table ID %1 to %2.)', Comment = '%1, %2 = table number';

    /// <summary>
    /// Adds a table to the list of allowed tables.
    /// </summary>
    /// <param name="TableId">The ID of the table to add.</param>
    /// <returns>True if the table is in the list of allowed tables. False if the table is not in the list of allowed tables.</returns>
    procedure AddAllowedTable(TableId: Integer): Boolean
    var
        Field: Record Field;
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
        CallerModuleInfo: ModuleInfo;
        TableFilters: JsonArray;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo); // This line of code must be here, in the facade to catch the correct caller module info.
        exit(RetenPolAllowedTblImpl.AddToAllowedTables(TableId, Field.FieldNo(SystemCreatedAt), CallerModuleInfo, 0, TableFilters));
    end;

    /// <summary>
    /// Adds a table to the list of allowed tables.
    /// </summary>
    /// <param name="TableId">The ID of the table to add.</param>
    /// <param name="DefaultDateFieldNo">The number of the date or datetime field used as default to determine the age of records in the table.</param>
    /// <returns>True if the table is in the list of allowed tables. False if the table is not in the list of allowed tables.</returns>
    procedure AddAllowedTable(TableId: Integer; DefaultDateFieldNo: Integer): Boolean
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
        CallerModuleInfo: ModuleInfo;
        TableFilters: JsonArray;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo); // This line of code must be here, in the facade to catch the correct caller module info.
        exit(RetenPolAllowedTblImpl.AddToAllowedTables(TableId, DefaultDateFieldNo, CallerModuleInfo, 0, TableFilters));
    end;

    /// <summary>
    /// Adds a table to the list of allowed tables.
    /// </summary>
    /// <param name="TableId">The ID of the table to add.</param>
    /// <param name="DefaultDateFieldNo">The number of the date or datetime field used as default to determine the age of records in the table.</param>
    /// <param name="MandatoryMinRetenDays">The minimum number of days records must be kept in the table. </param>
    /// <returns>True if the table is in the list of allowed tables. False if the table is not in the list of allowed tables.</returns>
    procedure AddAllowedTable(TableId: Integer; DefaultDateFieldNo: Integer; MandatoryMinRetenDays: Integer): Boolean
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
        CallerModuleInfo: ModuleInfo;
        TableFilters: JsonArray;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo); // This line of code must be here, in the facade to catch the correct caller module info.
        exit(RetenPolAllowedTblImpl.AddToAllowedTables(TableId, DefaultDateFieldNo, CallerModuleInfo, MandatoryMinRetenDays, TableFilters));
    end;

    /// <summary>
    /// Adds a table to the list of allowed tables.
    /// </summary>
    /// <param name="TableId">The ID of the table to add.</param>
    /// <param name="DefaultDateFieldNo">The number of the date or datetime field used as default to determine the age of records in the table.</param>
    /// <param name="TableFilters">A JsonArray which contains the default table filters for the retention policy</param>
    /// <returns>True if the table is in the list of allowed tables. False if the table is not in the list of allowed tables.</returns>
    procedure AddAllowedTable(TableId: Integer; DefaultDateFieldNo: Integer; TableFilters: JsonArray): Boolean
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo); // This line of code must be here, in the facade to catch the correct caller module info.
        exit(RetenPolAllowedTblImpl.AddToAllowedTables(TableId, DefaultDateFieldNo, CallerModuleInfo, 0, TableFilters));
    end;

    /// <summary>
    /// Adds a table to the list of allowed tables.
    /// </summary>
    /// <param name="TableId">The ID of the table to add.</param>
    /// <param name="TableFilters">A JsonArray which contains the default table filters for the retention policy</param>
    /// <returns>True if the table is in the list of allowed tables. False if the table is not in the list of allowed tables.</returns>
    procedure AddAllowedTable(TableId: Integer; TableFilters: JsonArray): Boolean
    var
        Field: Record Field;
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo); // This line of code must be here, in the facade to catch the correct caller module info.
        exit(RetenPolAllowedTblImpl.AddToAllowedTables(TableId, Field.FieldNo(SystemCreatedAt), CallerModuleInfo, 0, TableFilters));
    end;

    /// <summary>
    /// Adds a table to the list of allowed tables.
    /// </summary>
    /// <param name="TableId">The ID of the table to add.</param>
    /// <param name="DefaultDateFieldNo">The number of the date or datetime field used as default to determine the age of records in the table.</param>
    /// <param name="MandatoryMinRetenDays">The minimum number of days records must be kept in the table.</param>
    /// <param name="RetenPolFiltering">Determines the implementation used to filter records when applying retention polices.</param>
    /// <param name="RetenPolDeleting">Determines the implementation used to delete records when applying retention polices.</param>
    /// <param name="TableFilters">A JsonArray which contains the default table filters for the retention policy</param>
    /// <returns>True if the table is in the list of allowed tables. False if the table is not in the list of allowed tables.</returns>
    procedure AddAllowedTable(TableId: Integer; DefaultDateFieldNo: Integer; MandatoryMinRetenDays: Integer; RetenPolFiltering: Enum "Reten. Pol. Filtering"; RetenPolDeleting: Enum "Reten. Pol. Deleting"; TableFilters: JsonArray): Boolean
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo); // This line of code must be here, in the facade to catch the correct caller module info.
        exit(RetenPolAllowedTblImpl.AddToAllowedTables(TableId, DefaultDateFieldNo, CallerModuleInfo, MandatoryMinRetenDays, RetenPolFiltering, RetenPolDeleting, TableFilters));
    end;

    /// <summary>
    /// This helper method is used to build an array of table filters which will be inserted automatically when creating a retention policy for the allowed table.
    /// You must first build up the array by calling this helper function and adding all relevant table filter information before passing the JsonArray to the AddAllowedTable method. 
    /// </summary>
    /// <param name="TableFilters">The JsonArray to which the table filter information will be added.</param>
    /// <param name="RetentionPeriodEnum">Identifies the retention period for the retention policy table filter.</param>
    /// <param name="DateFieldNo">The number of the date or datetime field used as to determine the age of records in the table.</param>
    /// <param name="Enabled">Indicates whether the retention policy line will be enabled.</param>
    /// <param name="Locked">Indicates whether the retention policy line will be locked. If this parameter is true, the line will also be enabled.</param>
    /// <param name="RecordRef">A record reference containing the filters to be added to the retention policy setup line.</param>
    procedure AddTableFilterToJsonArray(var TableFilters: JsonArray; RetentionPeriodEnum: Enum "Retention Period Enum"; DateFieldNo: Integer; Enabled: Boolean; Locked: Boolean; RecordRef: RecordRef)
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
    begin
        RetenPolAllowedTblImpl.AddTableFilterToJsonArray(TableFilters, RetentionPeriodEnum, DateFieldNo, Enabled, Locked, RecordRef);
    end;

    /// <summary>
    /// This helper method is used to build an array of table filters which will be inserted automatically when creating a retention policy for the allowed table.
    /// You must first build up the array by calling this helper function and adding all relevant table filter information before passing the JsonArray to the AddAllowedTable method. 
    /// </summary>
    /// <param name="TableFilters">The JsonArray to which the table filter information will be added.</param>
    /// <param name="RetPeriodCalc">Identifies the retention period dateformula for the retention policy table filter.</param>
    /// <param name="DateFieldNo">The number of the date or datetime field used as to determine the age of records in the table.</param>
    /// <param name="Enabled">Indicates whether the retention policy line will be enabled.</param>
    /// <param name="Locked">Indicates whether the retention policy line will be locked. If this parameter is true, the line will also be enabled.</param>
    /// <param name="RecordRef">A record reference containing the filters to be added to the retention policy setup line.</param>
    procedure AddTableFilterToJsonArray(var TableFilters: JsonArray; RetPeriodCalc: DateFormula; DateFieldNo: Integer; Enabled: Boolean; Locked: Boolean; RecordRef: RecordRef)
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
    begin
        RetenPolAllowedTblImpl.AddTableFilterToJsonArray(TableFilters, RetPeriodCalc, DateFieldNo, Enabled, Locked, RecordRef);
    end;

    /// <summary>
    /// Removes a table from the list of allowed tables.
    /// </summary>
    /// <param name="TableId">The ID of the table to remove.</param>
    /// <returns>True if the table is not in the list of allowed tables. False if the table is in the list of allowed tables.</returns>
    procedure RemoveAllowedTable(TableId: Integer): Boolean
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
    begin
        exit(RetenPolAllowedTblImpl.RemoveFromAllowedTables(TableId))
    end;

    /// <summary>
    /// Checks whether a table exists in the list of allowed tables.
    /// </summary>
    /// <param name="TableId">The table ID to check.</param>
    /// <returns>True if the table is in the list of allowed tables. False if the table is not in the list of allowed tables.</returns>
    procedure IsAllowedTable(TableId: Integer): boolean
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
    begin
        exit(RetenPolAllowedTblImpl.IsAllowedTable(TableId))
    end;

    /// <summary>
    /// Returns the allowed tables as a list.
    /// </summary>
    /// <param name="AllowedTables">The allowed tables as a List.</param>
    procedure GetAllowedTables(var AllowedTables: List of [Integer])
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
    begin
        RetenPolAllowedTblImpl.GetAllowedTables(AllowedTables)
    end;

    /// <summary>
    /// Returns the allowed tables as a filter string.
    /// </summary>
    /// <returns>The allowed tables as a filter string.</returns>
    procedure GetAllowedTables(): Text
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
    begin
        exit(RetenPolAllowedTblImpl.GetAllowedTables())
    end;

    /// <summary>
    /// Returns the enum value set for retention policy filtering. This determines which code will handle the filtering of records when the retention policy for the allowed table is applied.
    /// </summary>
    /// <param name="TableId">The table ID of the allowed table.</param>
    /// <returns>The retention policy filtering enum value.</returns>
    procedure GetRetenPolFiltering(TableId: Integer): enum "Reten. Pol. Filtering"
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
    begin
        exit(RetenPolAllowedTblImpl.GetRetenPolFiltering(TableId))
    end;

    /// <summary>
    /// Returns the enum value set for retention policy deleting. This determines which code will handle the deleting of records when the retention policy for the allowed table is applied.
    /// </summary>
    /// <param name="TableId">The table ID of the allowed table.</param>
    /// <returns>The retention policy deleting enum value.</returns>
    procedure GetRetenPolDeleting(TableId: Integer): enum "Reten. Pol. Deleting"
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
    begin
        exit(RetenPolAllowedTblImpl.GetRetenPolDeleting(TableId))
    end;

    /// <summary>
    /// Returns the number of the date or datetime field in the list of allowed tables for the given table.
    /// </summary>
    /// <param name="TableId">The table ID of the allowed table.</param>
    /// <returns>The field number of the date or datetime field in the allowed table.</returns>
    procedure GetDefaultDateFieldNo(TableId: Integer): Integer
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
    begin
        exit(RetenPolAllowedTblImpl.GetDefaultDateFieldNo(TableId))
    end;

    /// <summary>
    /// Returns the mandatory minimum number of retention days for the given table.
    /// </summary>
    /// <param name="TableId">The table ID of the allowed table.</param>
    /// <returns>The mandatory minimum number of retention days for the allowed table.</returns>
    procedure GetMandatoryMinimumRetentionDays(TableId: Integer): Integer
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
    begin
        exit(RetenPolAllowedTblImpl.GetMandatoryMinimumRetentionDays(TableId))
    end;

    /// <summary>
    /// Calculates the minimum expiration date for a given allowed table based on the minimum number of retention days and today's date.
    /// </summary>
    /// <param name="TableId">The table ID of the allowed table.</param>
    /// <returns>The minimum expiration date.</returns>
    procedure CalcMinimumExpirationDate(TableId: Integer): Date
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
    begin
        exit(RetenPolAllowedTblImpl.CalcMinimumExpirationDate(TableId))
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Allowed Table", 'OnBeforeInsertEvent', '', false, false)]
    local procedure VerifyInsertAllowed(var Rec: Record "Retention Policy Allowed Table")
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
    begin
        if Rec.IsTemporary() then
            exit;

        RetenPolAllowedTblImpl.VerifyInsertAllowed(Rec."Table Id");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Allowed Table", 'OnBeforeRenameEvent', '', false, false)]
    local procedure ErrorOnBeforeRenameAllowedTable(var Rec: Record "Retention Policy Allowed Table"; var xRec: Record "Retention Policy Allowed Table")
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        RetentionPolicyLogCategory: Enum "Retention Policy Log Category";
    begin
        if Rec.IsTemporary() then
            exit;

        RetentionPolicyLog.LogError(RetentionPolicyLogCategory::"Retention Policy - Setup", StrSubstNo(RetenPolAllowedTblRenameErr, xRec."Table Id", Rec."Table Id"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Allowed Table", 'OnBeforeModifyEvent', '', false, false)]
    local procedure VerifyModifyAllowed(var Rec: Record "Retention Policy Allowed Table")
    var
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
    begin
        if Rec.IsTemporary() then
            exit;

        RetenPolAllowedTblImpl.VerifyModifyAllowed(Rec."Table Id");
    end;
}