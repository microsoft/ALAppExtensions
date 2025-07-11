// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;

tableextension 18157 "GST Ship-to Address Ext" extends "Ship-to Address"
{
    fields
    {
        field(18141; State; code[10])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
            TableRelation = State;
        }
        field(18142; Consignee; Boolean)
        {
            Caption = 'Consignee';
            DataClassification = CustomerContent;
        }
        field(18143; "GST Registration No."; code[20])
        {
            Caption = 'GST Registration No.';
            DataClassification = CustomerContent;
        }
        field(18144; "ARN No."; code[20])
        {
            Caption = 'ARN No.';
            DataClassification = CustomerContent;
        }
        field(18145; "Ship-to GST Customer Type"; Enum "GST Customer Type")
        {
            Caption = 'Ship-to GST Customer Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Ship-to GST Customer Type" in ["Ship-to GST Customer Type"::Exempted,
                                                    "Ship-to GST Customer Type"::Export,
                                                    "Ship-to GST Customer Type"::Unregistered] then
                    Error('Ship to Gst Customer Type is not allowed for Exempted,Export and Unregistered Customers');
            end;
        }
    }
}
