// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;

table 6101 "E-Document Purchase Line"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    fields
    {
        field(1; "E-Document Line Id"; Integer)
        {
            Caption = 'Line Id';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "E-Document Entry No."; Integer)
        {
            TableRelation = "E-Document"."Entry No";
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Date"; Date)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Product Code"; Text[100])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "Unit of Measure"; Text[50])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Unit Price"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Tax"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Tax Rate"; Text[100])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "E-Document Line Id")
        {
            Clustered = true;
        }
    }

}