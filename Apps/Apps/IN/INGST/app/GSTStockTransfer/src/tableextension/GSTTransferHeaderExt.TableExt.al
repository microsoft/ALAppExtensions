// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Sales;
using Microsoft.Inventory.Transfer;
using Microsoft.Purchases.Vendor;

tableextension 18391 "GST Transfer Header Ext" extends "Transfer Header"
{
    fields
    {
        field(18391; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor No.';
            TableRelation = Vendor where("GST Vendor Type" = filter(Import));
        }
        field(18392; "Bill Of Entry No."; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Bill Of Entry No.';
        }
        field(18393; "Bill Of Entry Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Bill Of Entry Date';
        }
        field(18394; "Vendor Invoice No."; code[20])
        {
            Caption = 'Vendor Invoice No.';
            DataClassification = CustomerContent;
        }
        field(18395; "Load Unreal Prof Amt on Invt."; Boolean)
        {
            Caption = 'Load Unreal Prof Amt on Invt.';
            DataClassification = CustomerContent;
        }
        field(18396; "Time of Removal"; Time)
        {
            Caption = 'Time of Removal';
            DataClassification = CustomerContent;
        }
        field(18397; "LR/RR No."; Code[20])
        {
            Caption = 'LR/RR No.';
            DataClassification = CustomerContent;
        }
        field(18398; "LR/RR Date"; Date)
        {
            Caption = 'LR/RR Date';
            DataClassification = CustomerContent;
        }
        field(18399; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            DataClassification = CustomerContent;
        }
        field(18400; "Mode of Transport"; text[15])
        {
            Caption = 'Mode of Transport';
            DataClassification = CustomerContent;
        }
        field(18401; "Distance (Km)"; Decimal)
        {
            Caption = 'Distance (Km)';
            DataClassification = CustomerContent;
        }
        field(18402; "Vehicle Type"; Enum "GST Vehicle Type")
        {
            Caption = 'Vehicle Type';
            DataClassification = CustomerContent;
        }
        field(18403; "Acknowledgement No."; Text[30])
        {
            Caption = 'Acknowledgement No.';
            DataClassification = CustomerContent;
        }
        field(18404; "IRN Hash"; Text[64])
        {
            Caption = 'IRN Hash';
            DataClassification = CustomerContent;
        }
        field(18405; "QR Code"; Blob)
        {
            Subtype = Bitmap;
            Caption = 'QR Code';
            DataClassification = CustomerContent;
        }
        field(18406; "Acknowledgement Date"; DateTime)
        {
            Caption = 'Acknowledgement Date';
            DataClassification = CustomerContent;
        }
        field(18407; "IsJSONImported"; Boolean)
        {
            Caption = 'IsJSONImported';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(18408; "E-Inv. Cancelled Date"; DateTime)
        {
            Caption = 'E-Inv. Cancelled Date';
            DataClassification = CustomerContent;
        }
        field(18409; "Cancel Reason"; Enum "e-Invoice Cancel Reason")
        {
            Caption = 'Cancel Reason';
            DataClassification = CustomerContent;
        }
        field(18410; "E-Way Bill No."; Text[50])
        {
            Caption = 'E-Way Bill No.';
            DataClassification = CustomerContent;
        }
    }
}
