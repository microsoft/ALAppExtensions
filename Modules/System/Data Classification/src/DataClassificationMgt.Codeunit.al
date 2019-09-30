// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to handle data classification tasks.
/// </summary>
codeunit 1750 "Data Classification Mgt."
{
    Access = Public;

    var
        DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";

    /// <summary>
    /// Creates an entry in the Data Sensitivity table for every field in the database that is classified as Customer Content,
    /// End User Identifiable Information (EUII), or End User Pseudonymous Identifiers (EUPI).
    /// </summary>
    procedure PopulateDataSensitivityTable()
    begin
        DataClassificationMgtImpl.PopulateDataSensitivityTable();
    end;

    /// <summary>
    /// Updates the Data Sensitivity table with the default data sensitivities for all the fields of all the tables
    /// in the DataPrivacyEntities record.
    /// </summary>
    /// <param name="DataPrivacyEntities">The variable that is used to update the Data Sensitivity table.</param>
    procedure SetDefaultDataSensitivity(var DataPrivacyEntities: Record "Data Privacy Entities")
    var
        DataPrivacyEntitiesMgt: Codeunit "Data Privacy Entities Mgt.";
    begin
        DataPrivacyEntitiesMgt.SetDefaultDataSensitivity(DataPrivacyEntities);
    end;

    /// <summary>
    /// For each Data Sensitivity entry, it sets the value of the "Data Sensitivity" field to the Sensitivity option.
    /// </summary>
    /// <param name="DataSensitivity">The record that gets updated</param>
    /// <param name="Sensitivity">The option that the "Data Sensitivity" field gets updated to.</param>
    procedure SetSensitivities(var DataSensitivity: Record "Data Sensitivity"; Sensitivity: Option)
    begin
        DataClassificationMgtImpl.SetSensitivities(DataSensitivity, Sensitivity);
    end;

    /// <summary>
    /// Synchronizes the Data Sensitivity table with the Field table. It inserts new values in the Data Sensitivity table for the
    /// fields that the Field table contains and the Data Sensitivity table does not and it deletes the unclassified fields from
    /// the Data Sensitivity table that the Field table does not contain.
    /// </summary>
    procedure SyncAllFields()
    begin
        DataClassificationMgtImpl.SyncAllFields();
    end;

    /// <summary>
    /// Gets the values that the "Data Sensitivity" field of the Data Sensitivity table can contain.
    /// </summary>
    /// <returns>
    /// A Text value representing the values that the "Data Sensitivity" field of the Data Sensitivity table can contain.
    /// </returns>
    procedure GetDataSensitivityOptionString(): Text
    begin
        exit(DataClassificationMgtImpl.GetDataSensitivityOptionString());
    end;

    /// <summary>
    /// Sets the data sensitivity to normal for all fields in the table with the ID TableNumber.
    /// </summary>
    /// <param name="TableNumber">The ID of the table in which the field sensitivities will be set to normal.</param>
    procedure SetTableFieldsToNormal(TableNumber: Integer)
    begin
        DataClassificationMgtImpl.SetTableFieldsToNormal(TableNumber);
    end;

    /// <summary>
    /// Sets the data sensitivity to personal for the field with the ID FieldNo from the table with the ID TableNo.
    /// </summary>
    /// <param name="TableNo">The table ID</param>
    /// <param name="FieldNo">The field ID</param>
    procedure SetFieldToPersonal(TableNo: Integer; FieldNo: Integer)
    begin
        DataClassificationMgtImpl.SetFieldToPersonal(TableNo, FieldNo);
    end;

    /// <summary>
    /// Sets the data sensitivity to sensitive for the field with the ID FieldNo from the table with the ID TableNo.
    /// </summary>
    /// <param name="TableNo">The table ID</param>
    /// <param name="FieldNo">The field ID</param>
    procedure SetFieldToSensitive(TableNo: Integer; FieldNo: Integer)
    begin
        DataClassificationMgtImpl.SetFieldToSensitive(TableNo, FieldNo);
    end;

    /// <summary>
    /// Sets the data sensitivity to company confidential for the field with the ID FieldNo from the table
    /// with the ID TableNo.
    /// </summary>
    /// <param name="TableNo">The table ID</param>
    /// <param name="FieldNo">The field ID</param>
    procedure SetFieldToCompanyConfidential(TableNo: Integer; FieldNo: Integer)
    begin
        DataClassificationMgtImpl.SetFieldToCompanyConfidential(TableNo, FieldNo);
    end;

    /// <summary>
    /// Sets the data sensitivity to normal for the field with the ID FieldNo from the table with the ID TableNo.
    /// </summary>
    /// <param name="TableNo">The table ID</param>
    /// <param name="FieldNo">The field ID</param>
    procedure SetFieldToNormal(TableNo: Integer; FieldNo: Integer)
    begin
        DataClassificationMgtImpl.SetFieldToNormal(TableNo, FieldNo);
    end;

    /// <summary>
    /// Checks whether any of the data privacy entity tables (Customer, Vendor, Employee, and so on) contain entries.
    /// </summary>
    /// <returns>True if there are any entries and false otherwise.</returns>
    procedure DataPrivacyEntitiesExist(): Boolean
    var
        DataPrivacyEntitiesMgt: Codeunit "Data Privacy Entities Mgt.";
    begin
        exit(DataPrivacyEntitiesMgt.DataPrivacyEntitiesExist());
    end;

    /// <summary>
    /// Checks whether the Data Sensitivity table contains any unclassified entries.
    /// </summary>
    /// <returns>True if there are any unclassified entries and false otherwise.</returns>
    procedure AreAllFieldsClassified(): Boolean
    begin
        exit(DataClassificationMgtImpl.AreAllFieldsClassified());
    end;

    /// <summary>
    /// Checks whether the Data Sensitivity table contains any entries for the current company.
    /// </summary>
    /// <returns>True if there are any entries and false otherwise.</returns>
    procedure IsDataSensitivityEmptyForCurrentCompany(): Boolean
    begin
        exit(DataClassificationMgtImpl.IsDataSensitivityEmptyForCurrentCompany());
    end;

    /// <summary>
    /// Inserts a new entry in the Data Sensitivity table for the specified table ID, field ID and with the given
    /// data sensitivity option (some of the values that the option can have are normal, sensitive and personal).
    /// </summary>
    /// <param name="TableNo">The table ID</param>
    /// <param name="FieldNo">The field ID</param>
    /// <param name="DataSensitivityOption">The data sensitivity option</param>
    procedure InsertDataSensitivityForField(TableNo: Integer; FieldNo: Integer; DataSensitivityOption: Option)
    begin
        DataClassificationMgtImpl.InsertDataSensitivityForField(TableNo, FieldNo, DataSensitivityOption);
    end;

    /// <summary>
    /// Inserts a new Data Privacy Entity entry in a record.
    /// </summary>
    /// <param name="DataPrivacyEntities">The record that the entry gets inserted into.</param>
    /// <param name="TableNo">The entity's table ID.</param>
    /// <param name="PageNo">The entity's page ID.</param>
    /// <param name="KeyFieldNo">The entity's primary key ID.</param>
    /// <param name="EntityFilter">The entity's ID.</param>
    /// <param name="PrivacyBlockedFieldNo">If the entity has a Privacy Blocked field, then the field's ID; otherwise 0.</param>
    procedure InsertDataPrivacyEntity(var DataPrivacyEntities: Record "Data Privacy Entities"; TableNo: Integer; PageNo: Integer; KeyFieldNo: Integer; EntityFilter: Text; PrivacyBlockedFieldNo: Integer)
    var
        DataPrivacyEntitiesMgt: Codeunit "Data Privacy Entities Mgt.";
    begin
        DataPrivacyEntitiesMgt.InsertDataPrivacyEntitity(DataPrivacyEntities, TableNo, PageNo, KeyFieldNo, EntityFilter, PrivacyBlockedFieldNo);
    end;

    /// <summary>
    /// Gets the last date when the Data Sensitivity and Field tables where synchronized.
    /// </summary>
    /// <returns>The last date when the Data Sensitivity and Field tables where synchronized.</returns>
    procedure GetLastSyncStatusDate(): DateTime
    var
        FieldsSyncStatusManagement: Codeunit "Fields Sync Status Management";
    begin
        exit(FieldsSyncStatusManagement.GetLastSyncStatusDate());
    end;

    /// <summary>
    /// Raises an event that allows subscribers to insert Data Privacy Entities in the DataPrivacyEntities record.
    /// Throws an error when it is not called with a temporary record.
    /// </summary>
    /// <param name="DataPrivacyEntities">
    /// The record that in the end will contain all the Data Privacy Entities that the subscribers have inserted.
    /// </param>
    procedure RaiseOnGetDataPrivacyEntities(var DataPrivacyEntities: Record "Data Privacy Entities")
    var
        DataPrivacyEntitiesMgt: Codeunit "Data Privacy Entities Mgt.";
    begin
        DataPrivacyEntitiesMgt.RaiseOnGetDataPrivacyEntities(DataPrivacyEntities);
    end;

    /// <summary>
    /// Publishes an event that allows subscribers to insert Data Privacy Entities in the DataPrivacyEntities record.
    /// </summary>
    /// <param name="DataPrivacyEntities">
    /// The record that in the end will contain all the Data Privacy Entities that the subscribers have inserted.
    /// </param>
    [IntegrationEvent(false, false)]
    internal procedure OnGetDataPrivacyEntities(var DataPrivacyEntities: Record "Data Privacy Entities")
    begin
    end;

    /// <summary>
    /// Publishes an event that allows subscribers to create evaluation data.
    /// </summary>
    [IntegrationEvent(false, false)]
    internal procedure OnCreateEvaluationData()
    begin
    end;

    /// <summary>
    /// Publishes an event that allows subscribers to show a notification that calls for users to synchronize their
    /// Data Sensitivity and Field tables.
    /// </summary>
    [IntegrationEvent(false, false)]
    internal procedure OnShowSyncFieldsNotification()
    begin
    end;
}