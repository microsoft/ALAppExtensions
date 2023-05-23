tableextension 18144 "GST Sales Cr.Memo Header Ext" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(18141; Trading; Boolean)
        {
            Caption = 'Trading';
            DataClassification = CustomerContent;
        }
        field(18142; "Nature of Supply"; Enum "GST Nature Of Supply")
        {
            Caption = 'Nature of Supply';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18143; "GST Customer Type"; Enum "GST Customer Type")
        {
            Caption = 'GST Customer Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18144; "GST Without Payment of Duty"; Boolean)
        {
            Caption = 'GST Without Payment of Duty';
            DataClassification = CustomerContent;
        }
        field(18145; "Invoice Type"; Enum "Sales Invoice Type")
        {
            Caption = 'Invoice Type';
            DataClassification = CustomerContent;
        }
        field(18146; "Bill Of Export No."; code[20])
        {
            Caption = 'Bill Of Export No.';
            DataClassification = CustomerContent;
        }
        field(18147; "Bill Of Export Date"; date)
        {
            Caption = 'Bill Of Export Date';
            DataClassification = CustomerContent;
        }
        field(18148; "E-Commerce Customer"; Code[20])
        {
            caption = 'E-Commerce Customer';
            TableRelation = Customer where("e-Commerce Operator" = const(true));
            DataClassification = CustomerContent;
        }
        field(18149; "E-Commerce Merchant Id"; code[30])
        {
            caption = 'E-Commerce Merchant Id';
            TableRelation = "e-Commerce Merchant"."Merchant Id" where(
                    "Merchant Id" = field("e-Commerce Merchant Id"),
                    "Customer No." = field("e-Commerce Customer"));
            DataClassification = CustomerContent;
            ObsoleteReason = 'New field introduced as E-Comm. Merchant Id';
#if CLEAN23
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
#else
            ObsoleteState = Pending;
            ObsoleteTag = '23.0';
#endif
        }
        field(18150; "GST Bill-to State Code"; Code[10])
        {
            Caption = 'GST Bill-to State Code';
            DataClassification = CustomerContent;
            TableRelation = State;
            Editable = false;
        }
        field(18151; "GST Ship-to State Code"; Code[10])
        {
            Caption = 'GST Ship-to State Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = State;
        }
        field(18152; "Location State Code"; code[10])
        {
            Caption = 'Location State Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = state;
        }
        field(18153; "GST Reason Type"; enum "GST Reason Type")
        {
            Caption = 'GST Reason Type';
            DataClassification = CustomerContent;
        }
        field(18154; "Location GST Reg. No."; Code[20])
        {
            Caption = 'Location GST Reg. No.';
            DataClassification = CustomerContent;
            TableRelation = "GST Registration Nos.";
        }
        field(18155; "Customer GST Reg. No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer GST Reg. No.';
            Editable = false;
        }
        field(18156; "Ship-to GST Reg. No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to GST Reg. No.';
            Editable = false;
        }
        field(18157; "Distance (Km)"; Decimal)
        {
            Caption = 'Distance (Km)';
            DataClassification = CustomerContent;
        }
        field(18158; "Vehicle Type"; Enum "GST Vehicle Type")
        {
            Caption = 'Vehicle Type';
            DataClassification = CustomerContent;
        }
        field(18159; "Reference Invoice No."; Code[20])
        {
            Caption = 'Reference Invoice No.';
            DataClassification = CustomerContent;
        }
        field(18160; "E-Way Bill No."; Text[50])
        {
            Caption = 'E-Way Bill No.';
            DataClassification = CustomerContent;
        }
        field(18161; "Supply Finish Date"; Enum "GST Rate Change")
        {
            Caption = 'Supply Finish Date';
            DataClassification = CustomerContent;
        }
        field(18162; "Payment Date"; Enum "GST Rate Change")
        {
            Caption = 'Payment Date';
            DataClassification = CustomerContent;
        }
        field(18163; "Rate Change Applicable"; Boolean)
        {
            Caption = 'Rate Change Applicable';
            DataClassification = CustomerContent;
        }
        field(18164; "POS Out Of India"; Boolean)
        {
            Caption = 'POS Out Of India';
            DataClassification = CustomerContent;
        }
        field(18165; "GST Invoice"; Boolean)
        {
            Caption = 'GST Invoice';
            DataClassification = CustomerContent;
        }
        field(18166; State; Code[10])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
            TableRelation = State;
        }
        field(18167; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            DataClassification = CustomerContent;
        }
        field(18168; "Sale Return Type"; Enum "Sale Return Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Sale Return Type';
        }
        field(18169; "Ship-to Customer"; Code[20])
        {
            Editable = false;
            Caption = 'Ship-to Customer';
            TableRelation = if ("GST Customer Type" = const(Export)) Customer."No." where("GST Customer Type" = const(Registered));
            DataClassification = CustomerContent;
        }
        field(18170; "Ship-to GST Customer Type"; Enum "GST Customer Type")
        {
            Editable = false;
            Caption = 'Ship-to GST Customer Type';
            DataClassification = CustomerContent;
        }
        field(18171; "Acknowledgement No."; Text[30])
        {
            Caption = 'Acknowledgement No.';
            DataClassification = CustomerContent;
        }
        field(18172; "IRN Hash"; Text[64])
        {
            Caption = 'IRN Hash';
            DataClassification = CustomerContent;
        }
        field(18173; "QR Code"; Blob)
        {
            Subtype = Bitmap;
            Caption = 'QR Code';
            DataClassification = CustomerContent;
        }
        field(18174; "Acknowledgement Date"; DateTime)
        {
            Caption = 'Acknowledgement Date';
            DataClassification = CustomerContent;
        }
        field(18175; "IsJSONImported"; Boolean)
        {
            Caption = 'IsJSONImported';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(18176; "E-Inv. Cancelled Date"; DateTime)
        {
            Caption = 'E-Inv. Cancelled Date';
            DataClassification = CustomerContent;
        }
        field(18177; "Cancel Reason"; Enum "e-Invoice Cancel Reason")
        {
            Caption = 'Cancel Reason';
            DataClassification = CustomerContent;
        }
        field(18180; "Post GST to Customer"; Boolean)
        {
            Caption = 'Post GST to Customer';
            DataClassification = CustomerContent;
        }
        field(18181; "E-Comm. Merchant Id"; code[30])
        {
            Caption = 'E-Comm. Merchant Id';
            TableRelation = "e-Comm. Merchant"."Merchant Id" where(
                    "Merchant Id" = field("e-Comm. Merchant Id"),
                    "Customer No." = field("e-Commerce Customer"));
            DataClassification = CustomerContent;
        }
    }
}