codeunit 148183 "Sustainability Check Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";
        LibrarySustainability: Codeunit "Library - Sustainability";

    [Test]
    procedure TestCommonConditionCheck()
    var
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustainabilityJnlCheck: Codeunit "Sustainability Jnl.-Check";
    begin
        // [SCENARIO] Test that the common conditions are checked before posting
        // Expecting error because: There should be at least one line in the journal
        asserterror SustainabilityJnlCheck.CheckCommonConditionsBeforePosting(SustainabilityJournalLine);
    end;

    [Test]
    procedure TestCheckJournalLine()
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJnlCheck: Codeunit "Sustainability Jnl.-Check";
    begin
        // [SCENARIO] Test the Check Journal Line function is working as expected
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] A Sustainability Journal Batch and An Account that's ready to Post 
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        SustainabilityAccount := LibrarySustainability.GetAReadyToPostAccount();

        // [WHEN] A Sustainability Journal Line is created, but without an Account
        SustainabilityJournalLine.Validate("Journal Template Name", SustainabilityJnlBatch."Journal Template Name");
        SustainabilityJournalLine.Validate("Journal Batch Name", SustainabilityJnlBatch.Name);
        SustainabilityJournalLine.Validate("Line No.", 1000);
        SustainabilityJournalLine.Validate("Document No.", 'Test1001');
        SustainabilityJournalLine.Validate("Posting Date", WorkDate());
        SustainabilityJournalLine.Insert(true);
        Commit();
        // [THEN] The Check Journal Line function should return an error
        asserterror SustainabilityJnlCheck.CheckSustainabilityJournalLine(SustainabilityJournalLine);


        // [WHEN] We add an Account to the Sustainability Journal Line
        SustainabilityJournalLine.Get(SustainabilityJnlBatch."Journal Template Name", SustainabilityJnlBatch.Name, 1000);
        SustainabilityJournalLine.Validate("Account No.", SustainabilityAccount."No.");
        SustainabilityJournalLine.Modify(true);
        Commit();
        // [THEN] The Check should still fail because the Account is Unit of Measure is not set
        asserterror SustainabilityJnlCheck.CheckSustainabilityJournalLine(SustainabilityJournalLine);


        // [WHEN] We add a Unit of Measure to the Sustainability Journal Line
        SustainabilityJournalLine.Get(SustainabilityJnlBatch."Journal Template Name", SustainabilityJnlBatch.Name, 1000);
        SustainabilityJournalLine."Unit of Measure" := 'kg';
        SustainabilityJournalLine.Modify(true);
        Commit();
        // [THEN] The Check should still fail because no emission is set
        asserterror SustainabilityJnlCheck.CheckSustainabilityJournalLine(SustainabilityJournalLine);


        // [WHEN] We add an emission to the Sustainability Journal Line
        SustainabilityJournalLine.Get(SustainabilityJnlBatch."Journal Template Name", SustainabilityJnlBatch.Name, 1000);
        SustainabilityJournalLine.Validate("Fuel/Electricity", 123);
        SustainabilityJournalLine.Modify(true);
        // [THEN] The Check should finally pass
        SustainabilityJnlCheck.CheckSustainabilityJournalLine(SustainabilityJournalLine);
    end;

    [Test]
    procedure TestCheckJournalLineWithErrorCollection()
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        TempErrorMessage: Record "Error Message" temporary;
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJnlCheck: Codeunit "Sustainability Jnl.-Check";
    begin
        // [SCENARIO] Test checking one Journal Line with error collection collects more than one errors
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] A Sustainability Journal Batch and An Account that's ready to Post 
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        SustainabilityAccount := LibrarySustainability.GetAReadyToPostAccount();

        // [WHEN] A Sustainability Journal Line is created, but with more than one error
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);

        SustainabilityJnlCheck.CheckSustainabilityJournalLineWithErrorCollect(SustainabilityJournalLine, TempErrorMessage);

        Assert.IsTrue(TempErrorMessage.Count() > 1, 'Expected more than one error');
    end;

    [Test]
    procedure TestCheckMultipleJournalLinesWithErrorCollection()
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        TempErrorMessage: Record "Error Message" temporary;
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJnlCheck: Codeunit "Sustainability Jnl.-Check";
        JnlLine1, JnlLine2 : RecordID;
    begin
        // [SCENARIO] Test checking multiple Journal Line with error collection collects more than one errors
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] A Sustainability Journal Batch and An Account that's ready to Post 
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        SustainabilityAccount := LibrarySustainability.GetAReadyToPostAccount();

        // [WHEN] A Sustainability Journal Line is created, but with more than one error
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        JnlLine1 := SustainabilityJournalLine.RecordId();
        // [WHEN] Another incomplete Sustainability Journal Line is created
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 2000);
        JnlLine2 := SustainabilityJournalLine.RecordId();

        // [THEN] The Check should fail with errors from both lines
        SustainabilityJnlCheck.CheckAllJournalLinesWithErrorCollect(SustainabilityJournalLine, TempErrorMessage);

        TempErrorMessage.SetRange("Context Record ID", JnlLine1);
        Assert.IsTrue(TempErrorMessage.Count() > 0, 'Expected at least one error for the first line');

        TempErrorMessage.SetRange("Context Record ID", JnlLine2);
        Assert.IsTrue(TempErrorMessage.Count() > 0, 'Expected at least one error for the second line');
    end;
}