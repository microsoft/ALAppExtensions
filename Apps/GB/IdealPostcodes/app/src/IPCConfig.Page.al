namespace Microsoft.Foundation.Address.IdealPostcodes;

using System.Telemetry;

page 9400 "IPC Config"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "IPC Config";
    Caption = 'IdealPostcodes Provider Setup';
    InsertAllowed = false;
    DeleteAllowed = false;


    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Enabled"; Rec."Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the postcode provider is enabled or not.';

                    trigger OnValidate()
                    begin
                        ValidateApiKey();
                        if not TermsAndCondsRead then
                            Error(ThirdPartyNoticeErr);
                    end;
                }
                field("API Key"; APIKeyText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'API Key';
                    ToolTip = 'Specifies the API Key for IdealPostcodes';
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    var
                        APIKeySecretTxt: SecretText;
                    begin
                        APIKeySecretTxt := ConvertToSecretText(APIKeyText);
                        Rec.SaveAPIKeyAsSecret(Rec."API Key", APIKeySecretTxt);
                        UpdateAPIField();
                    end;
                }
                field(TermsAndConditions; TermsAndCondsLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies the terms and conditions for using the IdealPostcodes service';

                    trigger OnDrillDown()
                    begin
                        HyperLink(TermsAndCondsUrlTok);
                        TermsAndCondsRead := true;
                    end;
                }
                field(GetAPIKey; GetAPIKeyLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    begin
                        HyperLink(APIKeyUrlTok);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestConnection)
            {
                ApplicationArea = All;
                Caption = 'Test Connection';
                Image = TestReport;
                ToolTip = 'Test the connection to the postcode API';

                trigger OnAction()
                var
                    CustomPostcodeMgt: Codeunit "IPC Management";
                begin
                    CustomPostcodeMgt.TestConnection();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateAPIField();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::Cancel then
            exit(true);

        if not TermsAndCondsRead then
            if Rec.Enabled then
                Message(ThirdPartyNoticeMsg);

        exit(true);
    end;

    [NonDebuggable]
    local procedure ConvertToSecretText(InputText: Text): SecretText
    begin
        exit(SecretStrSubstNo(InputText))
    end;

    var
        [NonDebuggable]
        APIKeyText: Text;
        TermsAndCondsRead: Boolean;
        APIKeyUrlTok: Label 'https://ideal-postcodes.co.uk/pricing', Locked = true;
        GetAPIKeyLbl: Label 'Get API Key';
        EmptyAPIKeyErr: Label 'You must specify an API Key.';
        ThirdPartyNoticeMsg: Label 'You are accessing a third-party website and service. You should review the third-party''s terms and privacy policy.';
        ThirdPartyNoticeErr: Label 'You must review the third-party''s terms and privacy policy.';
        TermsAndCondsLbl: Label 'Terms and conditions';
        TermsAndCondsUrlTok: Label 'https://terms.ideal-postcodes.co.uk/', Locked = true;

    local procedure UpdateAPIField()
    begin
        if IsNullGuid(Rec."API Key") then
            APIKeyText := ''
        else
            APIKeyText := '****************';
    end;

    local procedure ValidateApiKey()
    begin
        if APIKeyText = '' then
            Error(EmptyAPIKeyErr);
    end;

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000RFB', 'IdealPostcodes', Enum::"Feature Uptake Status"::Discovered);
        Rec.Reset();
        if not Rec.Get() then begin
            TermsAndCondsRead := false;
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert();
        end else
            TermsAndCondsRead := Rec."Enabled";
    end;
}