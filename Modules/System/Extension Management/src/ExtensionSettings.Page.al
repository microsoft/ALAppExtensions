// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 2511 "Extension Settings"
{
    Extensible = false;
    DataCaptionExpression = AppName;
    PageType = Card;
    SourceTable = "NAV App Setting";

    layout
    {
        area(content)
        {
            group(Group)
            {
                field(AppId; AppId)
                {
                    ApplicationArea = All;
                    Caption = 'App ID';
                    Editable = false;
                    ToolTip = 'Specifies the App ID of the extension.';
                }
                field(AppName; AppName)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the extension.';
                }
                field(AppPublisher; AppPublisher)
                {
                    ApplicationArea = All;
                    Caption = 'Publisher';
                    Editable = false;
                    ToolTip = 'Specifies the publisher of the extension.';
                }
                field(AllowHttpClientRequests; "Allow HttpClient Requests")
                {
                    ApplicationArea = All;
                    Caption = 'Allow HttpClient Requests';
                    ToolTip = 'Specifies whether the runtime should allow this extension to make HTTP requests through the HttpClient data type when running in a non-production environment.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    var
        NAVApp: Record "NAV App";
    begin
        NAVApp.SetRange(ID, "App ID");

        if NAVApp.FindFirst() then begin
            AppName := NAVApp.Name;
            AppPublisher := NAVApp.Publisher;
            AppId := LowerCase(DelChr(Format(NAVApp.ID), '=', '{}'));
        end
    end;

    trigger OnOpenPage()
    begin
        if GetFilter("App ID") = '' then
            exit;

        "App ID" := GetRangeMin("App ID");
        if not FindFirst() then begin
            Init();
            Insert();
        end;
    end;

    var
        AppName: Text;
        AppPublisher: Text;
        AppId: Text;
}

