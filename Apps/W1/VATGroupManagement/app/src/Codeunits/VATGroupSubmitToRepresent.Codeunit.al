codeunit 4706 "VAT Group Submit To Represent."
{
    TableNo = "VAT Report Header";

    var
        VATGroupSubmissionsEndPointTxt: Label '/vatGroupSubmissions?$expand=vatGroupSubmissionLines', Locked = true;
        VATGroupSubmissionEndPoint2017Txt: Label '/vatGroupSubmissions?$format=json', Locked = true;
        NoVATReportSetupErr: Label 'The VAT report setup was not found. You can create one on the VAT Report Setup page.';
        SubmitMembersOnlyErr: Label 'You must be configured as a VAT Group member in order to submit VAT returns to the group representative.';

    trigger OnRun()
    var
        VATReportSetup: Record "VAT Report Setup";
        ErrorMessage: Record "Error Message";
        VATGroupSerialization: Codeunit "VAT Group Serialization";
        VATGroupCommunication: Codeunit "VAT Group Communication";
        HttpResponseBodyText: Text;
        ContentJsonText: Text;
        EndPoint: Text;
    begin
        if not VATReportSetup.Get() then
            Error(NoVATReportSetupErr);

        if not VATReportSetup.IsGroupMember() then
            Error(SubmitMembersOnlyErr);

        VATGroupSerialization.CreateVATSubmissionJson(Rec).WriteTo(ContentJsonText);

        ErrorMessage.SetContext(Rec);
        ErrorMessage.ClearLog();

        case VATReportSetup."VAT Group BC Version" of
            VATReportSetup."VAT Group BC Version"::NAV2017:
                EndPoint := VATGroupSubmissionEndPoint2017Txt;
            VATReportSetup."VAT Group BC Version"::NAV2018,
            VATReportSetup."VAT Group BC Version"::BC:
                EndPoint := VATGroupSubmissionsEndPointTxt;
        end;

        if not VATGroupCommunication.Send('POST', EndPoint, ContentJsonText, HttpResponseBodyText, false) then begin
            ErrorMessage.LogLastError();
            while HttpResponseBodyText <> '' do begin
                ErrorMessage.LogSimpleMessage(
                    ErrorMessage."Message Type"::Error, CopyStr(HttpResponseBodyText, 1, MaxStrLen(ErrorMessage.Description)));
                HttpResponseBodyText := CopyStr(HttpResponseBodyText, MaxStrLen(ErrorMessage.Description) + 1);
            end;
        end;

        if ErrorMessage.HasErrors(true) then
            exit;

        Rec.Validate(Status, Rec.Status::Submitted);
        Rec.Modify(true);
    end;
}