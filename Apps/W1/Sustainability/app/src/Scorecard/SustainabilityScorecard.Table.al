namespace Microsoft.Sustainability.Scorecard;

using System.Security.User;

table 6218 "Sustainability Scorecard"
{
    DataClassification = CustomerContent;
    LookupPageId = "Sustainability Scorecards";
    DrillDownPageId = "Sustainability Scorecards";
    Caption = 'Sustainability Scorecard';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; "Name"; Text[100])
        {
            Caption = 'Name';
        }
        field(3; "Owner"; Code[50])
        {
            Caption = 'Owner';
            TableRelation = "User Setup"."User ID" where("Sustainability Manager" = const(true));
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    var
        CanDeleteScorecardQst: Label 'Deleting Scorecard No. : %1 will also delete associated Goals. Do you want to continue ?', Comment = '%1 - Scorecard No.';

    trigger OnDelete()
    var
        SustainabilityGoal: Record "Sustainability Goal";
        CanDelete: Boolean;
    begin
        CanDelete := true;

        if GuiAllowed() then
            CanDelete := Confirm(StrSubstNo(CanDeleteScorecardQst, Rec."No."));

        if CanDelete then begin
            SustainabilityGoal.SetRange("Scorecard No.", Rec."No.");
            if not SustainabilityGoal.IsEmpty() then
                SustainabilityGoal.DeleteAll(true);
        end else
            Error('');
    end;
}