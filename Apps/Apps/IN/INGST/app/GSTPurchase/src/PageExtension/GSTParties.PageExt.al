// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

pageextension 18099 "GST Parties" extends Parties
{
    layout
    {
        addafter(Address)
        {
            field("Address 2"; Rec."Address 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the additional address information.';
            }
            field(State; Rec.State)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Parties state code. This state code will appear on all documents for the party.';
            }
            field("Post Code"; Rec."Post Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Parties postal code.';
            }
            field("P.A.N. No."; Rec."P.A.N. No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Permanent Account Number of the Party.';
            }
            field("P.A.N. Reference No."; Rec."P.A.N. Reference No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the PAN reference number in case the PAN is not available or applied by the party.';
            }
            field("P.A.N. Status"; Rec."P.A.N. Status")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the PAN status.';
            }
            field("GST Party Type"; Rec."GST Party Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the party type. For example, Vendor/Customer.';
            }
            field("GST Vendor Type"; Rec."GST Vendor Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the type of the vendor. For example, Registered, Unregistered, Import, Exempted, SEZ etc.';
            }
            field("Associated Enterprises"; Rec."Associated Enterprises")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if party is an associated enterprise';
            }
            field("GST Registration Type"; Rec."GST Registration Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the GST registration type. For example, GSTIN,UID,GID.';
            }
            field("GST Customer Type"; Rec."GST Customer Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the type of the customer. For example, Registered, Unregistered, Export etc.';
            }
            field("GST Registration No."; Rec."GST Registration No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Parties goods and service tax registration number issued by authorized body.';
            }
            field("ARN No."; Rec."ARN No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the ARN number in case goods and service tax registration number is not available or applied by the party.';
            }
        }
    }
}
