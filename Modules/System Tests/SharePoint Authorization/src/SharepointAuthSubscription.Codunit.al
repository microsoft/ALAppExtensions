codeunit 132976 "SharePoint Auth. Subscriptions"
{
    EventSubscriberInstance = Manual;

    var
        Any: Codeunit Any;
        ShouldFail: Boolean;
        ExpectedError: Text;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SharePoint Authorization Code", 'OnBeforeGetToken', '', false, false)]
    local procedure OnBeforeGetToken(var IsHandled: Boolean; var IsSuccess: Boolean; var ErrorText: Text; var AccessToken: Text)
    begin
        IsHandled := true;
        IsSuccess := not ShouldFail;
        if IsSuccess then
            AccessToken := Any.AlphanumericText(250)
        else
            ErrorText := ExpectedError;
    end;

    procedure SetParameters(NewShouldFail: Boolean; NewExpectedError: Text)
    begin
        ShouldFail := NewShouldFail;
        ExpectedError := NewExpectedError;
    end;
}