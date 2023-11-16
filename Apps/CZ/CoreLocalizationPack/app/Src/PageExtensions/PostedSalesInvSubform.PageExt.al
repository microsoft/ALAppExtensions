// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

pageextension 31118 "Posted Sales Inv. Subform CZL" extends "Posted Sales Invoice Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
#if not CLEAN22
            field("Statistic Indication CZL"; Rec."Statistic Indication CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Statistic Indication (Obsolete)';
                ToolTip = 'Specifies the statistic indication code.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
            field("Country/Reg. of Orig. Code CZL"; Rec."Country/Reg. of Orig. Code CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Country/Region of Origin Code (Obsolete)';
                ToolTip = 'Specifies the origin country/region code.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
            }
#endif
        }
    }
}
