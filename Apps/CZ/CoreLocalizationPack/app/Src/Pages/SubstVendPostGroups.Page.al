// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Purchases.Vendor;

page 31028 "Subst. Vend. Post. Groups CZL"
{
    Caption = 'Subst. Vendor Posting Groups';
    DataCaptionFields = "Parent Vendor Posting Group";
    PageType = List;
    SourceTable = "Subst. Vend. Posting Group CZL";
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Replaced by Alt. Vendor Posting Groups page.';

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Vendor Posting Group"; Rec."Vendor Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor''s market type to link business transactions made for the vendor with the appropriate account in the general ledger.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
}
#endif
