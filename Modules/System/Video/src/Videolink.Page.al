// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>This page shows the video playing in Business Central.</summary>
page 1821 "Video Link"
{
    Extensible = false;
    Caption = 'Video link';
    Editable = false;
    PageType = Card;
    ContextSensitiveHelpPage = 'across-videos';

    layout
    {
        area(content)
        {
            group(Control5)
            {
                ShowCaption = false;
            }
            usercontrol(WebPageViewer; WebPageViewer)
            {
                ApplicationArea = All;

                trigger ControlAddInReady(callbackUrl: Text)
                begin
                    CurrPage.WebPageViewer.Navigate(URL);
                end;

                trigger Callback(data: Text)
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        URL: Text;


    internal procedure SetURL(NavigateToURL: Text)
    begin
        URL := NavigateToURL;
    end;
}

