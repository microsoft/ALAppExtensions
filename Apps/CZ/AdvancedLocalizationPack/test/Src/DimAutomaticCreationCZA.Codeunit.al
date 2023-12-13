codeunit 148103 "Dim. Automatic Creation CZA"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Automatic Creation Dimension]
        isInitialized := false;
    end;

    var
        Job: Record Job;
        Dimension: Record Dimension;
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        LibraryJob: Codeunit "Library - Job";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        isInitialized: Boolean;
        JobDescriptionTok: Label 'Test %1', Locked = true;

    local procedure Initialize();
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Dim. Automatic Creation CZA");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Dim. Automatic Creation CZA");

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Dim. Automatic Creation CZA");
    end;

    [Test]
    procedure AutomaticCreateDefaultDimension()
    var
        DimensionValueErr: Label 'Dimension value code must be equal to job No.';
    begin
        // [SCENARIO] When setup Default Dimension with automatic creation dimension then new created Job must have automatic created dimension. 
        Initialize();

        // [GIVEN] Create Dimension.
        LibraryDimension.CreateDimension(Dimension);

        // [GIVEN] Create Default Dimension with automatic creation setup.
        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::Job, '', Dimension.Code, '');
        CreateDefaultDimensionAutomaticCreation(DefaultDimension);
        DefaultDimension.Modify();

        // [WHEN] Create new Job.
        LibraryJob.CreateJob(Job);

        // [THEN] Default Dimension of new created job must be equal to Job No.
        DefaultDimension.Get(Database::Job, Job."No.", Dimension.Code);
        Assert.AreEqual(Job."No.", DefaultDimension."Dimension Value Code", DimensionValueErr);
    end;

    [Test]
    procedure AutomaticCreateDimensionValueDescription()
    var
        DimensionNameErr: Label 'Dimension value name must be equal to job setup name.';
    begin
        // [SCENARIO] When setup Default Dimension with automatic creation dimension and "Dim. Description Update CZA" = Create then after create new Job, Dimension Value Description must be equal to setup value. 
        Initialize();

        // [GIVEN] Create Dimension.
        LibraryDimension.CreateDimension(Dimension);

        // [GIVEN] Create Default Dimension with automatic creation description.
        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::Job, '', Dimension.Code, '');
        CreateDefaultDimensionAutomaticCreation(DefaultDimension);
        DefaultDimension."Dim. Description Field ID CZA" := Job.FieldNo(Description);
        DefaultDimension."Dim. Description Update CZA" := DefaultDimension."Dim. Description Update CZA"::Create;
        DefaultDimension."Dim. Description Format CZA" := JobDescriptionTok;
        DefaultDimension.Modify();

        // [WHEN] Create new Job.
        LibraryJob.CreateJob(Job);

        // [THEN] Dimension Value Name must be equal to default description setup.
        DimensionValue.Get(Dimension.Code, Job."No.");
        Assert.AreEqual(DimensionValue.Name, StrSubstNo(JobDescriptionTok, Job.Description), DimensionNameErr);
    end;

    [Test]
    procedure AutomaticUpdateDimensionValueDescription()
    var
        DimensionNameErr: Label 'Dimension value name must be equal to job changed setup name.';
        JobModifyDescritpion: Text[100];
    begin
        // [SCENARIO] When setup Default Dimension with automatic creation dimension and "Dim. Description Update CZA" = Update then after change Job Description, Dimension Value Description must be equal to setup value. 
        Initialize();

        // [GIVEN] Create Dimension.
        LibraryDimension.CreateDimension(Dimension);

        // [GIVEN] Create Default Dimension with automatic creation description.
        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::Job, '', Dimension.Code, '');
        CreateDefaultDimensionAutomaticCreation(DefaultDimension);
        DefaultDimension."Dim. Description Field ID CZA" := Job.FieldNo(Description);
        DefaultDimension."Dim. Description Update CZA" := DefaultDimension."Dim. Description Update CZA"::Update;
        DefaultDimension."Dim. Description Format CZA" := JobDescriptionTok;
        DefaultDimension.Modify();

        // [WHEN] Create new Job and modify description.
        LibraryJob.CreateJob(Job);
        JobModifyDescritpion := CopyStr(LibraryRandom.RandText(20), 1, MaxStrLen(JobModifyDescritpion));
        Job.Validate(Description, JobModifyDescritpion);
        Job.Modify();

        // [THEN] Dimension Value Name must be equal to default dimension description setup.
        DimensionValue.Get(Dimension.Code, Job."No.");
        Assert.AreEqual(DimensionValue.Name, StrSubstNo(JobDescriptionTok, Job.Description), DimensionNameErr);
    end;

    local procedure CreateDefaultDimensionAutomaticCreation(var DefaultDimension: Record "Default Dimension")
    begin
        DefaultDimension."Automatic Create CZA" := true;
        DefaultDimension."Auto. Create Value Posting CZA" := DefaultDimension."Auto. Create Value Posting CZA"::"Same Code";
        DefaultDimension."Value Posting" := DefaultDimension."Value Posting"::"Code Mandatory";
    end;
}
