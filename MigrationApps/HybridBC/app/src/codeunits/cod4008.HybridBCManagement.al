codeunit 4008 "Hybrid BC Management"
{
    var
        SqlCompatibilityErr: Label 'SQL database must be at comptibility level 130 or higher.';
        DatabaseTooLargeErr: Label '"The maximum allowed amount of data for migration has been exceeded. For more information on how to proceed, see https://go.microsoft.com/fwlink/?linkid=2013440.';
        TableNotExistsErr: Label 'The table does not exist in the local instance.';
        SchemaMismatchErr: Label 'The local table schema differs from the Business Central cloud table.';
        FailurePreparingDataErr: Label 'Failed to prepare data for the table.\\\\%1', Comment = '%1 - The inner error message.';
        FailureCopyingTableErr: Label 'Failed to copy the table.\\\\%1', Comment = '%1 - The inner error message.';
        UnsupportedVersionErr: Label 'Business Central on-premises must be on the same major version as the online instance. Check if the version was set correctly on the database. For more information, see the documentation - https://go.microsoft.com/fwlink/?linkid=2148701.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Message Management", 'OnResolveMessageCode', '', false, false)]
    local procedure GetBCMessageOnResolveMessageCode(MessageCode: Code[10]; InnerMessage: Text; var Message: Text)
    var
        InteligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridBCWizard: Codeunit "Hybrid BC Wizard";
    begin
        if Message <> '' then
            exit;

        if not InteligentCloudSetup.Get() then
            exit;

        if not (InteligentCloudSetup."Product ID" = HybridBCWizard.ProductId()) then
            exit;

        case MessageCode of
            '50001':
                Message := SqlCompatibilityErr;
            '50002':
                Message := DatabaseTooLargeErr;
            '50004':
                Message := TableNotExistsErr;
            '50005':
                Message := SchemaMismatchErr;
            '50006':
                Message := StrSubstNo(FailurePreparingDataErr, InnerMessage);
            '50007':
                Message := StrSubstNo(FailureCopyingTableErr, InnerMessage);
            '50018':
                Message := UnsupportedVersionErr;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnReplicationRunCompleted', '', false, false)]
    local procedure UpdateStatusOnHybridReplicationCompleted(RunId: Text[50]; SubscriptionId: Text; NotificationText: Text)
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        HybridBCWizard: Codeunit "Hybrid BC Wizard";
        HybridMessageManagement: Codeunit "Hybrid Message Management";
        Message: Text;
    begin
        if not HybridCloudManagement.CanHandleNotification(SubscriptionId, HybridBCWizard.ProductId()) then
            exit;

        HybridReplicationSummary.Get(RunId);

        // As of 16.0, Hybrid Replication Detail records are inserted via the pipeline
        // Need to update Hybrid Replication Detail records with translated error messages
        HybridReplicationDetail.SetRange("Run ID", RunId);
        HybridReplicationDetail.SetRange(Status, HybridReplicationDetail.Status::Failed);
        HybridReplicationDetail.SetFilter("Error Code", '<>%1', '');
        if HybridReplicationDetail.FindSet() then
            repeat
                Message := HybridMessageManagement.ResolveMessageCode(CopyStr(HybridReplicationDetail."Error Code", 1, 10), HybridReplicationDetail."Error Message");
                HybridMessageManagement.SetHybridReplicationDetailStatus(HybridReplicationDetail."Error Code", HybridReplicationDetail);
                HybridReplicationDetail."Error Message" := CopyStr(Message, 1, 2048);

                if HybridReplicationDetail."Start Time" = 0DT then
                    HybridReplicationDetail."Start Time" := HybridReplicationSummary."Start Time";

                if HybridReplicationDetail."End Time" = 0DT then
                    HybridReplicationDetail."End Time" := HybridReplicationSummary."End Time";

                HybridReplicationDetail.Modify();
            until HybridReplicationDetail.Next() = 0;
    end;
}