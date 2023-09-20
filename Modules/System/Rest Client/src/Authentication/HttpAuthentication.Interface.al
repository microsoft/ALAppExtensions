/// <summary>An interface to support different authorization mechanism in a generic way.</summary>
interface "Http Authentication"
{
    /// <summary>Indicates whether authentication is required for the request.</summary>
    /// <returns>True if authentication is required, false otherwise.</returns>
    procedure IsAuthenticationRequired(): Boolean

    /// <summary>Gets the authorization headers for the request.</summary>
    /// <returns>A dictionary of authorization headers.</returns>
    procedure GetAuthorizationHeaders(): Dictionary of [Text, SecretText]
}