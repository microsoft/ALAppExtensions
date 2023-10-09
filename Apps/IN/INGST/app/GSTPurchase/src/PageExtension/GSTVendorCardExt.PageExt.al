// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

pageextension 18092 "GST Vendor Card Ext" extends "Vendor Card"
{
    layout
    {
        addlast(General)
        {
            field(Transporter; Rec.Transporter)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the vendor as Transporter';
            }
        }
        addlast("Tax Information")
        {
            group("GST")
            {
                field("Govt. Undertaking"; Rec."Govt. Undertaking")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor as Government authorized body.';
                }
                field("GST Registration No."; Rec."GST Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendors GST registration number issued by authorized body.';
                }
                field("GST vendor Type"; Rec."GST vendor Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of GST registration or the vendor. For example, Registered/Un-registered/Import/Composite/Exempted/SEZ.';
                }
                field("Associated Enterprises"; Rec."Associated Enterprises")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that an import transaction of services from companys Associates Vendor';
                }
                field("Aggregate Turnover"; Rec."Aggregate Turnover")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the vendors aggregate turnover is more than 20 lacs or less than 20 lacs.';
                }
                field("ARN No."; Rec."ARN No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ARN number of the consignee till GST registration number is not assigned to the consignee.';
                }
            }
            group(Subcontractor)
            {
                field(SubcontractorVendor; Rec.Subcontractor)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the vendor is defined as a subcontractor or not.';
                }
                field("Vendor Location"; Rec."Vendor Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code for subcontractor.';
                }
                field("Commissioner's Permission No."; Rec."Commissioner's Permission No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the permission no. of the commissioner';
                }
            }
        }
    }
}
