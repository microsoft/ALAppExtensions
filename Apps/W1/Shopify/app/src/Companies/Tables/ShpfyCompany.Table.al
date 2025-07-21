namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;
using System.Reflection;

/// <summary>
/// Table Shpfy Company (ID 30150).
/// </summary>
table 30150 "Shpfy Company"
{
    Caption = 'Shopify Company';
    DataClassification = CustomerContent;
    DrillDownPageId = "Shpfy Companies";
    LookupPageId = "Shpfy Companies";

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }
        field(2; Name; Text[500])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; Note; Blob)
        {
            Caption = 'Note';
            DataClassification = CustomerContent;
        }
        field(4; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }

        field(5; "Updated At"; DateTime)
        {
            Caption = 'Updated At';
            DataClassification = CustomerContent;
        }
        field(6; "Last Updated by BC"; DateTime)
        {
            Caption = 'Last Updated by BC';
            DataClassification = SystemMetadata;
        }

        field(7; "Customer SystemId"; Guid)
        {
            Caption = 'Customer SystemId';
            DataClassification = SystemMetadata;
        }
        field(8; "Customer No."; Code[20])
        {
            CalcFormula = lookup(Customer."No." where(SystemId = field("Customer SystemId")));
            Caption = 'Customer No.';
            FieldClass = FlowField;
        }
        field(9; "Shop Id"; Integer)
        {
            Caption = 'Shop ID';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(10; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Shpfy Shop";
        }
        field(11; "Main Contact Customer Id"; BigInteger)
        {
            Caption = 'Main Contact Id';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Shpfy Customer";
        }
        field(12; "Main Contact Id"; BigInteger)
        {
            Caption = 'Main Contact Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Location Id"; BigInteger)
        {
            Caption = 'Location Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "External Id"; Text[500])
        {
            Caption = 'External Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }

        key(Idx1; "Customer SystemId") { }
        key(Idx2; "Shop Id") { }
    }

    trigger OnDelete()
    var
        CompanyLocation: Record "Shpfy Company Location";
    begin
        CompanyLocation.SetRange("Company SystemId", Rec.SystemId);
        CompanyLocation.DeleteAll();
    end;

    internal procedure GetNote(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields(Note);
        Note.CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, (TypeHelper.LFSeparator())));
    end;

    internal procedure SetNote(NewNote: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Note);
        Note.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewNote);
        if Modify() then;
    end;
}