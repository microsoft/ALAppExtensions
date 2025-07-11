codeunit 18800 "TDS Section Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [India TDS] [TDS Section Tests] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestAddTDSSubSection()
    var
        TDSSection: Record "TDS Section";
        TDSEntityMgmt: Codeunit "TDS Entity Management";
        LibraryTDS: Codeunit "Library-TDS";
        ParentCode: Code[20];
    begin
        // [SCENARIO] To check if system is creating Sub section for TDS a given TDS Section

        // [GIVEN] There has to be a TDS Section
        LibraryTDS.CreateTDSSection(TDSSection);
        ParentCode := TDSSection.Code;

        // [WHEN] function AddTDSSubSection is called 
        TDSEntityMgmt.AddTDSSubSection(TDSSection);

        // [THEN] It should create a new record child record for that given TDS section
        TDSSection.Reset();
        TDSSection.SetRange("Parent Code", ParentCode);
        Assert.RecordIsNotEmpty(TDSSection);
    end;
}