#pragma warning disable AA0247
page 10538 "MTD Web Client FP Headers"
{
    PageType = NavigatePage;
    Caption = 'Communicating with HMRC';

    layout
    {
        area(Content)
        {
            group(Main)
            {
                ShowCaption = false;
                Visible = FirstPageVisible;
                group(UserControl)
                {
                    ShowCaption = false;
                    InstructionalText = 'Please keep this window open.';
                    usercontrol(FPHeadersControl; "MTD Web Client FP Headers")
                    {
                        ApplicationArea = All;

                        trigger Ready()
                        begin
                            if Initialized then
                                exit;
                            Initialized := true;

                            if TestExternalService then
                                CurrPage.FPHeadersControl.TestExternalPublicIPService(PublicIPServiceURL)
                            else
                                CurrPage.FPHeadersControl.Run(PublicIPServiceURL);
                        end;

                        trigger Callback(headersJson: JsonObject)
                        var
                            MTDFraudPreventionMgt: Codeunit "MTD Fraud Prevention Mgt.";
                        begin
                            MTDFraudPreventionMgt.SetSessionFPHeadersFromJS(headersJson);
                            MTDFraudPreventionMgt.LogClientPublicIPInfo(headersJson);
                            CurrPage.Close();
                        end;
                    }
                }
            }
        }
    }

    var
        Initialized: Boolean;
        FirstPageVisible: Boolean;
        PublicIPServiceURL: Text;
        TestExternalService: Boolean;

    trigger OnOpenPage()
    begin
        FirstPageVisible := true;
    end;

    internal procedure SetPublicIPServiceURL(NewPublicIPServiceURL: Text; NewTestExternalService: Boolean)
    begin
        PublicIPServiceURL := NewPublicIPServiceURL;
        TestExternalService := NewTestExternalService;
    end;
}
