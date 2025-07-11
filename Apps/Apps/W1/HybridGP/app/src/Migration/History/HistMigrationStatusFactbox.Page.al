namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration.GP.HistoricalData;

page 4101 "Hist. Migration Status Factbox"
{
    Caption = 'GP Detail Snapshot Migration Status';
    PageType = CardPart;
    SourceTable = "Hist. Migration Current Status";
    InsertAllowed = false;
    DelayedInsert = false;
    ModifyAllowed = false;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(Main)
            {
                ShowCaption = false;

                field("Current Step"; Rec."Current Step")
                {
                    Caption = 'Current Step';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Current Step field.';
                }
            }

            group(CueGroup1)
            {
                ShowCaption = false;

                cuegroup(Statistics)
                {
                    ShowCaption = false;

                    field("Error Count"; ErrorCount)
                    {
                        Caption = 'GP Detail Snapshot Errors';
                        ApplicationArea = All;
                        Style = Unfavorable;
                        StyleExpr = (ErrorCount > 0);
                        ToolTip = 'Indicates the number of historical snapshot errors that occurred during the GP Detail Snapshot migration.';

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"Hist. Migration Errors");
                        end;
                    }
                    field("Log Count"; Rec."Log Count")
                    {
                        Caption = 'GP Detail Snapshot Log Entries';
                        ApplicationArea = All;
                        ToolTip = 'Indicates the number of historical snapshot log entries that have been logged during the GP Detail Snapshot migration.';

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"Hist. Migration Step Status");
                        end;
                    }
                }
            }
        }
    }

    trigger OnInit()
    begin
        if Rec.IsEmpty() then begin
            Rec."Current Step" := "Hist. Migration Step Type"::"Not Started";
            Rec.Insert();
        end;
    end;

    trigger OnAfterGetCurrRecord()
    var
        GPHistSourceError: Record "GP Hist. Source Error";
    begin
        ErrorCount := GPHistSourceError.Count();
    end;

    var
        ErrorCount: Integer;
}