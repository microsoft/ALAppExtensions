controladdin OAuthAddIn
{
    Scripts = 'src\oauth\js\OAuthIntegration.js';

    procedure StartAuthorization(url: Text);
    event AuthorizationCodeRetrieved(code: Text);
    event AuthorizationErrorOccurred(error: Text; desc: Text);
    event ControlAddInReady();
}
