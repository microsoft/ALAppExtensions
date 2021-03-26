codeunit 4012 "Handle Create Company Failure"
{
    trigger OnRun();
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        ErrorMessage: Text;
    begin
        ErrorMessage := GetLastErrorText();
        if ErrorMessage <> '' then
            if IntelligentCloudSetup.Get() then begin
                IntelligentCloudSetup."Company Creation Task Status" := IntelligentCloudSetup."Company Creation Task Status"::Failed;
                IntelligentCloudSetup."Company Creation Task Error" := CopyStr(ErrorMessage, 1, 250);
                IntelligentCloudSetup.Modify();
                Commit();
            end;
        Error(CompanyCreationFailedErr, ErrorMessage);
    end;

    var
        CompanyCreationFailedErr: Label 'Failed to create company for the Data Migration setup.\\\\%1', Comment = '%1 - Error message';
}
