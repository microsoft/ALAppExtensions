codeunit 139666 "Test Transformation W1"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryHybridBCLast: Codeunit "Library - Hybrid BC Last";
        CountryCodeTxt: Label 'W1', Locked = true;

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
        Assert.AreEqual(1, SourceTableMapping.Count(), 'Unexpected number of mapped, staged tables.');
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
        Assert.AreEqual(1, SourceTableMapping.Count(), 'Unexpected number of mapped, unstaged tables.');
    end;
}