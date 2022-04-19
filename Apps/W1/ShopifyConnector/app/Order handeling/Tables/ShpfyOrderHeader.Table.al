/// <summary>
/// Table Shpfy Order Header (ID 30118).
/// </summary>
table 30118 "Shpfy Order Header"
{
    Access = Internal;
    Caption = 'Shopify Order Header';
    DataCaptionFields = "Shopify Order No.", "Sell-to Customer Name";
    DataClassification = SystemMetadata;
    DrillDownPageID = "Shpfy Orders";
    LookupPageID = "Shpfy Orders";

    fields
    {
        field(1; "Shopify Order Id"; BigInteger)
        {
            DataClassification = SystemMetadata;
        }
        field(2; Email; Text[50])
        {
            Caption = 'Email';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(5; "Sell-to Address"; Text[100])
        {
            Caption = 'Sell-to Address';
            DataClassification = CustomerContent;
        }
        field(6; "Sell-to Address 2"; Text[100])
        {
            Caption = 'Sell-to Address 2';
            DataClassification = CustomerContent;
        }
        field(7; "Sell-to City"; Text[50])
        {
            Caption = 'Sell-to City';
            DataClassification = CustomerContent;
        }
        field(8; "Sell-to Post Code"; Text[50])
        {
            Caption = 'Sell-to Post Code';
            DataClassification = CustomerContent;
        }
        field(9; "Sell-to Country/Region Code"; Code[20])
        {
            Caption = 'Sell-to Country/Region Code';
            DataClassification = CustomerContent;
        }
        field(10; "Sell-to Country/Region Name"; Text[50])
        {
            Caption = 'Sell-to Country/Region Name';
            DataClassification = CustomerContent;
        }
        field(11; "Phone No."; Text[50])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }
        field(12; Token; Text[50])
        {
            Caption = 'Token';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; Gateway; Text[50])
        {
            Caption = 'Gateway';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Sell-to First Name"; Text[50])
        {
            Caption = 'Sell-to First Name';
            DataClassification = CustomerContent;
        }
        field(15; "Sell-to Last Name"; Text[50])
        {
            Caption = 'Sell-to Last Name';
            DataClassification = CustomerContent;
        }
        field(16; Currency; Code[10])
        {
            Caption = 'Currency';
            DataClassification = Customercontent;
            Editable = false;
        }
        field(17; "Cart Token"; Text[50])
        {
            Caption = 'Cart Token';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18; "Checkout Token"; Text[50])
        {
            Caption = 'Checkout Token';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(19; Reference; Text[50])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "Risk Level"; Enum "Shpfy Risk Level")
        {
            Caption = 'Risk Level';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(22; "Fully Paid"; Boolean)
        {
            Caption = 'Fully Paid';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(23; "Processing Method"; Enum "Shpfy Processing Method")
        {
            Caption = 'Processing Method';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(24; "Checkout Id"; BigInteger)
        {
            Caption = 'Checkout Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(25; "Contact Email"; Text[100])
        {
            Caption = 'Contact Email';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(26; "Total Tip Received"; Decimal)
        {
            Caption = 'Total Tip Received';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(27; "Session Hash"; Text[50])
        {
            Caption = 'Session Hash';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(48; "Ship-to First Name"; Text[50])
        {
            Caption = 'Ship-to First Name';
            DataClassification = CustomerContent;
        }
        field(49; "Ship-to Last Name"; Text[50])
        {
            Caption = 'Ship-to Last Name';
            DataClassification = CustomerContent;
        }
        field(50; "Ship-to Name"; Text[50])
        {
            Caption = 'Ship-to Name';
            DataClassification = CustomerContent;
        }
        field(51; "Ship-to Address"; Text[100])
        {
            Caption = 'Ship-to Address';
            DataClassification = CustomerContent;
        }
        field(52; "Ship-to Address 2"; Text[100])
        {
            Caption = 'Ship-to Address 2';
            DataClassification = CustomerContent;
        }
        field(53; "Ship-to City"; Text[50])
        {
            Caption = 'Ship-to City';
            DataClassification = CustomerContent;
        }
        field(54; "Ship-to Post Code"; Text[50])
        {
            Caption = 'Ship-to Post Code';
            DataClassification = CustomerContent;
        }
        field(55; "Ship-to Country/Region Code"; Code[20])
        {
            Caption = 'Ship-to Country/Region Code';
            DataClassification = CustomerContent;
        }
        field(56; "Ship-to Country/Region Name"; Text[50])
        {
            Caption = 'Ship-to Country/Region Name';
            DataClassification = CustomerContent;
        }
        field(57; "Ship-to Latitude"; Decimal)
        {
            Caption = 'Ship-to Latitude';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(58; "Ship-to Longitude"; Decimal)
        {
            Caption = 'Ship-to Longitude';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60; "Bill-to Name"; Text[50])
        {
            Caption = 'Bill-to Name';
            DataClassification = CustomerContent;
        }
        field(61; "Bill-to Address"; Text[100])
        {
            Caption = 'Bill-to Address';
            DataClassification = CustomerContent;
        }
        field(62; "Bill-to Address 2"; Text[100])
        {
            Caption = 'Bill-to Address 2';
            DataClassification = CustomerContent;
        }
        field(63; "Bill-to City"; Text[50])
        {
            Caption = 'Bill-to City';
            DataClassification = CustomerContent;
        }
        field(64; "Bill-to Post Code"; Text[50])
        {
            Caption = 'Bill-to Post Code';
            DataClassification = CustomerContent;
        }
        field(65; "Bill-to Country/Region Code"; Code[20])
        {
            Caption = 'Bill-to Country/Region Code';
            DataClassification = CustomerContent;
        }
        field(66; "Bill-to Country/Region Name"; Text[50])
        {
            Caption = 'Bill-to Country/Region Name';
            DataClassification = CustomerContent;
        }
        field(67; Test; Boolean)
        {
            Caption = 'Test';
            DataClassification = SystemMetadata;
        }
        field(68; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DataClassification = SystemMetadata;
        }
        field(69; "Subtotal Amount"; Decimal)
        {
            Caption = 'Subtotal Amount';
            DataClassification = SystemMetadata;
        }
        field(70; "Total Weight"; Decimal)
        {
            Caption = 'Total Weight';
            DataClassification = SystemMetadata;
        }
        field(71; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DataClassification = SystemMetadata;
        }
        field(72; "VAT Included"; Boolean)
        {
            Caption = 'VAT Included';
            DataClassification = SystemMetadata;
        }
        field(73; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = SystemMetadata;
        }
        field(74; "Financial Status"; Enum "Shpfy Financial Status")
        {
            Caption = 'Financial Status';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(75; Confirmed; Boolean)
        {
            Caption = 'Confirmed';
            DataClassification = SystemMetadata;
        }
        field(76; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = SystemMetadata;
        }
        field(77; "Total Items Amount"; Decimal)
        {
            Caption = 'Total Items Amount';
            DataClassification = SystemMetadata;
        }
        field(78; "Fulfillment Status"; Enum "Shpfy Order Fulfill. Status")
        {
            Caption = 'Fulfillment Status';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(79; "Buyer Accepts Marketing"; Boolean)
        {
            Caption = 'Buyer Accepts Marketing';
            DataClassification = SystemMetadata;
        }
        field(80; "Cancelled At"; DateTime)
        {
            Caption = 'Cancelled At';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(81; "Cancel Reason"; Enum "Shpfy Cancel Reason")
        {
            Caption = 'Cancel Reason';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(82; "Closed At"; DateTime)
        {
            Caption = 'Closed At';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(83; "Bill-to First Name"; Text[50])
        {
            Caption = 'Bill-to First Name';
            DataClassification = CustomerContent;
        }
        field(84; "Bill-to Lastname"; Text[50])
        {
            Caption = 'Bill-to Last Name';
            DataClassification = CustomerContent;
        }
        field(87; "Processed At"; DateTime)
        {
            Caption = 'Processed At';
            DataClassification = SystemMetadata;
        }
        field(89; "Shopify Order No."; Text[50])
        {
            Caption = 'Shopify Order No.';
            DataClassification = SystemMetadata;
        }
        field(90; "Order Status URL"; Text[250])
        {
            Caption = 'Order Status URL';
            DataClassification = SystemMetadata;
            ExtendedDatatype = URL;
        }
        field(91; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = SystemMetadata;
        }
        field(92; "Source Name"; Code[20])
        {
            Caption = 'Source Name';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(93; "Updated At"; DateTime)
        {
            Caption = 'Updated At';
            DataClassification = SystemMetadata;
        }
        field(94; "Shipping Charges Amount"; Decimal)
        {
            Caption = 'Shipping Charges Amount';
            DataClassification = SystemMetadata;
        }
        field(95; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = SystemMetadata;

            trigger OnValidate();
            begin
                TestField("Sales Order No.", '');
            end;
        }
        field(96; "Sell-to County"; Text[30])
        {
            Caption = 'Sell-to County';
            DataClassification = CustomerContent;
        }
        field(97; "Bill-to County"; Text[30])
        {
            Caption = 'Bill-to County';
            DataClassification = CustomerContent;
        }
        field(98; "Ship-to County"; Text[30])
        {
            Caption = 'Ship-to County';
            DataClassification = CustomerContent;
        }
        field(99; "Customer Id"; BigInteger)
        {
            Caption = 'Customer Id';
            DataClassification = CustomerContent;
        }
        field(100; Closed; Boolean)
        {
            Caption = 'Closed';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(101; "Location Id"; BigInteger)
        {
            Caption = 'Location Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(500; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Shop";
        }
        field(501; "Customer Template Code"; Code[10])
        {
            Caption = 'Customer Template Code';
            DataClassification = SystemMetadata;
            TableRelation = "Config. Template Header".Code where("Table Id" = const(18));
        }
        field(601; "Total Quantity of Items"; Decimal)
        {
            Caption = 'Total Quantity of Items';
            FieldClass = FlowField;
            CalcFormula = sum("Shpfy Order Line".Quantity where("Shopify Order Id" = field("Shopify Order Id"), "Gift Card" = const(false), Tip = const(false)));
        }
        field(602; "Number of Lines"; Integer)
        {
            Caption = 'Number of Lines';
            FieldClass = FlowField;
            CalcFormula = Count("Shpfy Order Line" where("Shopify Order Id" = field("Shopify Order Id")));
        }
        field(1000; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            DataClassification = SystemMetadata;
            TableRelation = Customer;
        }
        field(1001; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
            DataClassification = SystemMetadata;
        }
        field(1002; "Has Error"; Boolean)
        {
            Caption = 'Has Error';
            DataClassification = SystemMetadata;
        }
        field(1003; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
            DataClassification = SystemMetadata;
        }
        field(1004; Processed; Boolean)
        {
            Caption = 'Processed';
            DataClassification = SystemMetadata;
        }
        field(1005; "Sell-to Customer Name"; Text[50])
        {
            Caption = 'Sell-to Customer Name';
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                Customer: Record 18;
            begin
                Validate("Sell-to Customer No.", Customer.GetCustNo("Sell-to Customer Name"));
            end;
        }

        field(1006; "Sales Invoice No."; Code[20])
        {
            Caption = 'Sales Invoice No.';
            DataClassification = SystemMetadata;
        }
        field(1007; "Work Description"; Blob)
        {
            Caption = 'Work Description';
            DataClassification = SystemMetadata;

        }
        field(1008; "Sell-to Customer Name 2"; Text[50])
        {
            Caption = 'Sell-to Customer Name 2';
            DataClassification = CustomerContent;
        }
        field(1009; "Ship-to Name 2"; Text[50])
        {
            Caption = 'Ship-to Name 2';
            DataClassification = CustomerContent;
        }
        field(1010; "Bill-to Name 2"; Text[50])
        {
            Caption = 'Bill-to Name 2';
            DataClassification = CustomerContent;
        }
        field(1011; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(1012; "Shipping Method Code"; Code[10])
        {
            Caption = 'Shipping Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipment Method";
        }
        field(1013; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
        }
    }
    keys
    {
        key(Key1; "Shopify Order Id")
        {
            Clustered = true;
        }
    }
    var
        ShopifyOrderLine: Record "Shpfy Order Line";

    trigger OnDelete()
    var
        DataCapture: Record "Shpfy Data Capture";
    begin
        ShopifyOrderLine.SetRange("Shopify Order Id", "Shopify Order Id");
        ShopifyOrderLine.DeleteAll(true);
        DataCapture.SetCurrentKey("Linked To Table", "Linked To Id");
        DataCapture.SetRange("Linked To Table", Database::"Shpfy Order Header");
        DataCapture.SetRange("Linked To Id", Rec.SystemId);
        if not DataCapture.IsEmpty then
            DataCapture.DeleteAll(false);
    end;

    /// <summary> 
    /// Get Work Description.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetWorkDescription(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Work Description");
        "Work Description".CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    /// <summary> 
    /// Set Work Description.
    /// </summary>
    /// <param name="NewWorkDescription">Parameter of type Text.</param>
    internal procedure SetWorkDescription(NewWorkDescription: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Work Description");
        "Work Description".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewWorkDescription);
        Modify();
    end;

    /// <summary> 
    /// Update Tags.
    /// </summary>
    /// <param name="CommaSeperatedTags">Parameter of type Text.</param>
    internal procedure UpdateTags(CommaSeperatedTags: Text)
    var
        ShopifyTag: Record "Shpfy Tag";
    begin
        ShopifyTag.UpdateTags(Database::"Shpfy Order Header", "Shopify Order Id", CommaSeperatedTags);
    end;

}

