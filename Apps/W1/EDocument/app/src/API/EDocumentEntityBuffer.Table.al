table 6109 "E-Document Entity Buffer"
{
    Caption = 'E-Document Entity Buffer';
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

            trigger OnValidate()
            begin
                this.UpdateDocumentSystemId();
            end;
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
        field(31; "Receiving Company Id"; Text[250])
        {
            Caption = 'Receiving Company Id';
            ToolTip = 'Specifies the receiving company id, such as PEPPOL id, or other identifiers used in the electronic document exchange.';
        }
        field(32; "Unstructured Data Entry No."; Integer)
        {
            Caption = 'Unstructured Content';
            ToolTip = 'Specifies the content that is not structured, such as PDF';
            TableRelation = "E-Doc. Data Storage";
        }
        field(33; "Structured Data Entry No."; Integer)
        {
            Caption = 'Structured Content';
            ToolTip = 'Specifies the content that is structured, such as XML';
            TableRelation = "E-Doc. Data Storage";
        }
        field(34; Service; Code[20])
        {
            Caption = 'Service';
            ToolTip = 'Specifies the service that is used to process the E-Document.';
            Editable = false;
            TableRelation = "E-Document Service";
            ValidateTableRelation = true;

            trigger OnValidate()
            begin
                this.UpdateServiceId();
            end;
        }
        field(35; "File Name"; Text[256])
        {
            Caption = 'File Name';
            ToolTip = 'Specifies the file name of the E-Document source.';
        }
        field(36; "File Type"; Enum "E-Doc. Data Storage Blob Type")
        {
            Caption = 'File Type';
            ToolTip = 'Specifies the file type of the E-Document source.';
        }
        field(37; "Structured Data Process"; Enum "E-Doc. Structured Data Process")
        {
            Caption = 'Structured Data Process';
            ToolTip = 'Specifies the structured data process to run on the E-Document data.';
        }
        field(38; "Service Integration"; Enum "Service Integration")
        {
            Caption = 'Service Integration';
            ToolTip = 'Specifies the service integration to use for the E-Document.';
            Editable = false;
        }
        field(8000; Id; Guid)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }
        field(9000; "Service Id"; Guid)
        {
            Caption = 'Service Id';
            DataClassification = SystemMetadata;
        }
        field(9001; "Document System Id"; Guid)
        {
            Caption = 'Document System Id';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Entry No")
        {
            Clustered = true;
        }
    }

    internal procedure UpdateRelatedRecordsIds()
    begin
        this.UpdateServiceId();
        this.UpdateDocumentSystemId();
    end;

    local procedure UpdateServiceId()
    var
        EDocumentService: Record "E-Document Service";
    begin
        if Rec.Service = '' then begin
            Clear(Rec."Service Id");
            exit;
        end;

        if not EDocumentService.Get(Rec.Service) then
            exit;

        Rec."Service Id" := EDocumentService.SystemId;
    end;

    local procedure UpdateDocumentSystemId()
    var
        DocumentRecRef: RecordRef;
    begin
        if Rec."Document Record ID".TableNo() = 0 then begin
            Clear(Rec."Document System Id");
            exit;
        end;

        DocumentRecRef.Open(Rec."Document Record ID".TableNo());
        if not DocumentRecRef.Get(Rec."Document Record ID") then exit;

        Rec."Document System Id" := DocumentRecRef.Field(DocumentRecRef.SystemIdNo).Value;
    end;
}
