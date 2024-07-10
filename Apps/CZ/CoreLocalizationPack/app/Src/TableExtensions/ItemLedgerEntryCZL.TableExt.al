// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Ledger;

using Microsoft.Foundation.Address;
using Microsoft.Inventory.History;
using Microsoft.Inventory.Intrastat;
using Microsoft.Inventory.Transfer;

tableextension 11799 "Item Ledger Entry CZL" extends "Item Ledger Entry"
{
    fields
    {
        field(31050; "Tariff No. CZL"; Code[20])
        {
            Caption = 'Tariff No.';
            TableRelation = "Tariff Number";
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
        }
        field(31051; "Physical Transfer CZL"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31054; "Net Weight CZL"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
        }
        field(31057; "Country/Reg. of Orig. Code CZL"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
        }
        field(31058; "Statistic Indication CZL"; Code[10])
        {
            Caption = 'Statistic Indication';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31059; "Intrastat Transaction CZL"; Boolean)
        {
            Caption = 'Intrastat Transaction';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
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

    procedure SetFilterFromDirectTransHeaderCZL(DirectTransHeader: Record "Direct Trans. Header")
    begin
        SetCurrentKey("Document No.");
        SetRange("Document No.", DirectTransHeader."No.");
        SetRange("Posting Date", DirectTransHeader."Posting Date");
    end;

    procedure GetRegisterUserIDCZL(): Code[50]
    var
        ItemRegister: Record "Item Register";
    begin
        if ItemRegister.FindByEntryNoCZL("Entry No.") then
            exit(ItemRegister."User ID");
    end;
}
