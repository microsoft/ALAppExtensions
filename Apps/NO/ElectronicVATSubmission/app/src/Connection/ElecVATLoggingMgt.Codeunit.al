codeunit 10688 "Elec. VAT Logging Mgt."
{
    var
        InvokeReqMsg: Label 'invoke request: %1', Locked = true;
        ValidateVATReturnTxt: Label 'validate VAT return';
        NOVATReturnSubmissionTok: Label 'NOVATReturnSubmissionTelemetryCategoryTok', Locked = true;
        InvokeReqSuccessMsg: Label 'https request successfully executed', Locked = true;
        RefreshAccessTokenMsg: Label 'refreshing access token', Locked = true;

    procedure LogValidationRun()
    begin
        Session.LogMessage(
            '0000G8O', StrSubstNo(InvokeReqMsg, ValidateVATReturnTxt), Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, 'Category', NOVATReturnSubmissionTok);
    end;

    procedure LogInvokRequestSuccess()
    begin
        Session.LogMessage(
            '0000G8P', InvokeReqSuccessMsg, Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, 'Category', NOVATReturnSubmissionTok);
    end;

    procedure LogRefreshAccessToken()
    begin
        Session.LogMessage('0000G8Q', RefreshAccessTokenMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', NOVATReturnSubmissionTok);
    end;

}