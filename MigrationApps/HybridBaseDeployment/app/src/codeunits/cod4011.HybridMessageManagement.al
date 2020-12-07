codeunit 4011 "Hybrid Message Management"
{
    var
        InitializationCompleteMsg: Label 'Cloud migration setup completed.';
        UpdateCompleteMsg: Label 'Cloud migration update completed.';
        LoginFailedForUserErr: Label 'Login failed for the user specified in the connection string.';
        NoCompaniesSelectedErr: Label 'No companies have been selected for migration.';
        SqlConnectionErr: Label 'Could not connect to the local SQL Server instance.';
        ExtensionRefreshFailureErr: Label 'Some extensions could not be updated and may need to be reinstalled to refresh their data.';
        ExtensionRefreshUnexpectedFailureErr: Label 'Failed to update extensions. You may need to verify and reinstall any missing extensions if needed.';
        ReplicationAlreadyInProgressErr: Label 'Migration skipped as another migration is already in progress.';
        ReplicationNotEnabledErr: Label 'A cloud migration run was triggered but has been halted due to cloud migration being disabled in the system.';
        ChangeTrackingDisabledErr: Label 'Change tracking must be enabled in the source database with a recommended retention period of at least three days.';
        WebhookFailureErr: Label 'Communication with Business Central was unsuccessful. Verify that the cloud migration user (%1) has the correct permissions.', Comment = '%1 - user name';
        ADLConnectionErr: Label 'A connection could not be made to the specified Azure Data Lake Storage account. Please verify the connection information and try again.';
        ADLContainerExistsErr: Label 'The storage container used by the Azure Data Lake migration already exists. To run the migration, you must first delete or rename the existing container.';
        TableDoesnotExistErrorCodeTxt: Label '50004';
        ColumnMappingErr: Label '%1 column could not be mapped: %2', Comment = '%1 - the column name; %2 - the error';
        ColumnMappingPrimaryKeyErr: Label 'Missing in local instance and is a primary key in cloud.';
        ColumnMappingTypeErr: Label 'Incompatible type.';
        ColumnMappingLengthErr: Label 'Incompatible length.';
        UnsupportedVersionErr: Label 'Business Central on-premises must be at least version 15 to use the cloud migration functionality.';
        CopyTableTimeoutErr: Label 'The table copy operation timed out after 24 hours.';

    procedure ResolveMessageCode(MessageCode: Code[10]; InnerMessage: Text) Message: Text
    var
        TempString: Text;
        Position: Integer;
    begin
        if MessageCode = '' then begin
            Position := StrPos(InnerMessage, 'SqlErrorNumber=');
            if Position > 0 then begin
                TempString := CopyStr(InnerMessage, Position + 15);
                Position := StrPos(TempString, ',');
                if Position > 0 then
                    MessageCode := CopyStr(CopyStr(TempString, 1, Position - 1), 1, 10);
            end;
        end;

        OnResolveMessageCode(MessageCode, InnerMessage, Message);
        if Message <> '' then
            exit;

        case MessageCode of
            'INIT':
                Message := InitializationCompleteMsg;
            'UPGRADE':
                Message := UpdateCompleteMsg;
            '50003':
                Message := NoCompaniesSelectedErr;
            '0':
                Message := SqlConnectionErr;
            '2':
                Message := SqlConnectionErr;
            '1225':
                Message := SqlConnectionErr;
            '18456':
                Message := LoginFailedForUserErr;
            '50008':
                Message := ExtensionRefreshFailureErr;
            '50009':
                Message := ExtensionRefreshUnexpectedFailureErr;
            '50010':
                Message := ReplicationAlreadyInProgressErr;
            '50011':
                Message := BuildMessageFromColumnMappingErrors(InnerMessage);
            '50016':
                Message := ReplicationNotEnabledErr;
            '50017':
                Message := UnsupportedVersionErr;
            '50020':
                Message := ChangeTrackingDisabledErr;
            '52100':
                Message := HandleWebhookError();
            '52110':
                Message := CopyTableTimeoutErr;
            '60001':
                Message := ADLConnectionErr;
            '60002':
                Message := ADLContainerExistsErr;
            else
                Message := InnerMessage;
        end;
    end;

    procedure SetHybridReplicationDetailStatus(ErrorCode: Text; var HybridReplicationDetail: Record "Hybrid Replication Detail")
    begin
        case ErrorCode of
            TableDoesnotExistErrorCodeTxt:
                HybridReplicationDetail.Status := HybridReplicationDetail.Status::Warning
            else
                HybridReplicationDetail.Status := HybridReplicationDetail.Status::Failed;
        end;
    end;

    // Builds a localized error message from the errors found attempting to map an on-premises 
    // table to a cloud table. The format of the errors are as follows:
    //
    // ERRORS := <ERROR> | <ERRORS> "|" <ERROR>
    // ERROR := <COLUMN_NAME> <ERROR_TYPES>
    // COLUMN_NAME := "[" <SQL_QUOTENAME_ESCAPED_IDENTIFIER> "]"
    // ERROR_TYPES := <ERROR_TYPE> "," | <ERROR_TYPES> <ERROR_TYPE> ","
    // ERROR_TYPE := "PK" | "T" | "L"
    // SQL_QUOTENAME_ESCAPED_IDENTIFIER := All characters except "]" is escaped with another "]"
    local procedure BuildMessageFromColumnMappingErrors(Errors: Text) Message: Text
    var
        ErrorText: Text;
    begin
        Message := '';

        while GetColumnErrors(Errors, ErrorText) do
            Message := Message + ErrorText + '\';
    end;

    local procedure GetColumnErrors(var Errors: Text; var ErrorText: Text) HasError: Boolean
    var
        ColumnName: Text;
        Reason: Text;
    begin
        HasError := ExtractMappingErrorColumnName(Errors, ColumnName);

        if HasError then begin
            Reason := ExtractMappingErrorReason(Errors);
            ErrorText := StrSubstNo(ColumnMappingErr, ColumnName, Reason);
        end;
    end;

    local procedure ExtractMappingErrorColumnName(var Errors: Text; var ColumnName: Text) Found: Boolean
    var
        Index: Integer;
        Length: Integer;
    begin
        Found := false;
        Index := 1;
        Length := StrLen(Errors);

        while not Found and (Index <= Length) do begin
            if Errors[Index] = ']' then
                if Index < Length then
                    if Errors[Index + 1] <> ']' then
                        Found := true
                    else
                        Index := Index + 1
                else
                    Found := true;
            Index := Index + 1;
        end;

        if Found then begin
            ColumnName := CopyStr(Errors, 1, Index - 1);
            Errors := DelStr(Errors, 1, Index - 1);
        end;
    end;

    local procedure ExtractMappingErrorReason(var Errors: Text) Reason: Text
    var
        Length: Integer;
        Pos: Integer;
    begin
        Reason := '';
        Length := StrLen(Errors);

        while Length > 0 do begin
            if Errors[1] = '|' then begin
                Errors := DelStr(Errors, 1, 1);
                break;
            end;

            Pos := StrPos(Errors, ',');

            if Pos = 0 then
                break;

            if Reason <> '' then
                Reason := Reason + ' ';

            case CopyStr(Errors, 1, Pos - 1) of
                'PK':
                    Reason := Reason + ColumnMappingPrimaryKeyErr;
                'T':
                    Reason := Reason + ColumnMappingTypeErr;
                'L':
                    Reason := Reason + ColumnMappingLengthErr;
            end;

            Errors := DelStr(Errors, 1, Pos);
            Length := StrLen(Errors);
        end;
    end;

    local procedure HandleWebhookError() Message: Text
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        ReplicationUser: Code[50];
    begin
        if IntelligentCloudSetup.Get() then
            ReplicationUser := IntelligentCloudSetup."Replication User";

        Message := StrSubstNo(WebhookFailureErr, ReplicationUser);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnGetErrorMessage', '', false, false)]
    local procedure ResolveMessageCodeOnGetErrorMessage(ErrorCode: Text; var Message: Text)
    begin
        Message := ResolveMessageCode(CopyStr(ErrorCode, 1, 10), '');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnResolveMessageCode(MessageCode: Code[10]; InnerMessage: Text; var Message: Text)
    begin
    end;
}