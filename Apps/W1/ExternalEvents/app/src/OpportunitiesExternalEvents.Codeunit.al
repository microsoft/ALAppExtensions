Codeunit 38506 "Opportunities External Events"
{
    var
        ExternalEventsHelper: Codeunit "External Events Helper";
        EventCategory: Enum EventCategory;

    [EventSubscriber(ObjectType::Table, Database::Opportunity, 'OnCreateQuoteOnBeforePageRun', '', true, true)]
    local procedure OnCreateQuote(var SalesHeader: Record "Sales Header"; var Opportunity: Record Opportunity)
    var
        Url: Text[250];
        OpportunitiesApiUrlTok: Label 'v2.0/companies(%1)/opportunities(%2)', Locked = true;
    begin
        Url := ExternalEventsHelper.CreateLink(CopyStr(OpportunitiesApiUrlTok, 1, 250), Opportunity.SystemId);
        OpportunityQuoted(Opportunity.SystemId, SalesHeader.SystemId, Url);
    end;

    [ExternalBusinessEvent('OpportunityQuoted', 'Quote created for opportunity', 'This business event is triggered when a quote is created for an opportunity as part of the Quote to Cash process.', EventCategory::Opportunities)]
    local procedure OpportunityQuoted(OpportunitiesId: Guid; SalesQuoteId: Guid; Url: text[250])
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnAfterMoveWonLostOpportunity', '', true, true)]
    local procedure OnAfterMoveWonLostOpportunity(var SalesQuoteHeader: Record "Sales Header"; var SalesOrderHeader: Record "Sales Header"; var Opportunity: Record Opportunity)
    var
        Url: Text[250];
        OpportunitiesApiUrlTok: Label 'v2.0/companies(%1)/opportunities(%2)', Locked = true;
    begin
        Url := ExternalEventsHelper.CreateLink(CopyStr(OpportunitiesApiUrlTok, 1, 250), Opportunity.SystemId);
        case Opportunity.Status of
            Opportunity.Status::Won:
                OpportunityWon(Opportunity.SystemId, Opportunity.Status, Url);
            Opportunity.Status::Lost:
                OpportunityLost(Opportunity.SystemId, Opportunity.Status, Url);
        end;
    end;

    [ExternalBusinessEvent('OpportunityWon', 'Winning quote converted into sales order', 'This business event is triggered when a winning quote for an opportunity is converted into a sales order as part of the Quote to Cash process.', EventCategory::Opportunities)]
    local procedure OpportunityWon(OpportunitiesId: Guid; Status: Enum "Opportunity Status"; Url: text[250])
    begin
    end;

    [ExternalBusinessEvent('OpportunityLost', 'Opportunity closed as lost', 'This business event is triggered when a lost opportunity is closed as part of the Quote to Cash process.', EventCategory::Opportunities)]
    local procedure OpportunityLost(OpportunitiesId: Guid; Status: Enum "Opportunity Status"; Url: text[250])
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Opportunity, 'OnAfterStartActivateFirstStage', '', true, true)]
    local procedure OnAfterStartActivateFirstStage(SalesCycleStage: Record "Sales Cycle Stage"; var OpportunityEntry: Record "Opportunity Entry")
    var
        Opportunity: Record Opportunity;
        Url: Text[250];
        OpportunitiesApiUrlTok: Label 'v2.0/companies(%1)/opportunities(%2)', Locked = true;
    begin
        if not Opportunity.get(OpportunityEntry."Opportunity No.") then
            exit;
        Url := ExternalEventsHelper.CreateLink(CopyStr(OpportunitiesApiUrlTok, 1, 250), Opportunity.SystemId);
        OpportunityActivated(Opportunity.SystemId, Url);
    end;

    [ExternalBusinessEvent('OpportunityActivated', 'Opportunity activated', 'This business event is triggered when an opportunity is activated as part of the Quote to Cash process.', EventCategory::Opportunities)]
    local procedure OpportunityActivated(OpportunitiesId: Guid; Url: text[250])
    begin
    end;
}