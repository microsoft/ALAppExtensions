// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Foundation.Shipping;

pageextension 31065 "Shipment Methods CZL" extends "Shipment Methods"
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    layout
    {
        addafter(Description)
        {
            field("Intrastat Deliv. Grp. Code CZL"; Rec."Intrastat Deliv. Grp. Code CZL")
            {
                ApplicationArea = Suite;
                Caption = 'Intrastat Delivery Group Code (Obsolete)';
                ToolTip = 'Specifies the Intrastat Delivery Group Code.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
            field("Incl. Item Charges (S.Val) CZL"; Rec."Incl. Item Charges (S.Val) CZL")
            {
                ApplicationArea = Suite;
                Caption = 'Incl. Item Charges (Stat.Val.) (Obsolete)';
                ToolTip = 'Specifies whether additional cost of the item should be included in the Intrastat statistical value.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
            field("Adjustment % CZL"; Rec."Adjustment % CZL")
            {
                ApplicationArea = Suite;
                Caption = 'Adjustment % (Obsolete)';
                ToolTip = 'Specifies the adjustment percentage for the shipment method. This percentage is used to calculate an adjustment value for the Intrastat journal.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
            field("Incl. Item Charges (Amt.) CZL"; Rec."Incl. Item Charges (Amt.) CZL")
            {
                ApplicationArea = Suite;
                Caption = 'Include Item Charges (Amount) (Obsolete)';
                ToolTip = 'Specifies whether additional cost of the item should be included in the Intrastat amount.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
        }
    }
}
#endif
