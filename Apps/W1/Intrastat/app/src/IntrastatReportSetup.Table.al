// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.CRM.Contact;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Vendor;
using System.IO;

table 4810 "Intrastat Report Setup"
{
    Caption = 'Intrastat Report Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; "Report Receipts"; Boolean)
        {
            Caption = 'Report Receipts';
        }
        field(3; "Report Shipments"; Boolean)
        {
            Caption = 'Report Shipments';
        }
        field(4; "Default Trans. - Purchase"; Code[10])
        {
            Caption = 'Default Trans. Type';
            TableRelation = "Transaction Type";
        }
        field(5; "Default Trans. - Return"; Code[10])
        {
            Caption = 'Default Trans. Type - Returns';
            TableRelation = "Transaction Type";
        }
        field(6; "Intrastat Contact Type"; Enum "Intrastat Report Contact Type")
        {
            Caption = 'Intrastat Contact Type';

            trigger OnValidate()
            begin
                if "Intrastat Contact Type" <> xRec."Intrastat Contact Type" then
                    Validate("Intrastat Contact No.", '');
            end;
        }
        field(7; "Intrastat Contact No."; Code[20])
        {
            Caption = 'Intrastat Contact No.';
            TableRelation = if ("Intrastat Contact Type" = const(Contact)) Contact."No." else
            if ("Intrastat Contact Type" = const(Vendor)) Vendor."No.";
        }
        field(9; "Cust. VAT No. on File"; Enum "Intrastat Report VAT File Fmt")
        {
            Caption = 'Customer VAT Reg. No. on File';
        }
        field(10; "Vend. VAT No. on File"; Enum "Intrastat Report VAT File Fmt")
        {
            Caption = 'Vendor VAT Reg. No. on File';
        }
        field(11; "Company VAT No. on File"; Enum "Intrastat Report VAT File Fmt")
        {
            Caption = 'Company VAT Reg. No. on File';
        }
        field(12; "Default Trans. Spec. Code"; Code[10])
        {
            Caption = 'Default Trans. Spec. Code';
            TableRelation = "Transaction Specification";
        }
        field(13; "Default Trans. Spec. Ret. Code"; Code[10])
        {
            Caption = 'Default Trans. Spec. Returns Code';
            TableRelation = "Transaction Specification";
        }
        field(14; "Intrastat Nos."; Code[20])
        {
            Caption = 'Intrastat Nos.';
            TableRelation = "No. Series";
        }
        field(15; "Split Files"; Boolean)
        {
            Caption = 'Split Receipts/Shipments Files';
        }
        field(16; "Zip Files"; Boolean)
        {
            Caption = 'Zip File(-s)';
        }
        field(17; "Data Exch. Def. Code"; Code[20])
        {
            Caption = 'Data Exch. Def. Code';
            TableRelation = "Data Exch. Def";
        }
        field(18; "Data Exch. Def. Name"; Text[100])
        {
            Caption = 'Data Exch. Def. Name';
            CalcFormula = lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(19; "Data Exch. Def. Code - Receipt"; Code[20])
        {
            Caption = 'Data Exch. Def. Code - Receipt';
            TableRelation = "Data Exch. Def";
        }
        field(20; "Data Exch. Def. Name - Receipt"; Text[100])
        {
            Caption = 'Data Exch. Def. Name - Receipt';
            CalcFormula = lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Code - Receipt")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Data Exch. Def. Code - Shpt."; Code[20])
        {
            Caption = 'Data Exch. Def. Code - Shipment';
            TableRelation = "Data Exch. Def";
        }
        field(22; "Data Exch. Def. Name - Shpt."; Text[100])
        {
            Caption = 'Data Exch. Def. Name - Shipment';
            CalcFormula = lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Code - Shpt.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(23; "Shipments Based On"; Enum "Intrastat Report Shpt. Base")
        {
            Caption = 'Shipments Based On';
        }
        field(24; "VAT No. Based On"; Enum "Intrastat Report VAT No. Base")
        {
            Caption = 'VAT Reg. No. Based On';
        }
        field(25; "Def. Private Person VAT No."; Text[50])
        {
            Caption = 'Default Private Person VAT Reg. No.';
        }
        field(26; "Def. 3-Party Trade VAT No."; Text[50])
        {
            Caption = 'Default 3-Party Trade VAT Reg. No.';
        }
        field(27; "Def. VAT for Unknown State"; Text[50])
        {
            Caption = 'Def. VAT Reg. No. for Unknown State';
        }
        field(28; "Def. Country/Region Code"; Code[10])
        {
            Caption = 'Default Country/Region Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Company Information"."Ship-to Country/Region Code" where("Primary Key" = const('')));
            Editable = false;
        }
        field(29; "Suppl. Units Weight"; Enum "Intrastat Report Suppl. Weight")
        {
            Caption = 'Suppl. Units Weight';
        }
        field(30; "Get Partner VAT For"; Enum "Intrastat Report Line Type Sel")
        {
            Caption = 'Get VAT Reg. No. For';
        }
        field(31; "Include Drop Shipment"; Boolean)
        {
            Caption = 'Include Drop Shipment';
        }
        field(32; "Def. Country Code for Item Tr."; Enum "Default Ctry. Code-Item Track.")
        {
            Caption = 'Default Country Code for Item Tracking';
        }
    }
    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    var
        SetupRead: Boolean;
        OnDelIntrastatContactErr: Label 'You cannot delete contact number %1 because it is set up as an Intrastat contact in the Intrastat Setup window.', Comment = '%1 - Contact No';
        OnDelVendorIntrastatContactErr: Label 'You cannot delete vendor number %1 because it is set up as an Intrastat contact in the Intrastat Setup window.', Comment = '%1 - Vendor No';

    procedure CheckDeleteIntrastatContact(ContactType: Enum "Intrastat Report Contact Type"; ContactNo: Code[20])
    begin
        if (ContactNo = '') or (ContactType = "Intrastat Contact Type"::" ") then
            exit;

        if Get() then
            if (ContactNo = "Intrastat Contact No.") and (ContactType = "Intrastat Contact Type") then begin
                if ContactType = "Intrastat Contact Type"::Contact then
                    Error(OnDelIntrastatContactErr, ContactNo);
                Error(OnDelVendorIntrastatContactErr, ContactNo);
            end;
    end;

    procedure GetPartnerNo(SellTo: Code[20]; BillTo: Code[20]; VATNoBasedToCheck: Enum "Intrastat Report VAT No. Base") PartnerNo: Code[20]
    begin
        GetSetup();
        if VATNoBasedToCheck <> "VAT No. Based On" then
            exit('');

        exit(GetPartnerNo(SellTo, BillTo));
    end;

    procedure GetPartnerNo(SellTo: Code[20]; BillTo: Code[20]) PartnerNo: Code[20]
    begin
        GetSetup();
        case "VAT No. Based On" of
            "VAT No. Based On"::"Sell-to VAT":
                PartnerNo := SellTo;
            "VAT No. Based On"::"Bill-to VAT":
                PartnerNo := BillTo;
        end;
    end;

    procedure GetSetup()
    begin
        if not SetupRead then begin
            Get();
            SetupRead := true;
        end;
    end;
}