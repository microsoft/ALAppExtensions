namespace Microsoft.Bank.StatementImport.Yodlee;

using System.Utilities;
using System.Security.AccessControl;

codeunit 1267 "Password Helper"
{
    procedure GeneratePassword(Length: Integer): Text;
    var
        Regex: Codeunit "Regex";
        PasswordHandler: Codeunit "Password Handler";
        Result: Text;
    begin
        Regex.Regex('[\[\]\{\}\(\)\+\-&%\.\^;,:\|=\\\/\?''"`\~><_]');
        Result := Regex.Replace(PasswordHandler.GeneratePassword(Length), '');
        while WeakYodleePassword(Result) do
            Result := Regex.Replace(PasswordHandler.GeneratePassword(Length), '');
        exit(Result);
    end;

    procedure WeakYodleePassword(Password: Text): Boolean
    var
        CurrentChar: Char;
        ReferenceChar: Char;
        i: Integer;
        CurrentSequenceLength: Integer;
        Length: Integer;
    begin
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

