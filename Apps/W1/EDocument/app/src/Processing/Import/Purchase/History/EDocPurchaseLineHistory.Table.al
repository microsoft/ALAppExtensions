// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Processing.Import.Purchase;

using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.History;

/// <summary>
/// This table contains the history of field values that were on draft purchase lines, and the systemid of the purchase invoice line it was mapped to.
/// </summary>
table 6140 "E-Doc. Purchase Line History"
{

    DataClassification = CustomerContent;
    Caption = 'E-Doc. Purchase Line Matches';
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    Access = Internal;
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            Editable = false;
            AutoIncrement = true;
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            ToolTip = 'Specifies the vendor number.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(3; "Product Code"; Text[100])
        {
            Caption = 'Product Code';
            ToolTip = 'Specifies the product code.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Description"; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; "Purch. Inv. Line SystemId"; Guid)
        {
            Caption = 'Purchase Inv. Line SystemId';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Purch. Inv. Line".SystemId;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(K1; "Vendor No.", "Product Code", Description)
        {
        }
        key(K2; "Product Code", Description)
        {
        }
        key(K3; "Vendor No.", "Product Code")
        {
        }
        key(K4; "Vendor No.", Description)
        {
        }
    }

}