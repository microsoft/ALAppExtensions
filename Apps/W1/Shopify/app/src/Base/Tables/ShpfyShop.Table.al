/// <summary>
/// Table Shpfy Shop (ID 30102).
/// </summary>
table 30102 "Shpfy Shop"
{
    Access = Internal;
    Caption = 'Shopify Shop';
    DataClassification = SystemMetadata;
    DrillDownPageId = "Shpfy Shops";
    LookupPageId = "Shpfy Shops";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
        }
        field(2; "Shopify URL"; Text[250])
        {
            Caption = 'Shopify URL';
            DataClassification = SystemMetadata;
            ExtendedDatatype = URL;
        }
        field(3; Enabled; Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            var
                CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
            begin
                if not xRec."Enabled" and Rec."Enabled" then
                    Rec."Enabled" := CustomerConsentMgt.ConfirmUserConsent();
            end;
        }
        field(5; "Log Enabled"; Boolean)
        {
            Caption = 'Log Enabled';
            DataClassification = SystemMetadata;
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
        field(8; "Shipping Charges Account"; Code[20])
        {
            Caption = 'Shipping Charges Account';
            DataClassification = SystemMetadata;
            TableRelation = "G/L Account";
            ValidateTableRelation = true;
        }
        field(9; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = SystemMetadata;
            TableRelation = Language;
            ValidateTableRelation = true;
        }
        field(10; "Sync Item"; Option)
        {
            Caption = 'Sync Item';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,To Shopify,From Shopify';
            OptionMembers = " ","To Shopify","From Shopify";
        }
        field(11; "Item Template Code"; Code[10])
        {
            Caption = 'Item Template Code';
            DataClassification = SystemMetadata;
            TableRelation = "Config. Template Header".Code where("Table Id" = const(27));
            ValidateTableRelation = true;
        }
        field(12; "Sync Item Images"; Option)
        {
            Caption = 'Sync Item Images';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,To Shopify,From Shopify';
            OptionMembers = " ","To Shopify","From Shopify";
        }
        field(13; "Sync Item Extended Text"; boolean)
        {
            Caption = 'Sync Item Extended Text';
            DataClassification = SystemMetadata;
        }
        field(14; "Sync Item Attributes"; boolean)
        {
            Caption = 'Sync Item Attributes';
            DataClassification = SystemMetadata;
        }
        field(21; "Auto Create Orders"; Boolean)
        {
            Caption = 'Auto Create Orders';
            DataClassification = SystemMetadata;
        }
        field(22; "Auto Create Unknown Items"; Boolean)
        {
            Caption = 'Auto Create Unknown Items';
            DataClassification = SystemMetadata;
        }
        field(23; "Auto Create Unknown Customers"; Boolean)
        {
            Caption = 'Auto Create Unknown Customers';
            DataClassification = SystemMetadata;
        }
        field(24; "Customer Template Code"; Code[10])
        {
            Caption = 'Customer Template Code';
            DataClassification = SystemMetadata;
            TableRelation = "Config. Template Header".Code where("Table Id" = const(18));
            ValidateTableRelation = true;
        }
        field(25; "Product Collection"; Option)
        {
            Caption = 'Product Collection';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Tax Group,VAT Prod. Posting Group';
            OptionMembers = " ","Tax Group","VAT Prod. Posting Group";
        }
        field(27; "Shopify Order No. on Doc. Line"; Boolean)
        {
            Caption = 'Shopify Order No. on Doc. Line';
            DataClassification = CustomerContent;
        }
        field(28; "Customer Import From Shopify"; enum "Shpfy Customer Import Range")
        {
            Caption = 'Customer Import from Shopify';
            DataClassification = CustomerContent;
            InitValue = WithOrderImport;
        }
        field(29; "Export Customer To Shopify"; Boolean)
        {
            Caption = 'Export Customer to Shopify';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(30; "Shopify Can Update Customer"; Boolean)
        {
            Caption = 'Shopify Can Update Customers';
            DataClassification = CustomerContent;
            InitValue = false;

            trigger OnValidate()
            begin
                if "Shopify Can Update Customer" then
                    "Can Update Shopify Customer" := false;
            end;
        }
        field(31; "Can Update Shopify Customer"; Boolean)
        {
            Caption = 'Can Update Shopify Customers';
            DataClassification = CustomerContent;
            InitValue = false;

            trigger OnValidate()
            begin
                if "Can Update Shopify Customer" then
                    "Shopify Can Update Customer" := false;
            end;
        }
        field(32; "Name Source"; enum "Shpfy Name Source")
        {
            Caption = 'Name Source';
            DataClassification = CustomerContent;
            InitValue = CompanyName;
        }
        field(33; "Name 2 Source"; enum "Shpfy Name Source")
        {
            Caption = 'Name 2 Source';
            DataClassification = CustomerContent;
            InitValue = FirstAndLastName;
        }
        field(34; "Contact Source"; enum "Shpfy Name Source")
        {
            Caption = 'Contact Source';
            DataClassification = CustomerContent;
            InitValue = FirstAndLastName;
            ValuesAllowed = FirstAndLastName, LastAndFirstName, None;
        }
        field(35; "County Source"; enum "Shpfy County Source")
        {
            Caption = 'County Source';
            DataClassification = CustomerContent;
            InitValue = Code;
        }
        field(36; "Default Customer No."; Code[20])
        {
            Caption = 'Default Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(37; "UoM as Variant"; Boolean)
        {
            Caption = 'UoM as Variant';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "UoM as Variant" and ("Option Name for UoM" = '') then
                    "Option Name for UoM" := 'Unit of Measure';
            end;
        }
        field(38; "Option Name for UoM"; Text[50])
        {
            Caption = 'Variant Option Name for UoM';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Option Name for UoM" = '' then
                    "UoM as Variant" := false;
            end;
        }
        field(39; "Shopify Can Update Items"; Boolean)
        {
            Caption = 'Shopify Can Update Items';
            DataClassification = CustomerContent;
            InitValue = false;

            trigger OnValidate()
            begin
                if "Shopify Can Update Items" then
                    "Can Update Shopify Products" := false;
            end;
        }
        field(40; "Can Update Shopify Products"; Boolean)
        {
            Caption = 'Can Update Shopify Products';
            DataClassification = CustomerContent;
            InitValue = false;

            trigger OnValidate()
            begin
                if "Can Update Shopify Products" then
                    "Shopify Can Update Items" := false;
            end;
        }
        field(41; "Variant Prefix"; Code[5])
        {
            Caption = 'Variant Prefix';
            DataClassification = CustomerContent;
            InitValue = 'V_';
        }
        field(42; "Inventory Tracked"; Boolean)
        {
            Caption = 'Inventory Tracked';
            DataClassification = CustomerContent;
        }
        field(43; "Default Inventory Policy"; Enum "Shpfy Inventory Policy")
        {
            Caption = 'Default Inventory Policy';
            DataClassification = CustomerContent;
            InitValue = CONTINUE;
        }
        field(44; "Allow Background Syncs"; Boolean)
        {
            Caption = 'Allow Background Syncs';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(47; "Tip Account"; Code[20])
        {
            Caption = 'Tip Account';
            DataClassification = SystemMetadata;
            TableRelation = "G/L Account";
            ValidateTableRelation = true;
        }
        field(48; "Sold Gift Card Account"; Code[20])
        {
            Caption = 'Sold Gift Card Account';
            DataClassification = SystemMetadata;
            TableRelation = "G/L Account";
            ValidateTableRelation = true;
        }
        field(49; "Customer Mapping Type"; enum "Shpfy Customer Mapping")
        {
            Caption = 'Customer Mapping Type';
            DataClassification = CustomerContent;
        }
        field(50; "Status for Created Products"; Enum "Shpfy Cr. Prod. Status Value")
        {
            Caption = 'Status for Created Products';
            DataClassification = CustomerContent;
        }
        field(51; "Action for Removed Products"; Enum "Shpfy Remove Product Action")
        {
            Caption = 'Action for Removed Products';
            DataClassification = CustomerContent;
        }
        field(52; "Currency Code"; code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency.Code;
        }
        field(100; "Collection Last Export Version"; BigInteger)
        {
            Caption = 'Collection Last Export Version';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(101; "Collection Last Import Version"; BigInteger)
        {
            Caption = 'Collection Last Import Version';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(102; "Product Last Export Version"; BigInteger)
        {
            Caption = 'Product Last Export Version';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(103; "Product Last Import Version"; BigInteger)
        {
            Caption = 'Product Last Import Version';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(104; "SKU Mapping"; Enum "Shpfy SKU Mappging")
        {
            Caption = 'SKU Mapping';
            DataClassification = SystemMetadata;

        }
        field(105; "SKU Field Separator"; Code[10])
        {
            Caption = 'SKU Field Separator';
            DataClassification = SystemMetadata;
            InitValue = '|';
        }
        field(106; "Tax Area Priority"; Enum "Shpfy Tax By")
        {
            Caption = 'Tax Area Priority';
            DataClassification = CustomerContent;
            Description = 'Choose in which order the system try to find the county for the tax area.';
        }
        field(200; "Shop Id"; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
        key(Idx1; "Shop Id") { }
    }


    [NonDebuggable]
    internal procedure GetAccessToken() Result: Text
    var
        AuthorizationMgt: Codeunit "Shpfy Authentication Mgt.";
        Store: Text;
    begin
        Rec.Testfield(Enabled, true);
        Store := GetStoreName();
        if Store <> '' then
            exit(AuthorizationMgt.GetAccessToken(Store));
    end;

    [NonDebuggable]
    internal procedure RequestAccessToken()
    var
        AuthorizationMgt: Codeunit "Shpfy Authentication Mgt.";
        Store: Text;
    begin
        Store := GetStoreName();
        if Store <> '' then
            AuthorizationMgt.InstallShopifyApp(Store);
    end;

    [NonDebuggable]
    internal procedure HasAccessToken(): Boolean
    var
        AuthorizationMgt: Codeunit "Shpfy Authentication Mgt.";
        Store: Text;
    begin
        Store := GetStoreName();
        if Store <> '' then
            exit(AuthorizationMgt.AccessTokenExist(Store));
    end;

    local procedure GetStoreName() Store: Text
    begin
        Store := "Shopify URL".ToLower();
        if Store.Contains(':') then
            Store := Store.Split(':').Get(2);
        Store := Store.TrimStart('/').TrimEnd('/');
    end;

    /// <summary> 
    /// Calc Shop Id.
    /// </summary>
    internal procedure CalcShopId()
    var
        Shop: Record "Shpfy Shop";
        Hash: Codeunit "Shpfy Hash";
    begin
        if "Shopify URL" = '' then
            "Shop Id" := 0;

        "Shop Id" := Hash.CalcHash("Shopify URL");
        Shop.SetRange("Shop Id", "Shop Id");
        Shop.SetFilter("Shopify URL", '<>%1', "Shopify URL");
        Shop.SetCurrentKey("Shop Id");
        while not Shop.IsEmpty do begin
            "Shop Id" += 1;
            Shop.SetRange("Shop Id", "Shop Id");
        end;
    end;

    internal procedure GetLastSyncTime(Type: Enum "Shpfy Synchronization Type"): DateTime
    var
        SyncInfo: Record "Shpfy Synchronization Info";
    begin
        if SyncInfo.Get(Rec.Code, Type) then
            exit(SyncInfo."Last Sync Time");
        exit(0DT);
    end;

    internal procedure SetLastSyncTime(Type: Enum "Shpfy Synchronization Type")
    begin
        SetLastSyncTime(Type, CurrentDateTime);
    end;

    internal procedure SetLastSyncTime(Type: Enum "Shpfy Synchronization Type"; ToDateTime: DateTime)
    var
        SyncInfo: Record "Shpfy Synchronization Info";
    begin
        if SyncInfo.Get(Rec.Code, Type) then begin
            SyncInfo."Last Sync Time" := ToDateTime;
            SyncInfo.Modify();
        end else begin
            Clear(SyncInfo);
            SyncInfo."Shop Code" := Rec.Code;
            SyncInfo."Synchronization Type" := Type;
            SyncInfo."Last Sync Time" := ToDateTime;
            SyncInfo.Insert();
        end;
    end;
}