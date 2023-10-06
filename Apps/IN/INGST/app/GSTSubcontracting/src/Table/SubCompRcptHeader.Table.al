// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Navigate;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Intrastat;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using System.Security.AccessControl;

table 18474 "Sub. Comp. Rcpt. Header"
{
    Caption = 'Sub. Comp. Rcpt. Header';
    DataCaptionFields = "No.", "Buy-from Vendor Name";

    fields
    {
        field(2; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            NotBlank = true;
            TableRelation = Vendor;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(19; "Order Date"; Date)
        {
            Caption = 'Order Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(20; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(28; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location where("Use As In-Transit" = const(false));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(44; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(66; "Vendor Order No."; Code[35])
        {
            Caption = 'Vendor Order No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(67; "Vendor Shipment No."; Code[20])
        {
            Caption = 'Vendor Shipment No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(74; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(79; "Buy-from Vendor Name"; Text[100])
        {
            Caption = 'Buy-from Vendor Name';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(80; "Buy-from Vendor Name 2"; Text[50])
        {
            Caption = 'Buy-from Vendor Name 2';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(81; "Buy-from Address"; Text[100])
        {
            Caption = 'Buy-from Address';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(82; "Buy-from Address 2"; Text[50])
        {
            Caption = 'Buy-from Address 2';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(83; "Buy-from City"; Text[30])
        {
            Caption = 'Buy-from City';
            TableRelation = if ("Buy-from Country/Region Code" = const()) "Post Code".City
            else
            if ("Buy-from Country/Region Code" = filter(<> ''))
                "Post Code".City where("Country/Region Code" = field("Buy-from Country/Region Code"));
            //This property is currently not supported
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(
                    "Buy-from City",
                    "Buy-from Post Code",
                    "Buy-from County",
                    "Buy-from Country/Region Code",
                    (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(84; "Buy-from Contact"; Text[100])
        {
            Caption = 'Buy-from Contact';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(88; "Buy-from Post Code"; Code[20])
        {
            Caption = 'Buy-from Post Code';
            TableRelation = if ("Buy-from Country/Region Code" = const()) "Post Code"
            else
            if ("Buy-from Country/Region Code" = filter(<> ''))
                "Post Code" where("Country/Region Code" = field("Buy-from Country/Region Code"));
            //This property is currently not supported
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(
                    "Buy-from City",
                    "Buy-from Post Code",
                    "Buy-from County",
                    "Buy-from Country/Region Code",
                    (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(89; "Buy-from County"; Text[30])
        {
            Caption = 'Buy-from County';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(90; "Buy-from Country/Region Code"; Code[10])
        {
            Caption = 'Buy-from Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(95; "Order Address Code"; Code[10])
        {
            Caption = 'Order Address Code';
            TableRelation = "Order Address".Code where("Vendor No." = field("Buy-from Vendor No."));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(99; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(101; "Area"; Code[10])
        {
            Caption = 'Area';
            TableRelation = Area;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(102; "Transaction Specification"; Code[10])
        {
            Caption = 'Transaction Specification';
            TableRelation = "Transaction Specification";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(104; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(109; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(110; "Order No. Series"; Code[10])
        {
            Caption = 'Order No. Series';
            TableRelation = "No. Series";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(112; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
        field(113; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(114; "Tax Registration No."; Text[20])
        {
            Caption = 'Tax Registration No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(117; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. Order No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(118; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(119; "Subcontracting Order Line No."; Integer)
        {
            Caption = 'Subcontracting Order Line No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(120; "VAT Business Posting Group"; Code[20])
        {
            Caption = 'VAT Business Posting Group';
            Editable = false;
            TableRelation = "VAT Business Posting Group";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(121; "Vendor Shipment Date"; Date)
        {
            Caption = 'Vendor Shipment Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Order No.")
        {
        }
        key(Key3; "Posting Date")
        {
        }
    }

    trigger OnInsert()
    begin
        "Purch&payableSetup".Get();
        if "No." = '' then begin
            "Purch&payableSetup".TestField("Posted SC Comp. Rcpt. Nos.");
            NoSeriesMgt.InitSeries(
                "Purch&payableSetup"."Posted SC Comp. Rcpt. Nos.",
                xRec."No. Series",
                "Posting Date",
                "No.",
                "No. Series");
        end;
    end;

    procedure Navigate()
    var
        NavigateForm: Page Navigate;
    begin
        NavigateForm.SetDoc("Posting Date", "No.");
        NavigateForm.Run();
    end;

    procedure ShowDimensions()
    var
        DimStrSubLbl: Label '%1 %2', Comment = '%1= Table Caption %2 = No';
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo(DimStrSubLbl, TableCaption, "No."));
    end;

    var
        PostCode: Record "Post Code";
        "Purch&payableSetup": Record "Purchases & Payables Setup";
        DimMgt: Codeunit DimensionManagement;
        NoSeriesMgt: Codeunit NoSeriesManagement;
}
