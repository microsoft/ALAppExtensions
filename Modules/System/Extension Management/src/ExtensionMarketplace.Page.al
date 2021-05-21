// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Shows the Extension Marketplace.
/// </summary>
page 2502 "Extension Marketplace"
{
    Caption = 'Extension Marketplace';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Editable = false;

    layout
    {
        area(Content)
        {
            usercontrol(Marketplace; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = Basic, Suite;
                trigger ControlAddInReady(callbackUrl: Text)
                var
                    MarketplaceUrl: Text;
                BEGIN
                    MarketplaceUrl := ExtensionMarketplace.GetMarketplaceEmbeddedUrl();
                    CurrPage.Marketplace.SubscribeToEvent('message', MarketplaceUrl);
                    CurrPage.Marketplace.Navigate(MarketplaceUrl);
                END;

                trigger DocumentReady()
                BEGIN
                END;

                trigger Callback(data: Text);
                BEGIN
                    IF TryGetMsgType(data) THEN
                        PerformAction(MessageType);
                END;

                trigger Refresh(callbackUrl: Text);
                VAR
                    MarketplaceUrl: Text;
                BEGIN
                    MarketplaceUrl := ExtensionMarketplace.GetMarketplaceEmbeddedUrl();
                    CurrPage.Marketplace.SubscribeToEvent('message', MarketplaceUrl);
                    CurrPage.Marketplace.Navigate(MarketplaceUrl);
                END;
            }

        }
    }

    LOCAL PROCEDURE PerformAction(ActionName: Text);
    VAR
        applicationId: Text;
        ActionOption: Option acquireApp;
    BEGIN
        if EVALUATE(ActionOption, ActionName) then
            if ActionOption = ActionOption::acquireApp then begin
                TelemetryUrl := ExtensionMarketplace.GetTelementryUrlFromData(JObject);
                applicationId := ExtensionMarketplace.GetApplicationIdFromData(JObject);
                if NOT ExtensionMarketplace.InstallAppsourceExtension(applicationId, TelemetryUrl) then
                    MESSAGE(GETLASTERRORTEXT);
            end;
    end;

    [TryFunction]
    local procedure TryGetMsgType(data: Text);
    begin
        JObject := JObject.Parse(data);
        MessageType := ExtensionMarketplace.GetMessageType(JObject);
    end;

    var
        ExtensionMarketplace: Codeunit "Extension Marketplace";
        JObject: DotNet JObject;
        MessageType: Text;
        TelemetryUrl: Text;
}

