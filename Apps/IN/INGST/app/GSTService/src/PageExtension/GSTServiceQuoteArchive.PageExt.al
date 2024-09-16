// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Archive;

pageextension 18468 "GST Service Quote Archive" extends "Service Quote Archive"
{
    layout
    {
        addafter("Responsibility Center")
        {
            field("GST Reason Type"; Rec."GST Reason Type")
            {
                ApplicationArea = Service;
                ToolTip = 'Specifies the reason of return or credit memo of a posted document where gst is applicable. For example Deficiency in Service/Correction in Invoice etc.';
            }
        }
        addafter(" Foreign Trade")
        {
            group("Tax Information")
            {
                field(Trading; Rec.Trading)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies if trading is applicable for the transaction or not.';
                }
                field("Time of Removal"; Rec."Time of Removal")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the time of removal.';
                }
                field("Mode of Transport"; Rec."Mode of Transport")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the transportation mode e.g. by road, by air etc.';
                }
                field("LR/RR No."; Rec."LR/RR No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the LR/RR No. the service document.';
                }
                field("LR/RR Date"; Rec."LR/RR Date")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the LR/RR Date on the service document.';
                }
            }
        }
        addafter("Tax Information")
        {
            group(GST)
            {
                field("GST Bill-to State Code"; Rec."GST Bill-to State Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the bill-to state code of the customer on the service document.';
                }
                field("GST Ship-to State Code"; Rec."GST Ship-to State Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the ship-to state code of the customer on the service document';
                }
                field("Location State Code"; Rec."Location State Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the sate code mentioned of the location used in the transaction';
                }
                field("Location GST Reg. No."; Rec."Location GST Reg. No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the GST registration number of the Location specified on the service document.';
                }
                field("Customer GST Reg. No."; Rec."Customer GST Reg. No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the GST registration number of the customer specified on the service document.';
                }
                field("Ship-to GST Reg. No."; Rec."Ship-to GST Reg. No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the GST registration number of the shipping address specified on the service document.';
                }
                field("Nature of Supply"; Rec."Nature of Supply")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the nature of GST transaction. For example, B2B/B2C.';
                }
                field("GST Customer Type"; Rec."GST Customer Type")
                {
                    ApplicationArea = Service;
                    Tooltip = 'Specifies the type of the customer. For example, Registered/Unregistered/Export/Exempted/SEZ Unit/SEZ Development etc.';
                }
                field("Invoice Type"; Rec."Invoice Type")
                {
                    ApplicationArea = Service;
                    Tooltip = 'Specifies the invoice type on the service document. For example, Bill of supply, Export, Supplementary, Debit Note, Non-GST and Taxable.';
                }
                field("GST Without Payment of Duty"; Rec."GST Without Payment of Duty")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies whether with or without payment of duty.';
                }
                field("Bill Of Export No."; Rec."Bill Of Export No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the bill of export number. It is a document number which is submitted to custom department .';
                }
                field("Bill Of Export Date"; Rec."Bill Of Export Date")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the entry date defined in bill of export document.';
                }
                field("Reference Invoice No."; Rec."Reference Invoice No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the Reference Invoice number.';
                }
                field("Rate Change Applicable"; Rec."Rate Change Applicable")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies if rate change is applicable on the service document.';
                }
                field("Supply Finish Date"; Rec."Supply Finish Date")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the supply finish date. For example, Before rate change/After rate change.';
                }
                field("Payment Date"; Rec."Payment Date")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the payment date. For example, Before rate change/After rate change.';
                }
                field("GST Inv. Rounding Precision"; Rec."GST Inv. Rounding Precision")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies Rounding Precision on the service document.';
                }
                field("GST Inv. Rounding Type"; Rec."GST Inv. Rounding Type")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies Rounding Type on the service document.';
                }
                field("POS Out Of India"; Rec."POS Out Of India")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies if the place of supply of invoice is out of India.';
                }
            }
        }
    }
}
