namespace Microsoft.EServices;

permissionset 13608 "Nemhandel Status Objects DK"
{
    Access = Public;
    Assignable = false;

    Permissions = codeunit "Http Client Nemhandel Status" = X,
                  codeunit "Http Response Msg Nemhandel" = X,
                  codeunit "Nemhandel Status Mgt." = X,
                  codeunit "Nemhandel Status Page Bckgrnd" = X,
                  codeunit "Upd. Registered with Nemhandel" = X;
}