namespace Microsoft.Integration.Shopify;

using Microsoft.Finance.SalesTax;
using System.IO;
using Microsoft.Inventory.Item;
using Microsoft.Finance.VAT.Setup;

/// <summary>
/// Table Shpfy Shop Collection Map (ID 30128).
/// </summary>
table 30128 "Shpfy Shop Collection Map"
{
    Access = Internal;
    Caption = 'Shopify Shop Collection';
    DataClassification = CustomerContent;
    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Id';
            AutoIncrement = true;
        }

        field(2; "Shop Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shop Code';
            TableRelation = "Shpfy Shop".Code;
            NotBlank = true;

            trigger OnValidate()
            var
                Shop: Record "Shpfy Shop";
            begin
                TestField("Shop Code");
                Shop.Get("Shop Code");
                "Product Collection" := Shop."Product Collection";
            end;
        }

        field(3; "Product Collection"; Option)
        {
            Caption = 'Product Collection';
            OptionMembers = " ","Tax Group","VAT Prod. Posting Group";
            OptionCaption = ' ,Tax Group,VAT Prod. Posting Group';
            DataClassification = CustomerContent;
        }
#pragma warning disable AS0086
        field(4; "Product Group Code"; Code[20])
        {
            Caption = 'Product Group Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Product Collection" = const("Tax Group")) "Tax Group".Code else
            if ("Product Collection" = const("VAT Prod. Posting Group")) "VAT Product Posting Group".Code;
        }
#pragma warning disable AS0086
        field(5; "Collection Id"; BigInteger)
        {
            Caption = 'Collection Id';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(6; "Collection Name"; Text[250])
        {
            Caption = 'Collection Name';
            DataClassification = CustomerContent;
        }

        field(7; "Item Template Code"; Code[10])
        {
            Caption = 'Item Template Code';
            TableRelation = "Config. Template Header".Code where("Table Id" = const(27));
            ValidateTableRelation = true;
            DataClassification = CustomerContent;
            ObsoleteReason = 'Replaced by Item Templ. Code';
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
        }

        field(8; "Default for Export"; Boolean)
        {
            Caption = 'Default for Export';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Collection: Record "Shpfy Shop Collection Map";
            begin
                Collection.SetRange("Shop Code", "Shop Code");
                Collection.SetRange("Product Collection", "Product Collection");
                Collection.SetRange("Product Group Code", "Product Group Code");
                Collection.SetFilter(Id, '<>%1', Id);
                if Collection.IsEmpty() then
                    "Default for Export" := true
                else
                    if "Default for Export" then
                        Collection.ModifyAll("Default for Export", false, false);
            end;
        }
        field(9; Version; BigInteger)
        {
            Caption = 'Version';
            DataClassification = SystemMetadata;
            SqlTimestamp = true;
        }
        field(10; "Item Templ. Code"; Code[20])
        {
            Caption = 'Item Template Code';
            TableRelation = "Item Templ.".Code;
            ValidateTableRelation = true;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        Validate("Default for Export");
    end;


    trigger OnModify()
    begin
        Validate("Default for Export");
    end;
}