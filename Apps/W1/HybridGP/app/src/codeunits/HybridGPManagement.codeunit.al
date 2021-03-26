codeunit 4016 "Hybrid GP Management"
{
    var
        ItemLengthErr: Label 'There are items that need to be truncated which might cause duplicate key errors. Please check all items where the length of the ITEMNMBR field is greater than 20. Examples: %1', Comment = '%1 - List of Items';
        PostingSetupErr: Label 'These Posting Accounts are missing and will cause posting errors: %1', Comment = '%1 - List of Posting Accounts';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnReplicationRunCompleted', '', false, false)]
    local procedure UpdateStatusOnHybridReplicationCompleted(RunId: Text[50]; SubscriptionId: Text; NotificationText: Text)
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
        HybridMessageManagement: Codeunit "Hybrid Message Management";
        JsonManagement: Codeunit "JSON Management";
        JsonManagement2: Codeunit "JSON Management";
        ErrorCode: Text;
        ErrorMessage: Text;
        Errors: Text;
        IncrementalTable: Text;
        IncrementalTableCount: Integer;
        Value: Text;
        i: Integer;
        j: Integer;
    begin
        if not HybridCloudManagement.CanHandleNotification(SubscriptionId, HybridGPWizard.ProductId()) then
            exit;

        // Get table information, iterate through and create detail records for each
        for j := 1 to 2 do begin
            JsonManagement.InitializeObject(NotificationText);

            // Wrapping these in if/then pairs to ensure backward-compatibility
            if j = 1 then
                if (not JsonManagement.GetArrayPropertyValueAsStringByName('IncrementalTables', Value)) then EXIT;
            if j = 2 then
                if (not JsonManagement.GetArrayPropertyValueAsStringByName('GPHistoryTables', Value)) then EXIT;
            JsonManagement.InitializeCollection(Value);
            IncrementalTableCount := JsonManagement.GetCollectionCount();

            for i := 0 to IncrementalTableCount - 1 do begin
                JsonManagement.GetObjectFromCollectionByIndex(IncrementalTable, i);
                JsonManagement.InitializeObject(IncrementalTable);

                HybridReplicationDetail.Init();
                HybridReplicationDetail."Run ID" := RunId;
                JsonManagement.GetStringPropertyValueByName('TableName', Value);
                HybridReplicationDetail."Table Name" := CopyStr(Value, 1, 250);

                JsonManagement.GetStringPropertyValueByName('CompanyName', Value);
                HybridReplicationDetail."Company Name" := CopyStr(Value, 1, 250);

                HybridReplicationDetail.Status := HybridReplicationDetail.Status::Successful;
                if JsonManagement.GetStringPropertyValueByName('Errors', Errors) and Errors.StartsWith('[') then begin
                    JsonManagement2.InitializeCollection(Errors);
                    if JsonManagement2.GetCollectionCount() > 0 then begin
                        JsonManagement2.GetObjectFromCollectionByIndex(Value, 0);
                        JsonManagement2.InitializeObject(Value);
                        JsonManagement2.GetStringPropertyValueByName('Code', ErrorCode);
                        JsonManagement2.GetStringPropertyValueByName('Message', ErrorMessage);
                    end;
                end else begin
                    JsonManagement.GetStringPropertyValueByName('ErrorMessage', ErrorMessage);
                    JsonManagement.GetStringPropertyValueByName('ErrorCode', ErrorCode);
                end;

                if (ErrorMessage <> '') or (ErrorCode <> '') then begin
                    HybridReplicationDetail.Status := HybridReplicationDetail.Status::Failed;
                    ErrorMessage := HybridMessageManagement.ResolveMessageCode(CopyStr(ErrorCode, 1, 10), ErrorMessage);
                    HybridReplicationDetail."Error Message" := CopyStr(ErrorMessage, 1, 2048);
                    HybridReplicationDetail."Error Code" := CopyStr(ErrorCode, 1, 10);
                end;

                HybridReplicationDetail.Insert();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Message Management", 'OnResolveMessageCode', '', false, false)]
    local procedure GetGPMessageOnResolveMessageCode(MessageCode: Code[10]; InnerMessage: Text; var Message: Text)
    begin
        if Message <> '' then
            exit;

        case MessageCode of
            '50100':
                Message := StrSubstNo(ItemLengthErr, InnerMessage);
            '50110':
                Message := StrSubstNo(PostingSetupErr, InnerMessage);
        end;
    end;
}