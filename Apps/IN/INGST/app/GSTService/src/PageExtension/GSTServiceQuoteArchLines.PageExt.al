// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Archive;

using Microsoft.Finance.TaxEngine.TaxTypeHandler;

pageextension 18469 "GST Service Quote Arch. Lines" extends "Service Quote Archive Lines"
{
    layout
    {
        addfirst(factboxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                ApplicationArea = all;
                SubPageLink = "Table ID Filter" = const(6012),
                "Document Type Filter" = field("Document Type"),
                    "Document No. Filter" = field("Document No."),
                    "Line No. Filter" = field("Line No.");
            }
        }
        addafter("Line Amount")
        {
            field("GST Place Of Supply"; Rec."GST Place Of Supply")
            {
                ApplicationArea = Service;
                Editable = false;
                ToolTip = 'Specifies on which location state code system should consider for GST calculation in case of sale of product or service.';
            }
            field("GST Group Code"; Rec."GST Group Code")
            {
                ApplicationArea = Service;
                Editable = false;
                ToolTip = 'Specifies an identifier for the GST Group  used to calculate and post GST.';

            }
            field("HSN/SAC Code"; Rec."HSN/SAC Code")
            {
                ApplicationArea = Service;
                Editable = false;
                ToolTip = 'Specifies an unique identifier for the type of HSN or SAC that is used to calculate and post GST.';
            }
            field("GST Group Type"; Rec."GST Group Type")
            {
                ApplicationArea = Service;
                Editable = false;
                ToolTip = 'Specifies that the GST Group assigned for goods or service.';
            }
            field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
            {
                ApplicationArea = Service;
                Editable = false;
                Tooltip = 'Specifies the entries related to gst jurisdiction, for example interstate or intrastate.';
            }
            field("Exempted"; Rec."Exempted")
            {
                ApplicationArea = Service;
                Editable = false;
                ToolTip = 'Specifies whether the Service is exempted from GST or not.';
            }
            field("GST On Assessable Value"; Rec."GST On Assessable Value")
            {
                ApplicationArea = Service;
                ToolTip = 'Specifies the assessable value on which GST will be calculated.';
            }
            field("GST Assessable Value (LCY)"; Rec."GST Assessable Value (LCY)")
            {
                ApplicationArea = Service;
                ToolTip = 'Specifies the assessable value in local currency on which GST will be calculated.';
            }
            field("Non-GST Line"; Rec."Non-GST Line")
            {
                ApplicationArea = Service;
                ToolTIp = 'Specifies whether the line item is applicable for GST or not.';
            }
        }
    }
}
