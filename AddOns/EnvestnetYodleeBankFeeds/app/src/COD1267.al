Codeunit 1267 "Password Helper"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced with codeunit 1284 Password Handler';

    procedure GeneratePassword(Length: Integer): Text;
    var
        DotNet_Regex: Codeunit DotNet_Regex;
        PasswordHandler: Codeunit "Password Handler";
    begin
        DotNet_Regex.Regex('[\[\]\{\}\(\)\+\-&%\.\^;,:\|=\\\/\?''"`\~><_]');
        exit(DotNet_Regex.Replace(PasswordHandler.GeneratePassword(Length), '*'));
    end;
}

