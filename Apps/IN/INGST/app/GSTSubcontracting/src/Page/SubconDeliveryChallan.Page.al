// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

page 18490 "Subcon. Delivery Challan"
{
    Caption = 'Subcon. Delivery Challan';
    PageType = Document;
    SourceTable = "Subcontractor Delivery Challan";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the delivery challan number.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the document.';
                }
                field("Subcontractor No."; Rec."Subcontractor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting vendor number.';
                }
                field("Vendor Location"; Rec."Vendor Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor location for the document.';
                }
                field("From Location"; Rec."From Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source location code for the document.';
                }
            }
            part(subcondc; "Subcon. DC Subform")
            {
                SubPageLink = "Document No." = field("No.");
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Send Raw Material")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Send Raw Material';
                ToolTip = 'Send Raw Material';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    SubcontractingPost: Codeunit "Subcontracting Post";
                begin
                    SubcontractingPost.SendFromDC(Rec);
                end;
            }
        }
    }
}
