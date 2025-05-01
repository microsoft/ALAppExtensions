// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Sales.Setup;

tableextension 10566 "Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(10507; "Reverse Charge VAT Post. Gr."; Code[20])
        {
            Caption = 'Reverse Charge VAT Posting Gr.';
            TableRelation = "VAT Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(10508; "Domestic Customers GB"; Code[20])
        {
            Caption = 'Domestic Customers';
            TableRelation = "VAT Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(10509; "Invoice Wording GB"; Text[30])
        {
            Caption = 'Invoice Wording';
            DataClassification = CustomerContent;
        }
    }
}