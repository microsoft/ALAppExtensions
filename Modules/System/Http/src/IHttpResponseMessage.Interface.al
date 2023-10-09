interface IHttpResponseMessage
{
    procedure IsBlockedByEnvironment(): Boolean;
    procedure IsSuccessStatusCode(): Boolean;
    procedure HttpStatusCode(): Integer;
    procedure ReasonPhrase(): Text;
    procedure Content(): HttpContent;
    procedure Headers(): HttpHeaders;
}