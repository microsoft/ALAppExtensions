tableextension 11799 "Item Ledger Entry CZL" extends "Item Ledger Entry"
{
    fields
    {
        field(31050; "Tariff No. CZL"; Code[20])
        {
            Caption = 'Tariff No.';
            TableRelation = "Tariff Number";
            DataClassification = CustomerContent;
        }
        field(31051; "Physical Transfer CZL"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;
        }
        field(31054; "Net Weight CZL"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(31057; "Country/Reg. of Orig. Code CZL"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(31058; "Statistic Indication CZL"; Code[10])
        {
            Caption = 'Statistic Indication';
            TableRelation = "Statistic Indication CZL".Code where("Tariff No." = field("Tariff No. CZL"));
            DataClassification = CustomerContent;
        }
        field(31059; "Intrastat Transaction CZL"; Boolean)
        {
            Caption = 'Intrastat Transaction';
            DataClassification = CustomerContent;
        }
    }

    procedure SetFilterFromInvtReceiptHeaderCZL(InvtReceiptHeader: Record "Invt. Receipt Header")
    begin
        SetCurrentKey("Document No.");
        SetRange("Document No.", InvtReceiptHeader."No.");
        SetRange("Posting Date", InvtReceiptHeader."Posting Date");
    end;

    procedure SetFilterFromInvtShipmentHeaderCZL(InvtShipmentHeader: Record "Invt. Shipment Header")
    begin
        SetCurrentKey("Document No.");
        SetRange("Document No.", InvtShipmentHeader."No.");
        SetRange("Posting Date", InvtShipmentHeader."Posting Date");
    end;

    procedure GetRegisterUserIDCZL(): Code[50]
    var
        ItemRegister: Record "Item Register";
    begin
        if ItemRegister.FindByEntryNoCZL("Entry No.") then
            exit(ItemRegister."User ID");
    end;
}