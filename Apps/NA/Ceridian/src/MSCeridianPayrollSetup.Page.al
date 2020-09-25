page 1665 "MS - Ceridian Payroll Setup"
{
    PageType = Card;
    SourceTable = 1665;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Service URL"; "Service URL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'SFTP Server';
                    ToolTip = 'Specifies the URL address of the Ceridian Payroll.';
                }
                field("User Name"; "User Name")
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
                        SavePassword("Password Key", Password);
                        IF Password <> '' THEN
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
        UpdateEncryptedField("Password Key", Password);
    end;

    trigger OnOpenPage();
    begin
        RESET();
        IF NOT GET() THEN BEGIN
            INIT();
            INSERT(TRUE);
        END;
    end;

    var
        Password: Text[50];
        EncryptionIsNotActivatedQst: Label 'Data encryption is not activated. It is recommended that you encrypt data. \Do you want to open the Data Encryption Management window?';

    local procedure CheckEncryption();
    begin
        IF NOT ENCRYPTIONENABLED() THEN
            IF NOT ENCRYPTIONENABLED() THEN
                IF CONFIRM(EncryptionIsNotActivatedQst) THEN
                    PAGE.RUN(PAGE::"Data Encryption Management");
    end;

    local procedure UpdateEncryptedField(InputGUID: Guid; var Text: Text[50]);
    begin
        IF ISNULLGUID(InputGUID) THEN
            Text := ''
        ELSE
            Text := '*************';
    end;
}

