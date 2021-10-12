page 20361 "Tax Type Archival Log Entries"
{
    Caption = 'Tax Type Archival Log Entries';
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Tax Type Archival Log Entry";
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = true;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(Group1)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the Entry No. of the log entry.';
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the Description of the use case.';
                    ApplicationArea = Basic, Suite;
                }
                field(Version; VersionTxt)
                {
                    ToolTip = 'Specifies the version of the Tax Type.';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Log Date-Time"; Rec."Log Date-Time")
                {
                    ToolTip = 'Specifies the log Date-Time of archival.';
                    ApplicationArea = Basic, Suite;
                }
                field("Active Version"; Rec."Active Version")
                {
                    ToolTip = 'Specifies whether this version of use case is active or not.';
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Changed by"; Rec."Changed by")
                {
                    ToolTip = 'Specifies whether use case was changed by Partner or Microsoft.';
                    ApplicationArea = Basic, Suite;
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the USERID who has released the use case.';
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ShowTaxTypeAsJson)
            {
                Caption = 'Show Configuration File.';
                ApplicationArea = Basic, Suite;
                Image = ShowSelected;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Downloads the configuration file in the form of Json.';
                trigger OnAction();
                var
                    TaxTypeArchivalMgmt: Codeunit "Tax Type Archival Mgmt.";
                begin
                    TaxTypeArchivalMgmt.ShowConfigurationFile(Rec);
                end;
            }
            action(RestoreTaxType)
            {
                Caption = 'Restore this version.';
                ApplicationArea = Basic, Suite;
                Image = Restore;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Restore this version as a active Tax Type.';
                trigger OnAction();
                var
                    TaxTypeArchivalMgmt: Codeunit "Tax Type Archival Mgmt.";
                begin
                    TaxTypeArchivalMgmt.RestoreArchivalToUse(Rec);
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        UpdateVersion();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateVersion();
    end;

    local procedure UpdateVersion()
    begin
        if Rec."Tax Type" = '' then
            VersionTxt := ''
        else
            VersionTxt := StrSubstNo(VersionLbl, "Major Version", "Minor Version");
    end;

    var
        VersionLbl: Label '%1.%2', Comment = '%1 - Major Version, %2 - Minor Version';
        VersionTxt: Text;
}