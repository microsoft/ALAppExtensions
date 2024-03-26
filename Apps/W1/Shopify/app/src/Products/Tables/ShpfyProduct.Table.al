namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;
using System.Reflection;

/// <summary>
/// Table Shpfy Product (ID 30127).
/// </summary>
table 30127 "Shpfy Product"
{
    Caption = 'Shopify Product';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Updated At"; DateTime)
        {
            Caption = 'Updated At';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Has Variants"; Boolean)
        {
            Caption = 'Has Variants';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(6; "Description as HTML"; Blob)
        {
            Caption = 'Description as HTML';
            DataClassification = CustomerContent;
        }
        field(7; "Preview URL"; Text[250])
        {
            Caption = 'Preview URL';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; URL; Text[250])
        {
            Caption = 'URL';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Product Type"; Text[50])
        {
            Caption = 'Product Type';
            DataClassification = CustomerContent;
        }
        field(10; "SEO Description"; Text[250])
        {
            Caption = 'SEO Description';
            DataClassification = CustomerContent;
        }
        field(11; "SEO Title"; Text[100])
        {
            Caption = 'SEO Title';
            DataClassification = CustomerContent;
        }
        field(12; Title; Text[100])
        {
            Caption = 'Title';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; Vendor; Text[100])
        {
            Caption = 'Vendor';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Image Id"; BigInteger)
        {
            Caption = 'Image Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(15; Status; Enum "Shpfy Product Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }

        field(100; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Shpfy Shop";
        }

        field(101; "Item SystemId"; Guid)
        {
            Caption = 'Item SystemId';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(102; "Last Updated by BC"; DateTime)
        {
            Caption = 'Last Updated by BC';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(103; "Item No."; Code[20])
        {
            CalcFormula = lookup(Item."No." where(SystemId = field("Item SystemId")));
            Caption = 'Item No.';
            FieldClass = FlowField;
        }
        field(104; "Image Hash"; Integer)
        {
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(105; "Tags Hash"; Integer)
        {
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(106; "Description Html Hash"; Integer)
        {
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
    }

    trigger OnDelete()
    var
        Shop: Record "Shpfy Shop";
        ShopifyVariant: Record "Shpfy Variant";
        Metafield: Record "Shpfy Metafield";
        IRemoveProduct: Interface "Shpfy IRemoveProductAction";
    begin
        if Shop.Get(Rec."Shop Code") then begin
            IRemoveProduct := Shop."Action for Removed Products";
            IRemoveProduct.RemoveProductAction(Rec);
        end;
        ShopifyVariant.SetRange("Product Id", Id);
        if not ShopifyVariant.IsEmpty then
            ShopifyVariant.DeleteAll(true);

        Metafield.SetRange("Parent Table No.", Database::"Shpfy Product");
        Metafield.SetRange("Owner Id", Id);
        if not Metafield.IsEmpty then
            Metafield.DeleteAll();
    end;

    /// <summary> 
    /// Get Comma Seperated Tags.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetCommaSeparatedTags() Tags: Text
    var
        ShopifyTag: Record "Shpfy Tag";
        ProductEvents: Codeunit "Shpfy Product Events";
    begin
        Tags := ShopifyTag.GetCommaSeparatedTags(Id);
        ProductEvents.OnAfterGetCommaSeparatedTags(Rec, Tags);
        exit(Tags);
    end;

    /// <summary> 
    /// Get Description Html.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetDescriptionHtml(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Description as HTML");
        "Description as HTML".CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    /// <summary> 
    /// Set Description Html.
    /// </summary>
    /// <param name="NewDescriptionHtml">Parameter of type Text.</param>
    internal procedure SetDescriptionHtml(NewDescriptionHtml: Text)
    var
        Hash: Codeunit "Shpfy Hash";
        OutStream: OutStream;
    begin
        Clear("Description as HTML");
        "Description as HTML".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewDescriptionHtml);
        "Description Html Hash" := Hash.CalcHash(NewDescriptionHtml);
        if Modify() then;
    end;

    /// <summary> 
    /// Update Tags.
    /// </summary>
    /// <param name="CommaSeperatedTags">Parameter of type Text.</param>
    internal procedure UpdateTags(CommaSeparatedTags: Text)
    var
        ShopifyTag: Record "Shpfy Tag";
    begin
        ShopifyTag.UpdateTags(Database::"Shpfy Product", Id, CommaSeparatedTags);
    end;

    internal procedure CalcTagsHash(): Integer;
    var
        Hash: Codeunit "Shpfy Hash";
    begin
        exit(Hash.CalcHash(Rec.GetCommaSeparatedTags()));
    end;
}
