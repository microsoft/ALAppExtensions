tableextension 11510 "Swiss QR-Bill Incoming Doc" extends "Incoming Document"
{
    fields
    {
        field(11500; "Swiss QR-Bill"; Boolean)
        {
            Caption = 'QR-Bill';
            DataClassification = CustomerContent;
        }
        field(11501; "Swiss QR-Bill Vendor Address 1"; Text[100])
        {
            Caption = 'Address Line 1';
            DataClassification = CustomerContent;
        }
        field(11502; "Swiss QR-Bill Vendor Address 2"; Text[100])
        {
            Caption = 'Address Line 2';
            DataClassification = CustomerContent;
        }
        field(11503; "Swiss QR-Bill Vendor Post Code"; Code[20])
        {
            Caption = 'Postal Code';
            DataClassification = CustomerContent;
        }
        field(11504; "Swiss QR-Bill Vendor City"; Text[100])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(11505; "Swiss QR-Bill Vendor Country"; Code[10])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }
        field(11506; "Swiss QR-Bill Debitor Name"; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(11507; "Swiss QR-Bill Debitor Address1"; Text[100])
        {
            Caption = 'Address Line 1';
            DataClassification = CustomerContent;
        }
        field(11508; "Swiss QR-Bill Debitor Address2"; Text[100])
        {
            Caption = 'Address Line 2';
            DataClassification = CustomerContent;
        }
        field(11509; "Swiss QR-Bill Debitor PostCode"; Code[20])
        {
            Caption = 'Postal Code';
            DataClassification = CustomerContent;
        }
        field(11510; "Swiss QR-Bill Debitor City"; Text[100])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(11511; "Swiss QR-Bill Debitor Country"; Code[10])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }
        field(11512; "Swiss QR-Bill Reference Type"; Enum "Swiss QR-Bill Payment Reference Type")
        {
            Caption = 'Payment Reference Type';
            DataClassification = CustomerContent;
        }
        field(11513; "Swiss QR-Bill Reference No."; Code[50])
        {
            Caption = 'Payment Reference';
            DataClassification = CustomerContent;
        }
        field(11514; "Swiss QR-Bill Unstr. Message"; Text[140])
        {
            Caption = 'Unstructured Message';
            DataClassification = CustomerContent;
        }
        field(11515; "Swiss QR-Bill Bill Info"; Text[140])
        {
            Caption = 'Billing Information';
            DataClassification = CustomerContent;
        }
    }
}
