// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

table 11729 "Subst. Vend. Posting Group CZL"
{
    Caption = 'Subst. Vendor Posting Group';
#if not CLEAN22
    LookupPageId = "Subst. Vend. Post. Groups CZL";
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '25.0';
#endif
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
#if not CLEAN22
            trigger OnValidate()
            begin
                if "Vendor Posting Group" = "Parent Vendor Posting Group" then
                    Error(PostGrpSubstErr);
            end;
#endif
        }
    }

    keys
    {
        key(Key1; "Parent Vendor Posting Group", "Vendor Posting Group")
        {
            Clustered = true;
        }
    }
#if not CLEAN22
    var
        PostGrpSubstErr: Label 'Posting Group cannot substitute itself.';
#endif
}

