// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Document;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;

tableextension 18468 "Subcon Prod.Order Component" extends "Prod. Order Component"
{
    fields
    {
        field(18451; "Qty. To Consume"; Decimal)
        {
            Caption = 'Qty. To Consume';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18452; "Subcontracting Order No."; Code[20])
        {
            Caption = 'Subcontracting Order No.';
            Editable = false;
            TableRelation = "Purchase Header"."No." where(
                "Document Type" = const(1),
                "No." = field("Subcontracting Order No."),
                Subcontracting = const(true));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18453; "Subcontractor Code"; Code[20])
        {
            Caption = 'Subcontractor Code';
            Editable = false;
            TableRelation = Vendor."No." where(Subcontractor = const(true));
            DataClassification = EndUserIdentifiableInformation;
        }
    }
}
