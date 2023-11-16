// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

table 11728 "Subst. Cust. Posting Group CZL"
{
    Caption = 'Subst. Customer Posting Group';
#if not CLEAN22
    LookupPageId = "Subst. Cust. Post. Groups CZL";
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '25.0';
#endif
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
#if not CLEAN22
            trigger OnValidate()
            begin
                if "Customer Posting Group" = "Parent Customer Posting Group" then
                    Error(PostGrpSubstErr);
            end;
#endif
        }
    }

    keys
    {
        key(Key1; "Parent Customer Posting Group", "Customer Posting Group")
        {
            Clustered = true;
        }
    }
#if not CLEAN22
    var
        PostGrpSubstErr: Label 'Posting Group cannot substitute itself.';
#endif
}

