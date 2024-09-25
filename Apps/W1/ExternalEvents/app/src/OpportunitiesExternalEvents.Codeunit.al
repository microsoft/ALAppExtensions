namespace Microsoft.Integration.ExternalEvents;

using System.Integration;
using Microsoft.Sales.Document;
using Microsoft.CRM.Opportunity;

codeunit 38506 "Opportunities External Events"
{
    var
        ExternalEventsHelper: Codeunit "External Events Helper";
        EventCategory: Enum EventCategory;

    [EventSubscriber(ObjectType::Table, Database::Opportunity, 'OnCreateQuoteOnBeforePageRun', '', true, true)]
    local procedure OnCreateQuote(var SalesHeader: Record "Sales Header"; var Opportunity: Record Opportunity)
    var
        Url: Text[250];
        WebClientUrl: Text[250];
        OpportunitiesApiUrlTok: Label 'v2.0/companies(%1)/opportunities(%2)', Locked = true;
    begin
        Url := ExternalEventsHelper.CreateLink(CopyStr(OpportunitiesApiUrlTok, 1, 250), Opportunity.SystemId);
        WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Opportunity Card", Opportunity), 1, MaxStrLen(WebClientUrl));
        OpportunityQuoted(Opportunity.SystemId, SalesHeader.SystemId, Url, WebClientUrl);
    end;

    [ExternalBusinessEvent('OpportunityQuoted', 'Quote created for opportunity', 'This business event is triggered when a quote is created for an opportunity as part of the Quote to Cash process.', EventCategory::Opportunities, '1.0')]
    local procedure OpportunityQuoted(OpportunityId: Guid; SalesQuoteId: Guid; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnAfterMoveWonLostOpportunity', '', true, true)]
    local procedure OnAfterMoveWonLostOpportunity(var SalesQuoteHeader: Record "Sales Header"; var SalesOrderHeader: Record "Sales Header"; var Opportunity: Record Opportunity)
    var
        Url: Text[250];
        WebClientUrl: Text[250];
        OpportunitiesApiUrlTok: Label 'v2.0/companies(%1)/opportunities(%2)', Locked = true;
    begin
        Url := ExternalEventsHelper.CreateLink(CopyStr(OpportunitiesApiUrlTok, 1, 250), Opportunity.SystemId);
        WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Opportunity Card", Opportunity), 1, MaxStrLen(WebClientUrl));
        case Opportunity.Status of
            Opportunity.Status::Won:
                    OpportunityWon(Opportunity.SystemId, Opportunity.Status, Url, WebClientUrl);
            Opportunity.Status::Lost:
                    OpportunityLost(Opportunity.SystemId, Opportunity.Status, Url, WebClientUrl);
        end;
    end;

    [ExternalBusinessEvent('OpportunityWon', 'Winning quote converted into sales order', 'This business event is triggered when a winning quote for an opportunity is converted into a sales order as part of the Quote to Cash process.', EventCategory::Opportunities, '1.0')]
    local procedure OpportunityWon(OpportunityId: Guid; Status: Enum "Opportunity Status"; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;

    [ExternalBusinessEvent('OpportunityLost', 'Opportunity closed as lost', 'This business event is triggered when a lost opportunity is closed as part of the Quote to Cash process.', EventCategory::Opportunities, '1.0')]
    local procedure OpportunityLost(OpportunityId: Guid; Status: Enum "Opportunity Status"; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Opportunity, 'OnAfterStartActivateFirstStage', '', true, true)]
    local procedure OnAfterStartActivateFirstStage(SalesCycleStage: Record "Sales Cycle Stage"; var OpportunityEntry: Record "Opportunity Entry")
    var
        Opportunity: Record Opportunity;
        Url: Text[250];
        WebClientUrl: Text[250];
        OpportunitiesApiUrlTok: Label 'v2.0/companies(%1)/opportunities(%2)', Locked = true;
    begin
        if not Opportunity.get(OpportunityEntry."Opportunity No.") then
            exit;
        Url := ExternalEventsHelper.CreateLink(CopyStr(OpportunitiesApiUrlTok, 1, 250), Opportunity.SystemId);
        WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Opportunity Card", Opportunity), 1, MaxStrLen(WebClientUrl));
        OpportunityActivated(Opportunity.SystemId, Url, WebClientUrl);
    end;

    [ExternalBusinessEvent('OpportunityActivated', 'Opportunity activated', 'This business event is triggered when an opportunity is activated as part of the Quote to Cash process.', EventCategory::Opportunities, '1.0')]
    local procedure OpportunityActivated(OpportunityId: Guid; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;
}