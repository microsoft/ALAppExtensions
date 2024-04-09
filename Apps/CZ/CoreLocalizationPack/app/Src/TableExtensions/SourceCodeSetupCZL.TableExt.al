// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.AuditCodes;

tableextension 11752 "Source Code Setup CZL" extends "Source Code Setup"
{
    fields
    {
        field(11770; "Purchase VAT Delay CZL"; Code[10])
        {
            Caption = 'Purchase VAT Delay';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(11771; "Sales VAT Delay CZL"; Code[10])
        {
            Caption = 'Sales VAT Delay';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(11772; "VAT LCY Correction CZL"; Code[10])
        {
            Caption = 'VAT LCY Correction';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(11774; "Close Balance Sheet CZL"; Code[10])
        {
            Caption = 'Close Balance Sheet';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";

            trigger OnValidate()
            begin
                if "Close Balance Sheet CZL" = '' then
                    exit;
                ThrowErrorIfUsedCZL(FieldNo("Close Balance Sheet CZL"), FieldNo("Close Income Statement"));
                ThrowErrorIfUsedCZL(FieldNo("Close Balance Sheet CZL"), FieldNo("Open Balance Sheet CZL"));
            end;
        }
        field(11775; "Open Balance Sheet CZL"; Code[10])
        {
            Caption = 'Open Balance Sheet';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";

            trigger OnValidate()
            begin
                if "Open Balance Sheet CZL" = '' then
                    exit;
                ThrowErrorIfUsedCZL(FieldNo("Open Balance Sheet CZL"), FieldNo("Close Income Statement"));
                ThrowErrorIfUsedCZL(FieldNo("Open Balance Sheet CZL"), FieldNo("Close Balance Sheet CZL"));
            end;
        }
    }

    procedure ThrowErrorIfUsedCZL(CurrentFieldNo: Integer; ComparedFieldNo: Integer)
    var
        RecordRef: RecordRef;
        CurrentFieldRef: FieldRef;
        ComparedFieldRef: FieldRef;
        MustBeDifferentErr: Label 'must be different from %1 %2', Comment = '%1 = compared field caption, %2 = compared field value';
    begin
        RecordRef.GetTable(Rec);
        CurrentFieldRef := RecordRef.Field(CurrentFieldNo);
        ComparedFieldRef := RecordRef.Field(ComparedFieldNo);
        if CurrentFieldRef.Value = ComparedFieldRef.Value then
            CurrentFieldRef.FieldError(StrSubstNo(MustBeDifferentErr, ComparedFieldRef.Caption, ComparedFieldRef.Value));
    end;
}
