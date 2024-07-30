namespace Microsoft.Integration.Shopify;

using Microsoft.Foundation.Shipping;
using Microsoft.Sales.Document;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Inventory.Item;

/// <summary>
/// Table Shpfy Shipment Method Mapping (ID 30131).
/// </summary>
table 30131 "Shpfy Shipment Method Mapping"
{
    Access = Internal;
    Caption = 'Shopify Shipment Method';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Shop";
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipment Method";
        }
        field(4; "Shipping Charges Type"; Enum "Sales Line Type")
        {
            Caption = 'Shipping Charges Type';
            DataClassification = CustomerContent;
            ValuesAllowed = " ", "G/L Account", Item, "Charge (Item)";

            trigger OnValidate()
            begin
                if "Shipping Charges Type" <> xRec."Shipping Charges Type" then
                    Clear("Shipping Charges No.");
            end;
        }
        field(5; "Shipping Charges No."; Code[20])
        {
            Caption = 'Shipping Charges No.';
            TableRelation = if ("Shipping Charges Type" = const("G/L Account")) "G/L Account"
            else
            if ("Shipping Charges Type" = const(Item)) Item
            else
            if ("Shipping Charges Type" = const("Charge (Item)")) "Item Charge";

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
                ShpfyShop: Record "Shpfy Shop";
            begin
                if "Shipping Charges Type" = "Shipping Charges Type"::"G/L Account" then
                    if GLAccount.Get("Shipping Charges No.") then
                        ShpfyShop.CheckGLAccount(GLAccount);
            end;
        }
        field(6; "Shipping Agent Code"; Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services" = R;
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";

            trigger OnValidate()
            begin
                if "Shipping Agent Code" <> xRec."Shipping Agent Code" then
                    Clear("Shipping Agent Service Code");
            end;
        }
        field(7; "Shipping Agent Service Code"; Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services" = R;
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
        }
    }

    keys
    {
        key(PK; "Shop Code", Name)
        {
            Clustered = true;
        }
    }
}