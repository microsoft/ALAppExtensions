// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;
using System.Privacy;

page 10058 "Transmission IRIS"
{
    PageType = Card;
    InsertAllowed = false;
    Caption = 'IRIS Transmission';
    ApplicationArea = BasicUS;
    SourceTable = "Transmission IRIS";
    Permissions = tabledata "User Params IRIS" = M;

    layout
    {
        area(Content)
        {
            group(General)
            {
                ShowCaption = false;

                field(TestModeIndicator; TestModeText)
                {
                    ShowCaption = false;
                    Editable = false;
                    Visible = TestModeVisible;
                    StyleExpr = 'Unfavorable';

                    trigger OnDrillDown()
                    begin
                        Message(TestModeMsg);
                    end;
                }
                field("Period No."; Rec."Period No.")
                {
                }
                field(Status; Rec.Status)
                {
                    StyleExpr = StatusStyle;

                    trigger OnValidate()
                    begin
                        SetStatusStyle();
                        SetActionsVisibility();
                    end;
                }
                field("Receipt ID"; Rec."Receipt ID")
                {
                    Editable = false;
                }
                group(ErrorInfo)
                {
                    ShowCaption = false;
                    Visible = ErrorInfoVisible;

                    field("Error Information"; ErrorInfoCaption)
                    {
                        ShowCaption = false;
                        Editable = false;
                        StyleExpr = 'Attention';

                        trigger OnDrillDown()
                        begin
                            ProcessTransmission.ShowErrorInformation(Rec."Document ID", '', '');
                        end;
                    }
                }
            }
            part(IRS1099Documents; "Transmission IRIS Subform")
            {
                SubPageLink = "IRIS Transmission Document ID" = field("Document ID");
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateTransmission)
            {
                Caption = 'Update Transmission';
                Image = Recalculate;
                ToolTip = 'Recalculate the amounts of the related 1099 form documents and create new documents if necessary. Use this action if the amounts on the 1099 forms have been updated or new 1099 form documents have been created after the transmission was generated.';

                trigger OnAction()
                begin
                    ProcessTransmission.Update(Rec);
                end;
            }
            action(SendOriginal)
            {
                Caption = 'Send';
                Image = SendElectronicDocument;
                ToolTip = 'Send the transmission to the IRS.';
                Visible = SendOriginalActionVisible;

                trigger OnAction()
                var
                    UserParams: Record "User Params IRIS";
                    CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
                    ProcessDialog: Dialog;
                begin
                    if not ConfirmMgt.GetResponseOrDefault(SendTransmissionQst, false) then
                        exit;

                    UserParams.GetRecord();
                    if not UserParams."Privacy Consent Given" then begin
                        Commit();
                        if not CustomerConsentMgt.ConfirmCustomConsent(SendOrigTransmConsentTxt) then
                            exit;

                        UserParams."Privacy Consent Given" := true;
                        UserParams.Modify();
                    end;

                    ProcessDialog.Open(SendingTransmissionMsg);
                    ProcessTransmission.SendOriginal(Rec);
                    ProcessDialog.Close();
                end;
            }
            action(SendReplacement)
            {
                Caption = 'Send Replacement';
                Image = SendElectronicDocument;
                ToolTip = 'Send the replacement transmission to the IRS. Use this action when the previously sent transmission was rejected or partially accepted.';
                Visible = SendReplacementActionVisible;

                trigger OnAction()
                var
                    ProcessDialog: Dialog;
                begin
                    if not ConfirmMgt.GetResponseOrDefault(SendReplacementTransmissionQst, false) then
                        exit;

                    ProcessDialog.Open(SendingReplacementMsg);
                    ProcessTransmission.SendReplacement(Rec);
                    ProcessDialog.Close();
                end;
            }
            action(SendCorrection)
            {
                Caption = 'Send Correction';
                Image = SendElectronicDocument;
                ToolTip = 'Send the correction transmission to the IRS. Only lines marked with the "Needs Correction" flag will be sent. Use this action when the previously sent form had incorrect vendor name, TIN, or payment amounts.';
                Visible = SendCorrectionActionVisible;

                trigger OnAction()
                var
                    ProcessDialog: Dialog;
                begin
                    if not ConfirmMgt.GetResponseOrDefault(SendCorrectionTransmissionQst, false) then
                        exit;

                    ProcessDialog.Open(SendingCorrectionMsg);
                    ProcessTransmission.SendCorrection(Rec, false);
                    ProcessDialog.Close();
                end;
            }
            action(SendCorrectionToZero)
            {
                Caption = 'Send Zero Amounts Correction';
                Image = SendElectronicDocument;
                ToolTip = 'Send the correction transmission with zero amounts to the IRS. Only lines marked with the "Needs Correction" flag will be sent. Use this action when the previously sent form should not have been filed for the vendor.';
                Visible = SendCorrectionActionVisible;

                trigger OnAction()
                var
                    ProcessDialog: Dialog;
                begin
                    if not ConfirmMgt.GetResponseOrDefault(SendCorrectionTransmissionQst, false) then
                        exit;

                    ProcessDialog.Open(SendingCorrectionMsg);
                    ProcessTransmission.SendCorrection(Rec, true);
                    ProcessDialog.Close();
                end;
            }
            group(TwoStepCorrection)
            {
                Caption = 'Two-Step Correction';

                action(Step1CorrectionToZero)
                {
                    Caption = 'Step 1: Send Zero Amounts Correction';
                    Image = SendElectronicDocument;
                    ToolTip = 'Send the correction transmission with zero amounts to the IRS. *All* lines, except opened and abandoned, will be sent.';
                    Visible = SendCorrectionActionVisible;

                    trigger OnAction()
                    var
                        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
                        ProcessDialog: Dialog;
                    begin
                        if not ConfirmMgt.GetResponseOrDefault(SendCorrectionTransmissionQst, false) then
                            exit;

                        ProcessDialog.Open(SendingCorrectionMsg);

                        IRS1099FormDocHeader.SetRange("IRIS Transmission Document ID", Rec."Document ID");
                        IRS1099FormDocHeader.SetFilter(Status, ProcessTransmission.GetFormDocToSendStatusFilter());
                        IRS1099FormDocHeader.ModifyAll("IRIS Needs Correction", true);
                        ProcessTransmission.SendCorrection(Rec, true);
                        IRS1099FormDocHeader.ModifyAll("IRIS Needs Correction", false);

                        ProcessDialog.Close();

                        Message(FirstStepCompletedMsg);
                    end;
                }
                action(Step2SendCorrectedOriginal)
                {
                    Caption = 'Step 2: Send Corrected';
                    Image = SendElectronicDocument;
                    ToolTip = 'Send the transmission with the corrected form types to the IRS. *All* lines, except opened and abandoned, will be sent.';
                    Visible = SendCorrectionActionVisible;

                    trigger OnAction()
                    var
                        ProcessDialog: Dialog;
                    begin
                        if not ConfirmMgt.GetResponseOrDefault(SendTransmissionQst, false) then
                            exit;

                        ProcessDialog.Open(SendingTransmissionMsg);
                        ProcessTransmission.SendOriginal(Rec);
                        ProcessDialog.Close();
                    end;
                }
                action(TwoStepCorrectionHelp)
                {
                    Caption = 'Help';
                    Image = Help;
                    ToolTip = 'Learn more about the two-step correction process.';
                    Visible = SendCorrectionActionVisible;

                    trigger OnAction()
                    begin
                        Message(TwoStepCorrectionHelpMsg);
                    end;
                }
            }
            action(RequestTransmissionStatusByRID)
            {
                Caption = 'Request Status';
                Image = Status;
                ToolTip = 'Request the status of the transmission from the IRS using Receipt ID. Use this action if the transmission was sent and the status was not updated or when the status is Processing.';

                trigger OnAction()
                var
                    TransmissionLog: Record "Transmission Log IRIS";
                    TempErrorInfo: Record "Error Information IRIS" temporary;
                    ProcessDialog: Dialog;
                    TransmissionStatus: Text;
                    UniqueTransmissionId: Text[100];
                    SubmissionsStatus: Dictionary of [Text, Text];
                begin
                    if Rec."Receipt ID" = '' then
                        Error(ReceiptIDNotAssignedErr);

                    ProcessDialog.Open(RequestingStatusMsg);

                    if TransmissionLog.FindLastRecByReceiptID(Rec."Receipt ID") then
                        UniqueTransmissionId := TransmissionLog."Unique Transmission ID";

                    ProcessTransmission.RequestAcknowledgement(Rec."Receipt ID", UniqueTransmissionId, TransmissionStatus, SubmissionsStatus, TempErrorInfo);
                    ProcessTransmission.UpadateTransmissionStatus(Rec, TransmissionStatus, SubmissionsStatus);
                    ProcessTransmission.SetTransmissionErrors(Rec."Document ID", UniqueTransmissionId, SubmissionsStatus, TempErrorInfo);

                    Sleep(500);
                    ProcessDialog.Close();
                end;
            }
            action(RequestTransmissionStatusByUTID)
            {
                Caption = 'Request Status by UTID';
                Image = Status;
                ToolTip = 'Request the status of the transmission from the IRS using Unique Transmission Id. Use this action if the transmission was sent and the status was not updated or when the status is Processing.';
                Visible = false;    // hidden because status is requested by Receipt ID by default

                trigger OnAction()
                var
                    TransmissionLog: Record "Transmission Log IRIS";
                    TempErrorInfo: Record "Error Information IRIS" temporary;
                    ProcessDialog: Dialog;
                    TransmissionStatus: Text;
                    UniqueTransmissionId: Text[100];
                    SubmissionsStatus: Dictionary of [Text, Text];
                begin
                    ProcessDialog.Open(RequestingStatusMsg);

                    TransmissionLog.SetRange("Transmission Document ID", Rec."Document ID");
                    if not TransmissionLog.FindLast() then
                        Error(UTIDNotFoundErr);
                    UniqueTransmissionId := TransmissionLog."Unique Transmission ID";

                    ProcessTransmission.RequestAcknowledgement('', UniqueTransmissionId, TransmissionStatus, SubmissionsStatus, TempErrorInfo);
                    ProcessTransmission.UpadateTransmissionStatus(Rec, TransmissionStatus, SubmissionsStatus);
                    ProcessTransmission.SetTransmissionErrors(Rec."Document ID", UniqueTransmissionId, SubmissionsStatus, TempErrorInfo);

                    Sleep(500);
                    ProcessDialog.Close();
                end;
            }
            action(TransmissionHistory)
            {
                Caption = 'Transmission History';
                Image = Log;
                ToolTip = 'Show IRIS transmissions history.';
                RunObject = Page "Transmission Logs IRIS";
                RunPageLink = "Period No." = field("Period No.");
            }
            action(AssignReceiptIDManually)
            {
                Caption = 'Assign Receipt ID';
                Image = DocumentEdit;
                ToolTip = 'Assign the Receipt ID to the transmission manually. If the the Receipt ID was not received for some reason (e.g., the session times out or is terminated) or it is accidentally lost or deleted, request the Receipt ID from the IRIS help desk. You will be required to identify yourself and provide the unique transmission ID which can be found on Transmission History page.';

                trigger OnAction()
                var
                    TransmissionUpdate: Page "Transmission IRIS Update";
                begin
                    if not ConfirmMgt.GetResponseOrDefault(ConfirmAssignReceiptIDQst, false) then
                        exit;

                    if Rec."Receipt ID" <> '' then
                        if not ConfirmMgt.GetResponseOrDefault(OverwriteReceiptIDQst, false) then
                            exit;

                    TransmissionUpdate.LookupMode(true);
                    TransmissionUpdate.SetRec(Rec);
                    TransmissionUpdate.RunModal();
                end;
            }
            action(ClearTokens)
            {
                Caption = 'Clear OAuth Tokens';
                ToolTip = 'Remove all OAuth tokens from the user storage. Use this action if you receive the error 401 Unauthorized when trying to send the transmission.';
                Image = Delete;
                Visible = false;

                trigger OnAction()
                var
                    OAuthClient: Codeunit "OAuth Client IRIS";
                begin
                    OAuthClient.ClearTokens();
                    Message(TokensRemovedMsg);
                end;
            }
        }
        area(Promoted)
        {
            actionref(SendOriginal_Promoted; SendOriginal)
            {
            }
            actionref(SendReplacement_Promoted; SendReplacement)
            {
            }
            actionref(SendCorrection_Promoted; SendCorrection)
            {
            }
            actionref(SendCorrectionToZero_Promoted; SendCorrectionToZero)
            {
            }
            actionref(TransmissionLog_Promoted; TransmissionHistory)
            {
            }
            actionref(RequestTransmissionStatus_Promoted; RequestTransmissionStatusByRID)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetTestModeFields();
    end;

    trigger OnAfterGetRecord()
    begin
        SetErrorInfoField();
        SetStatusStyle();
        SetActionsVisibility();
    end;

    var
        ProcessTransmission: Codeunit "Process Transmission IRIS";
        ConfirmMgt: Codeunit "Confirm Management";
        StatusStyle: Text;
        ErrorInfoCaption: Text;
        TestModeText: Text;
        TestModeVisible: Boolean;
        ErrorInfoVisible: Boolean;
        SendOriginalActionVisible: Boolean;
        SendReplacementActionVisible: Boolean;
        SendCorrectionActionVisible: Boolean;
        SendTransmissionQst: Label 'Do you want to send the transmission to the IRS?';
        SendReplacementTransmissionQst: Label 'Do you want to send the replacement transmission to the IRS?';
        SendCorrectionTransmissionQst: Label 'Do you want to send the correction transmission to the IRS?';
        SendingTransmissionMsg: Label 'Sending transmission to the IRS...';
        SendingReplacementMsg: Label 'Sending replacement transmission to the IRS...';
        SendingCorrectionMsg: Label 'Sending correction transmission to the IRS...';
        RequestingStatusMsg: Label 'Requesting transmission status...';
        TokensRemovedMsg: Label 'The IRIS auth tokens were removed from the user storage.';
        TwoStepCorrectionHelpMsg: Label 'Use the two-step correction process if incorrect form type was previously filed, e.g., 1099-MISC instead of 1099-NEC. \\Step 1: Submit zero amounts correction. \Step 2.1: After the transmission is accepted, use the action Update Transmission to add the corrected 1099 form documents. \Step 2.2: Send the updated transmission to the IRS.';
        FirstStepCompletedMsg: Label 'The correction transmission with zero amounts was sent to the IRS. After the transmission is accepted, use the action Update Transmission to add the corrected 1099 form documents and then send the updated transmission to the IRS.';
        ConfirmAssignReceiptIDQst: Label 'Are you sure you want to assign the Receipt ID to the transmission manually?';
        OverwriteReceiptIDQst: Label 'The transmission already has a Receipt ID. Do you want to overwrite it?';
        SendOrigTransmConsentTxt: Label 'By choosing this action, you consent to use third party systems. These systems may have their own terms of use, license, pricing and privacy, and they may not meet the same compliance and security standards as Microsoft Dynamics 365 Business Central. Your privacy is important to us.';
        ReceiptIDNotAssignedErr: Label 'The Receipt ID is not assigned to the transmission.\\ If the the Receipt ID was not received for some reason (e.g., the session times out or is terminated) or it is accidentally lost or deleted, request the Receipt ID from the IRIS help desk. You will be required to identify yourself and provide the unique transmission ID which can be found on Transmission History page.\\ After you receive the Receipt ID, use the Assign Receipt ID action to associate it with the transmission and then request the status of the transmission.';
        UTIDNotFoundErr: Label 'Unable to get Unique Transmission Id from the transmission history, because it does not have any records for the current transmission.';
        TestModeMsg: Label 'This transmission is in test mode. No data will be reported to the IRS. All data will be transmitted to the IRIS Assurance Testing System (IRIS ATS) for testing purposes.';
        ErrorInfoCaptionTxt: Label 'Show %1 error(s)', Comment = '%1 - number of errors';

    local procedure SetTestModeFields()
    var
        KeyVaultClient: Codeunit "Key Vault Client IRIS";
    begin
        TestModeText := 'Test Mode';
        TestModeVisible := KeyVaultClient.TestMode();
    end;

    local procedure SetActionsVisibility()
    begin
        SendOriginalActionVisible := ProcessTransmission.IsSendOriginalAllowed(Rec);
        SendReplacementActionVisible := ProcessTransmission.IsSendReplacementAllowed(Rec);
        SendCorrectionActionVisible := ProcessTransmission.IsSendCorrectionAllowed(Rec);
    end;

    local procedure SetErrorInfoField()
    var
        ErrorInformation: Record "Error Information IRIS";
        ErrorsCount: Integer;
    begin
        ErrorInformation.SetRange("Transmission Document ID", Rec."Document ID");
        ErrorsCount := ErrorInformation.Count();
        ErrorInfoVisible := ErrorsCount > 0;
        ErrorInfoCaption := StrSubstNo(ErrorInfoCaptionTxt, ErrorsCount);
    end;

    local procedure SetStatusStyle()
    begin
        StatusStyle := '';
        case Rec.Status of
            Enum::"Transmission Status IRIS"::Accepted:
                StatusStyle := 'Favorable';
            Enum::"Transmission Status IRIS"::Rejected,
            Enum::"Transmission Status IRIS"::"Not Found":
                StatusStyle := 'Unfavorable';
            Enum::"Transmission Status IRIS"::"Partially Accepted",
            Enum::"Transmission Status IRIS"::"Accepted with Errors":
                StatusStyle := 'Attention';
        end;
    end;
}