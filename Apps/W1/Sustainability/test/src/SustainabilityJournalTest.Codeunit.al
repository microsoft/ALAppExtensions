codeunit 148181 "Sustainability Journal Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibrarySustainability: Codeunit "Library - Sustainability";
        OneDefaultTemplateShouldBeCreatedLbl: Label 'One default template should be created after page is opened', Locked = true;
        OneDefaultBatchShouldBeCreatedLbl: Label 'One default batch should be created after page is opened', Locked = true;

    [Test]
    procedure TestDefaultTemplateAndBatchSuccessfullyInserted()
    var
        SustainabilityJnlTemplate: Record "Sustainability Jnl. Template";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
    begin
        // [SCENARIO] Test default template and batch creation when Opening the Journal page
        LibrarySustainability.CleanUpBeforeTesting();

        // [WHEN] Opening the Journal page, the procedure `GetASustainabilityJournalBatch` will be called
        SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);

        Clear(SustainabilityJnlTemplate);
        Clear(SustainabilityJnlBatch);

        // [THEN] Exactly one default template and batch should be created
        Assert.AreEqual(1, SustainabilityJnlTemplate.Count(), OneDefaultTemplateShouldBeCreatedLbl);
        Assert.AreEqual(1, SustainabilityJnlBatch.Count(), OneDefaultBatchShouldBeCreatedLbl);
    end;

    [Test]
    procedure TestDefaultTemplateAndBatchRecurringSuccessfullyInserted()
    var
        SustainabilityJnlTemplate: Record "Sustainability Jnl. Template";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
    begin
        // [SCENARIO] Test default template and batch creation when Opening the Journal page
        LibrarySustainability.CleanUpBeforeTesting();

        // [WHEN] Opening the Journal page, the procedure `GetASustainabilityJournalBatch` will be called
        SustainabilityJournalMgt.GetASustainabilityJournalBatch(true);

        Clear(SustainabilityJnlTemplate);
        Clear(SustainabilityJnlBatch);

        // [THEN] Exactly one default template and batch should be created
        Assert.AreEqual(1, SustainabilityJnlTemplate.Count(), OneDefaultTemplateShouldBeCreatedLbl);
        Assert.AreEqual(1, SustainabilityJnlBatch.Count(), OneDefaultBatchShouldBeCreatedLbl);
    end;

    [Test]
    procedure TestCheckForEmissionScopeMatching()
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        Category1Tok, Category2Tok : Code[20];
    begin
        // [SCENARIO] Test the check for scope matching works as expected
        // Account Category needs to match the scope of the Batch
        // Unless no scope is defined on the Batch, then the Account Category just needs to be not empty
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] A Sustainability Journal Batch
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(true);

        // [WHEN] The Default Batch's "Emission Scope" should be empty
        Assert.AreEqual(Enum::"Emission Scope"::" ", SustainabilityJnlBatch."Emission Scope", 'The Default Emission Scope should be empty');

        // [GIVEN] A Account Category with Emission Scope = "Scope 1" and a Batch with Emission Scope = " "
        Category1Tok := 'Test Category 1';
        LibrarySustainability.InsertAccountCategory(Category1Tok, '', Enum::"Emission Scope"::"Scope 1", Enum::"Calculation Foundation"::"Fuel/Electricity", true, true, true, '', false);

        SustainabilityJournalLine.Validate("Journal Template Name", SustainabilityJnlBatch."Journal Template Name");
        SustainabilityJournalLine.Validate("Journal Batch Name", SustainabilityJnlBatch.Name);
        SustainabilityJournalLine.Validate("Line No.", 1000);
        SustainabilityJournalLine.Validate("Account Category", Category1Tok);
        SustainabilityJournalLine.Insert(true);

        // [THEN] The Check should pass
        SustainabilityJournalMgt.CheckScopeMatchWithBatch(SustainabilityJournalLine);


        // [GIVEN] A Account Category with Emission Scope = "Scope 2" and a Batch with Emission Scope = "Scope 1"
        Category2Tok := 'Test Category 2';
        LibrarySustainability.InsertAccountCategory(Category2Tok, '', Enum::"Emission Scope"::"Scope 2", Enum::"Calculation Foundation"::"Fuel/Electricity", true, true, true, '', false);

        SustainabilityJnlBatch."Emission Scope" := Enum::"Emission Scope"::"Scope 1";
        SustainabilityJnlBatch.Modify(true);

        SustainabilityJournalLine.Validate("Journal Template Name", SustainabilityJnlBatch."Journal Template Name");
        SustainabilityJournalLine.Validate("Journal Batch Name", SustainabilityJnlBatch.Name);
        SustainabilityJournalLine.Validate("Line No.", 2000);
        SustainabilityJournalLine.Validate("Account Category", Category2Tok);
        SustainabilityJournalLine.Insert(true);

        // [THEN] The Check should fail
        asserterror SustainabilityJournalMgt.CheckScopeMatchWithBatch(SustainabilityJournalLine);
    end;
}