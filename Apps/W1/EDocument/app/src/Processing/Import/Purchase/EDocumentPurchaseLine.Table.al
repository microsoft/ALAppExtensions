#pragma warning disable AS0049, AS0009, AS0005, AS0125
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import.Purchase;

using Microsoft.eServices.EDocument;

table 6101 "E-Document Purchase Line"
{
    Access = Internal;
    ReplicateData = false;
#pragma warning disable AS0034
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
#pragma warning restore AS0034

    fields
    {
        field(1; "E-Document Entry No."; Integer)
        {
            Caption = 'E-Document Entry No.';
            TableRelation = "E-Document"."Entry No";
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Product Code"; Text[100])
        {
            Caption = 'Product Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Description"; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            ToolTip = 'Specifies the quantity.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "Unit of Measure"; Text[50])
        {
            Caption = 'Unit of Measure';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            ToolTip = 'Specifies the direct unit cost.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Sub Total"; Decimal)
        {
            Caption = 'Sub Total';
            DataClassification = CustomerContent;
        }
        field(10; "Total Discount"; Decimal)
        {
            Caption = 'Total Discount';
            DataClassification = CustomerContent;
        }
        field(11; "VAT Rate"; Decimal)
        {
            Caption = 'VAT Rate';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "E-Document Entry No.", "Line No.")
        {
            Clustered = true;
        }
    }

}
#pragma warning restore AS0049, AS0009, AS0005, AS0125