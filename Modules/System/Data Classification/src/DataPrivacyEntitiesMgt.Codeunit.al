// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1758 "Data Privacy Entities Mgt."
{
    Access = Internal;
    Permissions = tabledata "Data Privacy Entities" = r;

    var
        SimilarFieldsLbl: Label 'Classify Similar Fields for %1', Comment = '%1=Table Caption';

    procedure DataPrivacyEntitiesExist(): Boolean
    var
        TempDataPrivacyEntities: Record "Data Privacy Entities" temporary;
        RecordRef: RecordRef;
    begin
        RaiseOnGetDataPrivacyEntities(TempDataPrivacyEntities);

        if TempDataPrivacyEntities.FindSet() then
            repeat
                RecordRef.Open(TempDataPrivacyEntities."Table No.");
                if (not RecordRef.IsEmpty()) and (TempDataPrivacyEntities."Table No." <> DATABASE::User) then
                    exit(true);
                RecordRef.Close();
            until TempDataPrivacyEntities.Next() = 0;
    end;

    procedure RaiseOnGetDataPrivacyEntities(var DataPrivacyEntities: Record "Data Privacy Entities")
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        if not DataPrivacyEntities.IsTemporary() then
            error('Please call this function with a temporary record.');

        DataClassificationMgt.OnGetDataPrivacyEntities(DataPrivacyEntities);
    end;

    procedure SetDefaultDataSensitivity(var DataPrivacyEntities: Record "Data Privacy Entities")
    var
        DataSensitivity: Record "Data Sensitivity";
        DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
    begin
        DataPrivacyEntities.SetRange(Include, true);
        if DataPrivacyEntities.FindSet() then
            repeat
                DataSensitivity.SetRange("Company Name", CompanyName());
                DataSensitivity.SetRange("Table No", DataPrivacyEntities."Table No.");
                DataClassificationMgtImpl.SetSensitivities(DataSensitivity, DataPrivacyEntities."Default Data Sensitivity");
            until DataPrivacyEntities.Next() = 0;
    end;

    procedure InsertDataPrivacyEntitity(var DataPrivacyEntities: Record "Data Privacy Entities" temporary; TableNo: Integer; PageNo: Integer; KeyFieldNo: Integer; EntityFilter: Text; PrivacyBlockedFieldNo: Integer)
    var
        OutStream: OutStream;
    begin
        if DataPrivacyEntities.Get(TableNo) then
            exit;

        DataPrivacyEntities.Init();
        DataPrivacyEntities.Include := true;
        DataPrivacyEntities."Table No." := TableNo;
        DataPrivacyEntities."Key Field No." := KeyFieldNo;
        DataPrivacyEntities."Privacy Blocked Field No." := PrivacyBlockedFieldNo;

        if EntityFilter <> '' then begin
            DataPrivacyEntities."Entity Filter".CreateOutStream(OutStream);
            OutStream.WriteText(EntityFilter);
        end;

        DataPrivacyEntities."Default Data Sensitivity" := DataPrivacyEntities."Default Data Sensitivity"::Personal;
        DataPrivacyEntities.CalcFields("Table Caption");
        DataPrivacyEntities."Similar Fields Label" := StrSubstNo(SimilarFieldsLbl, DataPrivacyEntities."Table Caption");
        DataPrivacyEntities."Page No." := PageNo;

        DataPrivacyEntities.Insert();
    end;
}