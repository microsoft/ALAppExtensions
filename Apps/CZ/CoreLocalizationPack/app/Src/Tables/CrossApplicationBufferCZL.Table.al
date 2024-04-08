// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ReceivablesPayables;

using System.Reflection;

table 31115 "Cross Application Buffer CZL"
{
    Caption = 'Cross Application Buffer';
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(11; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(12; "Table Name"; Text[249])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
        }
        field(21; "Applied Document No."; Code[20])
        {
            Caption = 'Applied Document No.';
        }
        field(22; "Applied Document Line No."; Integer)
        {
            Caption = 'Applied Document Line No.';
        }
        field(23; "Applied Document Date"; Date)
        {
            Caption = 'Applied Document Date';
        }
        field(30; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure ExcludeDocument(DocumentVariant: Variant)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        DocumentRecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(DocumentVariant, DocumentRecRef) then
            exit;
        OnExcludeDocument(DocumentRecRef.Number, DocumentVariant, Rec);
    end;

    procedure RemoveDocument(TableID: Integer; AppliedDocumentNo: Code[20]; AppliedDocumentLineNo: Integer)
    var
        CrossApplicationBufferCZL: Record "Cross Application Buffer CZL";
    begin
        CrossApplicationBufferCZL.CopyFilters(Rec);
        SetRange("Table ID", TableID);
        SetRange("Applied Document No.", AppliedDocumentNo);
        SetRange("Applied Document Line No.", AppliedDocumentLineNo);
        DeleteAll();
        Reset();
        CopyFilters(CrossApplicationBufferCZL);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnExcludeDocument(TableID: Integer; DocumentVariant: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    begin
    end;
}
