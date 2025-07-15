codeunit 139666 "Test Transformation W1"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryHybridBCLast: Codeunit "Library - Hybrid BC Last";
        CountryCodeTxt: Label 'W1', Locked = true;
        ProductIdTxt: Label 'DynamicsBCLast', Locked = true;

    [Test]
    procedure VerifyMappedTablesStaged()
    var
        SourceTableMapping: Record "Source Table Mapping";
    begin
        // [SCENARIO] W1 extension maps tables that need to be staged
        LibraryHybridBCLast.InitializeMapping(14.5);

        // [WHEN] The extension is installed
        // [THEN] The Source Table Mapping table is populated with staged tables
        SourceTableMapping.SetRange("Country Code", CountryCodeTxt);
        SourceTableMapping.SetRange(Staged, true);
        Assert.AreEqual(0, SourceTableMapping.Count(), 'Unexpected number of mapped, staged tables.');
    end;

    [Test]
    procedure VerifyMappedTablesUnstaged()
    var
        SourceTableMapping: Record "Source Table Mapping";
    begin
        // [SCENARIO] W1 extension maps tables that are not staged
        LibraryHybridBCLast.InitializeMapping(14.5);

        // [WHEN] The extension is installed
        // [THEN] The Source Table Mapping table is populated with the unstages tables
        SourceTableMapping.SetRange("Country Code", CountryCodeTxt);
        SourceTableMapping.SetRange(Staged, false);
        Assert.AreEqual(0, SourceTableMapping.Count(), 'Unexpected number of mapped, unstaged tables.');
    end;

    /// <summary>
    /// This test is meant to catch issues with the mapping code that populates the "Table Mappings" and "Table Field Mappings" tables wrt to obsoleted tables and fields.
    /// If fields are deleted from the schema, the code to populate the "Table Mappings" and "Table Field Mappings" tables will fail.
    /// If fields are osboleted (pending or removed), the tst will fail.
    /// In case the test fails, the mapping code needs CLEAN and CLEANSCHEMA preprocessor symbols. The test will have to manually exclude the fields that are 'handled' with preprocessor symbols.
    /// </summary>
    [Test]
    procedure VerifyMappedFieldsExist()
    var
        TableMappings: Record "Table Mappings";
        TableFieldMappings: Record "Table Field Mappings";
        Field: Record Field;
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        MissingTablesAndFields: List of [Text];
    begin
        // [SCENARIO] All mapped tables and fields exist]
        // [WHEN] The mapping tables are initialized
        LibraryHybridBCLast.InitializeMapping(14.5);
        IntelligentCloudSetup.Get();
        IntelligentCloudSetup."Product ID" := ProductIdTxt;
        IntelligentCloudSetup.Modify();
        HybridCloudManagement.RestoreDefaultMigrationTableMappings(true);


        // [THEN] it only contains tables and fields that exist in the database
        assert.RecordIsNotEmpty(TableMappings, 'Table Mappings should not be empty.');
        assert.RecordIsNotEmpty(TableFieldMappings, 'Table Field Mappings should not be empty.');

        TableMappings.FindSet();
        repeat
            Field.SetRange(TableName, TableMappings."From Table Name");
            Field.SetRange(ObsoleteState, Field.ObsoleteState::No);
            if Field.Isempty() then
                MissingTablesAndFields.Add(TableMappings."From Table Name");

            Field.SetRange(TableName, TableMappings."To Table Name");
            if Field.Isempty() then
                MissingTablesAndFields.Add(TableMappings."To Table Name");
        until TableMappings.Next() = 0;

        TableFieldMappings.FindSet();
        repeat
            Field.SetRange(TableName, TableFieldMappings."From Table Name");
            Field.SetRange(FieldName, TableFieldMappings."From Table Field Name");
            Field.SetRange(ObsoleteState, Field.ObsoleteState::No);
            if Field.IsEmpty then
                MissingTablesAndFields.Add(TableFieldMappings."From Table Name" + '' + TableFieldMappings."From Table Field Name");

            Field.SetRange(TableName, TableFieldMappings."To Table Name");
            Field.SetRange(FieldName, TableFieldMappings."To Table Field Name");
            Field.SetRange(ObsoleteState, Field.ObsoleteState::No);
            if Field.IsEmpty then
                MissingTablesAndFields.Add(TableFieldMappings."To Table Name" + '' + TableFieldMappings."To Table Field Name");
        until TableFieldMappings.Next() = 0;

        // Assert that there are no missing tables or fields
        if MissingTablesAndFields.Count() > 0 then
            // if/when we have moved and obsoleted fields, this assert will need to be updated. see comment above
            error('Missing tables and/or fields: %1', MissingTablesAndFields)
    end;
}