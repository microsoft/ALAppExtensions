namespace Microsoft.Test.Sustainability;

using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sustainability.Calculation;

codeunit 148181 "Sustainability Journal Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySustainability: Codeunit "Library - Sustainability";
        LibraryUtility: Codeunit "Library - Utility";
        OneDefaultTemplateShouldBeCreatedLbl: Label 'One default template should be created after page is opened', Locked = true;
        OneDefaultBatchShouldBeCreatedLbl: Label 'One default batch should be created after page is opened', Locked = true;
        CustomAmountMustBePositiveLbl: Label 'The custom amount must be positive', Locked = true;

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

    [Test]
    procedure TestCustomAmountIsPositiveForNegativeTotalOfGL()
    var
        SustainAccountCategory: Record "Sustain. Account Category";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJouralLine: Record "Gen. Journal Line";
        SustainabilityCalcMgt: Codeunit "Sustainability Calc. Mgt.";
        GenJournalTemplateCode: Code[10];
        GLAccountNo: Code[20];
        GLAmount, CustomAmount : Decimal;
    begin
        // [SCENARIO 540221] Test that the custom amount is positive when the total of the GL is negative

        // [GIVEN] G/L Account exists
        GLAccountNo := LibraryERM.CreateGLAccountNoWithDirectPosting();

        // [GIVEN] G/L Batch and Template exist
        GenJournalTemplateCode := LibraryERM.SelectGenJnlTemplate();
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplateCode);

        // [GIVEN] G/L Entry with Amount = -1000 for the G/L Account
        GLAmount := -LibraryRandom.RandDec(1000, 2);
        LibraryERM.CreateGeneralJnlLine2WithBalAcc(GenJouralLine, GenJournalTemplateCode, GenJournalBatch.Name, GenJouralLine."Document Type"::Payment, GenJouralLine."Account Type"::"G/L Account", GLAccountNo, GenJouralLine."Account Type"::"G/L Account", LibraryERM.CreateGLAccountNoWithDirectPosting(), GLAmount);
        LibraryERM.PostGeneralJnlLine(GenJouralLine);

        // [GIVEN] Sustain Account Category with the G/L Account calculation foundation
        SustainAccountCategory := CreateSustAccountCategoryWithGLAccountNo(GLAccountNo);

        // [WHEN] Getting the collectable amount for sustanability account category
        CustomAmount := SustainabilityCalcMgt.GetCollectableGLAmount(SustainAccountCategory, 0D, 0D);

        // [THEN] The custom amount = 1000
        Assert.AreEqual(Abs(GLAmount), CustomAmount, CustomAmountMustBePositiveLbl);
    end;

    local procedure CreateSustAccountCategoryWithGLAccountNo(GLAccountNo: Code[20]) SustainAccountCategory: Record "Sustain. Account Category"
    begin
        SustainAccountCategory := LibrarySustainability.InsertAccountCategory(LibraryUtility.GenerateGUID(), LibraryUtility.GenerateGUID(), Enum::"Emission Scope"::"Scope 2", Enum::"Calculation Foundation"::Custom, true, true, true, 'GL', true);
        SustainAccountCategory."G/L Account Filter" := GLAccountNo;
        SustainAccountCategory.Modify(true);
    end;
}