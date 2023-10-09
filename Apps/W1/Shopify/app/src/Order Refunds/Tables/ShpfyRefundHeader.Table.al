namespace Microsoft.Integration.Shopify;

using System.Reflection;

table 30142 "Shpfy Refund Header"
{
    Caption = 'Refund Header';
    DataClassification = SystemMetadata;
    LookupPageId = "Shpfy Refund";
    DrillDownPageId = "Shpfy Refunds";

    fields
    {
        field(1; "Refund Id"; BigInteger)
        {
            Caption = 'Refund Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Order Id"; BigInteger)
        {
            Caption = 'Order Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; "Updated At"; DateTime)
        {
            Caption = 'Updated At';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; "Return Id"; BigInteger)
        {
            Caption = 'Return Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; "Total Refunded Amount"; Decimal)
        {
            Caption = 'Total Refunded Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(7; "Pres. Tot. Refunded Amount"; Decimal)
        {
            Caption = 'Presentment Total Refunded Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(8; Note; Blob)
        {
            Caption = 'Note';
            DataClassification = SystemMetadata;
        }
        field(9; "Shop Code"; code[20])
        {
            Caption = 'Shop code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(50; "Has Processing Error"; Boolean)
        {
            Caption = 'Has Processing Error';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(51; "Last Error Description"; Blob)
        {
            Caption = 'Last Error Description';
            DataClassification = SystemMetadata;
        }
        field(101; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Header"."Sell-to Customer No." where("Shopify Order Id" = field("Order Id")));
            Editable = false;
        }
        field(102; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Header"."Bill-to Customer No." where("Shopify Order Id" = field("Order Id")));
            Editable = false;
        }
        field(103; "Sell-to Customer Name"; Text[50])
        {
            Caption = 'Sell-to Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Header"."Sell-to Customer Name" where("Shopify Order Id" = field("Order Id")));
            Editable = false;
        }
        field(104; "Bill-to Customer Name"; Text[50])
        {
            Caption = 'Bill-to Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Header"."Bill-to Name" where("Shopify Order Id" = field("Order Id")));
            Editable = false;
        }
        field(105; "Shopify Order No."; Text[50])
        {
            Caption = 'Shopify Order No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Header"."Shopify Order No." where("Shopify Order Id" = field("Order Id")));
            Editable = false;
        }
        field(106; "Return No."; Text[30])
        {
            Caption = 'Return No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Return Header"."Return No." where("Return Id" = field("Return Id")));
            Editable = false;
        }
        field(107; "Is Processed"; Boolean)
        {
            Caption = 'Is Processed';
            FieldClass = FlowField;
            CalcFormula = exist("Shpfy Doc. Link To Doc." where("Shopify Document Type" = const("Shopify Shop Refund"), "Shopify Document Id" = field("Refund Id")));
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Refund Id")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        RefundLine: Record "Shpfy Refund Line";
        DataCapture: Record "Shpfy Data Capture";
    begin
        RefundLine.SetRange("Refund Id");
        if not RefundLine.IsEmpty() then
            RefundLine.DeleteAll(true);

        DataCapture.SetCurrentKey("Linked To Table", "Linked To Id");
        DataCapture.SetRange("Linked To Table", Database::"Shpfy Refund Header");
        DataCapture.SetRange("Linked To Id", Rec.SystemId);
        if not DataCapture.IsEmpty then
            DataCapture.DeleteAll(false);
    end;

    internal procedure GetNote(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields(Note);
        Note.CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    internal procedure SetNote(NewNote: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Note);
        Note.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewNote);
        Modify();
    end;

    internal procedure GetLastErrorDescription(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Last Error Description");
        "Last Error Description".CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    internal procedure SetLastErrorDescription(NewLastErrorDescription: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Last Error Description");
        "Last Error Description".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewLastErrorDescription);
        "Has Processing Error" := NewLastErrorDescription <> '';
        Modify();
    end;

    internal procedure CheckCanCreateDocument(): Boolean
    var
        DocLinkToBCDoc: Record "Shpfy Doc. Link To Doc.";
    begin
        DocLinkToBCDoc.SetRange("Shopify Document Type", "Shpfy Shop Document Type"::"Shopify Shop Refund");
        DocLinkToBCDoc.SetRange("Shopify Document Id", Rec."Refund Id");
        DocLinkToBCDoc.SetCurrentKey("Shopify Document Type", "Shopify Document Id");
        exit(DocLinkToBCDoc.IsEmpty);
    end;
}