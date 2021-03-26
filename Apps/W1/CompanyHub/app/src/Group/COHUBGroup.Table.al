table 1155 "COHUB Group"
{
    LookupPageId = "COHUB Group List";
    ReplicateData = false;
    DataPerCompany = false;
    Access = Internal;

    fields
    {
        field(1; "Code"; Code[20])
        {
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        COHUBEnviroment: Record "COHUB Enviroment";
    begin
        COHUBEnviroment.SetRange("Group Code", Code);
        if COHUBEnviroment.FindFirst() then begin
            if not Confirm(ConfirmClearGroupCodeFromEnviromentQst) then
                Error('');
            repeat
                COHUBEnviroment."Group Code" := '';
                COHUBEnviroment.Modify();
            until COHUBEnviroment.Next() <= 0;
        end;
    end;

    var
        ConfirmClearGroupCodeFromEnviromentQst: Label 'There are companies assigned to this group. This action will remove the group assignment from the companies and delete the group. Do you want to continue?';

}

