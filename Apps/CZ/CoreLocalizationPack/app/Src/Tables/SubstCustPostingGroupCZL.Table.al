#if not CLEANSCHEMA25
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

table 11728 "Subst. Cust. Posting Group CZL"
{
    Caption = 'Subst. Customer Posting Group';
    ObsoleteState = Removed;
    ObsoleteTag = '25.0';
    ObsoleteReason = 'Replaced by Alt. Customer Posting Group table.';

    fields
    {
        field(1; "Parent Customer Posting Group"; Code[20])
        {
            Caption = 'Parent Customer Posting Group';
            TableRelation = "Customer Posting Group";
            DataClassification = CustomerContent;
        }
        field(2; "Customer Posting Group"; Code[20])
        {
            Caption = 'Customer Posting Group';
            TableRelation = "Customer Posting Group";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Parent Customer Posting Group", "Customer Posting Group")
        {
            Clustered = true;
        }
    }
}
#endif