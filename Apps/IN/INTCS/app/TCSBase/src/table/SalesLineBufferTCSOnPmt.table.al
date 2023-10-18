// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Location;
using Microsoft.Foundation.AuditCodes;

table 18815 "Sales Line Buffer TCS On Pmt."
{
    Caption = 'Sales Lines Buffer TCS on Payment';
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Payment Transaction No."; Code[20])
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(2; "Payment Transaction Line No."; Integer)
        {
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(3; "Customer No."; Code[20])
        {
            TableRelation = Customer;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(4; "Posted Invoice No."; Code[20])
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(5; "Invoice Line No."; Integer)
        {
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(6; "Type"; Enum "Sales Line Type")
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7; "No."; Code[20])
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(8; "Description"; Text[100])
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(9; "Description 2"; Text[50])
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(10; "Location Code"; Code[20])
        {
            TableRelation = Location;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11; "Unit of Measure Code"; Code[20])
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(12; Quantity; Decimal)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(13; "Unit Price"; Decimal)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14; "Line Amount"; Decimal)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(15; "Line Discount Amount"; Decimal)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(16; "Inv. Discount Amount"; Decimal)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(17; "TCS Nature of Collection"; Code[10])
        {
            TableRelation = "TCS Nature Of Collection";
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18; "GST Base Amount"; Decimal)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(19; "Total GST Amount"; Decimal)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(20; "Posting Date"; Date)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(21; "Amount"; Decimal)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(22; "User ID"; Text[50])
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(23; "Source Code"; Code[10])
        {
            TableRelation = "source Code";
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(24; Select; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Payment Transaction No.", "Payment Transaction Line No.", "Posted Invoice No.", "Invoice Line No.", "User ID")
        {
            Clustered = true;
        }
    }
}
