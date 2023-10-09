namespace Microsoft.Integration.Shopify;

using System.Reflection;

table 30141 "Shpfy Return Line"
{
    Caption = 'Return Line';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Return Line Id"; BigInteger)
        {
            Caption = 'Return Line Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Return Id"; BigInteger)
        {
            Caption = 'Return Id';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Return Header"."Return Id";
            Editable = false;
        }
        field(3; "Fulfillment Line Id"; BigInteger)
        {
            Caption = 'Fulfillment Line Id';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Fulfillment Line"."Fulfillment Line Id";
            Editable = false;
        }
        field(4; "Order Line Id"; BigInteger)
        {
            Caption = 'Order Line Id';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Order Line"."Line Id";
            Editable = false;
        }
        field(5; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; "Return Reason"; Enum "Shpfy Return Reason")
        {
            Caption = 'Return Reason';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(7; "Return Reason Note"; Blob)
        {
            Caption = 'Return Reason Note';
            DataClassification = SystemMetadata;
        }
        field(8; "Refundable Quantity"; Integer)
        {
            Caption = 'Refundable Quantity';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(9; "Refunded Quantity"; Integer)
        {
            Caption = 'Refunded Quantity';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(10; "Weight Unit"; Code[20])
        {
            Caption = 'Weight Unit';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; Weight; Decimal)
        {
            Caption = 'Weight';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(12; "Discounted Total Amount"; Decimal)
        {
            Caption = 'Discounted Total Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(13; "Presentment Disc. Total Amt."; Decimal)
        {
            Caption = 'Presentment Discounted Total Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(14; "Customer Note"; Blob)
        {
            Caption = 'Customer Note';
            DataClassification = SystemMetadata;
        }
        field(101; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Line"."Item No." where("Line Id" = field("Order Line Id")));
        }
        field(102; Description; Text[100])
        {
            Caption = 'Description';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Line".Description where("Line Id" = field("Order Line Id")));
        }
        field(103; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Line"."Variant Code" where("Line Id" = field("Order Line Id")));
        }
    }
    keys
    {
        key(PK; "Return Line Id")
        {
            Clustered = true;
        }
        key(Idx01; "Return Id", "Discounted Total Amount", "Presentment Disc. Total Amt.")
        {
            MaintainSiftIndex = true;
            SumIndexFields = "Discounted Total Amount", "Presentment Disc. Total Amt.";
        }
    }

    trigger OnDelete()
    var
        DataCapture: Record "Shpfy Data Capture";
    begin
        DataCapture.SetCurrentKey("Linked To Table", "Linked To Id");
        DataCapture.SetRange("Linked To Table", Database::"Shpfy Return Line");
        DataCapture.SetRange("Linked To Id", Rec.SystemId);
        if not DataCapture.IsEmpty then
            DataCapture.DeleteAll(false);
    end;

    internal procedure GetReturnReasonNote(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Return Reason Note");
        "Return Reason Note".CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    internal procedure SetReturnReasonNote(NewReturnReasonNote: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Return Reason Note");
        "Return Reason Note".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewReturnReasonNote);
        Modify();
    end;

    internal procedure GetCustomerNote(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Customer Note");
        "Customer Note".CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    internal procedure SetCustomerNote(NewCustomerNote: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Customer Note");
        "Customer Note".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewCustomerNote);
        Modify();
    end;
}