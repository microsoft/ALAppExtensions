table 30121 "Shpfy Orders to Import"
{
    Access = Internal;
    Caption = 'Shopify Orders to Import';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }

        field(2; "Shop Id"; Integer)
        {
            Caption = 'Shop Id';
            DataClassification = CustomerContent;
        }

        field(3; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = CustomerContent;
            TableRelation = "Shpfy Shop".Code;
        }

        field(4; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }

        field(5; "Order No."; Text[50])
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
        }

        field(6; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }

        field(7; "Updated At"; DateTime)
        {
            Caption = 'UpdatedAt';
            DataClassification = CustomerContent;
        }

        field(8; Test; Boolean)
        {
            Caption = 'Test';
            DataClassification = CustomerContent;
        }

        field(9; Confirmed; Boolean)
        {
            Caption = 'Confirmed';
            DataClassification = CustomerContent;
        }

        field(10; "Fully Paid"; Boolean)
        {
            Caption = 'Fully Paid';
            DataClassification = CustomerContent;
        }

        field(11; Unpaid; Boolean)
        {
            Caption = 'Unpaid';
            DataClassification = CustomerContent;
        }

        field(12; "Risk Level"; enum "Shpfy Risk Level")
        {
            Caption = 'Risk Level';
            DataClassification = CustomerContent;
        }
        field(13; "Financial Status"; enum "Shpfy Financial Status")
        {
            Caption = 'Financial Status';
            DataClassification = CustomerContent;
        }

        field(14; "Fulfillment Status"; enum "Shpfy Order Fulfill. Status")
        {
            Caption = 'Fulfillment Status';
            DataClassification = CustomerContent;
        }

        field(15; "Order Amount"; Decimal)
        {
            Caption = 'Order Amount';
            DataClassification = CustomerContent;
        }

        field(16; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }

        field(17; "Total Quantity of Items"; Integer)
        {
            Caption = 'Total Quantity of Items';
            DataClassification = CustomerContent;
        }

        field(18; "Number of Order Lines"; Integer)
        {
            Caption = 'Number of Order Lines';
            DataClassification = CustomerContent;
        }

        field(19; Tags; Text[2048])
        {
            Caption = 'Tags';
            DataClassification = CustomerContent;
        }
        field(20; "Attribute Key Filter"; Text[100])
        {
            Caption = 'Attribute Key Filter';
            FieldClass = FlowFilter;
        }
        field(21; "Attribute Key Exists"; Boolean)
        {
            Caption = 'Attribute Key Exists';
            FieldClass = FlowField;
            CalcFormula = exist("Shpfy Order Attribute" where("Order Id" = field(Id), "Key" = field("Attribute Key Filter")));
        }
        field(100; "Import Action"; enum "Shpfy Import Action")
        {
            Caption = 'Import Action';
            DataClassification = CustomerContent;
        }

        field(102; "Has Error"; Boolean)
        {
            Caption = 'Has Error';
            DataClassification = SystemMetadata;
        }
        field(103; "Error Message"; Blob)
        {
            Caption = 'Error Message';
            DataClassification = SystemMetadata;
        }
        field(104; "Error Call Stack"; Blob)
        {
            Caption = 'Error Call Stack';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Idx1; Id, "Shop Id") { }
    }

    /// <summary> 
    /// Description for SetErrorMessage.
    /// </summary>
    internal procedure SetErrorInfo()
    var
        OutStream: OutStream;
    begin
        Clear("Error Message");
        "Error Message".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(GetLastErrorText);
        Clear("Error Call Stack");
        "Error Call Stack".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(GetLastErrorCallStack);
        "Has Error" := true;
    end;

    /// <summary> 
    /// Description for GetErrorMessage.
    /// </summary>
    /// <returns>Return variable "Text".</returns>
    internal procedure GetErrorMessage(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Error Message");
        "Error Message".CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    /// <summary> 
    /// Description for GetErrorCallStack.
    /// </summary>
    /// <returns>Return variable "Text".</returns>
    internal procedure GetErrorCallStack(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Error Call Stack");
        "Error Call Stack".CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;
}