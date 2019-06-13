// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1750 "Data Classification Mgt."
{

    trigger OnRun()
    begin
    end;

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
    /// Updates the Data Sensitivity entries corresponding to the fields in the DataPrivacyEntities variable. The Data Sensitivity table
    /// is updated by setting the value of the "Data Sensitivity" field to the value of the "Default Data Sensitivity" field of the
    /// DataPrivacyEntities variable.
    /// </summary>
    /// <param name="DataPrivacyEntities">The variable that is used to update the Data Sensitivity table.</param>
    procedure SetTableClassifications(var DataPrivacyEntities: Record "Data Privacy Entities")
    begin

        DataClassificationMgtImpl.SetTableClassifications(DataPrivacyEntities);
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
    /// Filters the Data Sensitivity table using the "Table No." and "Field Caption" fields as criteria. The "Table No." field
    /// must be the ID of a table that is related to one of the tables in the DataSensitivity variable. The "Field Caption" field
    /// must be identical to, or contain the name of, one of the fields in the DataSensitivity variable.
    /// </summary>
    /// <param name="DataSensitivity">
    /// A record that includes all the fields for which fields with similar names from related tables should be found.
    /// After the function is run the variable will contain the fields with similar names from related tables.
    /// </param>
    procedure FindSimilarFieldsInRelatedTables(var DataSensitivity: Record "Data Sensitivity")
    begin

        DataClassificationMgtImpl.FindSimilarFieldsInRelatedTables(DataSensitivity);
    end;

    /// <summary>
    /// Populates the TempDataPrivacyEntities record with all the tables that have relationships to the table with the ID TableNo.
    /// </summary>
    /// <param name="TempDataPrivacyEntities">
    /// A temporary record that contains a row for each table that has a relationship to the table with the ID TableNo.
    /// </param>
    /// <param name="TableNo">The ID of the table whose relationships are retrieved.</param>
    procedure GetRelatedTablesForTable(var TempDataPrivacyEntities: Record "Data Privacy Entities" temporary; TableNo: Integer)
    begin

        DataClassificationMgtImpl.GetRelatedTablesForTable(TempDataPrivacyEntities, TableNo);
    end;

    /// <summary>
    /// Gets a filter that includes the table IDs of all tables that have the "Name" string in their name.
    /// </summary>
    /// <param name="Name">The substring that the names of the tables in the filter should contain.</param>
    procedure GetTableNoFilterForTablesWhoseNameContains(Name: Text): Text
    begin

        exit(DataClassificationMgtImpl.GetTableNoFilterForTablesWhoseNameContains(Name));
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
    /// Synchronizes the Data Sensitivity table with the Field variable. It inserts new values in the Data Sensitivity table for the
    /// fields that the Field variable contains and the Data Sensitivity table does not and it deletes the unclassified fields from
    /// the Data Sensitivity table that the Field variable does not contain.
    /// </summary>
    /// <param name="Field">The record that the Data Sensitivity table is synchronized with.</param>
    procedure RunSync("Field": Record "Field")
    begin
        DataClassificationMgtImpl.RunSync(Field);
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
    /// Gets the legal disclaimer for data classification.
    /// </summary>
    /// <returns>
    /// A Text value representing the legal disclaimer for data classification.
    /// </returns>
    procedure GetLegalDisclaimerTxt(): Text
    begin
        exit(DataClassificationMgtImpl.GetLegalDisclaimerTxt());
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
    begin
        exit(DataClassificationMgtImpl.DataPrivacyEntitiesExist());
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
    /// Filters the Field record for enabled, sensitive fields (fields that might contain customer content, End User Identifiable Information
    /// or End User Pseudonymous Identifiers) and for which have not ben removed.
    /// </summary>
    /// <param name="Field">The Field record that gets filtered.</param>
    procedure GetEnabledSensitiveFields(var "Field": Record "Field")
    begin
        DataClassificationMgtImpl.GetEnabledSensitiveFields(Field);
    end;

    /// <summary>
    /// Sets the entity table number on the Data Privacy Wizard page.
    /// </summary>
    /// <param name="DataPrivacyEntities">All the existent data privacy entities.</param>
    /// <param name="EntityTypeText">The name of the entity's table.</param>
    procedure SetEntityType(var DataPrivacyEntities: Record "Data Privacy Entities"; EntityTypeText: Text[80])
    begin
        DataClassificationMgtImpl.SetEntityType(DataPrivacyEntities, EntityTypeText);
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
    begin
        DataPrivacyEntities.InsertRow(TableNo, PageNo, KeyFieldNo, EntityFilter, PrivacyBlockedFieldNo);
    end;

    /// <summary>
    /// Publishes an event that allows subscribers to insert Data Privacy Entities in the DataPrivacyEntities record.
    /// </summary>
    /// <param name="DataPrivacyEntities">
    /// The record that in the end will contain all the Data Privacy Entities that the subscribers have inserted.
    /// </param>
    [IntegrationEvent(false, false)]
    procedure OnGetPrivacyMasterTables(var DataPrivacyEntities: Record "Data Privacy Entities")
    begin
    end;

    /// <summary>
    /// Inserts a new row in the Field Content Buffer table with the first 250 characters of the value in the FieldRef
    /// variable.
    /// </summary>
    /// <param name="FieldRef">A field reference to the field that is used to populate the Field Content Buffer table.</param>
    /// <param name="FieldContentBuffer">A Field Content Buffer record</param>
    [Scope('OnPrem')]
    procedure PopulateFieldValue(FieldRef: FieldRef; var FieldContentBuffer: Record "Field Content Buffer")
    begin
        DataClassificationMgtImpl.PopulateFieldValue(FieldRef, FieldContentBuffer);
    end;

    /// <summary>
    /// Publishes an event that allows subscribers to create evaluation data.
    /// </summary>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    procedure OnCreateEvaluationData()
    begin
    end;

    /// <summary>
    /// Publishes an event that allows subscribers to show a notification that calls for users to synchronize their
    /// Data Sensitivity and Field tables.
    /// </summary>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    procedure OnShowSyncFieldsNotification()
    begin
    end;
}

