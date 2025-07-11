// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Purchases.Setup;

tableextension 10559 "Purchases & Payables Setup" extends "Purchases & Payables Setup"
{
    fields
    {
        field(10507; "Reverse Charge VAT Post. Gr."; Code[20])
        {
            Caption = 'Reverse Charge VAT Posting Gr.';
            TableRelation = "VAT Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(10508; "Domestic Vendors GB"; Code[20])
        {
            Caption = 'Domestic Vendors';
            TableRelation = "VAT Business Posting Group";
            DataClassification = CustomerContent;
        }
    }
}