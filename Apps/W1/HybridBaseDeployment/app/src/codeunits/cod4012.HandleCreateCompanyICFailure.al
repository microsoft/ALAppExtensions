codeunit 4012 "Handle Create Company Failure"
{

    trigger OnRun()
    var
        ErrorMessage: Text;
    begin
        ErrorMessage := GetLastErrorText();
        UpdateIntelligentCloudSetup(ErrorMessage);
        Error(CompanyCreationFailedErr, ErrorMessage);
    end;

    procedure UpdateIntelligentCloudSetup(ErrorMessage: Text)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if ErrorMessage <> '' then
            if IntelligentCloudSetup.Get() then begin
                IntelligentCloudSetup."Company Creation Task Status" := IntelligentCloudSetup."Company Creation Task Status"::Failed;
                IntelligentCloudSetup."Company Creation Task Error" := CopyStr(ErrorMessage, 1, 250);
                IntelligentCloudSetup.Modify();
                Commit();
            end;
    end;

    var
        CompanyCreationFailedErr: Label 'Failed to create company for the Data Migration setup.\\\\%1', Comment = '%1 - Error message';
}
