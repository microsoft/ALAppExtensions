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
        FixedAsset: Record "Fixed Asset";
        Location: Record Location;
        Dimension: Record Dimension;
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        DimensionAutoCreateMgtCZA: Codeunit "Dimension Auto.Create Mgt. CZA";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibraryWarehouse: Codeunit "Library - Warehouse";
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
    procedure AutomaticCreateJobDefaultDimension()
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
        DefaultDimension.Modify(true);
        Commit();

        // [WHEN] Create new Job.
        Job.Init();
        Job."No." := CopyStr(LibraryRandom.RandText(10), 1, 10);
        Job.Insert(true);
        DimensionAutoCreateMgtCZA.AutoCreateDimension(Database::Job, Job."No.");

        // [THEN] Default Dimension of new created job must be equal to Job No.
        DefaultDimension.Get(Database::Job, Job."No.", Dimension.Code);
        Assert.AreEqual(Job."No.", DefaultDimension."Dimension Value Code", DimensionValueErr);
    end;

    [Test]
    procedure AutomaticCreateLocationDefaultDimension()
    var
        DimensionValueErr: Label 'Dimension value code must be equal to location Code';
    begin
        // [SCENARIO] When setup Default Dimension with automatic creation dimension then new created Location must have automatic created dimension. 
        Initialize();

        // [GIVEN] Create Dimension.
        LibraryDimension.CreateDimension(Dimension);

        // [GIVEN] Create Default Dimension with automatic creation setup.
        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::Location, '', Dimension.Code, '');
        CreateDefaultDimensionAutomaticCreation(DefaultDimension);
        DefaultDimension.Modify(true);
        Commit();

        // [WHEN] Create new Location.
        LibraryWarehouse.CreateLocation(Location);
        DimensionAutoCreateMgtCZA.AutoCreateDimension(Database::Location, Location.Code);

        // [THEN] Default Dimension of new created Location must be equal to location Code.
        DefaultDimension.Get(Database::Location, Location.Code, Dimension.Code);
        Assert.AreEqual(Location.Code, DefaultDimension."Dimension Value Code", DimensionValueErr);
    end;

    [Test]
    procedure AutomaticCreateFixedAssetDefaultDimension()
    var
        DimensionValueErr: Label 'Dimension value code must be equal to fixed asset No.';
    begin
        // [SCENARIO] When setup Default Dimension with automatic creation dimension then new created fixed Asset must have automatic created dimension. 
        Initialize();

        // [GIVEN] Create Dimension.
        LibraryDimension.CreateDimension(Dimension);

        // [GIVEN] Create Default Dimension with automatic creation setup.
        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::"Fixed Asset", '', Dimension.Code, '');
        CreateDefaultDimensionAutomaticCreation(DefaultDimension);
        DefaultDimension.Modify(true);
        Commit();

        // [WHEN] Create new Fixed Asseet.
        LibraryFixedAsset.CreateFixedAsset(FixedAsset);
        DimensionAutoCreateMgtCZA.AutoCreateDimension(Database::"Fixed Asset", FixedAsset."No.");

        // [THEN] Default Dimension of new created fixed asset must be equal to fixed asset No.
        DefaultDimension.Get(Database::"Fixed Asset", FixedAsset."No.", Dimension.Code);
        Assert.AreEqual(FixedAsset."No.", DefaultDimension."Dimension Value Code", DimensionValueErr);
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
        DefaultDimension.Modify(true);
        Commit();

        // [WHEN] Create new Job.
        Job.Init();
        Job."No." := CopyStr(LibraryRandom.RandText(10), 1, 10);
        Job.Insert(true);
        DimensionAutoCreateMgtCZA.AutoCreateDimension(Database::"Job", Job."No.");

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
        DefaultDimension.Modify(true);
        Commit();

        // [WHEN] Create new Job and modify description.
        Job.Init();
        Job."No." := CopyStr(LibraryRandom.RandText(10), 1, 10);
        Job.Insert(true);
        DimensionAutoCreateMgtCZA.AutoCreateDimension(Database::"Job", Job."No.");
        JobModifyDescritpion := CopyStr(LibraryRandom.RandText(20), 1, MaxStrLen(JobModifyDescritpion));
        Job.Validate(Description, JobModifyDescritpion);
        Job.Modify();

        // [THEN] Dimension Value Name must be equal to default dimension description setup.
        DimensionValue.Get(Dimension.Code, Job."No.");
        Assert.AreEqual(DimensionValue.Name, StrSubstNo(JobDescriptionTok, Job.Description), DimensionNameErr);
    end;

    local procedure CreateDefaultDimensionAutomaticCreation(var VarDefaultDimension: Record "Default Dimension")
    begin
        VarDefaultDimension."Automatic Create CZA" := true;
        VarDefaultDimension."Auto. Create Value Posting CZA" := VarDefaultDimension."Auto. Create Value Posting CZA"::"Same Code";
        VarDefaultDimension."Value Posting" := VarDefaultDimension."Value Posting"::"Code Mandatory";
    end;
}
