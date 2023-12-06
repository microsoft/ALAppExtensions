// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Sales.Customer;

page 31027 "Subst. Cust. Post. Groups CZL"
{
    Caption = 'Subst. Customer Posting Groups';
    DataCaptionFields = "Parent Customer Posting Group";
    PageType = List;
    SourceTable = "Subst. Cust. Posting Group CZL";
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Replaced by Alt. Customer Posting Groups page.';

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the customer''s market type to link business transactions to.';
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
