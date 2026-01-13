namespace Microsoft.Payroll.Ceridian;

using System.Security.Encryption;

page 1665 "MS - Ceridian Payroll Setup"
{
    PageType = Card;
    SourceTable = "MS Ceridian Payroll Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Service URL"; Rec."Service URL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'SFTP Server';
                    ToolTip = 'Specifies the URL address of the Ceridian Payroll.';
                }
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the user.';
                }
                field(Password; Password)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Password';
                    ToolTip = 'Specifies the password that is used for your company''s login to the Payroll service.';

                    trigger OnValidate();
                    begin
                        Rec.SavePassword(Rec."Password Key", Password);
                        if Password <> '' then
                            CheckEncryption();
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord();
    begin
        UpdateEncryptedField(Rec."Password Key", Password);
    end;

    trigger OnOpenPage();
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;

    var
        [NonDebuggable]
        Password: Text[50];
        EncryptionIsNotActivatedQst: Label 'Data encryption is not activated. It is recommended that you encrypt data. \Do you want to open the Data Encryption Management window?';

    local procedure CheckEncryption();
    begin
        if not ENCRYPTIONENABLED() then
            if not ENCRYPTIONENABLED() then
                if CONFIRM(EncryptionIsNotActivatedQst) then
                    PAGE.RUN(PAGE::"Data Encryption Management");
    end;

    local procedure UpdateEncryptedField(InputGUID: Guid; var Text: Text[50]);
    begin
        if ISNULLGUID(InputGUID) then
            Text := ''
        else
            Text := '*************';
    end;
}
