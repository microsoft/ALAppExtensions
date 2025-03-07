namespace Microsoft.eServices.EDocument.OrderMatch.Copilot;
using Microsoft.eServices.EDocument.OrderMatch;
using Microsoft.Purchases.Setup;

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
                    Editable = false;
                }
                field(Description; Rec."E-Document Description")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the E-Document line description.';
                    Editable = false;
                    StyleExpr = StyleTxt;
                }
                field("Quantity to Apply"; Rec."Matched Quantity")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the quantity that will be applied to purchase order line.';
                    Editable = false;
                }
                field("AI Proposal"; Rec."AI Proposal")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the action proposed by the AI.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        TempEDocOrderMatches.SetRange("E-Document Line No.", Rec."E-Document Line No.");
                        Page.Run(Page::"E-Doc. Order Match", TempEDocOrderMatches);
                        TempEDocOrderMatches.SetRange("E-Document Line No.");
                    end;
                }
                field("Learn Matching Rule"; Rec."Learn Matching Rule")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies whether a matching rule should be created for this proposal. Item references are created for Items and Text To Account Mappings are created for G/L Accounts.';

                    trigger OnValidate()
                    begin
                        TempEDocOrderMatches.Get(Rec."Document Order No.", Rec."Document Line No.", Rec."E-Document Entry No.", Rec."E-Document Line No.");
                        TempEDocOrderMatches."Learn Matching Rule" := Rec."Learn Matching Rule";
                        TempEDocOrderMatches.Modify();
                    end;
                }
            }
        }
    }

    var
        TempEDocOrderMatches: Record "E-Doc. Order Match" temporary;
        StyleTxt: Text;

    internal procedure GetRecords(var TempEDocOrderMatches2: Record "E-Doc. Order Match" temporary)
    begin
        Clear(TempEDocOrderMatches2);
        if TempEDocOrderMatches.FindSet() then
            repeat
                TempEDocOrderMatches2.TransferFields(TempEDocOrderMatches);
                TempEDocOrderMatches2.Insert();
            until TempEDocOrderMatches.Next() = 0;
    end;

    internal procedure Load(var TempAIProposalBuffer: Record "E-Doc. PO Match Prop. Buffer"; var TempInputEDocOrderMatches: Record "E-Doc. Order Match" temporary)
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        if PurchasesPayablesSetup.Get() then;
        TempAIProposalBuffer.Reset();
        if TempAIProposalBuffer.FindSet() then
            repeat
                Rec.TransferFields(TempAIProposalBuffer);
                Rec."Learn Matching Rule" := PurchasesPayablesSetup."E-Document Learn Copilot Matchings";
                Rec.Insert();
            until TempAIProposalBuffer.Next() = 0;

        if TempInputEDocOrderMatches.FindSet() then
            repeat
                TempEDocOrderMatches := TempInputEDocOrderMatches;
                TempEDocOrderMatches.Insert();
            until TempInputEDocOrderMatches.Next() = 0;
    end;

    trigger OnAfterGetRecord();
    begin
        StyleTxt := Rec.GetStyle();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        TempEDocOrderMatches.SetRange("E-Document Line No.", Rec."E-Document Line No.");
        if TempEDocOrderMatches.FindSet() then
            repeat
                TempEDocOrderMatches.Delete();
            until TempEDocOrderMatches.Next() = 0;
        TempEDocOrderMatches.Reset();
    end;
}