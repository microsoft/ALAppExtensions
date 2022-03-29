interface "Email Logging OAuth Client"
{
    Access = Internal;

    /// <summary>
    /// Initializes client id, client secret and redirect url with the default values
    /// </summary>
    procedure Initialize();

    /// <summary>
    /// Initializes client id, client secret and redirect url with the custom values
    /// </summary>
    procedure Initialize(ClientId: Text; ClientSecret: Text; RedirectUrl: Text);

    /// <summary>
    /// Retrieves the access token to connect to Outlook API.
    /// </summary>
    /// <param name="PromptInteraction">Prompt interaction type</param>
    /// <param name="AccessToken">Out parameter with the access token.</param>
    /// <error>Could not get access token.</error>
    procedure GetAccessToken(PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text);

    /// <summary>
    /// Retrieves the access token to connect to Outlook API.
    /// </summary>
    /// <param name="PromptInteraction">Prompt interaction type</param>
    /// <param name="AccessToken">Out parameter with the access token.</param>
    /// <returns>True, if the access token was acquired successfully, false otherwise.</returns>
    procedure TryGetAccessToken(PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text): Boolean;

    /// <summary>
    /// retrieves the access token for the current user to connect to Outlook API.
    /// </summary>
    /// <param name="AccessToken">Out parameter with the access token.</param>
    /// <error>Could not get access token.</error>
    procedure GetAccessToken(var AccessToken: Text);

    /// <summary>
    /// Retrieves the access Token for the current user to connect to Outlook API.
    /// </summary>
    /// <param name="AccessToken">Out parameter with the Access token of the account.</param>
    /// <returns>True, if the access token was acquired successfully, false otherwise.</returns>
    procedure TryGetAccessToken(var AccessToken: Text): Boolean;

    /// <summary>
    /// Returns the Type of the application that is used for authentication.
    /// </summary>
    /// <returns>The type of the application that is used for authentication.</returns>
    procedure GetApplicationType(): Enum "Email Logging App Type";

    /// <summary>
    /// Returns the last authorization error message.
    /// </summary>
    /// <returns>The last authorization error message, if any</returns>
    procedure GetLastErrorMessage(): Text;
}