// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ServicesTransfer;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Foundation.Navigate;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using System.Security.User;

table 18354 "Service Transfer Shpt. Header"
{
    Caption = 'Service Transfer Shpt. Header';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Service Transfer Order No."; Code[20])
        {
            Caption = 'Service Transfer Order No.';
            DataClassification = CustomerContent;
        }
        field(3; "Transfer-from Code"; Code[10])
        {
            Caption = 'Transfer-from Code';
            Editable = false;
            TableRelation = Location where("Use As In-Transit" = const(false));
            DataClassification = CustomerContent;
        }
        field(4; "Transfer-from Name"; Text[100])
        {
            Caption = 'Transfer-from Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Transfer-from Name 2"; Text[100])
        {
            Caption = 'Transfer-from Name 2';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Transfer-from Address"; Text[100])
        {
            Caption = 'Transfer-from Address';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "Transfer-from Address 2"; Text[100])
        {
            Caption = 'Transfer-from Address 2';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Transfer-from Post Code"; Code[20])
        {
            Caption = 'Transfer-from Post Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Transfer-from City"; Text[30])
        {
            Caption = 'Transfer-from City';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Transfer-from State"; Code[10])
        {
            Caption = 'Transfer-from State';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = State;
        }
        field(11; "Transfer-to Code"; Code[10])
        {
            Caption = 'Transfer-to Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Location where("Use As In-Transit" = const(false));
        }
        field(12; "Transfer-to Name"; Text[100])
        {
            Caption = 'Transfer-to Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Transfer-to Name 2"; Text[100])
        {
            Caption = 'Transfer-to Name 2';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Transfer-to Address"; Text[100])
        {
            Caption = 'Transfer-to Address';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(15; "Transfer-to Address 2"; Text[100])
        {
            Caption = 'Transfer-to Address 2';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(16; "Transfer-to Post Code"; Code[20])
        {
            Caption = 'Transfer-to Post Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; "Transfer-to City"; Text[30])
        {
            Caption = 'Transfer-to City';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18; "Transfer-to State"; Code[10])
        {
            Caption = 'Transfer-to State';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = State;
        }
        field(20; "Shipment Date"; Date)
        {
            Caption = 'Shipment Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "Receipt Date"; Date)
        {
            Caption = 'Receipt Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(22; Status; Enum Status)
        {
            Caption = 'Status';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(23; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            Editable = false;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
            DataClassification = CustomerContent;
        }
        field(24; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            Editable = false;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
            DataClassification = CustomerContent;
        }
        field(25; "Ship Control Account"; Code[20])
        {
            Caption = 'Ship Control Account';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Direct Posting" = const(true));
        }
        field(26; "Receive Control Account"; Code[20])
        {
            Caption = 'Receive Control Account';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "G/L Account" where("Direct Posting" = const(true));
        }
        field(27; "External Doc No."; Code[20])
        {
            Caption = 'External Doc No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(28; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(29; "GST Inv. Rounding Precision"; Decimal)
        {
            Caption = 'GST Inv. Rounding Precision';
            DataClassification = CustomerContent;
        }
        field(30; "GST Inv. Rounding Type"; Enum "GST Inv Rounding Type")
        {
            Caption = 'GST Inv. Rounding Type';
            DataClassification = CustomerContent;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            DataClassification = SystemMetadata;
        }
        field(9000; "Assigned User ID"; Code[50])
        {
            Caption = 'Assigned User ID';
            Editable = false;
            TableRelation = "User Setup";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    var
        DimensionManagement: Codeunit DimensionManagement;
        DimensionSetIdMsg: Label '%1', Comment = '%1=No.';

    procedure ShowDimensions()
    begin
        DimensionManagement.ShowDimensionSet("Dimension Set ID", StrSubstNo(DimensionSetIdMsg, "No."));
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Shipment Date", "No.");
        NavigatePage.Run();
    end;
}
