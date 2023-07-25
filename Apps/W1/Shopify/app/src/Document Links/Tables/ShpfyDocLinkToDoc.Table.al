table 30146 "Shpfy Doc. Link To Doc."
{
    Caption = 'Doc. Link To BC Doc.';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Shopify Document Type"; Enum "Shpfy Shop Document Type")
        {
            Caption = 'Shopify Document Type';
            DataClassification = SystemMetadata;
        }
        field(2; "Shopify Document Id"; BigInteger)
        {
            Caption = 'Shopify Document Id';
            DataClassification = SystemMetadata;
        }
        field(3; "Document Type"; Enum "Shpfy Document Type")
        {
            Caption = 'Document Type';
            DataClassification = SystemMetadata;
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Shopify Document Type", "Shopify Document Id", "Document Type", "Document No.")
        {
            Clustered = true;
        }
        key(Idx01; "Shopify Document Type", "Shopify Document Id") { }
        key(Idx02; "Document Type", "Document No.") { }
    }

    internal procedure OpenShopifYDocument()
    var
        IOpenShopifyDocument: Interface "Shpfy IOpenShopifyDocument";
    begin
        IOpenShopifyDocument := Rec."Shopify Document Type";
        IOpenShopifyDocument.OpenDocument(Rec."Shopify Document Id");
    end;

    internal procedure OpenBCDocument()
    var
        IOpenBCDocument: Interface "Shpfy IOpenBCDocument";
    begin
        IOpenBCDocument := Rec."Document Type";
        IOpenBCDocument.OpenDocument(Rec."Document No.");
    end;
}