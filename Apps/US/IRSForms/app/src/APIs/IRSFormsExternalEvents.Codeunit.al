// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Integration.ExternalEvents;
using System.Integration;

codeunit 10043 "IRS Forms External Events"
{

    [EventSubscriber(ObjectType::Table, Database::"IRS 1099 Form Doc. Header", 'OnAfterValidateEvent', 'Status', true, true)]
    local procedure RaiseExternalEventsOnOnAfterValidateStatus(Rec: Record "IRS 1099 Form Doc. Header")
    var
        ExternalEventsHelper: Codeunit "External Events Helper";
        APIId: Guid;
        Url: Text[250];
        WebClientUrl: Text[250];
        IRS1099FormDocApiUrlTok: Label 'v1.0/companies(%1)/irs1099documents(%2)', Locked = true;
    begin
        if Rec.IsTemporary then
            exit;
        APIId := Rec.SystemId;
        Url := ExternalEventsHelper.CreateLink(CopyStr(IRS1099FormDocApiUrlTok, 1, 250), APIId);
        WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"IRS 1099 Form Document", Rec), 1, MaxStrLen(WebClientUrl));
        IRS1099FormDocStatusChanged(APIId, Url, WebClientUrl);
    end;

    [ExternalBusinessEvent('IRS1099FormDocStatusChanged', 'Status of IRS 1099 form document is changed', 'This business event is triggered when a status of the IRS 1099 form document is changed.', EventCategory::"Accounts Payable", '1.0')]
    procedure IRS1099FormDocStatusChanged(IRS1099FormDocAPIId: Guid; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;
}