// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Location;

pageextension 18009 "GST Location Card Ext" extends "Location Card"
{
    layout
    {
        addlast("Tax Information")
        {
            field("Subcontracting Location"; Rec."Subcontracting Location")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if location is subcontractor''s location.';
            }
            field("Subcontractor No."; Rec."Subcontractor No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the subcontracting vendor code related to subcontracting location.';
            }
            field("Input Service Distributor"; Rec."Input Service Distributor")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the location is an input service distributor.';
            }
            field("Export or Deemed Export"; Rec."Export or Deemed Export")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the location is related to export or deemed export.';
            }
            field("GST Registration No."; Rec."GST Registration No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the goods and services tax registration number of the location.';
            }
            field("GST Input Service Distributor"; Rec."GST Input Service Distributor")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the location is a GST input service distributor.';
            }
            field("Location ARN No."; Rec."Location ARN No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the ARN number in case goods and service tax registration number is not available with the company.';
            }
            field("Bonded warehouse"; Rec."Bonded warehouse")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if location is defined as a bonded warehouse.';
            }
            field("Trading Location"; Rec."Trading Location")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Spacifies location use as a Trading Location';
            }
            field(Composition; Rec.Composition)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Spacifies location use as a Composition';
            }
            field("Composition Type"; Rec."Composition Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Spacifies the type of Composition';
            }
            field("GST Liability Invoice"; Rec."GST Liability Invoice")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the No. Series for GST liability invoice.';
            }
        }
    }
}
