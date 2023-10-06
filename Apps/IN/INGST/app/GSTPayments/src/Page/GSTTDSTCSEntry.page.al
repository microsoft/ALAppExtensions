// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

page 18245 "GST TDS/TCS Entry"
{
    Caption = 'GST TDS/TCS Entry';
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "GST TDS/TCS Entry";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of entry, as assigned from the specified number series when the entry was created.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line number as assigned by the system in a predefined incremental series.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entries posting date.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the entry is of TDS or TCS type.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the source type of the entry is Customer, Vendor, Bank or G/L Account.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source number as per defined type in source type.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type that entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s document number.';
                }
                field("Location GST Reg. No."; Rec."Location GST Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number of the location that entry belongs to.';
                }
                field("Location State Code"; Rec."Location State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state code of the location that the entry belongs to.';
                }
                field("Buyer/Seller Reg. No."; Rec."Buyer/Seller Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Customer/Vendor registration number that the entry is posted to.';
                }
                field("Buyer/Seller State Code"; Rec."Buyer/Seller State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Customer/Vendor state code that the entry is posted to.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code for which the entry was posted.';
                }
                field("Place of Supply"; Rec."Place of Supply")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the place of supply for posted entry as defined in sales & receivables setup.';
                }
                field("Location ARN No."; Rec."Location ARN No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ARN number of the location code that the entry was posted to.';
                }
                field("GST Component Code"; Rec."GST Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST component code with which the entry was posted.';
                }
                field("GST TDS/TCS Base Amount (LCY)"; Rec."GST TDS/TCS Base Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST TDS/TCS Base Amount in local currency.';
                }
                field("GST TDS/TCS Amount (LCY)"; Rec."GST TDS/TCS Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST TDS/TCS Amount in local currency.';
                }
                field("GST TDS/TCS %"; Rec."GST TDS/TCS %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST TDS/TCS % for the posted entry.';
                }
                field("GST Jurisdiction"; Rec."GST Jurisdiction")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Jurisdiction for the posted entry.';
                }
                field("Certificate Received"; Rec."Certificate Received")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GST TDS/TCS certificate has been received for the posted entry.';
                }
                field("Certificated Received Date"; Rec."Certificated Received Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which certificate was received for the posted entry.';
                }
                field("Certificate No."; Rec."Certificate No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the received certificate number for the posted entry.';
                }
                field("Payment Document Date"; Rec."Payment Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TDS TCS payment date for the posted entry.';
                }
                field("Payment Document No."; Rec."Payment Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TDS TCS payment document number for the posted entry.';
                }
                field(Paid; Rec.Paid)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the TDS/TCS was paid for the posted entry.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code for the posted entry.';
                }
                field("Currency Factor"; Rec."Currency Factor")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency factor with respect to local currency for the posted entry.';
                }
                field(Reversed; Rec.Reversed)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the posted entry is reversed.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user who created the document.';
                }
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction number of the posted entry.';
                }
                field("Credit Availed"; Rec."Credit Availed")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GST credit has to be availed or not.';
                }
                field("Liable to Pay"; Rec."Liable to Pay")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if GST TDS/TCS is liable to be paid for the posted entry.';
                }
            }
        }
    }
}

