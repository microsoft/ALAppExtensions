// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using Microsoft.Finance.GST.Base;
using Microsoft.Inventory.Location;
using System.Security.AccessControl;

table 18207 "Posted GST Distribution Header"
{
    Caption = 'Posted GST Distribution Header';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = false;
        }
        field(2; "From GSTIN No."; Code[20])
        {
            Caption = 'From GSTIN No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "GST Registration Nos."
                where("Input Service Distributor" = filter(true));
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(7; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
        }
        field(8; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            DataClassification = CustomerContent;
        }
        field(9; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
        }
        field(10; "Dist. Document Type"; Enum "BankCharges DocumentType")
        {
            Caption = 'Dist. Document Type';
            DataClassification = CustomerContent;
        }
        field(11; Reversal; Boolean)
        {
            Caption = 'Reversal';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; "Reversal Invoice No."; Code[20])
        {
            Caption = 'Reversal Invoice No.';
            DataClassification = CustomerContent;
        }
        field(13; "ISD Document Type"; Enum "Adjustment Document Type")
        {
            Caption = 'ISD Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14; "From Location Code"; Code[10])
        {
            Caption = 'From Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location where("GST Input Service Distributor" = filter(true));
        }
        field(16; "Dist. Credit Type"; Enum "GST Credit")
        {
            Caption = 'Dist. Credit Type';
            DataClassification = CustomerContent;
        }
        field(17; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            DataClassification = CustomerContent;
        }
        field(18; "Total Amout Applied for Dist."; Decimal)
        {
            Caption = 'Total Amout Applied for Dist.';
            DataClassification = CustomerContent;
        }
        field(19; "Distribution Basis"; Text[50])
        {
            Caption = 'Distribution Basis';
            DataClassification = CustomerContent;
        }
        field(20; "Pre Distribution No."; Code[20])
        {
            Caption = 'Pre Distribution No.';
            DataClassification = CustomerContent;
        }
        field(30; "Completely Reversed"; Boolean)
        {
            Caption = 'Completely Reversed';
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
}
