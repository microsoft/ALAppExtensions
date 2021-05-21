codeunit 31268 "Compensation - Post Yes/No CZC"
{
    EventSubscriberInstance = Manual;
    TableNo = "Compensation Header CZC";

    trigger OnRun()
    begin
        CompensationHeaderCZC.Copy(Rec);
        Code();
        Rec := CompensationHeaderCZC;
    end;

    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        PostQst: Label 'Do you want to post Compensation?';

    procedure Code()
    begin
        if not Confirm(PostQst, false) then
            Error('');

        Codeunit.Run(Codeunit::"Compensation - Post CZC", CompensationHeaderCZC);
        Commit();
    end;

    procedure Preview(CompensationHeader: Record "Compensation Header CZC")
    var
        CompensationPostYesNoCZC: Codeunit "Compensation - Post Yes/No CZC";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
    begin
        BindSubscription(CompensationPostYesNoCZC);
        GenJnlPostPreview.Preview(CompensationPostYesNoCZC, CompensationHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnRunPreview', '', false, false)]
    local procedure OnRunPreview(var Result: Boolean; Subscriber: Variant; RecVar: Variant)
    var
        PreviewCompensationHeaderCZC: Record "Compensation Header CZC";
        CompensationPostCZC: Codeunit "Compensation - Post CZC";
    begin
        PreviewCompensationHeaderCZC.Copy(RecVar);
        CompensationPostCZC.SetPreviewMode(true);
        Result := CompensationPostCZC.Run(PreviewCompensationHeaderCZC);
    end;
}
