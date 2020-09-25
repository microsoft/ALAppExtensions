page 1451 "MS - Yodlee Account Linking"
{
    Caption = ' ';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    PageType = Card;
    ShowFilter = false;
    LinksAllowed = false;

    layout
    {
        area(content)
        {
            group(BankAccountLink)
            {
                Caption = ' ';
                ShowCaption = false;
                InstructionalText = 'NOTE: You are accessing a third-party''s website and service. You should review the third-party''s terms and privacy policy before acquiring or using its website or service.';
            }
            usercontrol(WebPageViewer; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = Basic, Suite;

                trigger ControlAddInReady(callbackUrl: Text)
                begin
                    NavigateToFastlink();
                end;

                trigger DocumentReady()
                begin
                end;

                trigger Refresh(callbackUrl: Text)
                begin
                    NavigateToFastlink();
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

    var
        SearchKeyword: Text;

    local procedure NavigateToFastlink();
    var
        MSYodleeServiceMgt: Codeunit 1450;
        Data: Text;
        ErrorText: Text;
    begin
        IF NOT MSYodleeServiceMgt.GetFastlinkDataForLinking(SearchKeyword, Data, ErrorText) THEN BEGIN
            MESSAGE(ErrorText);
            CurrPage.CLOSE();
            EXIT;
        END;

        CurrPage.WebPageViewer.Navigate(MSYodleeServiceMgt.GetYodleeFastlinkUrl(), 'POST', Data);
    end;

    procedure SetSearchKeyword(NewSetSearchKeyword: Text);
    begin
        SearchKeyword := NewSetSearchKeyword;
    end;
}

