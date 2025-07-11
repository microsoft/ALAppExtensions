// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

using Microsoft.Purchases.Document;
using Microsoft.Sales.History;
using Microsoft.Inventory.Transfer;
using Microsoft.Sales.Document;
using Microsoft.Purchases.History;

table 18604 "Gate Entry Line"
{
    Caption = 'Gate Entry Line';
    fields
    {
        field(1; "Entry Type"; Enum "Gate Entry Type")
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
        }
        field(2; "Gate Entry No."; Code[20])
        {
            Caption = 'Gate Entry No.';
            TableRelation = "Gate Entry Header"."No." where("Entry Type" = field("Entry Type"));
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Source Type"; Enum "Gate Entry Source Type")
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if "Source Type" <> "Source Type" then begin
                    "Source No." := '';
                    "Source Name" := '';
                end;
            end;
        }
        field(5; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
            trigger OnLookup()
            begin
                GateEntryHeader.Get("Entry Type", "Gate Entry No.");
                case "Source Type" of
                    "Source Type"::"Sales Shipment":
                        begin
                            SalesShipHeader.Reset();
                            SalesShipHeader.FilterGroup(2);
                            SalesShipHeader.SetRange("Location Code", GateEntryHeader."Location Code");
                            SalesShipHeader.FilterGroup(0);
                            if Page.RunModal(0, SalesShipHeader) = Action::LookupOK then
                                Validate("Source No.", SalesShipHeader."No.");
                        end;
                    "Source Type"::"Sales Return Order":
                        begin
                            SalesHeader.Reset();
                            SalesHeader.FilterGroup(2);
                            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
                            SalesHeader.SetRange("Location Code", GateEntryHeader."Location Code");
                            SalesHeader.FilterGroup(0);
                            if Page.RunModal(0, SalesHeader) = Action::LookupOK then
                                Validate("Source No.", SalesHeader."No.");
                        end;
                    "Source Type"::"Purchase Order":
                        begin
                            PurchHeader.Reset();
                            PurchHeader.FilterGroup(2);
                            PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
                            PurchHeader.SetRange("Location Code", GateEntryHeader."Location Code");
                            PurchHeader.FilterGroup(0);
                            if Page.RunModal(0, PurchHeader) = Action::LookupOK then
                                Validate("Source No.", PurchHeader."No.");
                        end;
                    "Source Type"::"Purchase Return Shipment":
                        begin
                            ReturnShipHeader.Reset();
                            ReturnShipHeader.FilterGroup(2);
                            ReturnShipHeader.SetRange("Location Code", GateEntryHeader."Location Code");
                            ReturnShipHeader.FilterGroup(0);
                            if Page.RunModal(0, ReturnShipHeader) = Action::LookupOK then
                                Validate("Source No.", ReturnShipHeader."No.");
                        end;
                    "Source Type"::"Transfer Receipt":
                        begin
                            TransHeader.Reset();
                            TransHeader.FilterGroup(2);
                            TransHeader.SetRange("Transfer-to Code", GateEntryHeader."Location Code");
                            TransHeader.FilterGroup(0);
                            if Page.RunModal(0, TransHeader) = Action::LookupOK then
                                Validate("Source No.", TransHeader."No.");
                        end;
                    "Source Type"::"Transfer Shipment":
                        begin
                            TransShptHeader.Reset();
                            TransShptHeader.FilterGroup(2);
                            TransShptHeader.SetRange("Transfer-from Code", GateEntryHeader."Location Code");
                            TransShptHeader.FilterGroup(0);
                            if Page.RunModal(0, TransShptHeader) = Action::LookupOK then
                                Validate("Source No.", TransShptHeader."No.");
                        end
                end;
            end;

            trigger OnValidate()
            begin
                if "Source Type" = "Source Type"::" " then
                    Error(SourceTypeErr, FieldCaption("Line No."), "Line No.");

                if "Source No." <> "Source No." then
                    "Source Name" := '';

                if "Source No." = '' then begin
                    "Source Name" := '';
                    exit;
                end;

                case "Source Type" of
                    "Source Type"::"Sales Shipment":
                        begin
                            SalesShipHeader.Get("Source No.");
                            "Source Name" := CopyStr(SalesShipHeader."Bill-to Name", 1, MaxStrLen("Source Name"));
                        end;
                    "Source Type"::"Sales Return Order":
                        begin
                            SalesHeader.Get(SalesHeader."Document Type"::"Return Order", "Source No.");
                            "Source Name" := CopyStr(SalesHeader."Bill-to Name", 1, MaxStrLen("Source Name"));
                        end;
                    "Source Type"::"Purchase Order":
                        begin
                            PurchHeader.Get(PurchHeader."Document Type"::Order, "Source No.");
                            "Source Name" := CopyStr(PurchHeader."Pay-to Name", 1, MaxStrLen("Source Name"));
                        end;
                    "Source Type"::"Purchase Return Shipment":
                        begin
                            ReturnShipHeader.Get("Source No.");
                            "Source Name" := CopyStr(ReturnShipHeader."Pay-to Name", 1, MaxStrLen("Source Name"));
                        end;
                    "Source Type"::"Transfer Receipt":
                        begin
                            TransHeader.Get("Source No.");
                            "Source Name" := CopyStr(TransHeader."Transfer-from Name", 1, MaxStrLen("Source Name"));
                        end;
                    "Source Type"::"Transfer Shipment":
                        begin
                            TransShptHeader.Get("Source No.");
                            "Source Name" := CopyStr(TransShptHeader."Transfer-to Name", 1, MaxStrLen("Source Name"));
                        end
                end;
            end;
        }
        field(6; "Source Name"; Text[30])
        {
            Caption = 'Source Name';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7; Status; Enum "Gate Entry Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(8; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(9; "Challan No."; Code[20])
        {
            Caption = 'Challan No.';
            DataClassification = CustomerContent;
        }
        field(10; "Challan Date"; Date)
        {
            Caption = 'Challan Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry Type", "Gate Entry No.", "Line No.")
        {
            Clustered = true;
        }
    }
    var
        PurchHeader: Record "Purchase Header";
        SalesShipHeader: Record "Sales Shipment Header";
        TransHeader: Record "Transfer Header";
        SalesHeader: Record "Sales Header";
        ReturnShipHeader: Record "Return Shipment Header";
        TransShptHeader: Record "Transfer Shipment Header";
        GateEntryHeader: Record "Gate Entry Header";
        SourceTypeErr: Label 'Source Type must not be blank in %1 %2.', Comment = ' %1= FieldCaption("Line No."),  %2 = "Line No."';
}
