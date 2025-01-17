namespace Microsoft.Bank.StatementImport.Yodlee;

using System.Utilities;
using System.Security.AccessControl;

codeunit 1267 "Password Helper"
{
#if not CLEAN24
    [NonDebuggable]
    [Obsolete('Use GenerateSecretPassword with SecretText return type.', '24.0')]
    procedure GeneratePassword(Length: Integer): Text;
    var
        Regex: Codeunit "Regex";
        PasswordHandler: Codeunit "Password Handler";
        Result: Text;
    begin
        Regex.Regex('[\[\]\{\}\(\)\+\-&%\.\^;,:\|=\\\/\?''"`\~><_]');
        Result := Regex.Replace(PasswordHandler.GenerateSecretPassword(Length).Unwrap(), '');
        while WeakYodleePassword(Result) do
            Result := Regex.Replace(PasswordHandler.GenerateSecretPassword(Length).Unwrap(), '');
        exit(Result);
    end;
#endif

    [NonDebuggable]
    procedure GenerateSecretPassword(Length: Integer): SecretText;
    var
        Regex: Codeunit "Regex";
        PasswordHandler: Codeunit "Password Handler";
        Result: Text;
    begin
        Regex.Regex('[\[\]\{\}\(\)\+\-&%\.\^;,:\|=\\\/\?''"`\~><_]');
        Result := Regex.Replace(PasswordHandler.GenerateSecretPassword(Length).Unwrap(), '');
        while WeakYodleePassword(Result) do
            Result := Regex.Replace(PasswordHandler.GenerateSecretPassword(Length).Unwrap(), '');
        exit(Result);
    end;

#if not CLEAN24
    [NonDebuggable]
    [Obsolete('Use WeakYodleePassword with SecretText data type for Password parameter.', '24.0')]
    procedure WeakYodleePassword(Password: Text): Boolean
    var
        Pass: SecretText;
    begin
        Pass := Password;
        exit(WeakYodleePassword(Pass));
    end;
#endif

    [NonDebuggable]
    procedure WeakYodleePassword(Pass: SecretText): Boolean
    var
        CurrentChar: Char;
        ReferenceChar: Char;
        i: Integer;
        CurrentSequenceLength: Integer;
        Length: Integer;
        Password: Text;
    begin
        Password := Pass.Unwrap();
        if Password = DelChr(Password, '=', '!@#$*') then
            exit(true);

        if Password = DelChr(Password, '=', 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890') then
            exit(true);

        Length := StrLen(Password);

        ReferenceChar := 0;
        for i := 1 to Length do begin
            CurrentChar := Password[i];
            if CurrentChar = ReferenceChar then
                CurrentSequenceLength += 1
            else begin
                ReferenceChar := CurrentChar;
                CurrentSequenceLength := 1
            end;

            if CurrentSequenceLength = 3 then
                exit(true);
        end;

        CurrentSequenceLength := 0;
        ReferenceChar := 0;

        for i := 1 to Length do begin
            CurrentChar := Password[i];
            if CurrentChar - ReferenceChar = 1 then
                CurrentSequenceLength += 1
            else
                CurrentSequenceLength := 1;

            ReferenceChar := CurrentChar;
            if CurrentSequenceLength = 3 then
                exit(true);
        end;

        CurrentSequenceLength := 0;
        ReferenceChar := 0;

        for i := 1 to Length do begin
            CurrentChar := Password[i];
            if ReferenceChar - CurrentChar = 1 then
                CurrentSequenceLength += 1
            else
                CurrentSequenceLength := 1;

            ReferenceChar := CurrentChar;
            if CurrentSequenceLength = 3 then
                exit(true);
        end;

        exit(false);
    end;
}

