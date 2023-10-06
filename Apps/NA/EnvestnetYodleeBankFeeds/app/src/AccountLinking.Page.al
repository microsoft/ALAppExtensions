namespace Microsoft.Bank.StatementImport.Yodlee;

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
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
        Data: Text;
        ErrorText: Text;
    begin
        if not MSYodleeServiceMgt.GetFastlinkDataForLinking(SearchKeyword, Data, ErrorText) then begin
            MESSAGE(ErrorText);
            CurrPage.CLOSE();
            exit;
        end;

        CurrPage.WebPageViewer.Navigate(MSYodleeServiceMgt.GetYodleeFastlinkUrl(), 'POST', Data);
    end;

    procedure SetSearchKeyword(NewSetSearchKeyword: Text);
    begin
        SearchKeyword := NewSetSearchKeyword;
    end;
}

