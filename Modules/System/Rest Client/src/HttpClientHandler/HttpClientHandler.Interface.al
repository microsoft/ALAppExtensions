interface "Http Client Handler"
{
    procedure Send(HttpClient: HttpClient; HttpRequestMessage: Codeunit "Http Request Message"; var HttpResponseMessage: Codeunit "Http Response Message") Success: Boolean;
}