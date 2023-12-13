// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Purchases.Vendor;

pageextension 31012 "Vendor Posting Groups CZL" extends "Vendor Posting Groups"
{
    ObsoleteState = Pending;
#pragma warning disable AS0072
    ObsoleteTag = '22.0';
#pragma warning restore AS0072
    ObsoleteReason = 'All fields from this pageextension are obsolete.';

    actions
    {
#pragma warning disable AL0432
        addlast(navigation)
#pragma warning restore AL0432
        {
            group("Posting Group CZL")
            {
                Caption = '&Posting Group (Obsolete)';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Replaced by Posting Group group.';

                action("Substitutions CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Substitutions (Obsolete)';
                    Image = Relationship;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = page "Subst. Vend. Post. Groups CZL";
                    RunPageLink = "Parent Vendor Posting Group" = field(Code);
                    ToolTip = 'View or edit the related vendor posting group substitutions.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';
                    ObsoleteReason = 'Replaced by Alternative action.';
                }
            }
        }
    }
}
#endif
