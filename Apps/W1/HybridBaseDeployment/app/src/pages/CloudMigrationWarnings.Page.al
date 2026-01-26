namespace Microsoft.DataMigration;

page 40035 "Cloud Migration Warnings"
{
    PageType = List;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Cloud Migration Warning";
    SourceTableView = sorting(SystemModifiedAt) order(descending);
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                Caption = 'Migration warnings';
                Editable = false;

                field(Description; Rec.Message) { }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'Warning Date';
                    ToolTip = 'Specifies the date when the warning was created.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(FixWarning)
            {
                ApplicationArea = All;
                Caption = 'How to fix this warning';
                ToolTip = 'Learn more about this warning and how to fix it.';
                Image = Warning;

                trigger OnAction()
                var
                    ICloudMigrationWarning: Interface "Cloud Migration Warning";
                begin
                    ICloudMigrationWarning := Rec."Warning Type";
                    ICloudMigrationWarning.FixWarning();
                end;
            }
            action(IgnoreWarning)
            {
                ApplicationArea = All;
                Caption = 'Ignore';
                ToolTip = 'Ignore this warning and continue with the migration.';
                Image = Delete;

                trigger OnAction()
                begin
                    Rec.Ignored := true;
                    Rec.Modify();
                    CurrPage.Update();
                end;
            }
        }
        area(Promoted)
        {
            actionref(FixWarning_Promoted; FixWarning)
            {
            }
            actionref(IgnoreWarning_Promoted; IgnoreWarning)
            {
            }
        }
    }

    trigger OnOpenPage()
    var
        ICloudMigrationWarning: Interface "Cloud Migration Warning";
        CloudMigrationWarningType: Enum "Cloud Migration Warning Type";
        WarningImplementations: List of [Integer];
        WarningImplementation: Integer;
        FilterTxt: Text;
        RecFilter: Text;
    begin
        WarningImplementations := CloudMigrationWarningType.Ordinals();
        foreach WarningImplementation in WarningImplementations do begin
            ICloudMigrationWarning := "Cloud Migration Warning Type".FromInteger(WarningImplementation);
            FilterTxt := ICloudMigrationWarning.ShowWarning(Rec);
            if FilterTxt <> '' then
                RecFilter := RecFilter + FilterTxt + '|';
        end;
        RecFilter := RecFilter.TrimEnd('|');
        if RecFilter = '' then
            RecFilter := '0'; // No warnings found, set filter to something that yields no results.
        Rec.SetFilter("Entry No.", RecFilter);
        Rec.SetRange(Ignored, false);
    end;
}