#pragma warning disable AA0247
table 14101 "CD Number Format"
{
    Caption = 'CD Number Format';

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(2; Format; Code[50])
        {
            Caption = 'Format';
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        InventorySetup: Record "Inventory Setup";
        InvtSetupRead: Boolean;
        InvalidFormatErr: Label 'Invalid format: %1.', Comment = '%1 - CD number';
        PossibleCharsTxt: Label 'ABCDEFGHIJKLMNOPQRSTUVWXYZÇüéâäà­åçêëèïîìÄÅÉæÆôöòûùÿÖÜø£Ø×ƒ';

    procedure Check(CDNo: Code[50]; ShowError: Boolean): Boolean
    var
        CDNumberFormat: Record "CD Number Format";
        Success: Boolean;
    begin
        GetInvtSetup();
        if not InventorySetup."Check CD Number Format" then
            exit;

        Success := false;
        CDNumberFormat.Reset();
        if CDNumberFormat.FindSet() then
            repeat
                Success := Compare(CDNo, CDNumberFormat.Format);
            until (CDNumberFormat.Next() = 0) or Success;

        if ShowError and (not Success) then
            Error(InvalidFormatErr, CDNo);

        exit(Success);
    end;

    local procedure Compare(CDNo: Code[50]; Format: Text[50]) Checked: Boolean
    var
        i: Integer;
        Cf: Text[1];
        Ce: Text[1];
    begin
        Checked := true;
        if StrLen(CDNo) = StrLen(Format) then
            for i := 1 to StrLen(CDNo) do begin
                Cf := CopyStr(Format, i, 1);
                Ce := CopyStr(CDNo, i, 1);
                case Cf of
                    '#':
                        if not ((Ce >= '0') and (Ce <= '9')) then
                            Checked := false;
                    '@':
                        if StrPos(PossibleCharsTxt, UpperCase(Ce)) = 0 then
                            Checked := false;
                    else
                        if not ((Cf = Ce) or (Cf = '?')) then
                            Checked := false
                end;
            end
        else
            Checked := false;
    end;

    local procedure GetInvtSetup()
    begin
        if not InvtSetupRead then begin
            InventorySetup.Get();
            InvtSetupRead := true;
        end;
    end;
}

