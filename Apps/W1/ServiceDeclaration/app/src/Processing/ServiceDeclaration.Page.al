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
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Suggests Intrastat transactions to be reported and fills in the journal.';

                trigger OnAction()
                begin
                    Rec.SuggestLines();
                end;
            }
            action(Overview)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Overview';
                Ellipsis = true;
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
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
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Create the reporting file.';

                trigger OnAction()
                begin
                    FeatureTelemetry.LogUptake('0000IRF', ServDeclFormTok, Enum::"Feature Uptake Status"::Used);
                    Rec.CreateFile();
                    FeatureTelemetry.LogUsage('0000IRG', ServDeclFormTok, 'File created');
                end;
            }
        }
    }

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ServDeclFormTok: Label 'Service Declaration', Locked = true;
}

