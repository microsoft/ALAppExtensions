/// <summary>
/// Provides utility functions for creating and managing Rapid Implementation Methodology (RapidStart) configurations in test scenarios.
/// </summary>
codeunit 131903 "Library - Rapid Start"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        TemplateSelectionRuleTxt: Label '<?xml version="1.0" encoding="utf-8" standalone="yes"?><ReportParameters><DataItems><DataItem name="%1">SORTING(Field1) WHERE(Field%2=1(%3))</DataItem></DataItems></ReportParameters>', Locked = true;

    procedure CleanUp(PackageCode: Code[20])
    var
        ConfigLine: Record "Config. Line";
        ConfigPackage: Record "Config. Package";
        ConfigPackageError: Record "Config. Package Error";
    begin
        if PackageCode <> '' then begin
            ConfigPackage.SetRange(Code, PackageCode);
            ConfigLine.SetRange("Package Code", PackageCode);
            ConfigPackageError.SetRange("Package Code", PackageCode);
        end;
        ConfigPackage.DeleteAll(true);
        ConfigLine.DeleteAll(true);
        ConfigPackageError.DeleteAll();
        ClearLastError();
    end;

    procedure CreateConfigTemplateHeader(var ConfigTemplateHeader: Record "Config. Template Header")
    begin
        ConfigTemplateHeader.Init();
        ConfigTemplateHeader.Validate(
          Code,
          LibraryUtility.GenerateRandomCode(ConfigTemplateHeader.FieldNo(Code), DATABASE::"Config. Template Header"));
        // Validating Code as Description because value is not important.
        ConfigTemplateHeader.Validate(Description, ConfigTemplateHeader.Code);
        ConfigTemplateHeader.Insert(true);
    end;

    procedure CreateConfigTemplateLine(var ConfigTemplateLine: Record "Config. Template Line"; ConfigTemplateCode: Code[10])
    var
        RecRef: RecordRef;
    begin
        ConfigTemplateLine.Init();
        ConfigTemplateLine.Validate("Data Template Code", ConfigTemplateCode);
        RecRef.GetTable(ConfigTemplateLine);
        ConfigTemplateLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ConfigTemplateLine.FieldNo("Line No.")));
        ConfigTemplateLine.Insert(true);
    end;

    procedure CreateTemplateSelectionRule(var ConfigTmplSelectionRules: Record "Config. Tmpl. Selection Rules"; FieldNo: Integer; FieldValue: Text; "Order": Integer; PageID: Integer; ConfigTemplateHeader: Record "Config. Template Header")
    var
        TableMetadata: Record "Table Metadata";
        CriteriaOutStream: OutStream;
    begin
        ConfigTmplSelectionRules.Init();
        ConfigTmplSelectionRules.Order := Order;
        ConfigTmplSelectionRules."Table ID" := ConfigTemplateHeader."Table ID";
        ConfigTmplSelectionRules."Template Code" := ConfigTemplateHeader.Code;
        ConfigTmplSelectionRules."Page ID" := PageID;
        ConfigTmplSelectionRules."Selection Criteria".CreateOutStream(CriteriaOutStream);
        TableMetadata.Get(ConfigTmplSelectionRules."Table ID");
        CriteriaOutStream.WriteText(StrSubstNo(TemplateSelectionRuleTxt, TableMetadata.Caption, FieldNo, FieldValue));
        ConfigTmplSelectionRules.Insert(true);
    end;

    procedure CreateQuestionnaire(var ConfigQuestionnaire: Record "Config. Questionnaire")
    begin
        ConfigQuestionnaire.Init();
        ConfigQuestionnaire.Validate(
          Code,
          LibraryUtility.GenerateRandomCode(ConfigQuestionnaire.FieldNo(Code), DATABASE::"Config. Questionnaire"));
        // Validating Code as Description because value is not important.
        ConfigQuestionnaire.Validate(Description, ConfigQuestionnaire.Code);
        ConfigQuestionnaire.Insert(true);
    end;

    procedure CreateQuestion(var ConfigQuestion: Record "Config. Question"; ConfigQuestionArea: Record "Config. Question Area")
    var
        ConfigQuestion2: Record "Config. Question";
    begin
        ConfigQuestion2.SetRange("Questionnaire Code", ConfigQuestionArea."Questionnaire Code");
        ConfigQuestion2.SetRange("Question Area Code", ConfigQuestionArea.Code);
        if ConfigQuestion2.FindLast() then;  // IF condition is required because Question may not be found.

        ConfigQuestion.Init();
        ConfigQuestion.Validate("Questionnaire Code", ConfigQuestionArea."Questionnaire Code");
        ConfigQuestion.Validate("Question Area Code", ConfigQuestionArea.Code);
        ConfigQuestion.Validate("No.", ConfigQuestion2."No." + 1);
        ConfigQuestion.Insert(true);
    end;

    procedure CreateQuestionArea(var ConfigQuestionArea: Record "Config. Question Area"; QuestionnaireCode: Code[10])
    begin
        ConfigQuestionArea.Init();
        ConfigQuestionArea.Validate("Questionnaire Code", QuestionnaireCode);
        ConfigQuestionArea.Validate(
          Code,
          LibraryUtility.GenerateRandomCode(ConfigQuestionArea.FieldNo(Code), DATABASE::"Config. Question Area"));
        // Validating Primary Key as Description because value is not important.
        ConfigQuestionArea.Validate(Description, ConfigQuestionArea."Questionnaire Code" + ConfigQuestionArea.Code);
        ConfigQuestionArea.Insert(true);
    end;

    procedure CreatePackage(var ConfigPackage: Record "Config. Package")
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(DATABASE::"Config. Package");
        ConfigPackage.Init();
        ConfigPackage.Validate(
          Code,
          LibraryUtility.GenerateRandomCode(ConfigPackage.FieldNo(Code), DATABASE::"Config. Package"));
        ConfigPackage.Validate("Package Name", 'Package ' + Format(ConfigPackage.Code));
        ConfigPackage.Insert(true);
    end;

    procedure CreatePackageTable(var ConfigPackageTable: Record "Config. Package Table"; PackageCode: Code[20]; TableID: Integer)
    begin
        ConfigPackageTable.Init();
        ConfigPackageTable.Validate("Package Code", PackageCode);
        ConfigPackageTable.Validate("Table ID", TableID);
        ConfigPackageTable.Insert(true);
    end;

    procedure CreatePackageTableRule(var ConfigTableProcessingRule: Record "Config. Table Processing Rule"; ConfigPackageTable: Record "Config. Package Table"; ProcessingAction: Option; CodeunitID: Integer)
    begin
        ConfigTableProcessingRule.Init();
        ConfigTableProcessingRule.Validate("Package Code", ConfigPackageTable."Package Code");
        ConfigTableProcessingRule.Validate("Table ID", ConfigPackageTable."Table ID");
        ConfigTableProcessingRule."Rule No." += 10000;
        ConfigTableProcessingRule.Validate(Action, ProcessingAction);
        ConfigTableProcessingRule.Validate("Custom Processing Codeunit ID", CodeunitID);
        ConfigTableProcessingRule.Insert(true);
    end;

    procedure CreatePackageTableRuleFilter(var ConfigPackageFilter: Record "Config. Package Filter"; ConfigTableProcessingRule: Record "Config. Table Processing Rule"; FieldID: Integer; FilterValue: Text[250])
    begin
        ConfigPackageFilter.Init();
        ConfigPackageFilter.Validate("Package Code", ConfigTableProcessingRule."Package Code");
        ConfigPackageFilter.Validate("Table ID", ConfigTableProcessingRule."Table ID");
        ConfigPackageFilter.Validate("Processing Rule No.", ConfigTableProcessingRule."Rule No.");
        ConfigPackageFilter.Validate("Field ID", FieldID);
        ConfigPackageFilter.Validate("Field Filter", FilterValue);
        ConfigPackageFilter.Insert(true);
    end;

    procedure CreatePackageRecord(var ConfigPackageRecord: Record "Config. Package Record"; PackageCode: Code[20]; TableID: Integer; RecNo: Integer)
    begin
        ConfigPackageRecord.Init();
        ConfigPackageRecord.Validate("Package Code", PackageCode);
        ConfigPackageRecord.Validate("Table ID", TableID);
        ConfigPackageRecord.Validate("No.", RecNo);
        if ConfigPackageRecord.Insert() then;
    end;

    procedure CreatePackageFieldData(ConfigPackageRecord: Record "Config. Package Record"; FieldID: Integer; Value: Text[250])
    var
        ConfigPackageData: Record "Config. Package Data";
    begin
        ConfigPackageData.Init();
        ConfigPackageData.Validate("Package Code", ConfigPackageRecord."Package Code");
        ConfigPackageData.Validate("Table ID", ConfigPackageRecord."Table ID");
        ConfigPackageData.Validate("No.", ConfigPackageRecord."No.");
        ConfigPackageData.Validate("Field ID", FieldID);
        ConfigPackageData.Validate(Value, Value);
        ConfigPackageData.Insert(true);
    end;

    procedure CreatePackageData(PackageCode: Code[20]; TableID: Integer; RecNo: Integer; FieldID: Integer; Value: Text[250])
    var
        ConfigPackageRecord: Record "Config. Package Record";
    begin
        CreatePackageRecord(ConfigPackageRecord, PackageCode, TableID, RecNo);
        CreatePackageFieldData(ConfigPackageRecord, FieldID, Value);
    end;

    procedure CreatePackageDataForField(var ConfigPackage: Record "Config. Package"; var ConfigPackageTable: Record "Config. Package Table"; TableID: Integer; FieldID: Integer; Value: Code[250]; RecNo: Integer)
    begin
        if ConfigPackage.Code = '' then
            CreatePackage(ConfigPackage);

        if ConfigPackageTable."Table ID" = 0 then
            CreatePackageTable(ConfigPackageTable, ConfigPackage.Code, TableID);

        CreatePackageData(ConfigPackage.Code, TableID, RecNo, FieldID, Value);
    end;

    procedure CreateConfigLine(var ConfigLine: Record "Config. Line"; LineType: Option "Area",Group,"Table"; TableID: Integer; LineName: Text[50]; PackageCode: Code[20]; Dimensions: Boolean)
    var
        ConfigMgt: Codeunit "Config. Management";
        ConfigPackageManagement: Codeunit "Config. Package Management";
        NextLineNo: Integer;
    begin
        NextLineNo := 0;
        ConfigLine.Reset();
        if ConfigLine.FindLast() then
            NextLineNo := ConfigLine."Line No." + 10000;

        ConfigLine.Init();
        ConfigLine.Validate("Line No.", NextLineNo);
        ConfigLine.Validate("Line Type", LineType);
        if LineType = LineType::Table then
            ConfigLine.Validate("Table ID", TableID)
        else
            ConfigLine.Validate(Name, LineName);
        ConfigLine.Insert(true);

        ConfigMgt.AssignParentLineNos();

        if PackageCode <> '' then begin
            ConfigLine.SetRange("Line No.", ConfigLine."Line No.");
            ConfigPackageManagement.AssignPackage(ConfigLine, PackageCode);
            ConfigLine.SetRange("Line No.");
        end;

        if Dimensions then begin
            ConfigLine.Get(NextLineNo);
            ConfigLine.Validate("Dimensions as Columns", true);
            ConfigLine.Modify(true);
        end;
    end;

    procedure SetIncludeOneField(PackageCode: Code[20]; TableID: Integer; FieldID: Integer; SetInclude: Boolean)
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.Get(PackageCode, TableID, FieldID);
        ConfigPackageField.Validate("Include Field", SetInclude);
        ConfigPackageField.Modify();
    end;

    procedure SetIncludeFields(PackageCode: Code[20]; TableID: Integer; FromFieldID: Integer; ToFieldID: Integer; SetInclude: Boolean)
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.Reset();
        ConfigPackageField.SetRange("Package Code", PackageCode);
        ConfigPackageField.SetRange("Table ID", TableID);
        ConfigPackageField.SetRange("Field ID", FromFieldID, ToFieldID);
        ConfigPackageField.ModifyAll("Include Field", SetInclude, true);
    end;

    procedure SetIncludeAllFields(CoonfigPackageCode: Code[20]; TableNo: Integer; SetInclude: Boolean)
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.SetRange("Package Code", CoonfigPackageCode);
        ConfigPackageField.SetRange("Table ID", TableNo);
        ConfigPackageField.SetRange("Primary Key", false);
        ConfigPackageField.ModifyAll("Include Field", SetInclude, true);
    end;

    procedure SetValidateOneField(PackageCode: Code[20]; TableID: Integer; FieldID: Integer; SetValidate: Boolean)
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.Get(PackageCode, TableID, FieldID);
        ConfigPackageField.Validate("Validate Field", SetValidate);
        ConfigPackageField.Modify();
    end;

    procedure SetProcessingOrderForRecord(PackageCode: Code[20]; TableID: Integer; ProcessingNo: Integer)
    var
        ConfigPackageTable: Record "Config. Package Table";
    begin
        ConfigPackageTable.Get(PackageCode, TableID);
        ConfigPackageTable."Processing Order" := ProcessingNo;
        ConfigPackageTable.Modify();
    end;

    procedure SetProcessingOrderForField(PackageCode: Code[20]; TableID: Integer; FieldID: Integer; ProcessingNo: Integer)
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.Get(PackageCode, TableID, FieldID);
        ConfigPackageField."Processing Order" := ProcessingNo;
        ConfigPackageField.Modify();
    end;

    procedure SetCreateMissingCodesForField(PackageCode: Code[20]; TableID: Integer; FieldID: Integer; SetCreateMissingCodes: Boolean)
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.Get(PackageCode, TableID, FieldID);
        ConfigPackageField.Validate("Create Missing Codes", SetCreateMissingCodes);
        ConfigPackageField.Modify();
    end;

    procedure ApplyPackage(ConfigPackage: Record "Config. Package"; SetupProcessingOrderForTables: Boolean)
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageMgt: Codeunit "Config. Package Management";
    begin
        ConfigPackageMgt.SetHideDialog(true);
        ConfigPackageTable.SetRange("Package Code", ConfigPackage.Code);
        ConfigPackageMgt.ApplyPackage(ConfigPackage, ConfigPackageTable, SetupProcessingOrderForTables);
    end;

    procedure ValidatePackage(ConfigPackage: Record "Config. Package"; SetupProcessingOrderForTables: Boolean)
    var
        ConfigPackageTable: Record "Config. Package Table";
        TempConfigPackageTable: Record "Config. Package Table" temporary;
        ConfigPackageMgt: Codeunit "Config. Package Management";
    begin
        ConfigPackageMgt.SetHideDialog(true);
        ConfigPackageTable.SetRange("Package Code", ConfigPackage.Code);
        ConfigPackageMgt.ValidatePackageRelations(ConfigPackageTable, TempConfigPackageTable, SetupProcessingOrderForTables);
    end;
}

