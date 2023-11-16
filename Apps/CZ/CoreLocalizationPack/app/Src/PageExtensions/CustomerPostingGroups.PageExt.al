// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Sales.Customer;

pageextension 31011 "Customer Posting Groups CZL" extends "Customer Posting Groups"
{
    ObsoleteState = Pending;
#pragma warning disable AS0072
    ObsoleteTag = '22.0';
#pragma warning restore AS0072
    ObsoleteReason = 'All fields from this pageextension are obsolete.';

    actions
    {
#pragma warning disable AL0432
        addlast(Navigation)
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
                    RunObject = page "Subst. Cust. Post. Groups CZL";
                    RunPageLink = "Parent Customer Posting Group" = field(Code);
                    ToolTip = 'View or edit the related customer posting group substitutions.';
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
