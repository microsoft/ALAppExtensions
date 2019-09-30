// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays the satisfaction survey dialog box.
/// </summary>
page 1433 "Satisfaction Survey"
{
    Extensible = false;
    Caption = ' ';
    Editable = false;
    PageType = Card;

    layout
    {
        area(content)
        {
            usercontrol(SatisfactionSurvey; "Microsoft.Dynamics.Nav.Client.SatisfactionSurvey")
            {
                ApplicationArea = All;

                trigger ControlAddInReady(callbackUrl: Text)
                begin
                    Navigate();
                end;

                trigger Callback(data: Text)
                begin
                    if SatisfactionSurveyImpl.IsCloseCallback(data) then
                        CurrPage.Close();
                end;

                trigger Refresh(CallbackUrl: Text)
                begin
                    Navigate();
                end;
            }
        }
    }

    actions
    {
    }

    var
        SatisfactionSurveyImpl: Codeunit "Satisfaction Survey Impl.";

    local procedure Navigate()
    var
        Url: Text;
    begin
        Url := SatisfactionSurveyImpl.GetRenderUrl();
        if Url = '' then
            exit;
        CurrPage.SatisfactionSurvey.SubscribeToEvent('message', Url);
        CurrPage.SatisfactionSurvey.Navigate(Url);
    end;
}

