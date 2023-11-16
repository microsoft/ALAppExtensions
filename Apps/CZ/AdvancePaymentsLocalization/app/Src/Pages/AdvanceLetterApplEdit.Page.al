// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

page 31175 "Advance Letter Appl. Edit CZZ"
{
    Caption = 'Advance Letter Application';
    PageType = List;
    SourceTable = "Advance Letter Application CZZ";
    SourceTableTemporary = true;
    UsageCategory = None;
    LinksAllowed = false;

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
                    NotBlank = true;

                    trigger OnValidate()
                    begin
                        if Rec."Advance Letter No." <> '' then begin
                            TempAdvanceLetterApplication.Get(Rec."Advance Letter Type", Rec."Advance Letter No.", Rec."Document Type", Rec."Document No.");
                            Rec."Advance Letter Type" := TempAdvanceLetterApplication."Advance Letter Type";
                            Rec."Advance Letter No." := TempAdvanceLetterApplication."Advance Letter No.";
                            Rec."Document Type" := TempAdvanceLetterApplication."Document Type";
                            Rec."Document No." := TempAdvanceLetterApplication."Document No.";
                            Rec."Posting Date" := TempAdvanceLetterApplication."Posting Date";
                            Rec.Amount := TempAdvanceLetterApplication.Amount;
                            Rec."Amount (LCY)" := TempAdvanceLetterApplication."Amount (LCY)";
                        end
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if Page.RunModal(Page::"Advance Letter Application CZZ", TempAdvanceLetterApplication) = Action::LookupOK then begin
                            Rec."Advance Letter Type" := TempAdvanceLetterApplication."Advance Letter Type";
                            Rec."Advance Letter No." := TempAdvanceLetterApplication."Advance Letter No.";
                            Rec."Document Type" := TempAdvanceLetterApplication."Document Type";
                            Rec."Document No." := TempAdvanceLetterApplication."Document No.";
                            Rec."Posting Date" := TempAdvanceLetterApplication."Posting Date";
                            Rec.Amount := TempAdvanceLetterApplication.Amount;
                            Rec."Amount (LCY)" := TempAdvanceLetterApplication."Amount (LCY)";
                        end;
                    end;
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

                    trigger OnValidate()
                    begin
                        TempAdvanceLetterApplication.Get(Rec."Advance Letter Type", Rec."Advance Letter No.", Rec."Document Type", Rec."Document No.");
                        if Rec.Amount > TempAdvanceLetterApplication.Amount then
                            Error(AmountExceededErr, TempAdvanceLetterApplication.Amount);
                    end;
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

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Advance Letter Type" := AdvLetterType;
    end;

    var
        TempAdvanceLetterApplication: Record "Advance Letter Application CZZ" temporary;
        AdvLetterType: Enum "Advance Letter Type CZZ";
        AmountExceededErr: Label 'Only %1 can be used.', Comment = '%1 = Maximal Amount';

    procedure InitializeSales(NewFromAdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; NewFromDocumentNo: Code[20]; NewBillToCustomerNo: Code[20]; NewPostingDate: Date; NewCurrencyCode: Code[10])
    begin
        AdvLetterType := AdvLetterType::Sales;
        Rec.GetPossibleSalesAdvance(NewFromAdvLetterUsageDocTypeCZZ, NewFromDocumentNo, NewBillToCustomerNo, NewPostingDate, NewCurrencyCode, TempAdvanceLetterApplication);
        Rec.GetAssignedAdvance(NewFromAdvLetterUsageDocTypeCZZ, NewFromDocumentNo, Rec);
    end;

    procedure InitializePurchase(NewFromAdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; NewFromDocumentNo: Code[20]; NewPayToVendorNo: Code[20]; NewPostingDate: Date; NewCurrencyCode: Code[10])
    begin
        AdvLetterType := AdvLetterType::Purchase;
        Rec.GetPossiblePurchAdvance(NewFromAdvLetterUsageDocTypeCZZ, NewFromDocumentNo, NewPayToVendorNo, NewPostingDate, NewCurrencyCode, TempAdvanceLetterApplication);
        Rec.GetAssignedAdvance(NewFromAdvLetterUsageDocTypeCZZ, NewFromDocumentNo, Rec);
    end;

    procedure GetAssignedAdvance(var NewAdvanceLetterApplication: Record "Advance Letter Application CZZ")
    begin
        if Rec.FindSet() then
            repeat
                if Rec.Amount > 0 then begin
                    NewAdvanceLetterApplication := Rec;
                    NewAdvanceLetterApplication.Insert();
                end;
            until Rec.Next() = 0;
    end;
}
