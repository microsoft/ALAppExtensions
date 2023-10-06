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
#if not CLEAN23
        OpportunityQuoted(Opportunity.SystemId, SalesHeader.SystemId, Url);
#endif
        OpportunityQuoted(Opportunity.SystemId, SalesHeader.SystemId, Url, WebClientUrl);
    end;

#if not CLEAN23
    [Obsolete('This event is obsolete. Use version 1.0 instead.', '23.0')]
    [ExternalBusinessEvent('OpportunityQuoted', 'Quote created for opportunity', 'This business event is triggered when a quote is created for an opportunity as part of the Quote to Cash process.', EventCategory::Opportunities)]
    local procedure OpportunityQuoted(OpportunitiesId: Guid; SalesQuoteId: Guid; Url: Text[250])
    begin
    end;
#endif

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
#if not CLEAN23
                begin
                    OpportunityWon(Opportunity.SystemId, Opportunity.Status, Url);
                    OpportunityWon(Opportunity.SystemId, Opportunity.Status, Url, WebClientUrl);
                end;
#else
                    OpportunityWon(Opportunity.SystemId, Opportunity.Status, Url, WebClientUrl);
#endif
            Opportunity.Status::Lost:
#if not CLEAN23
                begin
                    OpportunityLost(Opportunity.SystemId, Opportunity.Status, Url);
                    OpportunityLost(Opportunity.SystemId, Opportunity.Status, Url, WebClientUrl);
                end;
#else
                    OpportunityLost(Opportunity.SystemId, Opportunity.Status, Url, WebClientUrl);
#endif
        end;
    end;

#if not CLEAN23
    [Obsolete('This event is obsolete. Use version 1.0 instead.', '23.0')]
    [ExternalBusinessEvent('OpportunityWon', 'Winning quote converted into sales order', 'This business event is triggered when a winning quote for an opportunity is converted into a sales order as part of the Quote to Cash process.', EventCategory::Opportunities)]
    local procedure OpportunityWon(OpportunitiesId: Guid; Status: Enum "Opportunity Status"; Url: Text[250])
    begin
    end;

    [Obsolete('This event is obsolete. Use version 1.0 instead.', '23.0')]
    [ExternalBusinessEvent('OpportunityLost', 'Opportunity closed as lost', 'This business event is triggered when a lost opportunity is closed as part of the Quote to Cash process.', EventCategory::Opportunities)]
    local procedure OpportunityLost(OpportunitiesId: Guid; Status: Enum "Opportunity Status"; Url: Text[250])
    begin
    end;
#endif

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
#if not CLEAN23
        OpportunityActivated(Opportunity.SystemId, Url);
#endif
        OpportunityActivated(Opportunity.SystemId, Url, WebClientUrl);
    end;

#if not CLEAN23
    [Obsolete('This event is obsolete. Use version 1.0 instead.', '23.0')]
    [ExternalBusinessEvent('OpportunityActivated', 'Opportunity activated', 'This business event is triggered when an opportunity is activated as part of the Quote to Cash process.', EventCategory::Opportunities)]
    local procedure OpportunityActivated(OpportunitiesId: Guid; Url: Text[250])
    begin
    end;
#endif

    [ExternalBusinessEvent('OpportunityActivated', 'Opportunity activated', 'This business event is triggered when an opportunity is activated as part of the Quote to Cash process.', EventCategory::Opportunities, '1.0')]
    local procedure OpportunityActivated(OpportunityId: Guid; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;
}