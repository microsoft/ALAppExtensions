// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using System.Telemetry;

page 5023 "Service Declaration"
{
    PageType = Card;
    SourceTable = "Service Declaration Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the service declaration.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Config. Code"; Rec."Config. Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the configuration code that uses for lines suggestion and file creation.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the starting date of a service declaration.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ending date of a service declaration.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the service declaration.';
                }
                field(Reported; Rec.Reported)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the entry has already been reported to the authorities.';
                }
                field("Export Date"; Rec."Export Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the declaration has been exported.';
                }
                field("Export Time"; Rec."Export Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the time when the declaration has been exported.';
                }
            }
            part(Lines; "Service Declaration Subform")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Service Declaration No." = FIELD("No.");
                SubPageView = SORTING("Service Declaration No.", "Line No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(GetEntries)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Suggest Lines';
                Ellipsis = true;
                Image = SuggestLines;
                ToolTip = 'Suggests transactions to be reported and fills in the journal.';

                trigger OnAction()
                begin
                    Rec.CheckStatusOpen();
                    Rec.SuggestLines();
                end;
            }
            group(Action21)
            {
                Caption = 'Release';
                Image = ReleaseDoc;

                action(Release)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the document to the next stage of processing. You must reopen the document before you can make changes to it.';

                    trigger OnAction()
                    begin
                        ServiceDeclMgt.ReleaseIntrastatReport(Rec);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&open';
                    Enabled = Rec.Status <> Rec.Status::Open;
                    Image = ReOpen;
                    ToolTip = 'Reopen the document to change it after it has been approved. Approved documents have the Released status and must be opened before they can be changed.';

                    trigger OnAction()
                    begin
                        ServiceDeclMgt.ReopenIntrastatReport(Rec);
                    end;
                }
            }
            action(Overview)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Overview';
                Ellipsis = true;
                Image = View;
                Visible = ShowOverview;
                ToolTip = 'Opens the overview with the service declaration lines grouped and summarized as in the exported file. ';

                trigger OnAction()
                var
                    ServiceDeclarationOverview: Page "Service Declaration Overview";
                begin
                    ServiceDeclarationOverview.SetSource(Rec);
                    ServiceDeclarationOverview.Run();
                end;
            }
            action(CreateFile)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Create File';
                Ellipsis = true;
                Image = MakeDiskette;
                ToolTip = 'Create the reporting file.';

                trigger OnAction()
                begin
                    FeatureTelemetry.LogUptake('0000IRF', ServDeclFormTok, Enum::"Feature Uptake Status"::Used);
                    ServiceDeclMgt.ReleaseIntrastatReport(Rec);
                    Rec.CreateFile();
                    FeatureTelemetry.LogUsage('0000IRG', ServDeclFormTok, 'File created');
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(GetEntries_Promoted; GetEntries)
                {
                }
                actionref(Overview_Promoted; Overview)
                {
                }
                actionref(CreateFile_Promoted; CreateFile)
                {
                }
                group(Category_Category5)
                {
                    Caption = 'Release';
                    ShowAs = SplitButton;
                    actionref(Release_Promoted; Release)
                    {
                    }
                    actionref(Reopen_Promoted; Reopen)
                    {
                    }
                }
            }
        }
    }

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ServiceDeclMgt: Codeunit "Service Declaration Mgt.";
        ShowOverview: Boolean;
        ServDeclFormTok: Label 'Service Declaration', Locked = true;

    trigger OnOpenPage()
    var
        ServDeclSetup: Record "Service Declaration Setup";
    begin
        if ServDeclSetup.Get() then;
        ShowOverview := ServDeclSetup."Show Serv. Decl. Overview";
    end;
}

