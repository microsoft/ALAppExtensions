page 1458 "MS - Yodlee Access Consent"
{
    Caption = ' ';
    SourceTable = 1451;

    layout
    {
        area(content)
        {
            group(BankAccountAccessConsent)
            {
                Caption = ' ';
                ShowCaption = false;
                InstructionalText = 'NOTE: You are accessing a third-party website and service. You should review the third-parties terms and privacy policy before acquiring or using its website or service.';
            }
            usercontrol(WebPageViewer; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = Basic, Suite;

                trigger ControlAddInReady(callbackUrl: Text)
                begin
                    NavigateToFastlink(callbackUrl);
                end;

                trigger DocumentReady()
                begin
                end;

                trigger Refresh(callbackUrl: Text)
                begin
                    NavigateToFastlink(callbackUrl);
                end;

                trigger Callback(data: Text)
                begin
                    CurrPage.CLOSE();
                end;
            }
        }
    }

    actions
    {
    }

    local procedure NavigateToFastlink(CallbackUrl: Text);
    var
        MSYodleeServiceMgt: Codeunit 1450;
        Data: Text;
        ErrorText: Text;
    begin
        IF NOT MSYodleeServiceMgt.GetFastlinkDataForAccessConsent("Online Bank ID", CallbackUrl, Data, ErrorText) THEN BEGIN
            MESSAGE(ErrorText);
            CurrPage.CLOSE();
            EXIT;
        END;

        CurrPage.WebPageViewer.Navigate(MSYodleeServiceMgt.GetYodleeFastlinkUrl(), 'POST', Data);
    end;
}

