codeunit 5573 "Contoso Job Queue"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Job Queue Category" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertJobQueueCategory(Name: Code[10]; Description: Text[30])
    var
        JobQueueCategory: Record "Job Queue Category";
        Exists: Boolean;
    begin
        if JobQueueCategory.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        JobQueueCategory.Code := Name;
        JobQueueCategory.Description := Description;

        if Exists then
            JobQueueCategory.Modify(true)
        else
            JobQueueCategory.Insert(true);
    end;
}