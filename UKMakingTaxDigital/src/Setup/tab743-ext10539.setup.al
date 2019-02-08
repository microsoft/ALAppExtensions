tableextension 10539 "MTD Report Setup" extends "VAT Report Setup"
{
    fields
    {
        field(10530; "MTD OAuth Setup Option"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = Production,Sandbox;
        }
        field(10531; "MTD Gov Test Scenario"; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    procedure GetMTDOAuthSetupCode(): Code[20]
    var
        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
    begin
        case "MTD OAuth Setup Option" of
            "MTD OAuth Setup Option"::Production:
                exit(MTDOAuth20Mgt.GetOAuthPRODSetupCode());
            "MTD OAuth Setup Option"::Sandbox:
                exit(MTDOAuth20Mgt.GetOAuthSandboxSetupCode());
            else
                exit('');
        end;
    end;
}
