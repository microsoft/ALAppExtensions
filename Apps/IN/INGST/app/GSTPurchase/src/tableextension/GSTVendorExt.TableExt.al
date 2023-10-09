// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Purchase;
using Microsoft.Inventory.Location;

tableextension 18092 "GST Vendor Ext" extends Vendor
{
    fields
    {
        field(18080; "GST Registration No."; Code[20])
        {
            Caption = 'GST Registration No.';
            DataClassification = CustomerContent;
        }
        field(18081; "GST Vendor Type"; Enum "GST Vendor Type")
        {
            Caption = 'GST Vendor Type';
            DataClassification = CustomerContent;
        }
        field(18082; "Associated Enterprises"; Boolean)
        {
            Caption = 'Associated Enterprises';
            DataClassification = CustomerContent;
        }
        field(18083; "Aggregate Turnover"; Enum "Aggregate Turnover")
        {
            Caption = 'Aggregate Turnover';
            DataClassification = CustomerContent;
        }
        field(18084; "ARN No."; Code[20])
        {
            Caption = 'ARN No.';
            DataClassification = CustomerContent;
        }
        field(18085; "Composition"; Boolean)
        {
            Caption = 'Composition';
            DataClassification = CustomerContent;
        }
        field(18086; Transporter; Boolean)
        {
            Caption = 'Transporter';
            DataClassification = CustomerContent;
        }
        field(18087; Subcontractor; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Subcontractor';
        }
        field(18088; "Vendor Location"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor Location';
            TableRelation = Location where("Subcontracting Location" = const(true));
        }
        field(18089; "Commissioner's Permission No."; text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Commissioners Permission No.';
        }
        field(18090; "Govt. Undertaking"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Govt. Undertaking';
        }

    }
}
