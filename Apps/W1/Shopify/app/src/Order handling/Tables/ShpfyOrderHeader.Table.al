namespace Microsoft.Integration.Shopify;

using System.IO;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Bank.BankAccount;
using Microsoft.Foundation.Shipping;
using System.Reflection;

/// <summary>
/// Table Shpfy Order Header (ID 30118).
/// </summary>
table 30118 "Shpfy Order Header"
{
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
        field(2; Email; Text[80])
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
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Not available in GraphQL data.';
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
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Replaced with the fields "Currency Code" and "Presentment Currency Code".';
        }
        field(17; "Cart Token"; Text[50])
        {
            Caption = 'Cart Token';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Not available in GraphQL data.';
        }
        field(18; "Checkout Token"; Text[50])
        {
            Caption = 'Checkout Token';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Not available in GraphQL data.';
        }
        field(19; Reference; Text[50])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Not available in GraphQL data.';
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
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Not available in GraphQL data.';
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
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Not available in GraphQL data.';
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
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Not available in GraphQL data.';
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
            ObsoleteReason = 'Location Id on Order Header is not used. Instead use Location Id on Order Lines.';
#if not CLEAN25
            ObsoleteState = Pending;
            ObsoleteTag = '25.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '28.0';
#endif
        }
        field(102; "Channel Name"; Text[100])
        {
            Caption = 'Channel Name';
            Editable = false;
        }
        field(103; "App Name"; Text[100])
        {
            Caption = 'App Name';
            Editable = false;
        }
        field(104; "Presentment Currency Code"; Code[10])
        {
            Caption = 'Presentment Currency Code';
            Editable = false;
        }
        field(105; Unpaid; Boolean)
        {
            Caption = 'Unpaid';
            Editable = false;
        }
        field(106; "Discount Code"; Code[20])
        {
            Caption = 'Discount Code';
            Editable = false;
        }
        field(107; "Discount Codes"; Text[250])
        {
            Caption = 'Discount Codes';
            Editable = false;
        }
        field(108; Refundable; Boolean)
        {
            Caption = 'Refundable';
            Editable = false;
        }
        field(109; "Presentment Total Amount"; Decimal)
        {
            Caption = 'Presentment Total Amount';
            DataClassification = SystemMetadata;
        }
        field(110; "Presentment Subtotal Amount"; Decimal)
        {
            Caption = 'Presentment Subtotal Amount';
            DataClassification = SystemMetadata;
        }
        field(111; "Presentment VAT Amount"; Decimal)
        {
            Caption = 'Presentment VAT Amount';
            DataClassification = SystemMetadata;
        }
        field(112; "Presentment Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = SystemMetadata;
        }
        field(113; "Presentment Total Tip Received"; Decimal)
        {
            Caption = 'Presentment Total Tip Received';
            DataClassification = SystemMetadata;
        }
        field(114; "Pres. Shipping Charges Amount"; Decimal)
        {
            Caption = 'Presentment Shipping Charges Amount';
            DataClassification = SystemMetadata;
        }
        field(115; Edited; Boolean)
        {
            Caption = 'Edited';
            DataClassification = SystemMetadata;
        }
        field(116; "Return Status"; Enum "Shpfy Order Return Status")
        {
            Caption = 'Return Status';
            DataClassification = SystemMetadata;
        }
        field(117; "Company Id"; BigInteger)
        {
            Caption = 'Company Id';
            DataClassification = SystemMetadata;
        }
        field(118; "Company Main Contact Id"; BigInteger)
        {
            Caption = 'Company Main Contact Id';
            DataClassification = SystemMetadata;
        }
        field(119; "Company Main Contact Email"; Text[100])
        {
            Caption = 'Company Main Contact Email';
            DataClassification = SystemMetadata;
        }
        field(120; "Company Main Contact Phone No."; Text[50])
        {
            Caption = 'Company Main Contact Phone No.';
            DataClassification = SystemMetadata;
            ExtendedDatatype = PhoneNo;
        }
        field(121; "Company Main Contact Cust. Id"; BigInteger)
        {
            Caption = 'Company Main Contact Customer Id';
            DataClassification = SystemMetadata;
        }
        field(122; B2B; Boolean)
        {
            Caption = 'B2B';
            DataClassification = SystemMetadata;
        }
        field(123; "Current Total Amount"; Decimal)
        {
            Caption = 'Current Total Amount';
            DataClassification = SystemMetadata;
        }
        field(124; "Current Total Items Quantity"; Integer)
        {
            Caption = 'Current Total Items Quantity';
            DataClassification = SystemMetadata;
        }
        field(125; "Line Items Redundancy Code"; Integer)
        {
            Caption = 'Line Items Redundancy Code';
            DataClassification = SystemMetadata;
        }
        field(126; "PO Number"; Text[512])
        {
            Caption = 'PO Number';
            DataClassification = SystemMetadata;
        }
        field(127; "Company Location Id"; BigInteger)
        {
            Caption = 'Company Location Id';
            DataClassification = SystemMetadata;
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
            ObsoleteReason = 'Replaced by Customer Templ. Code';
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
        }
        field(502; "Customer Templ. Code"; Code[20])
        {
            Caption = 'Customer Template Code';
            DataClassification = SystemMetadata;
            TableRelation = "Customer Templ.".Code;
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
            TableRelation = "Sales Header"."No." where("Document Type" = const(Order));
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
                Customer: Record Customer;
            begin
                Validate("Sell-to Customer No.", Customer.GetCustNo("Sell-to Customer Name"));
            end;
        }

        field(1006; "Sales Invoice No."; Code[20])
        {
            Caption = 'Sales Invoice No.';
            DataClassification = SystemMetadata;
            TableRelation = "Sales Header"."No." where("Document Type" = const(Invoice));
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
        field(1014; "Sell-to Contact Name"; Text[100])
        {
            Caption = 'Sell-to Contact Name';
            DataClassification = CustomerContent;
        }
        field(1015; "Bill-to Contact Name"; Text[100])
        {
            Caption = 'Bill-to Contact Name';
            DataClassification = CustomerContent;
        }
        field(1016; "Ship-to Contact Name"; Text[100])
        {
            Caption = 'Ship-to Contact Name';
            DataClassification = CustomerContent;
        }
        field(1017; "Sell-to Contact No."; Code[20])
        {
            Caption = 'Sell-to Contact No.';
            DataClassification = CustomerContent;
        }
        field(1018; "Bill-to Contact No."; Code[20])
        {
            Caption = 'Bill-to Contact No.';
            DataClassification = CustomerContent;
        }
        field(1019; "Ship-to Contact No."; Code[20])
        {
            Caption = 'Ship-to Contact No.';
            DataClassification = CustomerContent;
        }
        field(1020; "Has Order State Error"; Boolean)
        {
            Caption = 'Has Order State Error';
            DataClassification = SystemMetadata;
        }
        field(1021; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";

            trigger OnValidate()
            begin
                if "Shipping Agent Code" <> xRec."Shipping Agent Code" then
                    Clear("Shipping Agent Service Code");
            end;
        }
        field(1022; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
        }
        field(1030; "Payment Terms Type"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Payment Terms Type';
        }
        field(1040; "Payment Terms Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Payment Terms Name';
        }
    }
    keys
    {
        key(Key1; "Shopify Order Id")
        {
            Clustered = true;
        }
        key(Key2; "Shop Code", Processed)
        {

        }
    }
    var
        ShopifyOrderLine: Record "Shpfy Order Line";

    trigger OnDelete()
    var
        ShopifyReturnHeader: Record "Shpfy Return Header";
        ShopifyRefundHeader: Record "Shpfy Refund Header";
        DataCapture: Record "Shpfy Data Capture";
        FulfillmentOrderHeader: Record "Shpfy FulFillment Order Header";
        OrderFulfillment: Record "Shpfy Order Fulfillment";
    begin
        ShopifyOrderLine.SetRange("Shopify Order Id", "Shopify Order Id");
        if not ShopifyOrderLine.IsEmpty then
            ShopifyOrderLine.DeleteAll(true);
        ShopifyReturnHeader.SetRange("Order Id", "Shopify Order Id");
        if not ShopifyReturnHeader.IsEmpty then
            ShopifyReturnHeader.DeleteAll(true);
        ShopifyRefundHeader.SetRange("Order Id", "Shopify Order Id");
        if not ShopifyRefundHeader.IsEmpty then
            ShopifyRefundHeader.DeleteAll(true);
        DataCapture.SetCurrentKey("Linked To Table", "Linked To Id");
        DataCapture.SetRange("Linked To Table", Database::"Shpfy Order Header");
        DataCapture.SetRange("Linked To Id", Rec.SystemId);
        if not DataCapture.IsEmpty then
            DataCapture.DeleteAll(false);

        FulfillmentOrderHeader.SetRange("Shopify Order Id", Rec."Shopify Order Id");
        if not FulfillmentOrderHeader.IsEmpty then
            FulfillmentOrderHeader.DeleteAll(true);

        OrderFulfillment.SetRange("Shopify Order Id", Rec."Shopify Order Id");
        if not OrderFulfillment.IsEmpty then
            OrderFulfillment.DeleteAll(true);
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

    internal procedure IsProcessed(): Boolean
    var
        DocLinkToBCDoc: Record "Shpfy Doc. Link To Doc.";
    begin
        DocLinkToBCDoc.SetRange("Shopify Document Type", "Shpfy Shop Document Type"::"Shopify Shop Order");
        DocLinkToBCDoc.SetRange("Shopify Document Id", Rec."Shopify Order Id");
        DocLinkToBCDoc.SetCurrentKey("Shopify Document Type", "Shopify Document Id");
        exit(Rec.Processed or not DocLinkToBCDoc.IsEmpty);
    end;

}
