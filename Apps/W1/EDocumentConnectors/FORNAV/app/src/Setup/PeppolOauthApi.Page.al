namespace Microsoft.EServices.EDocumentConnector.ForNAV;

page 6411 "ForNAV Peppol Oauth API"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'peppol';
    APIVersion = 'v1.0';
    EntityName = 'peppolOauth';
    EntitySetName = 'peppolOauths';
    SourceTable = "ForNAV Peppol Setup";
    SourceTableTemporary = true;
    DelayedInsert = true;
    Caption = 'ForNavPeppolOauth', Locked = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(primaryKey; Rec.PK)
                {
                    ApplicationArea = All;
                }
                field(clientId; Rec."Client Id")
                {
                    ApplicationArea = All;
                }
                field(tenantId; tenantId)
                {
                    ApplicationArea = All;
                }
                field(clientSecret; clientSecret)
                {
                    ApplicationArea = All;
                }
                field(expires; SecretValidTo)
                {
                    ApplicationArea = All;
                }
                field(scope; scope)
                {
                    ApplicationArea = All;
                }
                field(endpoint; endpoint)
                {
                    ApplicationArea = All;
                }
                field(hash; hash)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var
        [NonDebuggable]
        clientSecret: Text;
        scope: Text;
        tenantId: Text;
        hash: Text;
        SecretValidTo: DateTime;
        endpoint: Text[20];

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Process();
    end;

    [NonDebuggable]
    local procedure Process()
    var
        Setup: Record "ForNAV Peppol Setup";
        PeppolCrypto: Codeunit "ForNAV Peppol Crypto";
        PeppolOauth: Codeunit "ForNAV Peppol Oauth";
    begin
        Setup.FindFirst();
        PeppolCrypto.TestHash(hash, Rec."Client Id", clientSecret);
        Setup.Validate("Client Id", Rec."Client Id");
        PeppolOauth.ValidateSecret(clientSecret);
        PeppolOauth.ValidateSecretValidTo(SecretValidTo);
        PeppolOauth.ValidateForNAVTenantID(tenantId);
        PeppolOauth.ValidateScope(scope);
        PeppolOauth.Validateendpoint(endpoint, false);
        Setup.Modify(true);
    end;
}