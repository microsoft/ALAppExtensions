// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

page 5024 "Service Declaration Subform"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Service Declaration Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the source entry.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type of the source entry.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the source entry.';
                }
                field("Item Charge No."; Rec."Item Charge No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item charge of the source entry.';
                }
                field("Service Transaction Code"; Rec."Service Transaction Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the service transaction code of the source entry.';
                    Visible = EnableServTransType;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the source entry.';
                }
#if not CLEAN22                
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT registration No. of the customer or vendor associated with a source entry.';
                    ObsoleteReason = 'Replaced with VAT Reg. No.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';
                    Visible = false;
                }
#endif
                field("VAT Reg. No."; Rec."VAT Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT registration No. of the customer or vendor associated with a source entry.';
                    Visible = EnableVATRegNo;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code of the source entry.';
                }
                field("Sales Amount (LCY)"; Rec."Sales Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Sales Amount (LCY) of the source entry.';
                }
                field("Purchase Amount (LCY)"; Rec."Purchase Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Purchase Amount (LCY) of the source entry.';
                }
            }
        }
    }

    actions
    {
    }

    var
        ServDeclSetup: Record "Service Declaration Setup";
        EnableVATRegNo: Boolean;
        EnableServTransType: Boolean;

    trigger OnOpenPage()
    var
        ServDeclMgt: Codeunit "Service Declaration Mgt.";
    begin
        ServDeclSetup.Get();
        EnableVATRegNo := ServDeclSetup."Enable VAT Registration No.";
        EnableServTransType := ServDeclMgt.IsServTransTypeEnabled();
    end;
}

