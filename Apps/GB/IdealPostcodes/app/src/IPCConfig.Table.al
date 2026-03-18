namespace Microsoft.Foundation.Address.IdealPostcodes;

using System.Telemetry;

table 9402 "IPC Config"
{
    DataClassification = CustomerContent;
    Caption = 'IdealPostcodes Configuration';
    Access = Internal;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "API Key"; Guid)
        {
            Caption = 'API Key';
            DataClassification = CustomerContent;
        }
        field(4; "Enabled"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        EndpointBaseUrlTxt: Label 'https://api.ideal-postcodes.co.uk/v1', Locked = true;

    internal procedure GetAPIPasswordAsSecret(APIKeyGUID: Guid): SecretText
    var
        APIPassword: SecretText;
    begin
        if IsNullGuid(APIKeyGUID) or not IsolatedStorage.Get(APIKeyGUID, Datascope::Company, APIPassword) then
            exit(APIPassword);

        exit(APIPassword);
    end;

    internal procedure SaveAPIKeyAsSecret(var APIKeyGUID: Guid; APIKeyValue: SecretText)
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if not IsNullGuid(APIKeyGUID) and (APIKeyValue.IsEmpty()) then begin
            if IsolatedStorage.Contains(APIKeyGUID, Datascope::Company) then
                IsolatedStorage.Delete(APIKeyGUID, Datascope::Company);
            Clear(Rec."API Key");
        end else begin
            if IsNullGuid(Rec."API Key") or not IsolatedStorage.Contains(APIKeyGUID, Datascope::Company) then begin
                APIKeyGuid := Format(CreateGuid());
                Rec."API Key" := APIKeyGuid;
            end;
            if not EncryptionEnabled() then
                IsolatedStorage.Set(APIKeyGUID, APIKeyValue, Datascope::Company)
            else
                IsolatedStorage.SetEncrypted(APIKeyGUID, APIKeyValue, Datascope::Company);

            FeatureTelemetry.LogUptake('0000RFC', 'IdealPostcodes', Enum::"Feature Uptake Status"::"Set up");
            FeatureTelemetry.LogUptake('0000RFD', 'IdealPostcodes', Enum::"Feature Uptake Status"::Used);
        end;
        Modify();
    end;

    internal procedure APIEndpoint(): Text[250]
    begin
        exit(EndpointBaseUrlTxt);
    end;
}