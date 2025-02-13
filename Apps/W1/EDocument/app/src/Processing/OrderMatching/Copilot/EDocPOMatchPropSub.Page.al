namespace Microsoft.eServices.EDocument.OrderMatch.Copilot;
using Microsoft.eServices.EDocument.OrderMatch;

page 6163 "E-Doc. PO Match Prop. Sub"
{
    Caption = 'Match Proposals';
    PageType = ListPart;
    ApplicationArea = All;
    Extensible = false;
    SourceTable = "E-Doc. PO Match Prop. Buffer";
    SourceTableTemporary = true;
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    InherentPermissions = X;
    InherentEntitlements = X;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("E-Document Line No."; Rec."E-Document Line No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the E-Document line number.';
                }
                field(Description; Rec."E-Document Description")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the E-Document line description.';
                    StyleExpr = StyleTxt;
                }
                field("Quantity to Apply"; Rec."Matched Quantity")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the quantity that will be applied to purchase order line.';
                }
                field("AI Proposal"; Rec."AI Proposal")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the action proposed by the AI.';

                    trigger OnDrillDown()
                    begin
                        TempEdocOrderMatches.SetRange("E-Document Line No.", Rec."E-Document Line No.");
                        Page.Run(Page::"E-Doc. Order Match", TempEdocOrderMatches);
                        TempEdocOrderMatches.SetRange("E-Document Line No.");
                    end;
                }
            }
        }
    }

    var
        TempEdocOrderMatches: Record "E-Doc. Order Match" temporary;
        StyleTxt: Text;

    internal procedure GetRecords(var TempEdocOrderMatches2: Record "E-Doc. Order Match" temporary)
    begin
        Clear(TempEdocOrderMatches2);
        if TempEdocOrderMatches.FindSet() then
            repeat
                TempEdocOrderMatches2.TransferFields(TempEdocOrderMatches);
                TempEdocOrderMatches2.Insert();
            until TempEdocOrderMatches.Next() = 0;
    end;

    internal procedure Load(var TempAIProposalBuffer: Record "E-Doc. PO Match Prop. Buffer"; var TempInputEdocOrderMatches: Record "E-Doc. Order Match" temporary)
    begin
        TempAIProposalBuffer.Reset();
        if TempAIProposalBuffer.FindSet() then
            repeat
                Rec.TransferFields(TempAIProposalBuffer);
                Rec.Insert();
            until TempAIProposalBuffer.Next() = 0;

        if TempInputEdocOrderMatches.FindSet() then
            repeat
                TempEdocOrderMatches := TempInputEdocOrderMatches;
                TempEdocOrderMatches.Insert();
            until TempInputEdocOrderMatches.Next() = 0;
    end;

    trigger OnAfterGetRecord();
    begin
        StyleTxt := Rec.GetStyle();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        TempEdocOrderMatches.SetRange("E-Document Line No.", Rec."E-Document Line No.");
        if TempEdocOrderMatches.FindSet() then
            repeat
                TempEdocOrderMatches.Delete();
            until TempEdocOrderMatches.Next() = 0;
        TempEdocOrderMatches.Reset();
    end;
}