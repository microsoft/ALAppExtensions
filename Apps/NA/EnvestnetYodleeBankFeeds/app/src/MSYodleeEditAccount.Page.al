namespace Microsoft.Bank.StatementImport.Yodlee;

page 1460 "MS - Yodlee Edit Account"
{
    Caption = ' ';
    SourceTable = "MS - Yodlee Bank Acc. Link";

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
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
        Data: Text;
        ErrorText: Text;
    begin
        if not MSYodleeServiceMgt.GetFastlinkDataForEditAccount("Online Bank ID", CallbackUrl, Data, ErrorText) then begin
            MESSAGE(ErrorText);
            CurrPage.CLOSE();
            exit;
        end;

        CurrPage.WebPageViewer.Navigate(MSYodleeServiceMgt.GetYodleeFastlinkUrl(), 'POST', Data);
    end;
}

