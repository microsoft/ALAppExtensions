/// <summary>
/// Table Shpfy Shop (ID 30102).
/// </summary>
table 30102 "Shpfy Shop"
{
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
            NotBlank = true;
        }
        field(2; "Shopify URL"; Text[250])
        {
            Caption = 'Shopify URL';
            Access = Internal;
            DataClassification = SystemMetadata;
            ExtendedDatatype = URL;

            trigger OnValidate()
            var
                AuthenticationMgt: Codeunit "Shpfy Authentication Mgt.";
            begin
                if ("Shopify URL" <> '') then begin
                    if not "Shopify URL".ToLower().StartsWith('https://') then
                        "Shopify URL" := CopyStr('https://' + "Shopify URL", 1, MaxStrLen("Shopify URL"));

                    if not AuthenticationMgt.IsValidShopUrl("Shopify URL") then
                        Error(InvalidShopUrlErr);
                end;
                Rec.CalcShopId();
            end;
        }
        field(3; Enabled; Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            var
                CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
            begin
                if Rec."Enabled" then begin
                    Rec.TestField("Shopify URL");
                    Rec."Enabled" := CustomerConsentMgt.ConfirmUserConsent();
                end;
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
            TableRelation = "G/L Account"."No.";
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                if GLAccount.Get("Shipping Charges Account") then
                    CheckGLAccount(GLAccount);
            end;
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
            ObsoleteReason = 'Replaced by Item Templ. Code';
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
        }
        field(12; "Sync Item Images"; Option)
        {
            Caption = 'Sync Item Images';
            DataClassification = SystemMetadata;
            OptionCaption = 'Disabled,To Shopify,From Shopify';
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
        field(15; "Sync Item Marketing Text"; Boolean)
        {
            Caption = 'Sync Item Marketing Text';
            DataClassification = SystemMetadata;
        }
        field(21; "Auto Create Orders"; Boolean)
        {
            Caption = 'Auto Create Orders';
            DataClassification = SystemMetadata;
            trigger OnValidate()
            var
                ErrorInfo: ErrorInfo;
                AutoCreateErrorMsg: Label 'You cannot turn "%1" off if "%2" is set to the value of "%3".', Comment = '%1 = Field Caption of "Auto Create Orders", %2 = Field Caption of "Return and Refund Process", %3 = Field Value of "Return and Refund Process"';
            begin
                if Rec."Return and Refund Process" = "Shpfy ReturnRefund ProcessType"::"Auto Create Credit Memo" then
                    if not Rec."Auto Create Orders" then begin
                        ErrorInfo.FieldNo(Rec.FieldNo("Auto Create Orders"));
                        ErrorInfo.ErrorType := ErrorType::Client;
                        ErrorInfo.RecordId := Rec.RecordId;
                        ErrorInfo.Message := StrSubstNo(AutoCreateErrorMsg, Rec.FieldCaption("Auto Create Orders"), Rec.FieldCaption("Return and Refund Process"), Rec."Return and Refund Process");
                        Error(ErrorInfo);
                    end;
            end;
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
            ObsoleteReason = 'Replaced by  "Customer Templ. Code"';
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
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
            TableRelation = "G/L Account"."No.";
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                if GLAccount.Get("Tip Account") then
                    CheckGLAccount(GLAccount);
            end;
        }
        field(48; "Sold Gift Card Account"; Code[20])
        {
            Caption = 'Sold Gift Card Account';
            DataClassification = SystemMetadata;
            TableRelation = "G/L Account"."No.";
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                if GLAccount.Get("Sold Gift Card Account") then
                    CheckGLAccount(GLAccount);
            end;
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
        field(52; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency.Code;
        }
        field(53; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
        }
        field(54; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(55; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
        }
        field(56; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
        }
        field(57; "VAT Country/Region Code"; Code[10])
        {
            Caption = 'VAT Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(58; "Customer Posting Group"; Code[20])
        {
            Caption = 'Customer Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Posting Group";
        }
        field(59; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
            DataClassification = CustomerContent;
        }
        field(60; "Auto Release Sales Orders"; Boolean)
        {
            Caption = 'Auto Release Sales Orders';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(61; "Allow Line Disc."; Boolean)
        {
            Caption = 'Allow Line Disc.';
            DataClassification = CustomerContent;
        }
        field(62; "Customer Templ. Code"; Code[20])
        {
            Caption = 'Customer Template Code';
            DataClassification = SystemMetadata;
            TableRelation = "Customer Templ.".Code;
            ValidateTableRelation = true;
        }
        field(63; "Item Templ. Code"; Code[20])
        {
            Caption = 'Item Template Code';
            DataClassification = SystemMetadata;
            TableRelation = "Item Templ.".Code;
            ValidateTableRelation = true;
        }
        field(70; "Return and Refund Process"; Enum "Shpfy ReturnRefund ProcessType")
        {
            Caption = 'Return and Refund Process';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ErrorInfo: ErrorInfo;
                AutoCreateErrorMsg: Label 'You need to turn "%1" on if you want to set "%2" to the value of "%3".', Comment = '%1 = Field Caption of "Auto Create Orders", %2 = Field Caption of "Return and Refund Process", %3 = Field Value of "Return and Refund Process"';
            begin
                if Rec."Return and Refund Process" = "Shpfy ReturnRefund ProcessType"::"Auto Create Credit Memo" then
                    if not Rec."Auto Create Orders" then begin
                        ErrorInfo.FieldNo(Rec.FieldNo("Return and Refund Process"));
                        ErrorInfo.ErrorType := ErrorType::Client;
                        ErrorInfo.RecordId := Rec.RecordId;
                        ErrorInfo.Message := StrSubstNo(AutoCreateErrorMsg, Rec.FieldCaption("Auto Create Orders"), Rec.FieldCaption("Return and Refund Process"), Rec."Return and Refund Process");
                        Error(ErrorInfo);
                    end;
            end;
        }
        field(73; "Return Location"; Code[10])
        {
            Caption = 'Return Location';
            DataClassification = CustomerContent;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(75; "Refund Acc. non-restock Items"; Code[20])
        {
            Caption = 'Refund Account non-restock Items';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                if GLAccount.Get("Refund Acc. non-restock Items") then
                    CheckGLAccount(GLAccount);
            end;
        }
        field(76; "Refund Account"; Code[20])
        {
            Caption = 'Refund Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                if GLAccount.Get("Refund Account") then
                    CheckGLAccount(GLAccount);
            end;
        }
        field(100; "Collection Last Export Version"; BigInteger)
        {
            Caption = 'Collection Last Export Version';
            DataClassification = SystemMetadata;
            Editable = false;
            Access = Internal;
            ObsoleteReason = 'Not used. Moved to "Shpfy Synchronization Info" table.';
#if not CLEAN21
            ObsoleteTag = '21.0';
            ObsoleteState = Pending;
#else
            ObsoleteTag = '24.0';
            ObsoleteState = Removed;
#endif
        }
        field(101; "Collection Last Import Version"; BigInteger)
        {
            Caption = 'Collection Last Import Version';
            DataClassification = SystemMetadata;
            Editable = false;
            Access = Internal;
            ObsoleteReason = 'Not used. Moved to "Shpfy Synchronization Info" table.';
#if not CLEAN21
            ObsoleteTag = '21.0';
            ObsoleteState = Pending;
#else
            ObsoleteTag = '24.0';
            ObsoleteState = Removed;
#endif
        }
        field(102; "Product Last Export Version"; BigInteger)
        {
            Caption = 'Product Last Export Version';
            DataClassification = SystemMetadata;
            Editable = false;
            Access = Internal;
            ObsoleteReason = 'Not used. Moved to "Shpfy Synchronization Info" table.';
#if not CLEAN21
            ObsoleteTag = '21.0';
            ObsoleteState = Pending;
#else
            ObsoleteTag = '24.0';
            ObsoleteState = Removed;
#endif
        }
        field(103; "Product Last Import Version"; BigInteger)
        {
            Caption = 'Product Last Import Version';
            DataClassification = SystemMetadata;
            Editable = false;
            Access = Internal;
            ObsoleteReason = 'Not used. Moved to "Shpfy Synchronization Info" table.';
#if not CLEAN21
            ObsoleteTag = '21.0';
            ObsoleteState = Pending;
#else
            ObsoleteTag = '24.0';
            ObsoleteState = Removed;
#endif
        }
#pragma warning disable AS0004
        field(104; "SKU Mapping"; Enum "Shpfy SKU Mapping")
#pragma warning restore AS0004
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
        field(107; "Allow Outgoing Requests"; Boolean)
        {
            Caption = 'Allow Outgoing Requests';
            DataClassification = SystemMetadata;
            InitValue = true;
        }
        field(108; "Order Created Webhooks"; Boolean)
        {
            Caption = 'Order Created Webhooks';
            DataClassification = SystemMetadata;
        }
        field(109; "Order Created Webhook User"; Code[50])
        {
            Caption = 'Order Created Webhook User';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
        }
        field(110; "Fulfillment Service Activated"; Boolean)
        {
            Caption = 'Fulfillment Service Activated';
            DataClassification = SystemMetadata;
            Description = 'Indicates whether the Shopify Fulfillment Service is activated.';
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

    var
        InvalidShopUrlErr: Label 'The URL must refer to the internal shop location at myshopify.com. It must not be the public URL that customers use, such as myshop.com.';

    [NonDebuggable]
    [Scope('OnPrem')]
    internal procedure GetAccessToken() Result: Text
    var
        AuthenticationMgt: Codeunit "Shpfy Authentication Mgt.";
        Store: Text;
    begin
        Rec.Testfield(Enabled, true);
        Store := GetStoreName();
        if Store <> '' then
            exit(AuthenticationMgt.GetAccessToken(Store));
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    internal procedure RequestAccessToken()
    var
        AuthenticationMgt: Codeunit "Shpfy Authentication Mgt.";
        Store: Text;
    begin
        Store := GetStoreName();
        if Store <> '' then
            AuthenticationMgt.InstallShopifyApp(Store);
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    internal procedure HasAccessToken(): Boolean
    var
        AuthenticationMgt: Codeunit "Shpfy Authentication Mgt.";
        Store: Text;
    begin
        Store := GetStoreName();
        if Store <> '' then
            exit(AuthenticationMgt.AccessTokenExist(Store));
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
        SynchronizationInfo: Record "Shpfy Synchronization Info";
    begin
        if Type = "Shpfy Synchronization Type"::Orders then begin
            if Rec."Shop Id" = 0 then begin
                Rec.CalcShopId();
                Rec.Modify();
            end;
            if SynchronizationInfo.Get(Format(Rec."Shop Id"), Type) then
                exit(SynchronizationInfo."Last Sync Time");
        end;
        if SynchronizationInfo.Get(Rec.Code, Type) then
            exit(SynchronizationInfo."Last Sync Time");
        exit(0DT);
    end;

    internal procedure SetLastSyncTime(Type: Enum "Shpfy Synchronization Type")
    begin
        SetLastSyncTime(Type, CurrentDateTime);
    end;

    internal procedure SetLastSyncTime(Type: Enum "Shpfy Synchronization Type"; ToDateTime: DateTime)
    var
        SynchronizationInfo: Record "Shpfy Synchronization Info";
        ShopCode: Code[20];
    begin
        if Type = "Shpfy Synchronization Type"::Orders then
            ShopCode := Format(Rec."Shop Id")
        else
            ShopCode := Rec.Code;
        if SynchronizationInfo.Get(ShopCode, Type) then begin
            SynchronizationInfo."Last Sync Time" := ToDateTime;
            SynchronizationInfo.Modify();
        end else begin
            Clear(SynchronizationInfo);
            SynchronizationInfo."Shop Code" := ShopCode;
            SynchronizationInfo."Synchronization Type" := Type;
            SynchronizationInfo."Last Sync Time" := ToDateTime;
            SynchronizationInfo.Insert();
        end;
    end;

    internal procedure CheckGLAccount(GLAccount: Record "G/L Account")
    begin
        GLAccount.TestField("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.TestField("Direct Posting", true);
        GLAccount.TestField(Blocked, false);
    end;

#if CLEAN22
    internal procedure CopyPriceCalculationFieldsFromCustomerTempl(TemplateCode: Code[20])
    var
        CustomerTempl: Record "Customer Templ.";
    begin
        if TemplateCode = '' then
            exit;
        if not CustomerTempl.Get(TemplateCode) then
            exit;
        Rec."Gen. Bus. Posting Group" := CustomerTempl."Gen. Bus. Posting Group";
        Rec."VAT Bus. Posting Group" := CustomerTempl."VAT Bus. Posting Group";
        Rec."Tax Area Code" := CustomerTempl."Tax Area Code";
        Rec."Tax Liable" := CustomerTempl."Tax Liable";
        Rec."VAT Country/Region Code" := CustomerTempl."Country/Region Code";
        Rec."Customer Posting Group" := CustomerTempl."Customer Posting Group";
        Rec."Prices Including VAT" := CustomerTempl."Prices Including VAT";
        Rec."Allow Line Disc." := CustomerTempl."Allow Line Disc.";
        Rec.Modify();
    end;
#endif

#if not CLEAN22
    internal procedure CopyPriceCalculationFieldsFromCustomerTemplate(TemplateCode: Code[10])
    var
        Customer: Record Customer;
    begin
        if TemplateCode <> '' then begin
            Rec."Gen. Bus. Posting Group" := GetValueFromConfigTemplateLine(TemplateCode, Database::Customer, Customer.FieldNo("Gen. Bus. Posting Group"));
            Rec."VAT Bus. Posting Group" := GetValueFromConfigTemplateLine(TemplateCode, Database::Customer, Customer.FieldNo("VAT Bus. Posting Group"));
            Rec."Tax Area Code" := GetValueFromConfigTemplateLine(TemplateCode, Database::Customer, Customer.FieldNo("Tax Area Code"));
            if Evaluate(Rec."Tax Liable", GetValueFromConfigTemplateLine(TemplateCode, Database::Customer, Customer.FieldNo("Tax Liable"))) then;
            Rec."VAT Country/Region Code" := GetValueFromConfigTemplateLine(TemplateCode, Database::Customer, Customer.FieldNo("Country/Region Code"));
            Rec."Customer Posting Group" := GetValueFromConfigTemplateLine(TemplateCode, Database::Customer, Customer.FieldNo("Customer Posting Group"));
            if Evaluate(Rec."Prices Including VAT", GetValueFromConfigTemplateLine(TemplateCode, Database::Customer, Customer.FieldNo("Prices Including VAT"))) then;
            if Evaluate(Rec."Allow Line Disc.", GetValueFromConfigTemplateLine(TemplateCode, Database::Customer, Customer.FieldNo("Allow Line Disc."))) then;
            Rec.Modify();
        end;
    end;

    local procedure GetValueFromConfigTemplateLine(TemplateCode: Code[10]; TableID: Integer; FieldID: Integer): Text
    var
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        ConfigTemplateLine.Reset();
        ConfigTemplateLine.SetRange("Data Template Code", TemplateCode);
        ConfigTemplateLine.SetRange(Type, ConfigTemplateLine.type::Field);
        ConfigTemplateLine.SetRange("Table ID", TableID);
        ConfigTemplateLine.SetRange("Field ID", FieldID);
        if ConfigTemplateLine.FindFirst() then
            exit(ConfigTemplateLine."Default Value");
    end;
#endif
}