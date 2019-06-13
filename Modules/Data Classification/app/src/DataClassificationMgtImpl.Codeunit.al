// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1753 "Data Classification Mgt. Impl."
{

    trigger OnRun()
    begin
    end;

    var
        DataSensitivityOptionStringTxt: Label 'Unclassified,Sensitive,Personal,Company Confidential,Normal', Comment = 'It needs to be translated as the field Data Sensitivity on Page 1751 Data Classification WorkSheet and field Data Sensitivity of Table 1180 Data Sensitivity Entities';
        LegalDisclaimerTxt: Label 'Microsoft is providing this Data Classification feature as a matter of convenience only. It''s your responsibility to classify the data appropriately and comply with any laws and regulations that are applicable to you. Microsoft disclaims all responsibility towards any claims related to your classification of the data.';

    [Scope('OnPrem')]
    procedure PopulateDataSensitivityTable()
    var
        "Field": Record "Field";
        DataSensitivity: Record "Data Sensitivity";
    begin
        GetEnabledSensitiveFields(Field);

        if Field.FindSet() then
            repeat
                InsertDataSensitivityForField(Field.TableNo, Field."No.", DataSensitivity."Data Sensitivity"::Unclassified);
            until Field.Next() = 0;

        SetLastSyncDateTimeForField();
    end;

    [Scope('OnPrem')]
    procedure InsertDataSensitivityForField(TableNo: Integer; FieldNo: Integer; DataSensitivityOption: Option)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        DataSensitivity.Init();
        DataSensitivity."Company Name" := CompanyName();
        DataSensitivity."Table No" := TableNo;
        DataSensitivity."Field No" := FieldNo;
        DataSensitivity."Data Sensitivity" := DataSensitivityOption;
        DataSensitivity.Insert();
    end;

    local procedure SetLastSyncDateTimeForField()
    var
        FieldsSyncStatus: Record "Fields Sync Status";
    begin
        if FieldsSyncStatus.Get() then begin
            FieldsSyncStatus."Last Sync Date Time" := CurrentDateTime();
            FieldsSyncStatus.Modify();
        end else begin
            FieldsSyncStatus."Last Sync Date Time" := CurrentDateTime();
            FieldsSyncStatus.Insert();
        end;
    end;

    [Scope('OnPrem')]
    procedure SetTableClassifications(var DataPrivacyEntities: Record "Data Privacy Entities")
    begin
        DataPrivacyEntities.SetRange(Include, true);
        if DataPrivacyEntities.FindSet() then
            repeat
                SetFieldsClassifications(DataPrivacyEntities."Table No.", DataPrivacyEntities."Default Data Sensitivity");
            until DataPrivacyEntities.Next() = 0;
    end;

    local procedure SetFieldsClassifications(TableNo: Integer; Class: Option)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        DataSensitivity.SetRange("Company Name", CompanyName());
        DataSensitivity.SetRange("Table No", TableNo);
        SetSensitivities(DataSensitivity, Class);
    end;

    [Scope('OnPrem')]
    procedure SetSensitivities(var DataSensitivity: Record "Data Sensitivity"; Sensitivity: Option)
    var
        Now: DateTime;
    begin
        // MODIFYALL does not result in a bulk query for this table,looping through the records performs faster
        // and eliminates issues with the filters of the record
        Now := CurrentDateTime();
        if DataSensitivity.FindSet() then
            repeat
                DataSensitivity."Data Sensitivity" := Sensitivity;
                DataSensitivity."Last Modified By" := UserSecurityId();
                DataSensitivity."Last Modified" := Now;
                DataSensitivity.Modify();
            until DataSensitivity.Next() = 0;
    end;

    [Scope('OnPrem')]
    procedure FindSimilarFieldsInRelatedTables(var DataSensitivity: Record "Data Sensitivity")
    var
        TempDataPrivacyEntities: Record "Data Privacy Entities" temporary;
        RecRef: RecordRef;
        FieldCaptionFilter: Text;
        TableNoFilter: Text;
    begin
        if DataSensitivity.FindSet() then begin
            // Form a filter using the Field Captions of all the fields that are included in the (filtered) DataSensitivity table
            FieldCaptionFilter := GetFieldCaptionFilterText(DataSensitivity);

            // Get the related tables of all the tables that are included in the (filtered) DataSensitivity table
            GetRelatedTables(DataSensitivity, TempDataPrivacyEntities);

            DataSensitivity.Reset();

            FilterDataSensitivityByFieldCaption(DataSensitivity, FieldCaptionFilter);

            RecRef.GetTable(TempDataPrivacyEntities);
            TableNoFilter := GetFilterTextForFieldValuesInTable(RecRef, TempDataPrivacyEntities.FieldNo("Table No."));

            DataSensitivity.SetFilter("Table No", TableNoFilter);

            // Performing a FINDFIRST s.t. the cursor is reset on the Data Sensitivity table
            if DataSensitivity.FindFirst() then;
        end;
    end;

    local procedure GetFieldCaptionFilterText(var DataSensitivity: Record "Data Sensitivity"): Text
    var
        FieldCaptionFilter: Text;
    begin
        repeat
            DataSensitivity.CalcFields("Field Caption");
            FieldCaptionFilter += StrSubstNo('''*%1*''|', DelChr(DataSensitivity."Field Caption", '=', ''''));
        until DataSensitivity.Next() = 0;

        FieldCaptionFilter := DelChr(FieldCaptionFilter, '>', '|');

        exit(FieldCaptionFilter);
    end;

    local procedure GetRelatedTables(var DataSensitivity: Record "Data Sensitivity"; var TempDataPrivacyEntities: Record "Data Privacy Entities" temporary)
    var
        PrevTableNo: Integer;
    begin
        repeat
            if PrevTableNo <> DataSensitivity."Table No" then begin
                GetRelatedTablesForTable(TempDataPrivacyEntities, DataSensitivity."Table No");
                PrevTableNo := DataSensitivity."Table No";
            end;
        until DataSensitivity.Next() = 0;
    end;

    [Scope('OnPrem')]
    procedure GetRelatedTablesForTable(var TempDataPrivacyEntitiesOut: Record "Data Privacy Entities" temporary; TableNo: Integer)
    var
        TableRelationsMetadata: Record "Table Relations Metadata";
    begin
        TableRelationsMetadata.SetRange("Related Table ID", TableNo);
        if TableRelationsMetadata.FindSet() then
            repeat
                TempDataPrivacyEntitiesOut.InsertRow(TableRelationsMetadata."Table ID", 0, 0, '', 0);
            until TableRelationsMetadata.Next() = 0;
    end;

    local procedure FilterDataSensitivityByFieldCaption(var DataSensitivity: Record "Data Sensitivity"; FieldCaptionFilter: Text)
    begin
        DataSensitivity.SetRange("Company Name", CompanyName());
        DataSensitivity.FilterGroup(2);
        DataSensitivity.SetFilter("Field Caption", FieldCaptionFilter);
    end;

    [Scope('OnPrem')]
    procedure GetTableNoFilterForTablesWhoseNameContains(Name: Text): Text
    var
        "Field": Record "Field";
        RecRef: RecordRef;
    begin
        Field.SetRange(DataClassification, Field.DataClassification::CustomerContent);
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        Field.SetFilter(TableName, StrSubstNo('*%1*', Name));

        RecRef.GetTable(Field);
        exit(GetFilterTextForFieldValuesInTable(RecRef, Field.FieldNo(TableNo)));
    end;

    [Scope('OnPrem')]
    procedure PopulateFieldValue(FieldRef: FieldRef; var FieldContentBuffer: Record "Field Content Buffer")
    var
        FieldValueText: Text;
    begin
        if IsFlowField(FieldRef) then
            FieldRef.CalcField();
        Evaluate(FieldValueText, Format(FieldRef.Value(), 0, 9));
        if FieldValueText <> '' then
            if not FieldContentBuffer.Get(FieldValueText) then begin
                FieldContentBuffer.Init();
                FieldContentBuffer.Value := CopyStr(FieldValueText, 1, 250);
                FieldContentBuffer.Insert();
            end;
    end;

    local procedure IsFlowField(FieldRef: FieldRef): Boolean
    var
        OptionVar: Option Normal,FlowFilter,FlowField;
    begin
        Evaluate(OptionVar, Format(FieldRef.Class()));
        exit(OptionVar = OptionVar::FlowField);
    end;

    [Scope('OnPrem')]
    procedure SyncAllFields()
    var
        "Field": Record "Field";
    begin
        RunSync(Field);
    end;

    [Scope('OnPrem')]
    procedure RunSync("Field": Record "Field")
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        DataSensitivity.SetRange("Company Name", CompanyName());
        if DataSensitivity.IsEmpty() then begin
            PopulateDataSensitivityTable();
            exit;
        end;

        Field.SetRange(Class, Field.Class::Normal);
        GetEnabledSensitiveFields(Field);

        UpdateDataSensitivityTable(Field);

        SetLastSyncDateTimeForField();
    end;

    local procedure UpdateDataSensitivityTable("Field": Record "Field")
    var
        DataSensitivity: Record "Data Sensitivity";
        TempDataSensitivity: Record "Data Sensitivity" temporary;
    begin
        if Field.FindSet() then begin
            // Read all records from the Data Sensitivity table into a temporary variable
            PopulateTempDataSensitivity(TempDataSensitivity);

            // Go through all the entries in the Field table and if they are present in the temporary variable, then delete them
            // from the temporary variable; otherwise, they are new fields and they are inserted in the Data Sensitivity table
            repeat
                if TempDataSensitivity.Get(CompanyName(), Field.TableNo, Field."No.") then
                    TempDataSensitivity.Delete()
                else
                    InsertDataSensitivityForField(Field.TableNo, Field."No.", DataSensitivity."Data Sensitivity"::Unclassified)
            until Field.Next() = 0;
        end;

        // Now the temporary variable only includes entries that are not present in the Field record, so these should
        // be removed from the Data Sensitivity table if they are not classified
        DeleteUnclasifiedEntriesInDataSensitivity(TempDataSensitivity);
    end;

    local procedure PopulateTempDataSensitivity(var TempDataSensitivity: Record "Data Sensitivity" temporary)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        if DataSensitivity.FindSet() then
            repeat
                TempDataSensitivity.TransferFields(DataSensitivity, true);
                TempDataSensitivity.Insert();
            until DataSensitivity.Next() = 0;
    end;

    local procedure DeleteUnclasifiedEntriesInDataSensitivity(TempDataSensitivity: Record "Data Sensitivity" temporary)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        if TempDataSensitivity.FindSet() then
            repeat
                if TempDataSensitivity."Data Sensitivity" = TempDataSensitivity."Data Sensitivity"::Unclassified then begin
                    DataSensitivity.Get(TempDataSensitivity."Company Name", TempDataSensitivity."Table No", TempDataSensitivity."Field No");
                    DataSensitivity.Delete();
                end;
            until TempDataSensitivity.Next() = 0;
    end;

    [Scope('OnPrem')]
    procedure AreAllFieldsClassified(): Boolean
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        if not DataSensitivity.WritePermission() then
            exit;

        DataSensitivity.SetRange("Company Name", CompanyName());
        DataSensitivity.SetRange("Data Sensitivity", DataSensitivity."Data Sensitivity"::Unclassified);

        exit(DataSensitivity.IsEmpty());
    end;

    [Scope('OnPrem')]
    procedure GetDataSensitivityOptionString(): Text
    begin
        exit(DataSensitivityOptionStringTxt);
    end;

    [Scope('OnPrem')]
    procedure GetLegalDisclaimerTxt(): Text
    begin
        exit(LegalDisclaimerTxt);
    end;

    [Scope('OnPrem')]
    procedure SetTableFieldsToNormal(TableNumber: Integer)
    var
        "Field": Record "Field";
    begin
        Field.SetRange(TableNo, TableNumber);
        GetSensitiveFields(Field);

        if Field.FindSet() then
            repeat
                SetFieldToNormal(Field.TableNo, Field."No.");
            until Field.Next() = 0;
    end;

    [Scope('OnPrem')]
    procedure SetFieldToPersonal(TableNo: Integer; FieldNo: Integer)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        SetDataSensitivityForField(TableNo, FieldNo, DataSensitivity."Data Sensitivity"::Personal);
    end;

    [Scope('OnPrem')]
    procedure SetFieldToSensitive(TableNo: Integer; FieldNo: Integer)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        SetDataSensitivityForField(TableNo, FieldNo, DataSensitivity."Data Sensitivity"::Sensitive);
    end;

    [Scope('OnPrem')]
    procedure SetFieldToCompanyConfidential(TableNo: Integer; FieldNo: Integer)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        SetDataSensitivityForField(TableNo, FieldNo, DataSensitivity."Data Sensitivity"::"Company Confidential");
    end;

    [Scope('OnPrem')]
    procedure SetFieldToNormal(TableNo: Integer; FieldNo: Integer)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        SetDataSensitivityForField(TableNo, FieldNo, DataSensitivity."Data Sensitivity"::Normal);
    end;

    local procedure SetDataSensitivityForField(TableNo: Integer; FieldNo: Integer; DataSensitivityOption: Option Unclassified,Sensitive,Personal,"Company Confidential",Normal)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        if DataSensitivity.Get(CompanyName(), TableNo, FieldNo) then begin
            DataSensitivity."Data Sensitivity" := DataSensitivityOption;
            DataSensitivity.Modify();
        end else
            InsertDataSensitivityForField(TableNo, FieldNo, DataSensitivityOption);
    end;

    [Scope('OnPrem')]
    procedure DataPrivacyEntitiesExist(): Boolean
    var
        TempDataPrivacyEntities: Record "Data Privacy Entities" temporary;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        RecordRef: RecordRef;
    begin
        DataClassificationMgt.OnGetPrivacyMasterTables(TempDataPrivacyEntities);

        if TempDataPrivacyEntities.FindSet() then
            repeat
                RecordRef.Open(TempDataPrivacyEntities."Table No.");
                if (not RecordRef.IsEmpty()) and (TempDataPrivacyEntities."Table No." <> DATABASE::User) then
                    exit(true);
                RecordRef.Close();
            until TempDataPrivacyEntities.Next() = 0;
    end;

    [Scope('OnPrem')]
    procedure IsDataSensitivityEmptyForCurrentCompany(): Boolean
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        DataSensitivity.SetRange("Company Name", CompanyName());
        exit(DataSensitivity.IsEmpty());
    end;

    [Scope('OnPrem')]
    procedure SetEntityType(var DataPrivacyEntities: Record "Data Privacy Entities"; EntityTypeText: Text[80])
    var
        DataPrivacyWizard: Page "Data Privacy Wizard";
        EntityTypeTableNo: Integer;
    begin
        DataPrivacyEntities.SetRange("Table Caption", EntityTypeText);
        if DataPrivacyEntities.FindFirst() then
            EntityTypeTableNo := DataPrivacyEntities."Table No.";
        Clear(DataPrivacyEntities);
        DataPrivacyWizard.SetEntitityType(EntityTypeText, EntityTypeTableNo);
        DataPrivacyWizard.RunModal();
    end;

    [Scope('OnPrem')]
    procedure GetEnabledSensitiveFields(var "Field": Record "Field")
    begin
        Field.SetRange(Enabled, true);
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        GetSensitiveFields(Field);
    end;

    [Scope('OnPrem')]
    procedure GetSensitiveFields(var "Field": Record "Field")
    begin
        Field.SetFilter(
          DataClassification,
          StrSubstNo('%1|%2|%3',
            Field.DataClassification::CustomerContent,
            Field.DataClassification::EndUserIdentifiableInformation,
            Field.DataClassification::EndUserPseudonymousIdentifiers));
    end;

    local procedure GetFilterTextForFieldValuesInTable(var RecRef: RecordRef; FieldNo: Integer): Text
    var
        FilterText: Text;
    begin
        if RecRef.FindSet() then begin
            repeat
                FilterText := StrSubstNo('%1|%2', FilterText, RecRef.Field(FieldNo));
            until RecRef.Next() = 0;

            // remove the first vertical bar from the filter text
            FilterText := DelChr(FilterText, '<', '|');
        end;

        exit(FilterText);
    end;
}

