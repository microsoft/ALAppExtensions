codeunit 139617 "E-Doc. Mapping Test"
{
    Subtype = Test;
    Permissions = tabledata "E-Doc. Mapping Test Rec" = rimd;

    trigger OnRun()
    begin
        // [FEATURE] [E-Document]
        IsInitialized := false;
    end;

    var
        EDocMappingTestRec: Record "E-Doc. Mapping Test Rec";
        EDocService: Record "E-Document Service";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryEDoc: Codeunit "Library - E-Document";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        EDocMappingMgt: Codeunit "E-Doc. Mapping";
        LibraryPermission: Codeunit "Library - Lower Permissions";
        TextAndCodeReplacementLbl: Label 'REPLACEMENT';
        GeneralMappingRuleErr: Label 'Incorrect direct mapping was applied to field';
        TranformationMappingRuleErr: Label 'Incorrect transformation rule was applied to field';
        MappingChangesErr: Label 'Incorrect mapping was applied to record';
        MappingPreviewPageErr: Label 'Mapping Preview Page is incorrect';
        MappingNoTempRecordErr: Label 'Mapping of record can only be applied to temporary record';
        IsInitialized: Boolean;

    [Test]
    procedure MappingWithNoTempFailure()
    var
        EDocMapping: Record "E-Doc. Mapping";
        EDocMappingTestRec2: Record "E-Doc. Mapping Test Rec";
    begin
        // [FEATURE] [E-Document] [Mapping]
        // [SCENARIO] Map without a temporary record to write into is not allowed

        // [GIVEN] A record with different type of fields
        Initialize();
        EDocService.Get(LibraryEDoc.CreateService());

        LibraryPermission.SetTeamMember();
        EDocMappingTestRec.FindFirst();

        // [WHEN] A direct mapping is setup
        LibraryEDoc.CreateDirectMapping(EDocMapping, EDocService, EDocMappingTestRec."Text Value", TextAndCodeReplacementLbl);
        LibraryEDoc.CreateDirectMapping(EDocMapping, EDocService, EDocMappingTestRec."Code Value", TextAndCodeReplacementLbl);
        LibraryEDoc.CreateDirectMapping(EDocMapping, EDocService, Format(EDocMappingTestRec."Decimal Value"), TextAndCodeReplacementLbl);
        EDocMapping.SetRange(Code, EDocService.Code);
        EDocMapping.FindSet();

        // [WHEN] Record is mapped into record causing error
        asserterror MapRecord(EDocMapping, EDocMappingTestRec, EDocMappingTestRec2);
        Assert.ExpectedError(MappingNoTempRecordErr);
    end;

    [Test]
    procedure MappingGeneralRuleSuccess()
    var
        EDocMapping: Record "E-Doc. Mapping";
        TempEDocMappingTestRec2: Record "E-Doc. Mapping Test Rec" temporary;
    begin
        // [FEATURE] [E-Document] [Mapping]
        // [SCENARIO] Map with general rules - Direct mapping from A to B on Text and Code values

        // Because of Error in last test we reinit 
        IsInitialized := false;

        // [GIVEN] A record with different type of fields
        Initialize();
        EDocService.Get(LibraryEDoc.CreateService());

        LibraryPermission.SetTeamMember();
        EDocMappingTestRec.FindFirst();

        // [WHEN] A direct mapping is setup
        LibraryEDoc.CreateDirectMapping(EDocMapping, EDocService, EDocMappingTestRec."Text Value", TextAndCodeReplacementLbl);
        LibraryEDoc.CreateDirectMapping(EDocMapping, EDocService, EDocMappingTestRec."Code Value", TextAndCodeReplacementLbl);
        LibraryEDoc.CreateDirectMapping(EDocMapping, EDocService, Format(EDocMappingTestRec."Decimal Value"), TextAndCodeReplacementLbl);
        EDocMapping.SetRange(Code, EDocService.Code);
        EDocMapping.FindSet();

        // [WHEN] Record is mapped into temporary record
        MapRecord(EDocMapping, EDocMappingTestRec, TempEDocMappingTestRec2);

        // [THEN] Text and Code types are mapped using rule, numeric types are not supported
        Assert.AreEqual(TextAndCodeReplacementLbl, TempEDocMappingTestRec2."Text Value", GeneralMappingRuleErr);
        Assert.AreEqual(TextAndCodeReplacementLbl, TempEDocMappingTestRec2."Code Value", GeneralMappingRuleErr);
        Assert.AreNotEqual(TextAndCodeReplacementLbl, TempEDocMappingTestRec2."Decimal Value", GeneralMappingRuleErr);
    end;

    [Test]
    procedure MappingTableRuleSuccess()
    var
        EDocMapping: Record "E-Doc. Mapping";
        TempEDocMappingTestRec2, TempEDocMappingTestRec3 : Record "E-Doc. Mapping Test Rec" temporary;
    begin
        // [FEATURE] [E-Document] [Mapping]
        // [SCENARIO] Map with rules for specific table - Direct mapping from A to B

        // [GIVEN] A record with different type of fields
        Initialize();
        EDocService.Get(LibraryEDoc.CreateService());

        LibraryPermission.SetTeamMember();
        EDocMappingTestRec.FindFirst();

        // [WHEN] A direct mapping is setup for table "E-Doc. Mapping Test Rec"
        LibraryEDoc.CreateDirectMapping(EDocMapping, EDocService, EDocMappingTestRec."Text Value", TextAndCodeReplacementLbl, Database::"E-Doc. Mapping Test Rec", 0);
        LibraryEDoc.CreateDirectMapping(EDocMapping, EDocService, EDocMappingTestRec."Code Value", TextAndCodeReplacementLbl, Database::"E-Doc. Mapping Test Rec", 0);
        LibraryEDoc.CreateDirectMapping(EDocMapping, EDocService, Format(EDocMappingTestRec."Decimal Value"), TextAndCodeReplacementLbl, Database::"E-Doc. Mapping Test Rec", 0);

        EDocMapping.SetRange(Code, EDocService.Code);
        EDocMapping.FindSet();

        // [WHEN] Record is mapped into temporary record
        MapRecord(EDocMapping, EDocMappingTestRec, TempEDocMappingTestRec2);

        // [THEN] Text and Code types are mapped using rule for table "E-Doc. Mapping Test Rec", numeric types are not supported
        Assert.AreEqual(TextAndCodeReplacementLbl, TempEDocMappingTestRec2."Text Value", GeneralMappingRuleErr);
        Assert.AreEqual(TextAndCodeReplacementLbl, TempEDocMappingTestRec2."Code Value", GeneralMappingRuleErr);
        Assert.AreNotEqual(TextAndCodeReplacementLbl, TempEDocMappingTestRec2."Decimal Value", GeneralMappingRuleErr);

        // [WHEN] A direct mapping is setup for table not "E-Doc. Mapping Test Rec"
        LibraryPermission.SetOutsideO365Scope();
        EDocMapping.DeleteAll();
        EDocMapping.Reset();
        EDocService.Get(LibraryEDoc.CreateService());
        LibraryPermission.SetTeamMember();

        LibraryEDoc.CreateDirectMapping(EDocMapping, EDocService, EDocMappingTestRec."Text Value", TextAndCodeReplacementLbl, Database::"E-Doc. Mapping", 0);
        LibraryEDoc.CreateDirectMapping(EDocMapping, EDocService, EDocMappingTestRec."Code Value", TextAndCodeReplacementLbl, Database::"E-Doc. Mapping", 0);
        LibraryEDoc.CreateDirectMapping(EDocMapping, EDocService, Format(EDocMappingTestRec."Decimal Value"), TextAndCodeReplacementLbl, Database::"E-Doc. Mapping", 0);
        EDocMapping.SetRange(Code, EDocService.Code);
        EDocMapping.FindSet();

        // [WHEN] Record is mapped into temporary record
        MapRecord(EDocMapping, EDocMappingTestRec, TempEDocMappingTestRec3);

        // [THEN] Text and Code types are not mapped using rule for table "E-Doc. Mapping Test Rec", numeric types are not supported
        Assert.AreNotEqual(TextAndCodeReplacementLbl, TempEDocMappingTestRec3."Text Value", GeneralMappingRuleErr);
        Assert.AreNotEqual(TextAndCodeReplacementLbl, TempEDocMappingTestRec3."Code Value", GeneralMappingRuleErr);
        Assert.AreNotEqual(TextAndCodeReplacementLbl, TempEDocMappingTestRec3."Decimal Value", GeneralMappingRuleErr);
    end;

    [Test]
    procedure MappingTableAndFieldRuleSuccess()
    var
        EDocMapping: Record "E-Doc. Mapping";
        TempEDocMappingTestRec2: Record "E-Doc. Mapping Test Rec" temporary;
    begin
        // [FEATURE] [E-Document] [Mapping]
        // [SCENARIO] Map with rules for specific table and field - Direct mapping from A to B

        // [GIVEN] A record with different type of fields
        Initialize();
        EDocService.Get(LibraryEDoc.CreateService());

        LibraryPermission.SetTeamMember();
        EDocMappingTestRec.FindFirst();

        // [WHEN] A direct mapping is setup for table "E-Doc. Mapping Test Rec" on fields Text Value and Key Field
        LibraryEDoc.CreateDirectMapping(EDocMapping, EDocService, EDocMappingTestRec."Text Value", TextAndCodeReplacementLbl, Database::"E-Doc. Mapping Test Rec", EDocMappingTestRec.FieldNo(EDocMappingTestRec."Text Value"));
        LibraryEDoc.CreateDirectMapping(EDocMapping, EDocService, EDocMappingTestRec."Code Value", TextAndCodeReplacementLbl, Database::"E-Doc. Mapping Test Rec", EDocMappingTestRec.FieldNo(EDocMappingTestRec."Key Field"));
        LibraryEDoc.CreateDirectMapping(EDocMapping, EDocService, Format(EDocMappingTestRec."Decimal Value"), TextAndCodeReplacementLbl, Database::"E-Doc. Mapping Test Rec", EDocMappingTestRec.FieldNo(EDocMappingTestRec."Decimal Value"));

        EDocMapping.SetRange(Code, EDocService.Code);
        EDocMapping.FindSet();

        // [WHEN] Record is mapped into temporary record
        MapRecord(EDocMapping, EDocMappingTestRec, TempEDocMappingTestRec2);

        // [THEN] Text is mapped using rule for table "E-Doc. Mapping Test Rec" and field Text Value
        // [THEN] Code Value was not found as we mapped on Key Field, which did not contain the value we were looking for. Numeric types are not supported
        Assert.AreEqual(TextAndCodeReplacementLbl, TempEDocMappingTestRec2."Text Value", GeneralMappingRuleErr);
        Assert.AreNotEqual(TextAndCodeReplacementLbl, TempEDocMappingTestRec2."Code Value", GeneralMappingRuleErr);
        Assert.AreNotEqual(TextAndCodeReplacementLbl, TempEDocMappingTestRec2."Decimal Value", GeneralMappingRuleErr);
    end;

    [Test]
    procedure MappingTransformationRuleSuccess()
    var
        TransformationRule: Record "Transformation Rule";
        EDocMapping: Record "E-Doc. Mapping";
        TempEDocMappingTestRec2: Record "E-Doc. Mapping Test Rec" temporary;
    begin
        // [FEATURE] [E-Document] [Mapping]
        // [SCENARIO] Map with transformation rule - GetFourthToSixthSubstringCode transformation rule on Text and Code values

        // [GIVEN] A record with different type of fields
        Initialize();
        EDocService.Get(LibraryEDoc.CreateService());

        LibraryPermission.SetTeamMember();
        EDocMappingTestRec.FindFirst();
        TransformationRule.CreateDefaultTransformations();
        TransformationRule.Get(TransformationRule.GetFourthToSixthSubstringCode());

        // [WHEN] A transformation mapping is setup
        LibraryEDoc.CreateTransformationMapping(EDocMapping, TransformationRule, EDocService.Code);
        EDocMapping.SetRange(Code, EDocService.Code);
        EDocMapping.FindSet();

        // [WHEN] Record is mapped into temporary record
        MapRecord(EDocMapping, EDocMappingTestRec, TempEDocMappingTestRec2);

        // [THEN] Text and Code types are mapped using rule, numeric types are not supported
        Assert.AreEqual(TransformationRule.TransformText(EDocMappingTestRec."Text Value"), TempEDocMappingTestRec2."Text Value", TranformationMappingRuleErr);
        Assert.AreEqual(TransformationRule.TransformText(EDocMappingTestRec."Code Value"), TempEDocMappingTestRec2."Code Value", TranformationMappingRuleErr);
        Assert.AreEqual(EDocMappingTestRec."Decimal Value", TempEDocMappingTestRec2."Decimal Value", TranformationMappingRuleErr);
    end;

    [Test]
    procedure MappingRuleWithChangesSuccess()
    var
        TransformationRule: Record "Transformation Rule";
        EDocMapping: Record "E-Doc. Mapping";
        TempEDocMappingTestRec2: Record "E-Doc. Mapping Test Rec" temporary;
        TempChanges: Record "E-Doc. Mapping" temporary;
    begin
        // [FEATURE] [E-Document] [Mapping]
        // [SCENARIO] Map with transformation rule - GetFourthToSixthSubstringCode transformation rule on Text and Code values and get changes in variable

        // [GIVEN] A record with different type of fields
        Initialize();
        EDocService.Get(LibraryEDoc.CreateService());

        LibraryPermission.SetTeamMember();
        EDocMappingTestRec.FindFirst();
        TransformationRule.CreateDefaultTransformations();
        TransformationRule.Get(TransformationRule.GetFourthToSixthSubstringCode());

        // [WHEN] A transformation mapping is setup
        LibraryEDoc.CreateTransformationMapping(EDocMapping, TransformationRule, EDocService.Code);
        EDocMapping.SetRange(Code, EDocService.Code);
        EDocMapping.FindSet();

        // [WHEN] Record is mapped into temporary record and changes ar stored in variable
        MapRecord(EDocMapping, EDocMappingTestRec, TempEDocMappingTestRec2, TempChanges);

        // [THEN] Text and Code types are mapped using rule, numeric types are not supported. Number of changes are 2.
        Assert.AreEqual(TransformationRule.TransformText(EDocMappingTestRec."Text Value"), TempEDocMappingTestRec2."Text Value", TranformationMappingRuleErr);
        Assert.AreEqual(TransformationRule.TransformText(EDocMappingTestRec."Code Value"), TempEDocMappingTestRec2."Code Value", TranformationMappingRuleErr);
        Assert.AreEqual(EDocMappingTestRec."Decimal Value", TempEDocMappingTestRec2."Decimal Value", TranformationMappingRuleErr);

        Assert.AreEqual(2, TempChanges.Count(), MappingChangesErr);
        TempChanges.FindSet();

        // [THEN] First change is text value.
        Assert.AreEqual(TransformationRule.TransformText(EDocMappingTestRec."Text Value"), TempChanges."Replace Value", MappingChangesErr);
        Assert.AreEqual(EDocMappingTestRec."Text Value", TempChanges."Find Value", MappingChangesErr);
        Assert.AreEqual(TransformationRule.GetFourthToSixthSubstringCode(), TempChanges."Transformation Rule", MappingChangesErr);
        Assert.AreEqual(Database::"E-Doc. Mapping Test Rec", TempChanges."Table ID", MappingChangesErr);
        Assert.AreEqual(EDocMappingTestRec.FieldNo(EDocMappingTestRec."Text Value"), TempChanges."Field ID", MappingChangesErr);

        // [THEN] Second change is code value.
        TempChanges.Next();
        Assert.AreEqual(TransformationRule.TransformText(EDocMappingTestRec."Code Value"), TempChanges."Replace Value", MappingChangesErr);
        Assert.AreEqual(EDocMappingTestRec."Code Value", TempChanges."Find Value", MappingChangesErr);
        Assert.AreEqual(TransformationRule.GetFourthToSixthSubstringCode(), TempChanges."Transformation Rule", MappingChangesErr);
        Assert.AreEqual(Database::"E-Doc. Mapping Test Rec", TempChanges."Table ID", MappingChangesErr);
        Assert.AreEqual(EDocMappingTestRec.FieldNo(EDocMappingTestRec."Code Value"), TempChanges."Field ID", MappingChangesErr);
    end;

    [Test]
    [HandlerFunctions('EDocServicesPageHandler,EDocChangesPreviewPageHandler')]
    procedure PreviewMappingUISuccess()
    var
        TransformationRule: Record "Transformation Rule";
        EDocMapping: Record "E-Doc. Mapping";
        TempEDocMappingTestRec2: Record "E-Doc. Mapping Test Rec" temporary;
        TempChanges: Record "E-Doc. Mapping" temporary;
    begin
        // [FEATURE] [E-Document] [Mapping]
        // [SCENARIO] Check that correct number of entries show up on preview mapping page

        // [GIVEN] A record with different type of fields
        Initialize();
        EDocService.Get(LibraryEDoc.CreateService());

        LibraryPermission.SetTeamMember();
        EDocMappingTestRec.FindFirst();
        TransformationRule.CreateDefaultTransformations();
        TransformationRule.Get(TransformationRule.GetFourthToSixthSubstringCode());

        // [WHEN] A transformation mapping is setup
        EDocService.Get(LibraryEDoc.CreateService());
        LibraryEDoc.CreateTransformationMapping(EDocMapping, TransformationRule, EDocService.Code);
        EDocMapping.SetRange(Code, EDocService.Code);
        EDocMapping.FindSet();

        // [WHEN] Record is mapped into temporary record and changes ar stored in variable
        MapRecord(EDocMapping, EDocMappingTestRec, TempEDocMappingTestRec2, TempChanges);

        // Run Preview Mapping
        TempChanges.FindSet();
        LibraryVariableStorage.Enqueue(TempChanges);
        TempChanges.Next();
        LibraryVariableStorage.Enqueue(TempChanges);
        EDocMappingMgt.PreviewMapping(EDocMappingTestRec, EDocMappingTestRec, EDocMappingTestRec.FieldNo(EDocMappingTestRec."Key Field"));
    end;

    local procedure Initialize()
    begin
        LibraryPermission.SetOutsideO365Scope();
        if IsInitialized then
            exit;

        LibraryPermission.PushPermissionSet('E-Doc. Test');
        EDocMappingTestRec.Init();
        EDocMappingTestRec."Key Field" := 1;
        EDocMappingTestRec."Code Value" := CopyStr(LibraryRandom.RandText(LibraryUtility.GetFieldLength(DATABASE::"E-Doc. Mapping Test Rec", EDocMappingTestRec.FieldNo("Code Value"))), 1, LibraryUtility.GetFieldLength(DATABASE::"E-Doc. Mapping Test Rec", EDocMappingTestRec.FieldNo("Code Value")));
        EDocMappingTestRec."Text Value" := CopyStr(LibraryRandom.RandText(LibraryUtility.GetFieldLength(DATABASE::"E-Doc. Mapping Test Rec", EDocMappingTestRec.FieldNo("Text Value"))), 1, LibraryUtility.GetFieldLength(DATABASE::"E-Doc. Mapping Test Rec", EDocMappingTestRec.FieldNo("Text Value")));
        EDocMappingTestRec."Decimal Value" := LibraryRandom.RandDec(5, 5);
        EDocMappingTestRec.Insert();
        LibraryPermission.SetOutsideO365Scope();

        IsInitialized := true;
    end;

    local procedure MapRecord(var EDocMapping: Record "E-Doc. Mapping"; var EDocMappingTest: Record "E-Doc. Mapping Test Rec"; var EDocMappingTest2: Record "E-Doc. Mapping Test Rec" temporary; var Changes: Record "E-Doc. Mapping" temporary)
    var
        InputRec, OutputRec : RecordRef;
    begin
        InputRec.GetTable(EDocMappingTest);
        OutputRec.GetTable(EDocMappingTest2);
        EDocMappingMgt.MapRecord(EDocMapping, InputRec, OutputRec, Changes);
        EDocMappingTest2.FindFirst();
    end;

    local procedure MapRecord(var EDocMapping: Record "E-Doc. Mapping"; var EDocMappingTest: Record "E-Doc. Mapping Test Rec"; var EDocMappingTest2: Record "E-Doc. Mapping Test Rec" temporary)
    var
        TempChanges: Record "E-Doc. Mapping" temporary;
    begin
        MapRecord(EDocMapping, EDocMappingTest, EDocMappingTest2, TempChanges);
    end;

    [ModalPageHandler]
    internal procedure EDocServicesPageHandler(var EDocServicesPage: TestPage "E-Document Services")
    begin
        EDocServicesPage.Filter.SetFilter(Code, EDocService.Code);
        EDocServicesPage.First();
        EDocServicesPage.OK().Invoke();
    end;

    [PageHandler]
    internal procedure EDocChangesPreviewPageHandler(var EDocChangesPreview: TestPage "E-Doc. Changes Preview")
    var
        TransformationRule: Record "Transformation Rule";
        TempChanges, TempChanges2 : Record "E-Doc. Mapping" temporary;
        ChangesVariant, ChangesVariant2 : Variant;
    begin
        EDocChangesPreview."Applied Mapping".First();
        Assert.AreEqual('', EDocChangesPreview."Applied Mapping"."Find Value".Value(), MappingPreviewPageErr);
        Assert.AreEqual('', EDocChangesPreview."Applied Mapping"."Replace Value".Value(), MappingPreviewPageErr);
        Assert.AreEqual(TransformationRule.GetFourthToSixthSubstringCode(), EDocChangesPreview."Applied Mapping"."Transformation Rule".Value(), MappingPreviewPageErr);
        Assert.AreEqual('0', EDocChangesPreview."Applied Mapping"."Field ID".Value(), MappingPreviewPageErr);
        Assert.AreEqual('0', EDocChangesPreview."Applied Mapping"."Table ID".Value(), MappingPreviewPageErr);
        Assert.IsFalse(EDocChangesPreview."Applied Mapping".Next(), MappingPreviewPageErr);

        EDocChangesPreview."Document Header Changes".First();
        LibraryVariableStorage.Dequeue(ChangesVariant);
        TempChanges := ChangesVariant;
        Assert.AreEqual(TempChanges."Find Value", EDocChangesPreview."Document Header Changes"."Find Value".Value(), MappingPreviewPageErr);
        Assert.AreEqual(TempChanges."Replace Value", EDocChangesPreview."Document Header Changes"."Replace Value".Value(), MappingPreviewPageErr);

        EDocChangesPreview."Document Header Changes".Next();
        LibraryVariableStorage.Dequeue(ChangesVariant2);
        TempChanges2 := ChangesVariant2;
        Assert.AreEqual(TempChanges2."Find Value", EDocChangesPreview."Document Header Changes"."Find Value".Value(), MappingPreviewPageErr);
        Assert.AreEqual(TempChanges2."Replace Value", EDocChangesPreview."Document Header Changes"."Replace Value".Value(), MappingPreviewPageErr);
        Assert.IsFalse(EDocChangesPreview."Document Header Changes".Next(), MappingPreviewPageErr);

        EDocChangesPreview."Document Lines Changes".First();
        TempChanges := ChangesVariant;
        Assert.AreEqual(TempChanges."Find Value", EDocChangesPreview."Document Lines Changes"."Find Value".Value(), MappingPreviewPageErr);
        Assert.AreEqual(TempChanges."Replace Value", EDocChangesPreview."Document Lines Changes"."Replace Value".Value(), MappingPreviewPageErr);

        EDocChangesPreview."Document Lines Changes".Next();
        TempChanges := ChangesVariant2;
        Assert.AreEqual(TempChanges."Find Value", EDocChangesPreview."Document Lines Changes"."Find Value".Value(), MappingPreviewPageErr);
        Assert.AreEqual(TempChanges."Replace Value", EDocChangesPreview."Document Lines Changes"."Replace Value".Value(), MappingPreviewPageErr);
        Assert.IsFalse(EDocChangesPreview."Document Lines Changes".Next(), MappingPreviewPageErr);
    end;

}