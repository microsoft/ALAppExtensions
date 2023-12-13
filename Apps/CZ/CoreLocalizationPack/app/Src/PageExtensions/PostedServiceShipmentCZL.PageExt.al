// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.History;

pageextension 11770 "Posted Service Shipment CZL" extends "Posted Service Shipment"
{
    layout
    {
        addlast(General)
        {
            field("Customer Posting Group CZL"; Rec."Customer Posting Group")
            {
                ApplicationArea = Service;
                Editable = false;
                ToolTip = 'Specifies the customer''s market type to link business transakcions to.';
            }
            field("Posting Description CZL"; Rec."Posting Description")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies a description of the document. The posting description also appers on customer and G/L entries.';
                Visible = false;
            }
        }
        addafter("EU 3-Party Trade")
        {
            field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
            {
                ApplicationArea = Service;
                Editable = false;
                ToolTip = 'Specifies when the service header will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
            }
#if not CLEAN22
            field("Intrastat Exclude CZL"; Rec."Intrastat Exclude CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Exclude (Obsolete)';
                Editable = false;
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
            }
#endif
        }
#if not CLEAN22
        addafter("EU 3-Party Trade")
        {
            field("Physical Transfer CZL"; Rec."Physical Transfer CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Physical Transfer (Obsolete)';
                ToolTip = 'Specifies if there is physical transfer of the item.';
                Editable = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
        }
#endif
    }
}
