// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

page 31174 "Advance Letter Application CZZ"
{
    Caption = 'Advance Letter Application';
    PageType = List;
    SourceTable = "Advance Letter Application CZZ";
    SourceTableTemporary = true;
    Editable = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Advance Letter No."; Rec."Advance Letter No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies advance letter no.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies posting date.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies amount.';
                    MinValue = 0;
                }
            }
        }
        area(FactBoxes)
        {
            part(SalesAdvLetterFactBox; "Sales Adv. Letter FactBox CZZ")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Advance Letter No.");
                Visible = Rec."Advance Letter Type" = Rec."Advance Letter Type"::Sales;
            }
            part(PurchAdvLetterFactBox; "Purch. Adv. Letter FactBox CZZ")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Advance Letter No.");
                Visible = Rec."Advance Letter Type" = Rec."Advance Letter Type"::Purchase;
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(AdvanceCard)
            {
                Caption = 'Advance Letter';
                ToolTip = 'Show advance letter.';
                ApplicationArea = Basic, Suite;
                Image = "Invoicing-Document";

                trigger OnAction()
                var
                    SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                    PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
                begin
                    if Rec."Advance Letter No." = '' then
                        exit;
                    case Rec."Advance Letter Type" of
                        Rec."Advance Letter Type"::Sales:
                            begin
                                SalesAdvLetterHeaderCZZ.Get(Rec."Advance Letter No.");
                                Page.Run(Page::"Sales Advance Letter CZZ", SalesAdvLetterHeaderCZZ);
                            end;
                        Rec."Advance Letter Type"::Purchase:
                            begin
                                PurchAdvLetterHeaderCZZ.Get(Rec."Advance Letter No.");
                                Page.Run(Page::"Purch. Advance Letter CZZ", PurchAdvLetterHeaderCZZ);
                            end;
                    end;
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(AdvanceCard_Promoted; AdvanceCard)
                {
                }
            }
        }
    }
}
