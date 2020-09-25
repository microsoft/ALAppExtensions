Codeunit 1267 "Password Helper"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced with codeunit 1284 Password Handler';
    ObsoleteTag = '16.0';

    procedure GeneratePassword(Length: Integer): Text;
    var
        DotNet_Regex: Codeunit DotNet_Regex;
        PasswordHandler: Codeunit "Password Handler";
        Result: Text;
    begin
        DotNet_Regex.Regex('[\[\]\{\}\(\)\+\-&%\.\^;,:\|=\\\/\?''"`\~><_]');
        Result := DotNet_Regex.Replace(PasswordHandler.GeneratePassword(Length), '');
        while Result = DelChr(Result, '=', '!@#$*') do
            Result := DotNet_Regex.Replace(PasswordHandler.GeneratePassword(Length), '');
        exit(Result);
    end;
}

