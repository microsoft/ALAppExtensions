// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Reporting;
using Microsoft.Finance.Currency;
using Microsoft.Utilities;
using System.Automation;
using System.IO;
using System.Reflection;
using System.Threading;

table 6121 "E-Document"
{
    DataCaptionFields = "Entry No", "Bill-to/Pay-to Name";
    LookupPageId = "E-Documents";
    DrillDownPageId = "E-Documents";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            Caption = 'Document Entry No';
            AutoIncrement = true;
        }
        field(2; "Document Record ID"; RecordId)
        {
            Caption = 'Document Record ID';
            DataClassification = SystemMetadata;
        }
        field(3; "Bill-to/Pay-to No."; Code[20])
        {
            Caption = 'Bill-to/Pay-to No.';
        }
        field(4; "Bill-to/Pay-to Name"; Text[100])
        {
            Caption = 'Bill-to/Pay-to Name';
            Editable = false;
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(6; "Document Type"; Enum "E-Document Type")
        {
            Caption = 'Document Type';
            Editable = false;
        }
        field(7; "Document Date"; Date)
        {
            Caption = 'Document Date';
            Editable = false;
        }
        field(8; "Due Date"; Date)
        {
            Caption = 'Due Date';
            Editable = false;
        }
        field(9; "Amount Incl. VAT"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            Editable = false;
        }
        field(10; "Amount Excl. VAT"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Excluding VAT';
            Editable = false;
        }
        field(11; "Index In Batch"; Integer)
        {
            Caption = 'Index In Batch';
            Editable = false;
        }
        field(12; "Order No."; Code[20])
        {
            Caption = 'Order No.';
        }
        field(13; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Editable = false;
        }
        field(14; Direction; Enum "E-Document Direction")
        {
            Caption = 'Direction';
            Editable = false;
        }
        field(15; "Incoming E-Document No."; Text[50])
        {
            Caption = 'Incoming E-Document No.';
            Editable = false;
        }
        field(16; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(17; "Table Name"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
            Caption = 'Document Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(18; Status; Enum "E-Document Status")
        {
            Caption = 'Electronic Document Status';
        }
        field(19; "Document Sending Profile"; Code[20])
        {
            Caption = 'Document Sending Profile';
            TableRelation = "Document Sending Profile";
        }
        field(20; "Source Type"; enum "E-Document Source Type")
        {
            Caption = 'Source Type';
        }
        field(21; "Data Exch. Def. Code"; Code[20])
        {
            TableRelation = "Data Exch. Def";
            Caption = 'Data Exch. Def. Code';
        }
        field(22; "Receiving Company VAT Reg. No."; Text[20])
        {
            Caption = 'Receiving Company VAT Reg. No.';
        }
        field(23; "Receiving Company GLN"; Code[13])
        {
            Caption = 'Receiving Company GLN';
            Numeric = true;
        }
        field(24; "Receiving Company Name"; Text[150])
        {
            Caption = 'Receiving Company Name';
        }
        field(25; "Receiving Company Address"; Text[200])
        {
            Caption = 'Receiving Company Address';
        }
        field(26; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(27; "Workflow Code"; Code[20])
        {
            TableRelation = Workflow where(Template = const(false), Category = const('EDOC'));
            Caption = 'Workflow Code';
        }
        field(28; "Workflow Step Instance ID"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(29; "Job Queue Entry ID"; Guid)
        {
            TableRelation = "Job Queue Entry";
            DataClassification = SystemMetadata;
        }
        field(30; "Journal Line System ID"; Guid)
        {
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(Key1; "Entry No")
        {
            Clustered = true;
        }
        key(Key2; "Document Record ID")
        {
        }
    }

    trigger OnModify()
    var
        EDocAttachGen: Codeunit "E-Doc. Attachment Processor";
    begin
        if Rec.Status = Status::Error then
            EDocAttachGen.DeleteAll(Rec);
        if (Rec.Status = Status::Processed) and (Rec.Direction = Direction::Incoming) then
            EDocAttachGen.MoveToProcessedDocument(Rec);
    end;

    internal procedure OpenEDocument(EDocumentRecordId: RecordId)
    var
        EDocument: Record "E-Document";
        EDocumentPage: Page "E-Document";
    begin
        EDocument.SetRange("Document Record ID", EDocumentRecordId);
        EDocument.FindFirst();
        EDocumentPage.SetTableView(EDocument);
        EDocumentPage.RunModal();
    end;

    internal procedure ShowRecord()
    var
        PageManagement: Codeunit "Page Management";
        DataTypeManagement: Codeunit "Data Type Management";
        EDocHelper: Codeunit "E-Document Processing";
        RecRef: RecordRef;
        RelatedRecord: Variant;
    begin
        if EDocHelper.GetRecord(Rec, RelatedRecord) then begin
            DataTypeManagement.GetRecordRef(RelatedRecord, RecRef);
            PageManagement.PageRun(RecRef);
        end;
    end;

    internal procedure ToString(): Text
    begin
        exit(StrSubstNo(ToStringLbl, SystemId, "Document Record ID", "Workflow Step Instance ID", "Job Queue Entry ID"));
    end;

    var
        ToStringLbl: Label '%1,%2,%3,%4', Locked = true;
}
