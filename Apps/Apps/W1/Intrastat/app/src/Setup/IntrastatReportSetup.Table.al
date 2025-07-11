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
            ToolTip = 'Specifies that you must include arrivals of received goods in Intrastat reports.';
        }
        field(3; "Report Shipments"; Boolean)
        {
            Caption = 'Report Shipments';
            ToolTip = 'Specifies that you must include shipments of dispatched items in Intrastat reports.';
        }
        field(4; "Default Trans. - Purchase"; Code[10])
        {
            Caption = 'Default Trans. Type';
            TableRelation = "Transaction Type";
            ToolTip = 'Specifies the default transaction type for regular sales shipments and service shipments, and purchase receipts.';
        }
        field(5; "Default Trans. - Return"; Code[10])
        {
            Caption = 'Default Trans. Type - Returns';
            TableRelation = "Transaction Type";
            ToolTip = 'Specifies the default transaction type for sales returns and service returns, and purchase returns.';
        }
        field(6; "Intrastat Contact Type"; Enum "Intrastat Report Contact Type")
        {
            Caption = 'Intrastat Contact Type';
            ToolTip = 'Specifies the Intrastat contact type.';
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
            ToolTip = 'Specifies the Intrastat contact.';
        }
        field(9; "Cust. VAT No. on File"; Enum "Intrastat Report VAT File Fmt")
        {
            Caption = 'Customer VAT Reg. No. on File';
            ToolTip = 'Specifies how a customer''s VAT registration number exports to the Intrastat file. 0 is the value of the VAT Reg. No. field, 1 adds the EU country code as a prefix, and 2 removes the EU country code.';
        }
        field(10; "Vend. VAT No. on File"; Enum "Intrastat Report VAT File Fmt")
        {
            Caption = 'Vendor VAT Reg. No. on File';
            ToolTip = 'Specifies how a vendor''s VAT registration number exports to the Intrastat file. 0 is the value of the VAT Reg. No. field, 1 adds the EU country code as a prefix, and 2 removes the EU country code.';
        }
        field(11; "Company VAT No. on File"; Enum "Intrastat Report VAT File Fmt")
        {
            Caption = 'Company VAT Reg. No. on File';
            ToolTip = 'Specifies how the company''s VAT registration number exports to the Intrastat file. 0 is the value of the VAT Reg. No. field, 1 adds the EU country code as a prefix, and 2 removes the EU country code.';
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
            ToolTip = 'Specifies the code for the number series that will be used to assign numbers to intrastat documents. To see the number series that have been set up in the No. Series table, click the drop-down arrow in the field.';
        }
        field(15; "Split Files"; Boolean)
        {
            Caption = 'Split Receipts/Shipments Files';
            ToolTip = 'Specifies if Receipts and Shipments shall be reported in two separate files.';
        }
        field(16; "Zip Files"; Boolean)
        {
            Caption = 'Zip File(-s)';
            ToolTip = 'Specifies if report file (-s) shall be added to Zip file.';
        }
        field(17; "Data Exch. Def. Code"; Code[20])
        {
            Caption = 'Data Exch. Def. Code';
            TableRelation = "Data Exch. Def";
            ToolTip = 'Specifies the data exchange definition code to generate the intrastat file.';
        }
        field(18; "Data Exch. Def. Name"; Text[100])
        {
            Caption = 'Data Exch. Def. Name';
            CalcFormula = lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Code")));
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the data exchange definition name to generate the intrastat file.';
        }
        field(19; "Data Exch. Def. Code - Receipt"; Code[20])
        {
            Caption = 'Data Exch. Def. Code - Receipt';
            TableRelation = "Data Exch. Def";
            ToolTip = 'Specifies the data exchange definition code to generate the intrastat file for received goods.';
        }
        field(20; "Data Exch. Def. Name - Receipt"; Text[100])
        {
            Caption = 'Data Exch. Def. Name - Receipt';
            CalcFormula = lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Code - Receipt")));
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the data exchange definition name to generate the intrastat file for received goods.';
        }
        field(21; "Data Exch. Def. Code - Shpt."; Code[20])
        {
            Caption = 'Data Exch. Def. Code - Shipment';
            TableRelation = "Data Exch. Def";
            ToolTip = 'Specifies the data exchange definition code to generate the intrastat file for shipped goods.';
        }
        field(22; "Data Exch. Def. Name - Shpt."; Text[100])
        {
            Caption = 'Data Exch. Def. Name - Shipment';
            CalcFormula = lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Code - Shpt.")));
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the data exchange definition name to generate the intrastat file for shipped goods.';
        }
        field(23; "Shipments Based On"; Enum "Intrastat Report Shpt. Base")
        {
            Caption = 'Shipments Based On';
            ToolTip = 'Specifies based on which country code Intrastat report lines are taken.';
        }
#if not CLEANSCHEMA29        
        field(24; "VAT No. Based On"; Enum "Intrastat Report VAT No. Base")
        {
            Caption = 'VAT Reg. No. Based On';
            ToolTip = 'Specifies based on which customer/vendor code VAT number is taken for the Intrastat report.';
            ObsoleteReason = 'Use "Sales VAT No. Based On" and "Purchase VAT No. Based On" fields instead.';
#if CLEAN26            
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#else            
            ObsoleteState = Pending;
            ObsoleteTag = '26.0';
#endif            
        }
#endif        
        field(25; "Def. Private Person VAT No."; Text[50])
        {
            Caption = 'Default Private Person VAT Reg. No.';
            ToolTip = 'Specifies the default private person VAT number.';
        }
        field(26; "Def. 3-Party Trade VAT No."; Text[50])
        {
            Caption = 'Default 3-Party Trade VAT Reg. No.';
            ToolTip = 'Specifies the default 3-party trade VAT number.';
        }
        field(27; "Def. VAT for Unknown State"; Text[50])
        {
            Caption = 'Def. VAT Reg. No. for Unknown State';
            ToolTip = 'Specifies the default VAT number for unknown state.';
        }
        field(28; "Def. Country/Region Code"; Code[10])
        {
            Caption = 'Default Country/Region Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Company Information"."Ship-to Country/Region Code" where("Primary Key" = const('')));
            Editable = false;
            ToolTip = 'Specifies the default receiving country code.';
        }
        field(29; "Suppl. Units Weight"; Enum "Intrastat Report Suppl. Weight")
        {
            Caption = 'Suppl. Units Weight';
        }
        field(30; "Get Partner VAT For"; Enum "Intrastat Report Line Type Sel")
        {
            Caption = 'Get VAT Reg. No. For';
            ToolTip = 'Specifies the type of line that the partner''s VAT registration number is updated for.';
        }
        field(31; "Include Drop Shipment"; Boolean)
        {
            Caption = 'Include Drop Shipment';
            ToolTip = 'Specifies if drop shipment transactions are included in Intrastat reports.';
        }
        field(32; "Def. Country Code for Item Tr."; Enum "Default Ctry. Code-Item Track.")
        {
            Caption = 'Default Country Code for Item Tracking';
            ToolTip = 'Specifies the default source of country code for item tracking.';
        }
        field(33; "Sales VAT No. Based On"; Enum "Intrastat Report VAT No. Base")
        {
            Caption = 'Sales VAT Reg. No. Based On';
            ToolTip = 'Specifies based on which customer code, or document VAT number is taken for the Intrastat report.';
        }
        field(34; "Purchase VAT No. Based On"; Enum "Intr. Rep. Purch. VAT No. Base")
        {
            Caption = 'Purchase VAT Reg. No. Based On';
            ToolTip = 'Specifies based on which vendor code, or document VAT number is taken for the Intrastat report.';
        }
        field(35; "Project VAT No. Based On"; Enum "Intr. Rep. Proj. VAT No. Base")
        {
            Caption = 'Project VAT Reg. No. Based On';
            ToolTip = 'Specifies based on which customer code VAT number is taken for the Intrastat report.';
        }
        field(36; "Sales Intrastat Info Based On"; Enum "Intr. Report Sales Info Base")
        {
            Caption = 'Sales Intrastat Info Based On';
            ToolTip = 'Specifies based on which customer code Intrastat settings are added to the document.';
        }
        field(37; "Purch. Intrastat Info Based On"; Enum "Intr. Report Purch. Info Base")
        {
            Caption = 'Purchase Intrastat Info Based On';
            ToolTip = 'Specifies based on which vendor code Intrastat settings are added to the document.';
        }
        field(38; "Transaction Type Mandatory"; Boolean)
        {
            Caption = 'Transaction Type Mandatory';
            ToolTip = 'Specifies if it is mandatory to enter a transaction type on a document header.';
        }
        field(39; "Transaction Spec. Mandatory"; Boolean)
        {
            Caption = 'Transaction Spec. Mandatory';
            ToolTip = 'Specifies if it is mandatory to enter a transaction specification on a document header.';
        }
        field(40; "Transport Method Mandatory"; Boolean)
        {
            Caption = 'Transport Method Mandatory';
            ToolTip = 'Specifies if it is mandatory to enter a transport method on a document header.';
        }
        field(41; "Shipment Method Mandatory"; Boolean)
        {
            Caption = 'Shipment Method Mandatory';
            ToolTip = 'Specifies if it is mandatory to enter a shipment method on a document header.';
        }
        field(42; "Max. No. of Lines in File"; Integer)
        {
            Caption = 'Max. No. of Lines in File';
            ToolTip = 'Specifies the maximum number of lines in the Intrastat file.';
            MinValue = 0;
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

#if not CLEAN26
    [Obsolete('Pending removal.', '26.0')]
    procedure GetPartnerNo(SellTo: Code[20]; BillTo: Code[20]; VATNoBasedToCheck: Enum "Intrastat Report VAT No. Base") PartnerNo: Code[20]
    begin
        GetSetup();
        if VATNoBasedToCheck <> "VAT No. Based On" then
            exit('');

        exit(GetPartnerNo(SellTo, BillTo));
    end;

    [Obsolete('Pending removal.', '26.0')]
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
#endif
    procedure GetSetup()
    begin
        if not SetupRead then begin
            Get();
            SetupRead := true;
        end;
    end;
}