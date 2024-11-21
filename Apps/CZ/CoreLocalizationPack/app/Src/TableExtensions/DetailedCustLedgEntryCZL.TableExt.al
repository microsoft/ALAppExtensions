#if not CLEANSCHEMA25
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Receivables;

using Microsoft.Sales.Customer;

tableextension 11785 "Detailed Cust. Ledg. Entry CZL" extends "Detailed Cust. Ledg. Entry"
{
    fields
    {
        field(11770; "Customer Posting Group CZL"; Code[20])
        {
            Caption = 'Customer Posting Group';
            TableRelation = "Customer Posting Group";
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Replaced by "Posting Group" field.';
        }
        field(11790; "Appl. Across Post. Groups CZL"; Boolean)
        {
            Caption = 'Application Across Posting Groups';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'The "Alter Posting Groups" feature is replaced by standard "Multiple Posting Groups" feature.';
        }
    }
}
#endif