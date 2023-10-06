// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

page 18476 "Multiple Order Subcon Delivery"
{
    Caption = 'Multiple Order Subcon Delivery';
    PageType = Document;
    SourceTable = "Multiple Subcon. Order Details";
    SourceTableView = sorting("No.") order(Ascending) where("No." = filter(<> ''));

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
                    ToolTip = 'Specifies the multiple order subcon delivery number.';
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Subcontractor No."; Rec."Subcontractor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontractor number.';

                    trigger OnValidate()
                    begin
                        SubcontractorNoOnAfterValidate();
                    end;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the entry.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document date of the entry.';
                }
            }
            part(PurchLinesSubcontracting; "Purchase Lines Subcontracting")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Document Type" = const(Order),
                              "Buy-from Vendor No." = field("Subcontractor No."),
                              Subcontracting = const(true);
                SubPageView = sorting("Document Type", "Document No.", "Line No.");
            }
        }
    }
    actions
    {
        area(navigation)
        {
            group("Multiple Order Subcon Details")
            {
                Caption = 'Multiple Order Subcon Details';
                Image = View;
                action(List)
                {
                    Caption = 'List';
                    ToolTip = 'List View';
                    Image = OpportunitiesList;
                    RunObject = Page "Multiple Order Subcon Det List";
                    ShortCutKey = 'Shift+Ctrl+L';
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(processing)
        {
            action("&Send")
            {
                Caption = '&Send';
                ToolTip = 'Send';
                Image = SendTo;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"Subcontracting Post Batch", Rec);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CurrPage.PurchLinesSubcontracting.page.SetSubconAppliesToID(Rec."No.");
    end;

    local procedure SubcontractorNoOnAfterValidate()
    begin
        CurrPage.Update();
    end;
}
