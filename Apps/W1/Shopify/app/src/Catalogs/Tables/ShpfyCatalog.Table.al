namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Pricing;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.Address;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.SalesTax;
using Microsoft.Finance.Currency;

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
            ToolTip = 'Specifies the unique identifier for the catalog in Shopify.';
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
            ToolTip = 'Specifies the name of the company that the catalog belongs to.';
        }
        field(4; Name; Text[500])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the catalog''s name.';
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
            ToolTip = 'Specifies which Customer Price Group is used to calculate the prices in the catalog.';
        }
        field(7; "Customer Discount Group"; Code[20])
        {
            Caption = 'Customer Discount Group';
            DataClassification = SystemMetadata;
            TableRelation = "Customer Discount Group";
            ValidateTableRelation = true;
            ToolTip = 'Specifies which Customer Discount Group is used to calculate the prices in the catalog.';
        }
        field(8; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
            ToolTip = 'Specifies which Gen. Bus. Posting Group is used to calculate the prices in the catalog.';
        }
        field(9; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
            ToolTip = 'Specifies which VAT. Bus. Posting Group is used to calculate the prices in the catalog.';
        }
        field(10; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
            ToolTip = 'Specifies which Tax Area Code is used to calculate the prices in the catalog.';
        }
        field(11; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if Tax Liable is used to calculate the prices in the catalog.';
        }
        field(12; "VAT Country/Region Code"; Code[10])
        {
            Caption = 'VAT Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
            ToolTip = 'Specifies which VAT Country/Region Code is used to calculate the prices in the catalog.';
        }
        field(13; "Customer Posting Group"; Code[20])
        {
            Caption = 'Customer Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Posting Group";
            ToolTip = 'Specifies which Customer Posting Group is used to calculate the prices in the catalog.';
        }
        field(14; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if the prices are Including VAT.';
        }
        field(15; "Allow Line Disc."; Boolean)
        {
            Caption = 'Allow Line Disc.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if line discount is allowed while calculating prices for the catalog.';
        }
        field(16; "Sync Prices"; Boolean)
        {
            Caption = 'Sync Prices';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if the prices are synced to Shopify.';
        }
        field(17; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = "Customer";
            ToolTip = 'Specifies the customer''s no.  When Customer No. is Selected: Parameters like ''Customer Discount Group'', ''Customer Price Group'', and ''Allow Line Discount'' on the customer card take precedence over catalog settings';
        }
        field(18; "Catalog Type"; Enum "Shpfy Catalog Type")
        {
            Caption = 'Catalog Type';
            DataClassification = CustomerContent;
        }
        field(19; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = "Currency";
            ToolTip = 'Specifies the currency code for the catalog.';
        }
    }
    keys
    {
        key(PK; Id, "Company SystemId")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        ClearCatalogMarketRelations();
    end;

    local procedure ClearCatalogMarketRelations()
    var
        MarketCatalogRelation: Record "Shpfy Market Catalog Relation";
    begin
        MarketCatalogRelation.SetRange("Catalog Id", Id);
        MarketCatalogRelation.DeleteAll(true);
    end;
}
