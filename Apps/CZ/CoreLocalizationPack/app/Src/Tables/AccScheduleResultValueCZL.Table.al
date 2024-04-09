// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

table 31113 "Acc. Schedule Result Value CZL"
{
    Caption = 'Acc. Schedule Result Value';

    fields
    {
        field(1; "Result Code"; Code[20])
        {
            Caption = 'Result Code';
            DataClassification = CustomerContent;
            TableRelation = "Acc. Schedule Result Hdr. CZL";
        }
        field(2; "Row No."; Integer)
        {
            Caption = 'Row No.';
            DataClassification = CustomerContent;
        }
        field(3; "Column No."; Integer)
        {
            Caption = 'Column No.';
            DataClassification = CustomerContent;
        }
        field(4; Value; Decimal)
        {
            Caption = 'Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                AddChangeHistoryEntry();
            end;
        }
    }

    keys
    {
        key(Key1; "Result Code", "Row No.", "Column No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        Validate(Value, 0);
    end;

    procedure AddChangeHistoryEntry()
    var
        AccScheduleResultHistCZL: Record "Acc. Schedule Result Hist. CZL";
        VariantNo: Integer;
    begin
        AccScheduleResultHistCZL.SetRange("Result Code", "Result Code");
        AccScheduleResultHistCZL.SetRange("Row No.", "Row No.");
        AccScheduleResultHistCZL.SetRange("Column No.", "Column No.");
        if AccScheduleResultHistCZL.FindLast() then
            VariantNo := AccScheduleResultHistCZL."Variant No." + 1
        else
            VariantNo := 1;

        AccScheduleResultHistCZL.Init();
        AccScheduleResultHistCZL."Result Code" := "Result Code";
        AccScheduleResultHistCZL."Row No." := "Row No.";
        AccScheduleResultHistCZL."Column No." := "Column No.";
        AccScheduleResultHistCZL."Variant No." := VariantNo;
        AccScheduleResultHistCZL."New Value" := Value;
        AccScheduleResultHistCZL."Old Value" := xRec.Value;
        AccScheduleResultHistCZL.Insert(true);
    end;
}
