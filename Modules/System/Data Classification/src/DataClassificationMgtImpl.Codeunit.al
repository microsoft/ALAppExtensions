// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1753 "Data Classification Mgt. Impl."
{
    Access = Internal;
    Permissions = tabledata "Data Sensitivity" = rimd,
                  tabledata Field = r,
                  tabledata "Table Relations Metadata" = r;

    var
        DataSensitivityOptionStringTxt: Label 'Unclassified,Sensitive,Personal,Company Confidential,Normal', Comment = 'It needs to be translated as the field Data Sensitivity on Page 1751 Data Classification WorkSheet and field Data Sensitivity of Table 1180 Data Privacy Entities';
        LegalDisclaimerTxt: Label 'Microsoft is providing this Data Classification feature as a matter of convenience only. It''s your responsibility to classify the data appropriately and comply with any laws and regulations that are applicable to you. Microsoft disclaims all responsibility towards any claims related to your classification of the data.';

    procedure PopulateDataSensitivityTable()
    var
        "Field": Record "Field";
        DataSensitivity: Record "Data Sensitivity";
        FieldsSyncStatusManagement: Codeunit "Fields Sync Status Management";
    begin
        GetEnabledSensitiveFields(Field);

        if Field.FindSet() then
            repeat
                InsertDataSensitivityForField(Field.TableNo, Field."No.", DataSensitivity."Data Sensitivity"::Unclassified);
            until Field.Next() = 0;

        FieldsSyncStatusManagement.SetLastSyncDate();
    end;

    procedure InsertDataSensitivityForField(TableNo: Integer; FieldNo: Integer; DataSensitivityOption: Option)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        DataSensitivity.Init();
        DataSensitivity."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(DataSensitivity."Company Name"));
        DataSensitivity."Table No" := TableNo;
        DataSensitivity."Field No" := FieldNo;
        DataSensitivity."Data Sensitivity" := DataSensitivityOption;
        DataSensitivity.Insert();
    end;

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

    procedure FindSimilarFieldsInRelatedTables(var DataSensitivity: Record "Data Sensitivity")
    var
        TempDataPrivacyEntities: Record "Data Privacy Entities" temporary;
        RecordRef: RecordRef;
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

            RecordRef.GetTable(TempDataPrivacyEntities);
            TableNoFilter := GetFilterTextForFieldValuesInTable(RecordRef, TempDataPrivacyEntities.FieldNo("Table No."));

            DataSensitivity.SetFilter("Table No", TableNoFilter);

            // Performing a FINDFIRST s.t. the cursor is reset on the Data Sensitivity table
            if DataSensitivity.FindFirst() then;
        end;
    end;

    local procedure GetFieldCaptionFilterText(var DataSensitivity: Record "Data Sensitivity"): Text
    var
        FieldCaptionFilter: Text;
        FieldCaptionFilterLbl: Label '''*%1*''|', Comment = '%1 - Filter', Locked = true;
    begin
        repeat
            DataSensitivity.CalcFields("Field Caption");
            FieldCaptionFilter += StrSubstNo(FieldCaptionFilterLbl, DelChr(DataSensitivity."Field Caption", '=', ''''));
        until DataSensitivity.Next() = 0;

        FieldCaptionFilter := DelChr(FieldCaptionFilter, '>', '|');

        exit(FieldCaptionFilter);
    end;

    local procedure GetRelatedTables(var DataSensitivity: Record "Data Sensitivity"; var TempDataPrivacyEntities: Record "Data Privacy Entities" temporary)
    var
        PrevTableNo: Integer;
    begin
        PrevTableNo := 0;
        repeat
            if PrevTableNo <> DataSensitivity."Table No" then begin
                GetRelatedTablesForTable(TempDataPrivacyEntities, DataSensitivity."Table No");
                PrevTableNo := DataSensitivity."Table No";
            end;
        until DataSensitivity.Next() = 0;
    end;

    procedure GetRelatedTablesForTable(var TempDataPrivacyEntitiesOut: Record "Data Privacy Entities" temporary; TableNo: Integer)
    var
        TableRelationsMetadata: Record "Table Relations Metadata";
        DataPrivacyEntitiesMgt: Codeunit "Data Privacy Entities Mgt.";
    begin
        TableRelationsMetadata.SetRange("Related Table ID", TableNo);
        if TableRelationsMetadata.FindSet() then
            repeat
                DataPrivacyEntitiesMgt.InsertDataPrivacyEntitity(TempDataPrivacyEntitiesOut,
                    TableRelationsMetadata."Table ID", 0, 0, '', 0);
            until TableRelationsMetadata.Next() = 0;
    end;

    local procedure FilterDataSensitivityByFieldCaption(var DataSensitivity: Record "Data Sensitivity"; FieldCaptionFilter: Text)
    begin
        DataSensitivity.SetRange("Company Name", CompanyName());
        DataSensitivity.FilterGroup(2);
        DataSensitivity.SetFilter("Field Caption", FieldCaptionFilter);
    end;

    procedure GetTableNoFilterForTablesWhoseNameContains(Name: Text): Text
    var
        "Field": Record "Field";
        RecordRef: RecordRef;
        TableNameFilterLbl: Label '*%1*', Comment = '%1 - Table name', Locked = true;
    begin
        Field.SetRange(DataClassification, Field.DataClassification::CustomerContent);
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        Field.SetFilter(TableName, StrSubstNo(TableNameFilterLbl, Name));

        RecordRef.GetTable(Field);
        exit(GetFilterTextForFieldValuesInTable(RecordRef, Field.FieldNo(TableNo)));
    end;

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

    procedure SyncAllFields()
    var
        "Field": Record "Field";
        DataSensitivity: Record "Data Sensitivity";
        FieldsSyncStatusManagement: Codeunit "Fields Sync Status Management";
    begin
        DataSensitivity.SetRange("Company Name", CompanyName());
        if DataSensitivity.IsEmpty() then begin
            PopulateDataSensitivityTable();
            exit;
        end;

        Field.SetRange(Class, Field.Class::Normal);
        GetEnabledSensitiveFields(Field);

        UpdateDataSensitivityTable(Field);

        FieldsSyncStatusManagement.SetLastSyncDate();
    end;

    local procedure UpdateDataSensitivityTable(var "Field": Record "Field")
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

    local procedure DeleteUnclasifiedEntriesInDataSensitivity(var TempDataSensitivity: Record "Data Sensitivity" temporary)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        repeat
            if TempDataSensitivity."Data Sensitivity" = TempDataSensitivity."Data Sensitivity"::Unclassified then begin
                DataSensitivity.Get(TempDataSensitivity."Company Name", TempDataSensitivity."Table No", TempDataSensitivity."Field No");
                DataSensitivity.Delete();
            end;
        until TempDataSensitivity.Next() = 0;
    end;

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

    procedure GetDataSensitivityOptionString(): Text
    begin
        exit(DataSensitivityOptionStringTxt);
    end;

    procedure GetLegalDisclaimerTxt(): Text
    begin
        exit(LegalDisclaimerTxt);
    end;

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

    procedure SetFieldToPersonal(TableNo: Integer; FieldNo: Integer)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        SetDataSensitivityForField(TableNo, FieldNo, DataSensitivity."Data Sensitivity"::Personal);
    end;

    procedure SetFieldToSensitive(TableNo: Integer; FieldNo: Integer)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        SetDataSensitivityForField(TableNo, FieldNo, DataSensitivity."Data Sensitivity"::Sensitive);
    end;

    procedure SetFieldToCompanyConfidential(TableNo: Integer; FieldNo: Integer)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        SetDataSensitivityForField(TableNo, FieldNo, DataSensitivity."Data Sensitivity"::"Company Confidential");
    end;

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

    procedure IsDataSensitivityEmptyForCurrentCompany(): Boolean
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        DataSensitivity.SetRange("Company Name", CompanyName());
        exit(DataSensitivity.IsEmpty());
    end;

    procedure GetEnabledSensitiveFields(var "Field": Record "Field")
    begin
        Field.SetRange(Enabled, true);
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        GetSensitiveFields(Field);
    end;

    procedure GetSensitiveFields(var "Field": Record "Field")
    var
        DataClassificationFilterLbl: Label '%1|%2|%3', Comment = '%1 - Customer content, %2 - EUII, %3 = EUPI', Locked = true;
    begin
        Field.SetFilter(
          DataClassification,
          StrSubstNo(DataClassificationFilterLbl,
            Field.DataClassification::CustomerContent,
            Field.DataClassification::EndUserIdentifiableInformation,
            Field.DataClassification::EndUserPseudonymousIdentifiers));
    end;

    local procedure GetFilterTextForFieldValuesInTable(var RecordRef: RecordRef; FieldNo: Integer): Text
    var
        FilterText: Text;
        FilterTextOrLbl: Label '%1|%2', Comment = '%1 - Filter text, %2 - Field ref', Locked = true;
    begin
        if RecordRef.FindSet() then begin
            repeat
                FilterText := StrSubstNo(FilterTextOrLbl, FilterText, RecordRef.Field(FieldNo));
            until RecordRef.Next() = 0;

            // remove the first vertical bar from the filter text
            FilterText := DelChr(FilterText, '<', '|');
        end;

        exit(FilterText);
    end;

    procedure RunDataClassificationWorksheetForTableWhoseNameContains(TableNoFilter: Text)
    var
        DataSensitivity: Record "Data Sensitivity";
        DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
    begin
        DataSensitivity.SetRange("Company Name", CompanyName());
        DataSensitivity.SetFilter("Table No", DataClassificationMgtImpl.GetTableNoFilterForTablesWhoseNameContains(TableNoFilter));
        PAGE.Run(PAGE::"Data Classification Worksheet", DataSensitivity);
    end;

    procedure RunDataClassificationWorksheetForPersonalAndSensitiveDataInTable(TableNo: Integer)
    var
        DataSensitivity: Record "Data Sensitivity";
        DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
        DataClassificationFilterLbl: Label '%1|%2', Comment = '%1 - Personal data sensitivity, %2 - Sensitive data sensitivity', Locked = true;
    begin
        DataSensitivity.SetRange("Company Name", CompanyName());
        DataSensitivity.SetRange("Table No", TableNo);
        DataSensitivity.SetFilter("Data Sensitivity", StrSubstNo(DataClassificationFilterLbl,
            DataSensitivity."Data Sensitivity"::Personal,
            DataSensitivity."Data Sensitivity"::Sensitive));
        DataClassificationMgtImpl.FindSimilarFieldsInRelatedTables(DataSensitivity);
        PAGE.RunModal(PAGE::"Data Classification Worksheet", DataSensitivity);
    end;

    procedure RunDataClassificationWorksheetForTable(TableNo: Integer)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        DataSensitivity.SetRange("Company Name", CompanyName());
        DataSensitivity.FilterGroup(2);
        DataSensitivity.SetRange("Table No", TableNo);
        PAGE.RunModal(PAGE::"Data Classification Worksheet", DataSensitivity);
    end;
}

