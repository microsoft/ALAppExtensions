// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

table 11729 "Subst. Vend. Posting Group CZL"
{
    Caption = 'Subst. Vendor Posting Group';
    ObsoleteState = Removed;
    ObsoleteTag = '25.0';
    ObsoleteReason = 'Replaced by Alt. Vendor Posting Group table.';

    fields
    {
        field(1; "Parent Vendor Posting Group"; Code[20])
        {
            Caption = 'Parent Vendor Posting Group';
            TableRelation = "Vendor Posting Group";
            DataClassification = CustomerContent;
        }
        field(2; "Vendor Posting Group"; Code[20])
        {
            Caption = 'Vendor Posting Group';
            TableRelation = "Vendor Posting Group";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Parent Vendor Posting Group", "Vendor Posting Group")
        {
            Clustered = true;
        }
    }
}

