namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Pricing;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.Address;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.SalesTax;

/// <summary>
/// Table Shpfy Catalog (ID 30152).
/// </summary>
table 30152 "Shpfy Catalog"
{
    Caption = 'Shopify Catalog';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Company SystemId"; Guid)
        {
            Caption = 'Company SystemId';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Company Name"; Text[500])
        {
            Caption = 'Company Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Company".Name where(SystemId = field("Company SystemId")));
        }
        field(4; Name; Text[500])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(5; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Shpfy Shop";
        }
        field(6; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            DataClassification = SystemMetadata;
            TableRelation = "Customer Price Group";
            ValidateTableRelation = true;
        }
        field(7; "Customer Discount Group"; Code[20])
        {
            Caption = 'Customer Discount Group';
            DataClassification = SystemMetadata;
            TableRelation = "Customer Discount Group";
            ValidateTableRelation = true;
        }
        field(8; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
        }
        field(9; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(10; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
        }
        field(11; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
        }
        field(12; "VAT Country/Region Code"; Code[10])
        {
            Caption = 'VAT Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(13; "Customer Posting Group"; Code[20])
        {
            Caption = 'Customer Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Posting Group";
        }
        field(14; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
            DataClassification = CustomerContent;
        }
        field(15; "Allow Line Disc."; Boolean)
        {
            Caption = 'Allow Line Disc.';
            DataClassification = CustomerContent;
        }
        field(16; "Sync Prices"; Boolean)
        {
            Caption = 'Sync Prices';
            DataClassification = CustomerContent;
        }
        field(17; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = "Customer";
        }
    }
    keys
    {
        key(PK; Id, "Company SystemId")
        {
            Clustered = true;
        }
    }
}
