codeunit 5549 "Create Cue Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()

    begin
        CreateActivitiesCue();
        CreateFinanceCue();
        CreateSalesCue();
        CreateRelationshipManagementCue();
    end;

    procedure CreateActivitiesCue()
    var
        ActivitiesCue: Record "Activities Cue";
        CuesAndKPIs: Codeunit "Cues And KPIs";
    begin
        CuesAndKPIs.InsertData(Database::"Activities Cue", ActivitiesCue.FieldNo("Ongoing Sales Invoices"), Enum::"Cues And KPIs Style"::None, 15, Enum::"Cues And KPIs Style"::Ambiguous, 30, Enum::"Cues And KPIs Style"::Unfavorable);
        CuesAndKPIs.InsertData(Database::"Activities Cue", ActivitiesCue.FieldNo("Ongoing Purchase Invoices"), Enum::"Cues And KPIs Style"::None, 15, Enum::"Cues And KPIs Style"::Ambiguous, 30, Enum::"Cues And KPIs Style"::Unfavorable);
        CuesAndKPIs.InsertData(Database::"Activities Cue", ActivitiesCue.FieldNo("Sales This Month"), Enum::"Cues And KPIs Style"::Ambiguous, 1000, Enum::"Cues And KPIs Style"::None, 100000, Enum::"Cues And KPIs Style"::Favorable);
        CuesAndKPIs.InsertData(Database::"Activities Cue", ActivitiesCue.FieldNo("Top 10 Customer Sales YTD"), Enum::"Cues And KPIs Style"::Favorable, 0.5, Enum::"Cues And KPIs Style"::None, 0.9, Enum::"Cues And KPIs Style"::Unfavorable);
        CuesAndKPIs.InsertData(Database::"Activities Cue", ActivitiesCue.FieldNo("Overdue Purch. Invoice Amount"), Enum::"Cues And KPIs Style"::Favorable, 10000, Enum::"Cues And KPIs Style"::Ambiguous, 100000, Enum::"Cues And KPIs Style"::Unfavorable);
        CuesAndKPIs.InsertData(Database::"Activities Cue", ActivitiesCue.FieldNo("Overdue Sales Invoice Amount"), Enum::"Cues And KPIs Style"::None, 10000, Enum::"Cues And KPIs Style"::Ambiguous, 100000, Enum::"Cues And KPIs Style"::Unfavorable);
        CuesAndKPIs.InsertData(Database::"Activities Cue", ActivitiesCue.FieldNo("Average Collection Days"), Enum::"Cues And KPIs Style"::Favorable, 10, Enum::"Cues And KPIs Style"::None, 30, Enum::"Cues And KPIs Style"::Unfavorable);
        CuesAndKPIs.InsertData(Database::"Activities Cue", ActivitiesCue.FieldNo("Ongoing Sales Quotes"), Enum::"Cues And KPIs Style"::None, 15, Enum::"Cues And KPIs Style"::Ambiguous, 30, Enum::"Cues And KPIs Style"::Unfavorable);
    end;

    procedure CreateFinanceCue()
    var
        FinanceCue: Record "Finance Cue";
        CuesAndKPIs: Codeunit "Cues And KPIs";
    begin
        CuesAndKPIs.InsertData(Database::"Finance Cue", FinanceCue.FieldNo("Overdue Purchase Documents"), Enum::"Cues And KPIs Style"::Favorable, 0, Enum::"Cues And KPIs Style"::None, 1, Enum::"Cues And KPIs Style"::Unfavorable);
        CuesAndKPIs.InsertData(Database::"Finance Cue", FinanceCue.FieldNo("Purchase Documents Due Today"), Enum::"Cues And KPIs Style"::Favorable, 0, Enum::"Cues And KPIs Style"::None, 1, Enum::"Cues And KPIs Style"::Ambiguous);
        CuesAndKPIs.InsertData(Database::"Finance Cue", FinanceCue.FieldNo("Purch. Invoices Due Next Week"), Enum::"Cues And KPIs Style"::Favorable, 0, Enum::"Cues And KPIs Style"::None, 1, Enum::"Cues And KPIs Style"::Ambiguous);
        CuesAndKPIs.InsertData(Database::"Finance Cue", FinanceCue.FieldNo("Purchase Discounts Next Week"), Enum::"Cues And KPIs Style"::Favorable, 0, Enum::"Cues And KPIs Style"::Ambiguous, 1, Enum::"Cues And KPIs Style"::None);
    end;

    local procedure CreateSalesCue()
    var
        SalesCue: Record "Sales Cue";
        CuesAndKPIs: Codeunit "Cues And KPIs";

        SalesCueFields: array[5] of Integer;
        i: Integer;
    begin
        SalesCueFields[1] := SalesCue.FieldNo("Sales Quotes - Open");
        SalesCueFields[2] := SalesCue.FieldNo("Sales Orders - Open");
        SalesCueFields[3] := SalesCue.FieldNo("Ready to Ship");
        SalesCueFields[4] := SalesCue.FieldNo("Sales Return Orders - Open");
        SalesCueFields[5] := SalesCue.FieldNo("Sales Credit Memos - Open");

        for i := 1 to ArrayLen(SalesCueFields) do
            CuesAndKPIs.InsertData(Database::"Sales Cue", SalesCueFields[i], Enum::"Cues And KPIs Style"::None, 15, Enum::"Cues And KPIs Style"::Ambiguous, 20, Enum::"Cues And KPIs Style"::Unfavorable);

        CuesAndKPIs.InsertData(Database::"Sales Cue", SalesCue.FieldNo("Partially Shipped"), Enum::"Cues And KPIs Style"::Favorable, 1, Enum::"Cues And KPIs Style"::Ambiguous, 20, Enum::"Cues And KPIs Style"::Unfavorable);
        CuesAndKPIs.InsertData(Database::"Sales Cue", SalesCue.FieldNo(Delayed), Enum::"Cues And KPIs Style"::Favorable, 1, Enum::"Cues And KPIs Style"::Ambiguous, 20, Enum::"Cues And KPIs Style"::Unfavorable);
        CuesAndKPIs.InsertData(Database::"Sales Cue", SalesCue.FieldNo("Average Days Delayed"), Enum::"Cues And KPIs Style"::Favorable, 3, Enum::"Cues And KPIs Style"::None, 7, Enum::"Cues And KPIs Style"::Unfavorable);
    end;

    local procedure CreateRelationshipManagementCue()
    var
        RelationshipMgmtCue: Record "Relationship Mgmt. Cue";
        CuesAndKPIs: Codeunit "Cues And KPIs";
    begin
        CuesAndKPIs.InsertData(Database::"Relationship Mgmt. Cue", RelationshipMgmtCue.FieldNo("Contacts - Duplicates"), Enum::"Cues And KPIs Style"::None, 0, Enum::"Cues And KPIs Style"::None, 1, Enum::"Cues And KPIs Style"::Unfavorable);
    end;
}