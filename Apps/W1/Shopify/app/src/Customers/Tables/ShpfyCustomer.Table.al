namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;
using System.Reflection;

/// <summary>
/// Table Shpfy Customer (ID 30105).
/// </summary>
table 30105 "Shpfy Customer"
{
    Caption = 'Shopify Customer';
    DataClassification = CustomerContent;
    DrillDownPageId = "Shpfy Customers";
    LookupPageId = "Shpfy Customers";

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }
        field(2; "First Name"; Text[100])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
        }
        field(3; "Last Name"; Text[100])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;
        }

        field(4; Email; Text[100])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }

        field(5; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }

        field(6; "Accepts Marketing"; Boolean)
        {
            Caption = 'Accepts Marketing';
            DataClassification = CustomerContent;
        }

        field(7; "Accepts Marketing Update At"; DateTime)
        {
            Caption = 'Accepts Marketing Update At';
            DataClassification = CustomerContent;
        }

        field(8; "ISO Currency Code"; Code[3])
        {
            Caption = 'ISO Currency Code';
            DataClassification = CustomerContent;
        }

        field(9; "Tax Exempt"; Boolean)
        {
            Caption = 'Tax Exempt';
            DataClassification = CustomerContent;
        }

        field(10; "Verified Email"; Boolean)
        {
            Caption = 'Verified E-Mail';
            DataClassification = CustomerContent;
        }

        field(11; State; enum "Shpfy Customer State")
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }

        field(12; Note; Blob)
        {
            Caption = 'Note';
            DataClassification = CustomerContent;
        }

        field(13; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }

        field(14; "Updated At"; DateTime)
        {
            Caption = 'Updated At';
            DataClassification = CustomerContent;
        }
        field(15; "Last Updated by BC"; DateTime)
        {
            Caption = 'Last Updated by BC';
            DataClassification = SystemMetadata;
        }

        field(101; "Customer SystemId"; Guid)
        {
            Caption = 'Customer SystemId';
            DataClassification = SystemMetadata;
        }
        field(102; "Customer No."; Code[20])
        {
            CalcFormula = lookup(Customer."No." where(SystemId = field("Customer SystemId")));
            Caption = 'Customer No.';
            FieldClass = FlowField;
        }
        field(103; "Shop Id"; Integer)
        {
            Caption = 'Shop ID';
            DataClassification = SystemMetadata;
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
        CustomerAddress: Record "Shpfy Customer Address";
        Metafield: Record "Shpfy Metafield";
        Tag: Record "Shpfy Tag";
    begin
        CustomerAddress.SetRange("Customer Id", Id);
        if not CustomerAddress.IsEmpty() then
            CustomerAddress.DeleteAll(false);

        Tag.SetRange("Parent Id", Id);
        if not Tag.IsEmpty() then
            Tag.DeleteAll();

        Metafield.SetRange("Parent Table No.", Database::"Shpfy Customer");
        Metafield.SetRange("Owner Id", Id);
        if not Metafield.IsEmpty then
            Metafield.DeleteAll();
    end;

    /// <summary> 
    /// Get Comma Seperated Tags.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetCommaSeparatedTags(): Text
    var
        ShopifyTag: Record "Shpfy Tag";
    begin
        ShopifyTag.GetCommaSeparatedTags(Id);
    end;

    /// <summary> 
    /// Get Note.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetNote(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields(Note);
        Note.CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, (TypeHelper.LFSeparator())));
    end;

    /// <summary> 
    /// Set Note.
    /// </summary>
    /// <param name="NewNote">Parameter of type Text.</param>
    internal procedure SetNote(NewNote: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Note);
        Note.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewNote);
        if Modify() then;
    end;

    /// <summary> 
    /// Update Tags.
    /// </summary>
    /// <param name="CommaSeperatedTags">Parameter of type Text.</param>
    internal procedure UpdateTags(CommaSeperatedTags: Text)
    var
        ShopifyTag: Record "Shpfy Tag";
    begin
        ShopifyTag.UpdateTags(Database::"Shpfy Customer", Id, CommaSeperatedTags);
    end;
}