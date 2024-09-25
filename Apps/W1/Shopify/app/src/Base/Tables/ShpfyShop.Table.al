namespace Microsoft.Integration.Shopify;

using Microsoft.Finance.GeneralLedger.Account;
using System.Globalization;
using System.IO;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Pricing;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.SalesTax;
using Microsoft.Foundation.Address;
using Microsoft.Inventory.Item;
using System.Security.AccessControl;
using System.DataAdministration;
using System.Privacy;
using System.Threading;
using Microsoft.Inventory.Location;

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

                    if "Shopify URL".ToLower().StartsWith('https://admin.shopify.com/store/') then
                        "Shopify URL" := CopyStr('https://' + "Shopify URL".Replace('https://admin.shopify.com/store/', '').Split('/').Get(1) + '.myshopify.com', 1, MaxStrLen("Shopify URL"));

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
                WebhooksMgt: Codeunit "Shpfy Webhooks Mgt.";
            begin
                if Rec."Enabled" then begin
                    Rec.TestField("Shopify URL");
                    Rec."Enabled" := CustomerConsentMgt.ConfirmUserConsent();
                end else begin
                    Rec.Enabled := true;
                    Rec.Validate("Order Created Webhooks", false);
                    WebhooksMgt.DisableBulkOperationsWebhook(Rec);
                    Rec.Enabled := false;
                end;
            end;
        }
        field(5; "Log Enabled"; Boolean)
        {
            Caption = 'Log Enabled';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Replaced with field "Logging Mode"';
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
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
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
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
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
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
            ObsoleteReason = 'Replaced with action "Add Customer to Shopify" in Shopify Customers page.';
#if not CLEAN24
            ObsoleteState = Pending;
            ObsoleteTag = '24.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '27.0';
#endif
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
            Caption = 'Action for Removed Products and Blocked Items';
            DataClassification = CustomerContent;
        }
        field(52; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency.Code;

            trigger OnValidate()
            var
                CurrencyExchangeRate: Record "Currency Exchange Rate";
            begin
                if "Currency Code" <> '' then begin
                    CurrencyExchangeRate.SetRange("Currency Code", "Currency Code");
                    if CurrencyExchangeRate.IsEmpty() then
                        Error(CurrencyExchangeRateNotDefinedErr);
                end;
            end;
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
            InitValue = "Import Only";

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
            Caption = 'Default Return Location';
            DataClassification = CustomerContent;
            TableRelation = Location where("Use As In-Transit" = const(false));
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
            ObsoleteTag = '24.0';
            ObsoleteState = Removed;
        }
        field(101; "Collection Last Import Version"; BigInteger)
        {
            Caption = 'Collection Last Import Version';
            DataClassification = SystemMetadata;
            Editable = false;
            Access = Internal;
            ObsoleteReason = 'Not used. Moved to "Shpfy Synchronization Info" table.';
            ObsoleteTag = '24.0';
            ObsoleteState = Removed;
        }
        field(102; "Product Last Export Version"; BigInteger)
        {
            Caption = 'Product Last Export Version';
            DataClassification = SystemMetadata;
            Editable = false;
            Access = Internal;
            ObsoleteReason = 'Not used. Moved to "Shpfy Synchronization Info" table.';
            ObsoleteTag = '24.0';
            ObsoleteState = Removed;
        }
        field(103; "Product Last Import Version"; BigInteger)
        {
            Caption = 'Product Last Import Version';
            DataClassification = SystemMetadata;
            Editable = false;
            Access = Internal;
            ObsoleteReason = 'Not used. Moved to "Shpfy Synchronization Info" table.';
            ObsoleteTag = '24.0';
            ObsoleteState = Removed;
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

            trigger OnValidate()
            var
                ShpfyWebhooksMgt: Codeunit "Shpfy Webhooks Mgt.";
            begin
                if "Order Created Webhooks" then
                    ShpfyWebhooksMgt.EnableOrderCreatedWebhook(Rec)
                else
                    ShpfyWebhooksMgt.DisableOrderCreatedWebhook(Rec);
            end;
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
        field(111; "Order Created Webhook User Id"; Guid)
        {
            Caption = 'Order Created Webhook User Id';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User;

            trigger OnValidate()
            var
                User: Record User;
            begin
                if User.Get("Order Created Webhook User Id") then
                    "Order Created Webhook User" := User."User Name";
            end;
        }
        field(112; "Order Created Webhook Id"; Text[500])
        {
            Caption = 'Order Created Webhook Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(113; "Logging Mode"; Enum "Shpfy Logging Mode")
        {
            Caption = 'Logging Mode';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Logging Mode" = "Logging Mode"::All then
                    EnableShopifyLogRetentionPolicySetup();
            end;
        }
        field(114; "Bulk Operation Webhook User Id"; Guid)
        {
            Caption = 'Bulk Operation Webhook User Id';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User;
        }
        field(115; "Bulk Operation Webhook Id"; Text[500])
        {
            Caption = 'Bulk Operation Webhook Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(116; "Sync Prices"; Boolean)
        {
            Caption = 'Sync Prices with Products';
            DataClassification = SystemMetadata;
            InitValue = true;
        }
        field(117; "B2B Enabled"; Boolean)
        {
            Caption = 'B2B Enabled';
            DataClassification = SystemMetadata;
        }
        field(118; "Can Update Shopify Companies"; Boolean)
        {
            Caption = 'Can Update Shopify Companies';
            DataClassification = CustomerContent;
            InitValue = false;

            trigger OnValidate()
            begin
                if "Can Update Shopify Companies" then
                    "Shopify Can Update Companies" := false;
            end;
        }
        field(119; "Default Contact Permission"; Enum "Shpfy Default Cont. Permission")
        {
            Caption = 'Default Contact Permission';
            DataClassification = CustomerContent;
            InitValue = "Ordering Only";
        }
        field(120; "Auto Create Catalog"; Boolean)
        {
            Caption = 'Auto Create Catalog';
            DataClassification = CustomerContent;
        }
        field(121; "Company Import From Shopify"; Enum "Shpfy Company Import Range")
        {
            Caption = 'Company Import from Shopify';
            DataClassification = CustomerContent;
            InitValue = WithOrderImport;
        }
        field(122; "Shopify Can Update Companies"; Boolean)
        {
            Caption = 'Shopify Can Update Companies';
            DataClassification = CustomerContent;
            InitValue = false;

            trigger OnValidate()
            begin
                if "Shopify Can Update Companies" then
                    "Can Update Shopify Companies" := false;
            end;
        }
        field(123; "Auto Create Unknown Companies"; Boolean)
        {
            Caption = 'Auto Create Unknown Companies';
            DataClassification = CustomerContent;
        }
        field(124; "Send Shipping Confirmation"; Boolean)
        {
            Caption = 'Send Shipping Confirmation';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(125; "Default Company No."; Code[20])
        {
            Caption = 'Default Company No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(126; "Company Mapping Type"; Enum "Shpfy Company Mapping")
        {
            Caption = 'Company Mapping Type';
            DataClassification = CustomerContent;
        }
        field(127; "Replace Order Attribute Value"; Boolean)
        {
            Caption = 'Replace Order Attribute Value';
            DataClassification = SystemMetadata;
            InitValue = true;
            ObsoleteReason = 'This feature will be enabled by default with version 27.0.';
#if not CLEAN24
            ObsoleteState = Pending;
            ObsoleteTag = '24.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '27.0';
#endif

#if not CLEAN24
            trigger OnValidate()
            begin
                if "Replace Order Attribute Value" then
                    UpdateOrderAttributes(Rec.Code);
            end;
#endif
        }
        field(128; "Return Location Priority"; Enum "Shpfy Return Location Priority")
        {
            Caption = 'Return Location Priority';
            DataClassification = CustomerContent;
        }
        field(129; "Weight Unit"; Enum "Shpfy Weight Unit")
        {
            Caption = 'Weight Unit';
            DataClassification = CustomerContent;
        }
        field(200; "Shop Id"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(201; "Items Mapped to Products"; Boolean)
        {
            Caption = 'Items Must be Mapped to Products';
            ObsoleteReason = 'This setting is not used';
#if not CLEAN26
            ObsoleteState = Pending;
            ObsoleteTag = '26.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
        }
        field(202; "Posted Invoice Sync"; Boolean)
        {
            Caption = 'Posted Invoice Sync';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
        key(Idx1; "Shop Id") { }
        key(Idx2; "Shopify URL") { }
        key(Idx3; Enabled) { }
    }

    trigger OnDelete()
    var
        ShpfyWebhooksMgt: Codeunit "Shpfy Webhooks Mgt.";
    begin
        ShpfyWebhooksMgt.DisableOrderCreatedWebhook(Rec);
        ShpfyWebhooksMgt.DisableBulkOperationsWebhook(Rec);
    end;

    var
        InvalidShopUrlErr: Label 'The URL must refer to the internal shop location at myshopify.com. It must not be the public URL that customers use, such as myshop.com.';
        CurrencyExchangeRateNotDefinedErr: Label 'The specified currency must have exchange rates configured. If your online shop uses the same currency as Business Central then leave the field empty.';
        AutoCreateErrorMsg: Label 'You cannot turn "%1" off if "%2" is set to the value of "%3".', Comment = '%1 = Field Caption of "Auto Create Orders", %2 = Field Caption of "Return and Refund Process", %3 = Field Value of "Return and Refund Process"';

    [Scope('OnPrem')]
    internal procedure GetAccessToken() Result: SecretText
    var
        AuthenticationMgt: Codeunit "Shpfy Authentication Mgt.";
        Store: Text;
    begin
        Rec.Testfield(Enabled, true);
        Store := GetStoreName();
        if Store <> '' then
            exit(AuthenticationMgt.GetAccessToken(Store));
    end;

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

    internal procedure TestConnection(): Boolean
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
    begin
        CommunicationMgt.SetShop(Rec);
        CommunicationMgt.ExecuteGraphQL('{"query":"query { app { id } }"}');
        exit(true);
    end;

    internal procedure GetStoreName() Store: Text
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

    internal procedure GetEmptySyncTime(): DateTime
    begin
        exit(CreateDateTime(20040101D, 0T));
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
                if SynchronizationInfo."Last Sync Time" = 0DT then
                    exit(GetEmptySyncTime())
                else
                    exit(SynchronizationInfo."Last Sync Time");
        end;
        if SynchronizationInfo.Get(Rec.Code, Type) then
            if SynchronizationInfo."Last Sync Time" = 0DT then
                exit(GetEmptySyncTime())
            else
                exit(SynchronizationInfo."Last Sync Time");
        exit(GetEmptySyncTime());
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

    local procedure EnableShopifyLogRetentionPolicySetup()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not TaskScheduler.CanCreateTask() then
            exit;

        if not (JobQueueEntry.ReadPermission() and JobQueueEntry.WritePermission()) then
            exit;

        if not RetentionPolicySetup.Get(Database::"Shpfy Log Entry") then
            exit;

        if RetentionPolicySetup.Enabled then
            exit;

        RetentionPolicySetup.Validate(Enabled, true);
        RetentionPolicySetup.Modify(true);
    end;

    internal procedure GetB2BEnabled(): Boolean;
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        JResponse: JsonToken;
        JItem: JsonToken;
    begin
        CommunicationMgt.SetShop(Rec);
        JResponse := CommunicationMgt.ExecuteGraphQL('{"query":"query { shop { name plan { partnerDevelopment shopifyPlus } } }"}');
        if JResponse.SelectToken('$.data.shop.plan', JItem) then
            if JItem.IsObject then begin
                if JsonHelper.GetValueAsBoolean(JItem, 'shopifyPlus') then
                    exit(true);
                if JsonHelper.GetValueAsBoolean(JItem, 'partnerDevelopment') then
                    exit(true);
            end;
    end;

    internal procedure GetShopWeightUnit(): Enum "Shpfy Weight Unit"
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        JResponse: JsonToken;
    begin
        CommunicationMgt.SetShop(Rec);
        JResponse := CommunicationMgt.ExecuteGraphQL('{"query":"query { shop { weightUnit } }"}');
        exit(ConvertToWeightUnit(JsonHelper.GetValueAsText(JResponse, 'data.shop.weightUnit')));
    end;

#if not CLEAN24
    local procedure UpdateOrderAttributes(ShopCode: Code[20])
    var
        OrderHeader: Record "Shpfy Order Header";
        OrderAttribute: Record "Shpfy Order Attribute";
    begin
        OrderHeader.SetRange("Shop Code", ShopCode);
        if OrderHeader.FindSet() then
            repeat
                OrderAttribute.SetRange("Order Id", OrderHeader."Shopify Order Id");
                if OrderAttribute.FindSet() then
                    repeat
                        OrderAttribute."Attribute Value" := OrderAttribute.Value;
                        OrderAttribute.Modify();
                    until OrderAttribute.Next() = 0;
            until OrderHeader.Next() = 0;
    end;
#endif

    internal procedure SyncCountries()
    begin
        Codeunit.Run(Codeunit::"Shpfy Sync Countries", Rec);
    end;

    local procedure ConvertToWeightUnit(Value: Text): Enum "Shpfy Weight Unit"
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Weight Unit".Names().Contains(Value) then
            exit(Enum::"Shpfy Weight Unit".FromInteger(Enum::"Shpfy Weight Unit".Ordinals().Get(Enum::"Shpfy Weight Unit".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Weight Unit"::" ");
    end;
}