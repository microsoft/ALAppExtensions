namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Customer;
using Microsoft.CRM.Contact;
using Microsoft.Inventory.Item;
using System.Security.AccessControl;

table 8008 "Imported Service Object"
{
    DataClassification = CustomerContent;
    Caption = 'Imported Service Object';
    Access = Internal;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            NotBlank = true;
        }
        field(2; "Service Object No."; Code[20])
        {
            Caption = 'Service Object No.';
            TableRelation = "Service Object";
            ValidateTableRelation = false;
        }
        field(3; "End-User Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(4; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            NotBlank = true;
            TableRelation = Customer;
        }
        field(5; "Bill-to Contact No."; Code[20])
        {
            Caption = 'Bill-to Contact No.';
            TableRelation = Contact;
        }
        field(6; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            TableRelation = "Ship-to Address".Code where("Customer No." = field("End-User Customer No."));
        }
        field(7; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item where("Service Commitment Option" = filter("Sales with Service Commitment" | "Service Commitment Item"));

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if Description = '' then
                    if "Item No." <> '' then begin
                        Item.Get("Item No.");
                        Description := Item.Description;
                    end;
            end;
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
        }

        field(10; "Customer Reference"; Text[35])
        {
            Caption = 'Customer Reference';
        }
        field(11; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';

            trigger OnValidate()
            begin
                if ("Quantity (Decimal)" <> 1) and ("Serial No." <> '') then
                    Error(SerialQtyErr);
            end;
        }
        field(12; Version; Text[100])
        {
            Caption = 'Version';
        }
        field(13; "Key"; Text[100])
        {
            Caption = 'Key';
        }
        field(14; "Provision Start Date"; Date)
        {
            Caption = 'Provision Start Date';
        }
        field(15; "Provision End Date"; Date)
        {
            Caption = 'Provision End Date';
        }
        field(16; "End-User Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            TableRelation = Contact;
        }
        field(17; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
        }
        field(19; "Quantity (Decimal)"; Decimal)
        {
            Caption = 'Quantity';
            InitValue = 1;
        }
        field(100; "Service Object created"; Boolean)
        {
            Caption = 'Service Object created';
            Editable = false;
        }
        field(101; "Error Text"; Text[250])
        {
            Caption = 'Error Text';
            Editable = false;
        }
        field(102; "Processed by"; Code[50])
        {
            Caption = 'Processed by';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            Editable = false;
            ValidateTableRelation = false;
        }
        field(103; "Processed at"; DateTime)
        {
            Caption = 'Processed at';
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    var
        SerialQtyErr: Label 'Only service objects with quantity 1 may have a serial number.';
}