// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 2505 "Extension Installation Dialog"
{
    Extensible = false;
    PageType = NavigatePage;
    SourceTable = "NAV App";

    layout
    {
        area(content)
        {
            group(Control7)
            {
                ShowCaption = false;
                Visible = IsVisible;
                fixed(Control3)
                {
                    //The GridLayout property is only supported on controls of type Grid
                    //GridLayout = Columns;
                    ShowCaption = false;
                    Caption = '';
                    part(DetailsPart; "Extension Logo Part")
                    {
                        ApplicationArea = All;
                        Caption = 'Installing Extension';
                        ShowFilter = false;
                        SubPageLink = "Package ID" = FIELD("Package ID");
                        SubPageView = SORTING("Package ID")
                                      ORDER(Ascending);
                    }
                    group(Control4)
                    {
                        ShowCaption = false;
                        label(Control5)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Caption = '';
                        }
                        usercontrol(WebView; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
                        {
                            ApplicationArea = All;

                            trigger ControlAddInReady(callbackUrl: Text)
                            begin
                                InstallExtension(LanguageId);
                            end;

                            trigger DocumentReady()
                            begin
                            end;

                            trigger Callback(data: Text)
                            begin
                            end;

                            trigger Refresh(callbackUrl: Text)
                            begin
                            end;
                        }
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        LanguageId := 1033; // Default to english if unset
        IsVisible := true; // Hack to get the navigation page 'button' to hide properly
    end;

    var
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        LanguageId: Integer;
        RestartActivityInstallMsg: Label 'The extension %1 was successfully installed. All active users must log out and log in again to see the navigation changes.', Comment = 'Indicates that users need to restart their activity to pick up new menusuite items. %1=Name of Extension';
        IsVisible: Boolean;

    local procedure InstallExtension(LangId: Integer)
    begin
        ExtensionInstallationImpl.InstallExtensionSilently("Package ID", LangId);

        // If successfully installed, message users to restart activity for menusuites
        if ExtensionInstallationImpl.IsInstalledByPackageId("Package ID") then
            Message(StrSubstNo(RestartActivityInstallMsg, Name));

        CurrPage.Close();
    end;

    [Scope('OnPrem')]
    procedure SetLanguageId(LangId: Integer)
    begin
        LanguageId := LangId
    end;
}

