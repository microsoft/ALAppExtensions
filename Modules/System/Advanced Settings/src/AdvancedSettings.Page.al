// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>This page shows all the registered entries in the advanced settings page.</summary>
page 9202 "Advanced Settings"
{
    PageType = NavigatePage;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Advanced Settings';

    layout
    {
        area(Content)
        {
            grid(Header)
            {
                ShowCaption = false;
                GridLayout = Rows;

                grid(SystemLinks)
                {
                    GridLayout = Rows;

                    group(ExtensionsGroup)
                    {
                        InstructionalText = 'Extensions enhance the capabilities of Business Central.';
                        ShowCaption = false;

                        field(Extensions; 'Extensions')
                        {
                            ShowCaption = false;
                            ApplicationArea = All;
                            DrillDown = true;
                            Caption = 'Extensions';
                            ToolTip = 'Open the Extensions management page.';

                            trigger OnDrillDown()
                            begin
                                Page.Run(Page::"Extension Management");
                                CurrPage.Close();
                            end;
                        }
                    }

                    group(ManualSetupGroup)
                    {
                        ShowCaption = false;
                        InstructionalText = 'Overview and manage individual settings and behaviors.';

                        field(ManualSetup; 'Manual Setup')
                        {
                            ShowCaption = false;
                            ApplicationArea = All;
                            DrillDown = true;
                            Caption = 'Manual Setup';
                            ToolTip = 'Open the Manual Setup page.';

                            trigger OnDrillDown()
                            begin
                                Page.Run(Page::"Manual Setup");
                                CurrPage.Close();
                            end;
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Done)
            {
                ApplicationArea = All;
                Caption = 'Done';
                ToolTip = 'Close the page.';
                Image = Close;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }
}